import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/tenants_repository.dart';

final tenantsRepositoryProvider = Provider((ref) => TenantsRepository(ref.read(apiClientProvider)));

final tenantsListProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(tenantsRepositoryProvider);
  return repo.getTenants();
});

final tenantDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(tenantsRepositoryProvider);
  return repo.getTenant(id);
});
