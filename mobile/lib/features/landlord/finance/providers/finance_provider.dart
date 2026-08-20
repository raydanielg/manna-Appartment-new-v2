import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/finance_repository.dart';

final financeRepositoryProvider = Provider((ref) => FinanceRepository(ref.read(apiClientProvider)));

final revenueReportProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, RevenueReportParams>((ref, params) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getRevenueReport(
    period: params.period,
    year: params.year,
    month: params.month,
    propertyId: params.propertyId,
    unitId: params.unitId,
  );
});

final leaseReportProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int?>((ref, year) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getLeaseReport(year: year);
});

final expiryReportProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int?>((ref, daysAhead) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getExpiryReport(daysAhead: daysAhead);
});

final debtReportProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getDebtReport();
});

class RevenueReportParams {
  final String period;
  final int? year;
  final int? month;
  final String? propertyId;
  final String? unitId;

  const RevenueReportParams({
    this.period = 'monthly',
    this.year,
    this.month,
    this.propertyId,
    this.unitId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevenueReportParams &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          year == other.year &&
          month == other.month &&
          propertyId == other.propertyId &&
          unitId == other.unitId;

  @override
  int get hashCode =>
      period.hashCode ^
      year.hashCode ^
      month.hashCode ^
      propertyId.hashCode ^
      unitId.hashCode;
}
