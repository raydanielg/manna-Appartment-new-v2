import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/maintenance_provider.dart';

class MaintenanceDetailScreen extends ConsumerStatefulWidget {
  const MaintenanceDetailScreen({super.key});

  @override
  ConsumerState<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends ConsumerState<MaintenanceDetailScreen> {
  final _notesController = TextEditingController();
  String? _selectedStatus;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'open', 'label': 'Open', 'color': Colors.orange, 'icon': Icons.circle},
    {'value': 'in_progress', 'label': 'In Progress', 'color': AppColors.info, 'icon': Icons.play_arrow},
    {'value': 'resolved', 'label': 'Resolved', 'color': AppColors.success, 'icon': Icons.check_circle},
    {'value': 'cancelled', 'label': 'Cancelled', 'color': Colors.grey, 'icon': Icons.cancel},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String id, String status) async {
    if (_selectedStatus == null) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(maintenanceRepositoryProvider);
      await repo.updateStatus(id, status, notes: _notesController.text.trim());
      ref.invalidate(maintenanceDetailProvider(id));
      ref.invalidate(maintenanceRequestsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${status.replaceAll('_', ' ')}'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final requestAsync = ref.watch(maintenanceDetailProvider(id));
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final initialStatus = extra?['initialStatus']?.toString();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Request Details', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: requestAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(maintenanceDetailProvider(id))),
        data: (req) {
          final status = req['status'] ?? 'open';
          if (_selectedStatus == null) {
            _selectedStatus = initialStatus ?? status;
          }
          final createdAt = req['created_at'] != null ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.tryParse(req['created_at'].toString()) ?? DateTime.now()) : '-';
          final tenant = req['tenant'];
          final unit = req['unit'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              req['title'] ?? 'Request',
                              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
                            ),
                          ),
                          StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.person, 'Tenant', tenant?['full_name'] ?? tenant?['user']?['full_name'] ?? 'Unknown'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.meeting_room, 'Unit', unit?['name'] ?? unit?['unit_number'] ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.access_time, 'Submitted', createdAt),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                      const SizedBox(height: 8),
                      Text(
                        req['description'] ?? 'No description provided.',
                        style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight),
                      ),
                      if (req['landlord_notes'] != null) ...[
                        const SizedBox(height: 16),
                        Text('Landlord Notes', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                        const SizedBox(height: 8),
                        Text(req['landlord_notes'], style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Update Status', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _statusOptions.map((opt) {
                    final isSelected = _selectedStatus == opt['value'];
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(opt['icon'] as IconData, size: 16, color: isSelected ? Colors.white : opt['color'] as Color),
                          const SizedBox(width: 6),
                          Text(opt['label'] as String, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textLight))),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: opt['color'] as Color,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      onSelected: (_) => setState(() => _selectedStatus = opt['value'] as String),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Response / Notes',
                  controller: _notesController,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Update Status',
                  isLoading: _isLoading,
                  onPressed: () => _updateStatus(id, _selectedStatus!),
                ),
                const SizedBox(height: 12),
                if (req['resolved_at'] != null)
                  Center(
                    child: Text(
                      'Resolved on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.tryParse(req['resolved_at'].toString()) ?? DateTime.now())}',
                      style: GoogleFonts.nunito(fontSize: 12, color: AppColors.success),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textLight)),
        Expanded(child: Text(value, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark))),
      ],
    );
  }
}
