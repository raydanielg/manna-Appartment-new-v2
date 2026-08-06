import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/tenants_provider.dart';
import '../widgets/tenant_card.dart';

class TenantsListScreen extends ConsumerStatefulWidget {
  const TenantsListScreen({super.key});

  @override
  ConsumerState<TenantsListScreen> createState() => _TenantsListScreenState();
}

class _TenantsListScreenState extends ConsumerState<TenantsListScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, moved_out

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantsListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          context.tr('tenants'),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: const Color(0xFF111827), fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: context.tr('search_name_phone'),
                hintStyle: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 20),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context.tr('all_tenants'), 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('active'), 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('moved_out'), 'moved_out'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(tenantsListProvider),
              color: const Color(0xFF2563EB),
              child: tenantsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
                error: (e, _) {
                  final message = e.toString();
                  final isSetupError = message.toLowerCase().contains('kyc') ||
                      message.toLowerCase().contains('subscription') ||
                      message.toLowerCase().contains('organization');
                  return ErrorState(
                    message: message,
                    onRetry: () => ref.invalidate(tenantsListProvider),
                    onAction: isSetupError ? () => context.go('/landlord/subscription') : null,
                    actionLabel: context.tr('complete_setup'),
                  );
                },
                data: (tenants) {
                  final filtered = tenants.where((t) {
                    final userData = t['user'] as Map<String, dynamic>?;
                    final name = (userData?['full_name'] ?? userData?['name'] ?? t['full_name'] ?? t['name'] ?? '').toString().toLowerCase();
                    final phone = (userData?['phone'] ?? t['phone'] ?? '').toString().toLowerCase();
                    final matchesSearch = name.contains(_searchQuery) || phone.contains(_searchQuery);
                    final status = (t['status'] ?? 'active').toString();
                    final matchesStatus = _filterStatus == 'all' || status == _filterStatus;
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(message: context.tr('no_tenants_found'), icon: Icons.people_outline);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tenant = filtered[index];
                      final tenantId = tenant['id']?.toString() ?? '';
                      return Dismissible(
                        key: Key(tenantId.isNotEmpty ? tenantId : index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(context.tr('delete_tenant')),
                              content: Text(context.tr('confirm_delete_tenant')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('cancel'))),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(context.tr('delete'), style: const TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          try {
                            await ref.read(tenantsRepositoryProvider).deleteTenant(tenantId);
                            ref.invalidate(tenantsListProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(context.tr('tenant_deleted')), backgroundColor: AppColors.success),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(context.tr('failed_msg').replaceAll('{0}', e.toString())), backgroundColor: AppColors.error),
                              );
                              ref.invalidate(tenantsListProvider);
                            }
                          }
                        },
                        child: TenantCard(tenant: tenant),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/landlord/tenants/add'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(context.tr('add_tenant'), style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      labelStyle: GoogleFonts.nunito(
        fontSize: 13, 
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, 
        color: isSelected ? Colors.white : const Color(0xFF6B7280)
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
      showCheckmark: false,
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }
}
