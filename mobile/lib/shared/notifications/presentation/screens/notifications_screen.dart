import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/notifications_repository.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _page = 1;
  final List<Map<String, dynamic>> _items = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final data = await repo.getNotifications(page: _page);
      final List<dynamic> newItems = data['data'] ?? [];
      setState(() {
        _items.addAll(newItems.cast<Map<String, dynamic>>());
        _hasMore = (data['current_page'] ?? 1) < (data['last_page'] ?? 1);
        if (_hasMore) _page++;
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _items.clear();
      _hasMore = true;
    });
    await _loadMore();
  }

  Future<void> _markAsRead(String id) async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      await repo.markAsRead(id);
      ref.invalidate(unreadCountProvider);
      _refresh();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      await repo.markAllAsRead();
      ref.invalidate(unreadCountProvider);
      _refresh();
    } catch (e) {
      // ignore
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    final dt = DateTime.tryParse(date);
    if (dt == null) return '';
    return DateFormat('MMM d, y HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _markAllAsRead,
            child: const Text('Mark all read', style: TextStyle(fontSize: 12, color: AppColors.gold)),
          ),
        ],
      ),
      body: _items.isEmpty && !_isLoadingMore
          ? const EmptyState(message: 'No notifications yet')
          : RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    _loadMore();
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingIndicator(),
                    );
                  }

                  final item = _items[index];
                  final id = item['id'] as String? ?? '';
                  final title = item['title'] as String? ?? 'Notification';
                  final body = item['body'] as String? ?? '';
                  final read = item['read_at'] != null;
                  final createdAt = item['created_at'] as String?;

                  return Dismissible(
                    key: ValueKey(id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: AppColors.primary,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    onDismissed: (_) => _markAsRead(id),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: read ? null : AppColors.primary.withValues(alpha: 0.05),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: read ? (isDark ? AppColors.darkInput : Colors.grey.shade200) : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            read ? Icons.notifications_none : Icons.notifications_active,
                            color: read ? AppColors.textLight : Colors.white,
                          ),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(body, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight)),
                            const SizedBox(height: 6),
                            Text(_formatDate(createdAt), style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.textLight)),
                          ],
                        ),
                        trailing: read
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                                onPressed: () => _markAsRead(id),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
