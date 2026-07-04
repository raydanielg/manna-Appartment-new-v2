import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/units_repository.dart';

final unitsRepositoryProvider = Provider((ref) => UnitsRepository(ref.read(apiClientProvider)));

final unitsListProvider = FutureProvider.autoDispose.family<List<dynamic>, String?>((ref, propertyId) async {
  final repo = ref.watch(unitsRepositoryProvider);
  return repo.getUnits(propertyId: propertyId);
});

final unitDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(unitsRepositoryProvider);
  return repo.getUnit(id);
});
