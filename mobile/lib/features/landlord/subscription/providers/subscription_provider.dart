import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider((ref) => SubscriptionRepository(ref.read(apiClientProvider)));

final currentPlanProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getCurrentPlan();
});

final subscriptionPlansProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getPlans();
});
