import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/payments_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  final String? propertyId;
  const PaymentsListScreen({super.key, this.propertyId});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  String _searchQuery = '';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final paymentsAsync =
        ref.watch(landlordPaymentsProvider(widget.propertyId));
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('payments'),
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
            variant: _filterType != 'all' ? .secondary : .ghost,
            size: .sm,
            onPress: () => _showFilterSheet(context),
            child: const HugeIcon(
                icon: HugeIcons.strokeRoundedFilterHorizontal, size: null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FTextField(
              control: .managed(
                onChange: (v) =>
                    setState(() => _searchQuery = v.text.toLowerCase()),
              ),
              hint: context.tr('search_payments'),
              prefixBuilder: (context, style, variants) =>
                  FTextField.prefixIconBuilder(
                    context,
                    style,
                    variants,
                    const HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01, size: null),
                  ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(landlordPaymentsProvider(widget.propertyId)),
              color: colors.primary,
              child: paymentsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) {
                  final message = AppError.getMessage(e);
                  final isSetupError =
                      message.toLowerCase().contains('kyc') ||
                          message.toLowerCase().contains('subscription') ||
                          message.toLowerCase().contains('organization');
                  return ErrorState(
                    message: message,
                    onRetry: () => ref.invalidate(landlordPaymentsProvider(widget.propertyId)),
                    onAction: isSetupError
                        ? () => context.go('/landlord/subscription')
                        : null,
                    actionLabel: context.tr('complete_setup'),
                  );
                },
                data: (payments) {
                  final filtered = payments.where((p) {
                    final tenant = (p['tenant']?['user']?['full_name'] ??
                            p['tenant']?['full_name'] ??
                            p['tenant_name'] ??
                            '')
                        .toString()
                        .toLowerCase();
                    final matchesSearch = tenant.contains(_searchQuery) ||
                        (p['reference'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(_searchQuery);
                    final type = (p['payment_type'] ?? 'rent').toString();
                    final matchesType =
                        _filterType == 'all' || type == _filterType;
                    return matchesSearch && matchesType;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                        message: context.tr('no_payments_recorded_yet'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final payment = filtered[index];
                      return Dismissible(
                        key: Key(
                            payment['id']?.toString() ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius:
                                context.theme.style.borderRadius.lg,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            size: 22,
                            color: colors.errorForeground,
                          ),
                        ),
                        confirmDismiss: (direction) => showConfirmDialog(
                          context,
                          title: context.tr('delete_payment'),
                          message: context.tr('confirm_delete_payment'),
                          confirmText: context.tr('delete'),
                          cancelText: context.tr('cancel'),
                          isDestructive: true,
                        ),
                        onDismissed: (direction) async {
                          try {
                            await ref
                                .read(paymentsRepositoryProvider)
                                .deletePayment(payment['id'].toString());
                            ref.invalidate(landlordPaymentsProvider(widget.propertyId));
                            if (context.mounted) {
                              AppToast.success(
                                  context, context.tr('payment_deleted'));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.error(
                                context,
                                context.tr('failed_msg').replaceAll(
                                    '{0}', AppError.getMessage(e)),
                              );
                              ref.invalidate(landlordPaymentsProvider(widget.propertyId));
                            }
                          }
                        },
                        child: _PaymentRow(payment: payment),
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
        onPressed: () => context.push('/landlord/payments/record'),
        backgroundColor: colors.primary,
        foregroundColor: colors.primaryForeground,
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 20),
        label: Text(context.tr('record')),
      ),
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String type = _filterType;
        return StatefulBuilder(
          builder: (context, setSheet) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('filter'),
                      style: typography.body.md
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('payment_type').toUpperCase(),
                      style: typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final (label, v) in [
                          (context.tr('all'), 'all'),
                          (context.tr('rent'), 'rent'),
                          (context.tr('water'), 'water'),
                          (context.tr('electricity'), 'electricity'),
                          (context.tr('other'), 'other'),
                        ])
                          FButton(
                            variant: type == v ? .primary : .outline,
                            size: .xs,
                            mainAxisSize: MainAxisSize.min,
                            onPress: () => setSheet(() => type = v),
                            child: Text(label),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FButton(
                      variant: .primary,
                      onPress: () {
                        setState(() => _filterType = type);
                        Navigator.pop(context);
                      },
                      child: Text(context.tr('apply')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Map<String, dynamic> payment;
  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final amount = _parseAmount(payment['amount']);
    final type = (payment['payment_type'] ?? 'rent').toString();
    final date = payment['payment_date'] != null
        ? DateFormat('dd MMM yyyy').format(
            DateTime.tryParse(payment['payment_date'].toString()) ??
                DateTime.now())
        : '-';
    final tenant = payment['tenant']?['user']?['full_name'] ??
        payment['tenant']?['full_name'] ??
        payment['tenant_name'] ??
        context.tr('unknown');

    return FTappable(
      onPress: () => context.push('/landlord/payments/${payment['id']}'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.sm
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$type · $date',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.xs3
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'TZS ${NumberFormat('#,###').format(amount)}',
                style: typography.body.sm
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
