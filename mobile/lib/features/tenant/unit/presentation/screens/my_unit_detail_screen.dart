import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../providers/unit_provider.dart';

class MyUnitDetailScreen extends ConsumerWidget {
  const MyUnitDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitAsync = ref.watch(myUnitProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(title: Text('My Unit', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: unitAsync.when(
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
                      child: const Icon(Icons.meeting_room_outlined, size: 36, color: AppColors.textLight),
                    ),
                    const SizedBox(height: 20),
                    Text('No Unit Assigned', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text('You haven\'t been assigned a unit yet. Please contact your landlord.', textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textLight, height: 1.5)),
                  ],
                ),
              ),
            );
          }
          return ErrorState(message: e.toString(), onRetry: () => ref.invalidate(myUnitProvider));
        },
        data: (unit) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Icon(Icons.meeting_room, size: 64, color: Colors.white70)),
              ),
              const SizedBox(height: 20),
              Text(unit['name'] ?? 'My Unit', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('TZS ${unit['monthly_rent'] ?? unit['rent_amount'] ?? 0}/month', style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              StatusBadge(status: unit['status'] ?? 'occupied'),
              const SizedBox(height: 20),
              _buildInfoRow(context, Icons.category_outlined, 'Type', unit['type'] ?? 'N/A'),
              _buildInfoRow(context, Icons.square_foot, 'Size', '${unit['size'] ?? 'N/A'} sqm'),
              _buildInfoRow(context, Icons.bed, 'Bedrooms', '${unit['bedrooms'] ?? 0}'),
              _buildInfoRow(context, Icons.bathtub, 'Bathrooms', '${unit['bathrooms'] ?? 0}'),
              if (unit['property'] != null)
                _buildInfoRow(context, Icons.apartment, 'Property', unit['property']['name'] ?? 'N/A'),
              if (unit['description'] != null) ...[
                const SizedBox(height: 20),
                Text('Description', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text(unit['description'], style: TextStyle(fontSize: 14, color: AppColors.textDark)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.textLight)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
