import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository(ref.read(apiClientProvider)));

final tenantProfileProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile();
});
