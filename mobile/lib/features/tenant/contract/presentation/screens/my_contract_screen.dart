import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/contract_provider.dart';

class MyContractScreen extends ConsumerWidget {
  const MyContractScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(myContractProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(title: Text(context.tr('my_contract'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: contractAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) {
          if (e is DioException && e.response?.statusCode == 404) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: AppColors.textLight.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.description_outlined, size: 36, color: AppColors.textLight),
                    ),
                    const SizedBox(height: 20),
                    Text(context.tr('no_contract_yet'), style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(context.tr('no_contract_desc'), textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight, height: 1.5)),
                  ],
                ),
              ),
            );
          }
          return ErrorState(message: e.toString(), onRetry: () => ref.invalidate(myContractProvider));
        },
        data: (contract) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.info, AppColors.primary]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('my_contract'), style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    const StatusBadge(status: 'active'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildRow(context, Icons.calendar_today, context.tr('start_date'), contract['start_date'] ?? 'N/A'),
              _buildRow(context, Icons.event, context.tr('end_date'), contract['end_date'] ?? 'N/A'),
              _buildRow(context, Icons.account_balance_wallet, context.tr('monthly_rent_label'), 'TZS ${contract['rent_amount'] ?? contract['monthly_rent'] ?? 0}'),
              _buildRow(context, Icons.savings, context.tr('deposit'), 'TZS ${contract['deposit_amount'] ?? contract['deposit'] ?? 0}'),
              if (contract['unit'] != null)
                _buildRow(context, Icons.meeting_room, context.tr('unit'), contract['unit']['name'] ?? 'N/A'),
              const SizedBox(height: 24),
              PrimaryButton(
                text: context.tr('view_contract_pdf'),
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => context.push('/tenant/contract/pdf'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
        trailing: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ),
    );
  }
}

