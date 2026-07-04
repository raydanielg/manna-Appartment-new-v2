import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/maintenance_repository.dart';

final tenantMaintenanceRepositoryProvider = Provider((ref) => TenantMaintenanceRepository(ref.read(apiClientProvider)));

final myMaintenanceRequestsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(tenantMaintenanceRepositoryProvider);
  return repo.getMyRequests();
});
