import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/unit_repository.dart';

final unitRepositoryProvider = Provider((ref) => UnitRepository(ref.read(apiClientProvider)));

final myUnitProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(unitRepositoryProvider);
  return repo.getMyUnit();
});
