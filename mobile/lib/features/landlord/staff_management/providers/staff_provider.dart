import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/staff_repository.dart';

final staffRepositoryProvider = Provider((ref) => StaffRepository(ref.read(apiClientProvider)));

final staffListProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getStaff();
});
