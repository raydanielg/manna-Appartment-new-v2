import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/admin_landlords_repository.dart';

final adminLandlordsRepositoryProvider = Provider((ref) => AdminLandlordsRepository(ref.read(apiClientProvider)));

final adminLandlordsProvider = FutureProvider.autoDispose.family<List<dynamic>, ({String status, String search})>((ref, params) async {
  final repo = ref.watch(adminLandlordsRepositoryProvider);
  return repo.getLandlords(status: params.status, search: params.search);
});

final adminLandlordDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(adminLandlordsRepositoryProvider);
  return repo.getLandlord(id);
});
