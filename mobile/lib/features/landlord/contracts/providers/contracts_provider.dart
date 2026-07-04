import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/contracts_repository.dart';

final contractsRepositoryProvider = Provider((ref) => ContractsRepository(ref.read(apiClientProvider)));

final contractsListProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(contractsRepositoryProvider);
  return repo.getContracts();
});

final contractDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(contractsRepositoryProvider);
  return repo.getContract(id);
});
