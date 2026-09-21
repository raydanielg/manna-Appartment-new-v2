import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
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

  String _dayLabel(String? date) {
    if (date == null) return '';
    final dt = DateTime.tryParse(date);
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return context.tr('today');
    if (diff == 1) return context.tr('yesterday');
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String _timeLabel(String? date) {
    final dt = date == null ? null : DateTime.tryParse(date);
    return dt == null ? '' : DateFormat('HH:mm').format(dt);
  }

  List<List<dynamic>> _iconFor(String type) {
    return switch (type.toLowerCase()) {
      'payment' => HugeIcons.strokeRoundedMoney01,
      'maintenance' => HugeIcons.strokeRoundedWrench01,
      'lease' || 'contract' => HugeIcons.strokeRoundedFile01,
      'expiry' || 'expiring' => HugeIcons.strokeRoundedCalendar01,
      'debt' || 'debts' => HugeIcons.strokeRoundedAlert02,
      _ => HugeIcons.strokeRoundedNotification02,
    };
  }

  Color _colorFor(String type, FColors colors) {
    return switch (type.toLowerCase()) {
      'payment' => const Color(0xFF16A34A),
      'maintenance' => colors.primary,
      'lease' || 'contract' => const Color(0xFF0EA5E9),
      'expiry' || 'expiring' => const Color(0xFFD97706),
      'debt' || 'debts' => colors.error,
      _ => colors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('notifications'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => context.pop(),
          child: context.theme.icons.arrowLeft(context),
        ),
        actions: [
          FButton(
            variant: .ghost,
            size: .sm,
            mainAxisSize: MainAxisSize.min,
            onPress: _items.isEmpty ? null : _markAllAsRead,
            child: Text(context.tr('mark_all_read')),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _items.isEmpty && !_isLoadingMore
          ? EmptyState(message: context.tr('no_notifications'))
          : RefreshIndicator(
              onRefresh: _refresh,
              color: colors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                  final createdAt = item['created_at'] as String?;
                  final label = _dayLabel(createdAt);
                  final prevLabel = index > 0
                      ? _dayLabel(_items[index - 1]['created_at'] as String?)
                      : '';
                  final isLast = index == _items.length - 1;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0 || label != prevLabel)
                        _TimelineHeader(
                          label: label,
                          colors: colors,
                          typography: typography,
                        ),
                      _TimelineItem(
                        item: item,
                        timeLabel: _timeLabel(createdAt),
                        icon: _iconFor(item['type']?.toString() ?? ''),
                        color:
                            _colorFor(item['type']?.toString() ?? '', colors),
                        isLast: isLast,
                        onRead: () =>
                            _markAsRead(item['id'] as String? ?? ''),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  final String label;
  final FColors colors;
  final FTypography typography;

  const _TimelineHeader({
    required this.label,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label.toUpperCase(),
            style: typography.body.xs3.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final String timeLabel;
  final List<List<dynamic>> icon;
  final Color color;
  final bool isLast;
  final VoidCallback onRead;

  const _TimelineItem({
    required this.item,
    required this.timeLabel,
    required this.icon,
    required this.color,
    required this.isLast,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final read = item['read_at'] != null;
    final title = item['title'] as String? ?? 'Notification';
    final body = item['body'] as String? ?? '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail — dot + connecting line
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: read ? Colors.transparent : color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: read
                          ? colors.mutedForeground.withValues(alpha: 0.5)
                          : color,
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: isLast
                      ? const SizedBox()
                      : Container(
                          width: 1.5,
                          margin: const EdgeInsets.only(top: 2),
                          color: colors.border.withValues(alpha: 0.6),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content — plain row, no card
          Expanded(
            child: FTappable(
              onPress: read ? null : onRead,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        HugeIcon(
                          icon: icon,
                          size: 14,
                          color: read ? colors.mutedForeground : color,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.xs2.copyWith(
                              fontWeight:
                                  read ? FontWeight.w500 : FontWeight.w700,
                              color: read
                                  ? colors.mutedForeground
                                  : colors.foreground,
                            ),
                          ),
                        ),
                        if (timeLabel.isNotEmpty)
                          Text(
                            timeLabel,
                            style: typography.body.xs3
                                .copyWith(color: colors.mutedForeground),
                          ),
                      ],
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.xs3.copyWith(
                          color: colors.mutedForeground,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (!read)
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: onRead,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                size: 16,
                color: colors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
