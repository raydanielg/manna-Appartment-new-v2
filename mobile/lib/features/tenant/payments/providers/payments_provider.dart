import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/payments_repository.dart';

final tenantPaymentsRepositoryProvider = Provider((ref) => TenantPaymentsRepository(ref.read(apiClientProvider)));

final myPaymentsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(tenantPaymentsRepositoryProvider);
  return repo.getMyPayments();
});
