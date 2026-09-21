import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/tenants_provider.dart';
import '../../../contracts/providers/contracts_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class TenantDetailScreen extends ConsumerWidget {
  const TenantDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final tenantAsync = ref.watch(tenantDetailProvider(id));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('tenant_details_label'),
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () {
            if (context.canPop()) context.pop();
          },
          child: context.theme.icons.arrowLeft(context),
        ),
        actions: [
          FButton.icon(
            variant: .ghost,
            size: .sm,
            onPress: () => _confirmDelete(context, ref, id),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              size: 20,
              color: colors.error,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: tenantAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) {
          final message = AppError.getMessage(e);
          final isSetup = AppError.isSetupError(e);
          return ErrorState(
            message: message,
            onRetry: () => ref.invalidate(tenantDetailProvider(id)),
            onAction: isSetup ? () => context.go('/landlord/subscription') : null,
            actionLabel: context.tr('complete_setup'),
          );
        },
        data: (tenant) {
          final isActive = (tenant['status'] ?? 'active') == 'active';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — name + phone + status, no avatar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTenantName(tenant),
                            style: typography.display.lg
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTenantPhone(tenant),
                            style: typography.body.xs
                                .copyWith(color: colors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    FBadge(
                      variant: isActive ? .primary : .destructive,
                      child: Text(isActive
                          ? context.tr('active').toUpperCase()
                          : context.tr('moved_out').toUpperCase()),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildInfoCard(context, tenant, colors, typography),
                const SizedBox(height: 24),
                _buildContractsSection(context, tenant, ref, colors, typography),
                const SizedBox(height: 24),
                _buildPaymentsSection(context, tenant, ref, colors, typography),
                const SizedBox(height: 24),

                // Actions — stacked full-width, no overflow
                FButton(
                  variant: .outline,
                  size: .sm,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02, size: null),
                  onPress: () => _showEditDialog(context, ref, id, tenant),
                  child: Text(context.tr('edit')),
                ),
                const SizedBox(height: 10),
                FButton(
                  variant: .secondary,
                  size: .sm,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedSent, size: null),
                  onPress: () => _sendCredentials(context, ref, id),
                  child: Text(context.tr('send_credentials')),
                ),
                const SizedBox(height: 10),
                FButton(
                  variant: .destructive,
                  size: .sm,
                  prefix: const HugeIcon(
                      icon: HugeIcons.strokeRoundedUserRemove01, size: null),
                  onPress: () => _confirmMoveOut(context, id, ref),
                  child: Text(context.tr('move_out')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getTenantName(Map<String, dynamic> t) {
    final userData = t['user'] as Map<String, dynamic>?;
    return userData?['full_name'] ?? t['full_name'] ?? t['name'] ?? 'Unknown';
  }

  String _getTenantPhone(Map<String, dynamic> t) {
    final userData = t['user'] as Map<String, dynamic>?;
    return userData?['phone'] ?? t['phone'] ?? '';
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatAmount(dynamic value) {
    return NumberFormat('#,###').format(_parseAmount(value));
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return date.toString();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildInfoCard(
    BuildContext context,
    Map<String, dynamic> tenant,
    FColors colors,
    FTypography typography,
  ) {
    final balance = _parseAmount(tenant['balance_due']);
    final unit = tenant['unit'] ?? {};
    final property = unit['property'] ?? {};

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
          _row(colors, typography, HugeIcons.strokeRoundedBuilding03,
              context.tr('property'), property['name'] ?? 'N/A'),
          _divider(colors),
          _row(colors, typography, HugeIcons.strokeRoundedLocation01,
              context.tr('address'), property['address'] ?? 'N/A'),
          _divider(colors),
          _row(colors, typography, HugeIcons.strokeRoundedDoor01,
              context.tr('unit'), unit['name'] ?? context.tr('no_unit')),
          _divider(colors),
          _row(colors, typography, HugeIcons.strokeRoundedMoney01,
              context.tr('rent'), 'TZS ${_formatAmount(tenant['rent_amount'])}'),
          _divider(colors),
          _row(colors, typography, HugeIcons.strokeRoundedWallet01,
              context.tr('total_paid'), 'TZS ${_formatAmount(tenant['total_paid'])}'),
          _divider(colors),
          _row(
            colors,
            typography,
            HugeIcons.strokeRoundedAlert02,
            context.tr('balance_due'),
            'TZS ${_formatAmount(balance)}',
            valueColor: balance > 0 ? colors.error : const Color(0xFF16A34A),
          ),
          _divider(colors),
          _row(colors, typography, HugeIcons.strokeRoundedCalendar01,
              context.tr('move_in'), _formatDate(tenant['moved_in_date'])),
          ],
        ),
      ),
    );
  }

  Widget _divider(FColors colors) =>
      Divider(height: 1, indent: 14, color: colors.border.withValues(alpha: 0.6));

  Widget _row(
    FColors colors,
    FTypography typography,
    List<List<dynamic>> icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 16, color: colors.mutedForeground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: typography.body.xs2.copyWith(color: colors.mutedForeground),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs2.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractsSection(
    BuildContext context,
    Map<String, dynamic> tenant,
    WidgetRef ref,
    FColors colors,
    FTypography typography,
  ) {
    final contracts = (tenant['contracts'] ?? []) as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('contracts'),
              style: typography.display.sm.copyWith(fontWeight: FontWeight.w700),
            ),
            FButton(
              variant: .ghost,
              size: .sm,
              mainAxisSize: MainAxisSize.min,
              prefix:
                  const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: null),
              onPress: () => context.push('/landlord/contracts/create'),
              child: Text(context.tr('new_contract')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (contracts.isEmpty)
          FCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  context.tr('no_contracts_yet'),
                  style:
                      typography.body.xs2.copyWith(color: colors.mutedForeground),
                ),
              ),
            ),
          )
        else
          ...contracts.map((c) {
            final contract = c is Map<String, dynamic> ? c : <String, dynamic>{};
            return _buildContractCard(context, contract, ref, colors, typography);
          }),
      ],
    );
  }

  Widget _buildContractCard(
    BuildContext context,
    Map<String, dynamic> contract,
    WidgetRef ref,
    FColors colors,
    FTypography typography,
  ) {
    final unitName =
        contract['unit']?['name'] ?? contract['unit']?['unit_number'] ?? 'N/A';
    final startDate = _formatDate(contract['start_date']);
    final endDate = _formatDate(contract['end_date']);
    final status = (contract['status'] ?? 'active').toString();
    final contractId = contract['id']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FTappable(
        onPress: () => context.push('/landlord/contracts/$contractId'),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: context.theme.style.borderRadius.md,
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedFile01,
                        size: 18,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.tr('unit')}: $unitName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.sm
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$startDate - $endDate',
                          style: typography.body.xs3
                              .copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  FBadge(
                    variant: status == 'active' ? .primary : .secondary,
                    child: Text(status.toUpperCase()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FButton(
                variant: .outline,
                size: .sm,
                prefix: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDownload04, size: null),
                onPress: () async {
                  try {
                    final path = await ref
                        .read(contractsRepositoryProvider)
                        .downloadPdf(contractId);
                    await OpenFilex.open(path);
                  } catch (e) {
                    if (context.mounted) {
                      AppToast.error(
                          context, '${context.tr('download_failed')}: $e');
                    }
                  }
                },
                child: Text(context.tr('download_pdf')),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsSection(
    BuildContext context,
    Map<String, dynamic> tenant,
    WidgetRef ref,
    FColors colors,
    FTypography typography,
  ) {
    final payments = (tenant['payments'] ?? []) as List<dynamic>;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';

    return FTappable(
      onPress: () => context.push('/landlord/tenants/$id/payments'),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: context.theme.style.borderRadius.md,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedMoney01,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('payment_history'),
                      style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${payments.length} ${context.tr('payments')}',
                      style: typography.body.xs3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: colors.mutedForeground.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmMoveOut(
      BuildContext context, String id, WidgetRef ref) async {
    final confirmed = await _confirmDialog(
      context,
      title: context.tr('move_out_tenant'),
      body: context.tr('confirm_move_out'),
      confirmLabel: context.tr('move_out'),
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(tenantsRepositoryProvider).moveOut(id);
      ref.invalidate(tenantDetailProvider(id));
      if (context.mounted) {
        AppToast.success(context, context.tr('tenant_moved_out'));
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
            context, context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  Future<void> _sendCredentials(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await _confirmDialog(
      context,
      title: context.tr('send_credentials'),
      body: context.tr('send_credentials_confirm'),
      confirmLabel: context.tr('send'),
    );
    if (confirmed != true) return;
    try {
      await ref.read(tenantsRepositoryProvider).sendCredentials(id);
      if (context.mounted) {
        AppToast.success(context, context.tr('credentials_sent_success'));
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
            context, context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await _confirmDialog(
      context,
      title: context.tr('delete_tenant'),
      body: context.tr('confirm_delete_tenant'),
      confirmLabel: context.tr('delete'),
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref.read(tenantsRepositoryProvider).deleteTenant(id);
      ref.invalidate(tenantsListProvider);
      if (context.mounted) {
        AppToast.success(context, context.tr('tenant_deleted'));
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(
            context, context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)));
      }
    }
  }

  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        builder: (context, style) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: style.titleTextStyle),
            const SizedBox(height: 8),
            Text(body, style: style.bodyTextStyle),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: .outline,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => Navigator.pop(context, false),
                  child: Text(context.tr('cancel')),
                ),
                const SizedBox(width: 8),
                FButton(
                  variant: destructive ? .destructive : .primary,
                  size: .sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => Navigator.pop(context, true),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    Map<String, dynamic> tenant,
  ) {
    final nameController = TextEditingController(text: _getTenantName(tenant));
    final phoneController = TextEditingController(text: _getTenantPhone(tenant));
    final emailController = TextEditingController(
        text: (tenant['email'] ?? tenant['user']?['email'] ?? '').toString());
    final emergencyController =
        TextEditingController(text: tenant['emergency_contact'] ?? '');

    showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        builder: (context, style) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('edit_tenant'), style: style.titleTextStyle),
              const SizedBox(height: 16),
              FTextField(
                control: .managed(controller: nameController),
                label: Text(context.tr('full_name')),
              ),
              const SizedBox(height: 12),
              FTextField(
                control: .managed(controller: phoneController),
                label: Text(context.tr('phone')),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              FTextField(
                control: .managed(controller: emailController),
                label: Text(context.tr('email')),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              FTextField(
                control: .managed(controller: emergencyController),
                label: Text(context.tr('emergency_contact')),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: .outline,
                    size: .sm,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => Navigator.pop(context),
                    child: Text(context.tr('cancel')),
                  ),
                  const SizedBox(width: 8),
                  FButton(
                    variant: .primary,
                    size: .sm,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () async {
                      Navigator.pop(context);
                      try {
                        await ref.read(tenantsRepositoryProvider).updateTenant(id, {
                          'full_name': nameController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'email': emailController.text.trim(),
                          'emergency_contact': emergencyController.text.trim(),
                        });
                        ref.invalidate(tenantDetailProvider(id));
                        ref.invalidate(tenantsListProvider);
                        if (context.mounted) {
                          AppToast.success(context, context.tr('tenant_updated'));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppToast.error(
                            context,
                            context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e)),
                          );
                        }
                      }
                    },
                    child: Text(context.tr('save')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
