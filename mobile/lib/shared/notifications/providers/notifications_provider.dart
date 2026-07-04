import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider((ref) => NotificationsRepository(ref.read(apiClientProvider)));

final notificationsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, page) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getNotifications(page: page);
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getUnreadCount();
});
