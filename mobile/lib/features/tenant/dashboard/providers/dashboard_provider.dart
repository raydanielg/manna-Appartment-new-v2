import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/dashboard_repository.dart';

final tenantDashboardRepositoryProvider = Provider((ref) => TenantDashboardRepository(ref.read(apiClientProvider)));

final tenantDashboardProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(tenantDashboardRepositoryProvider);
  return repo.fetchDashboard();
});
