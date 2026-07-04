import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/maintenance_provider.dart';

class MaintenanceRequestsScreen extends ConsumerStatefulWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  ConsumerState<MaintenanceRequestsScreen> createState() => _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState extends ConsumerState<MaintenanceRequestsScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requestsAsync = ref.watch(maintenanceRequestsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Maintenance', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search requests...',
                hintStyle: GoogleFonts.nunito(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Open', 'open'),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', 'in_progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Resolved', 'resolved'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(maintenanceRequestsProvider),
              color: AppColors.primary,
              child: requestsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(maintenanceRequestsProvider)),
                data: (requests) {
                  final filtered = requests.where((req) {
                    final title = (req['title'] ?? '').toString().toLowerCase();
                    final tenant = (req['tenant']?['full_name'] ?? '').toString().toLowerCase();
                    final matchesSearch = title.contains(_searchQuery) || tenant.contains(_searchQuery);
                    final status = (req['status'] ?? 'open').toString();
                    final matchesStatus = _filterStatus == 'all' || status == _filterStatus;
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const EmptyState(message: 'No maintenance requests.', icon: Icons.build_outlined);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _RequestCard(req: filtered[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textLight))),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> req;
  const _RequestCard({required this.req});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = req['status'] ?? 'open';
    final createdAt = req['created_at'] != null ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(req['created_at'].toString()) ?? DateTime.now()) : '-';
    final Color statusColor = {
      'open': Colors.orange,
      'in_progress': AppColors.info,
      'resolved': AppColors.success,
      'cancelled': Colors.grey,
    }[status] ?? Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/maintenance/${req['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.build, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(req['title'] ?? 'Request', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(req['tenant']?['full_name'] ?? 'Unknown', style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                      ],
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              if (req['description'] != null && req['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(req['description'], style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(createdAt, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                  Text('Unit: ${req['unit']?['name'] ?? req['unit']?['unit_number'] ?? 'N/A'}', style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(context, 'Start', Icons.play_arrow, status == 'open' ? AppColors.info : Colors.grey, () => _updateStatus(context, 'in_progress')),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(context, 'Resolve', Icons.check_circle, status == 'resolved' ? Colors.grey : AppColors.success, () => _updateStatus(context, 'resolved')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, String status) {
    context.push('/landlord/maintenance/${req['id']}', extra: {'initialStatus': status});
  }
}
