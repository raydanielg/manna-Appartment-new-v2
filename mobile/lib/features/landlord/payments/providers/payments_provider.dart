import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/payments_repository.dart';

final paymentsRepositoryProvider = Provider((ref) => PaymentsRepository(ref.read(apiClientProvider)));

final landlordPaymentsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(paymentsRepositoryProvider);
  return repo.getPayments();
});

final paymentDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(paymentsRepositoryProvider);
  return repo.getPayment(id);
});
