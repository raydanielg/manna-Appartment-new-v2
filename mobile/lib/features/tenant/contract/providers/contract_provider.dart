import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/contract_repository.dart';

final contractRepositoryProvider = Provider((ref) => ContractRepository(ref.read(apiClientProvider)));

final myContractProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(contractRepositoryProvider);
  return repo.getMyContract();
});
