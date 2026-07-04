import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/maintenance_repository.dart';

final maintenanceRepositoryProvider = Provider((ref) => MaintenanceRepository(ref.read(apiClientProvider)));

final maintenanceRequestsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(maintenanceRepositoryProvider);
  return repo.getRequests();
});
