import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/sms_repository.dart';

final smsRepositoryProvider = Provider((ref) => SmsRepository(ref.read(apiClientProvider)));

final smsLogsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(smsRepositoryProvider);
  return repo.getLogs();
});

final smsBalanceProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(smsRepositoryProvider);
  return repo.getBalance();
});
