import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/payments_provider.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  String _searchQuery = '';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paymentsAsync = ref.watch(landlordPaymentsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('payments'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
                hintText: context.tr('search_payments'),
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
                  _buildFilterChip(context.tr('all'), 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('rent'), 'rent'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('water'), 'water'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('electricity'), 'electricity'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('other'), 'other'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(landlordPaymentsProvider),
              color: AppColors.primary,
              child: paymentsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) {
                  final message = AppError.getMessage(e);
                  final isSetupError = message.toLowerCase().contains('kyc') ||
                      message.toLowerCase().contains('subscription') ||
                      message.toLowerCase().contains('organization');
                  return ErrorState(
                    message: message,
                    onRetry: () => ref.invalidate(landlordPaymentsProvider),
                    onAction: isSetupError ? () => context.go('/landlord/subscription') : null,
                    actionLabel: context.tr('complete_setup'),
                  );
                },
                data: (payments) {
                  final filtered = payments.where((p) {
                    final tenant = (p['tenant']?['user']?['full_name'] ?? p['tenant']?['full_name'] ?? p['tenant_name'] ?? '').toString().toLowerCase();
                    final matchesSearch = tenant.contains(_searchQuery) || (p['reference'] ?? '').toString().toLowerCase().contains(_searchQuery);
                    final type = (p['payment_type'] ?? 'rent').toString();
                    final matchesType = _filterType == 'all' || type == _filterType;
                    return matchesSearch && matchesType;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(message: context.tr('no_payments_recorded_yet'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final payment = filtered[index];
                      return Dismissible(
                        key: Key(payment['id']?.toString() ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(context.tr('delete_payment')),
                              content: Text(context.tr('confirm_delete_payment')),
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
                            await ref.read(paymentsRepositoryProvider).deletePayment(payment['id'].toString());
                            ref.invalidate(landlordPaymentsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(context.tr('payment_deleted')), backgroundColor: AppColors.success),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(context.tr('failed_msg').replaceAll('{0}', AppError.getMessage(e))), backgroundColor: AppColors.error),
                              );
                              ref.invalidate(landlordPaymentsProvider);
                            }
                          }
                        },
                        child: _PaymentCard(payment: payment),
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
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(context.tr('record')),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textLight))),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (_) => setState(() => _filterType = value),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = _parseAmount(payment['amount']);
    final type = (payment['payment_type'] ?? 'rent').toString();
    final date = payment['payment_date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(payment['payment_date'].toString()) ?? DateTime.now()) : '-';
    final Color typeColor = {
      'rent': AppColors.primary,
      'water': Colors.blue,
      'electricity': Colors.amber,
      'other': Colors.grey,
    }[type] ?? AppColors.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/landlord/payments/${payment['id']}'),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.15),
          child: Icon(_iconForType(type), color: typeColor, size: 18),
        ),
        title: Text(
          'TZS ${amount.toStringAsFixed(0)}',
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payment['tenant']?['user']?['full_name'] ?? payment['tenant']?['full_name'] ?? payment['tenant_name'] ?? context.tr('unknown'),
              style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight),
            ),
            Text(
              type.toUpperCase(),
              style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: typeColor),
            ),
          ],
        ),
        trailing: Text(date, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
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

  IconData _iconForType(String type) {
    switch (type) {
      case 'water':
        return Icons.water_drop;
      case 'electricity':
        return Icons.electric_bolt;
      case 'rent':
        return Icons.home;
      default:
        return Icons.payments;
    }
  }
}
