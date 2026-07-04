import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider((ref) => NotificationsRepository(ref.read(apiClientProvider)));

final notificationsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getNotifications();
});
