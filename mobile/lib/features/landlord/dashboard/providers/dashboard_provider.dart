import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository(ref.read(apiClientProvider)));

final landlordDashboardProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchDashboard();
});
