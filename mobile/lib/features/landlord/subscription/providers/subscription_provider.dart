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

final freeTrialNotifierProvider = StateNotifierProvider<FreeTrialNotifier, AsyncValue<void>>((ref) {
  return FreeTrialNotifier(ref.read(subscriptionRepositoryProvider), ref);
});

class FreeTrialNotifier extends StateNotifier<AsyncValue<void>> {
  final SubscriptionRepository _repository;
  final Ref _ref;

  FreeTrialNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> activate() async {
    state = const AsyncValue.loading();
    try {
      await _repository.activateFreeTrial();
      _ref.invalidate(currentPlanProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void clearError() => state = const AsyncValue.data(null);
}
