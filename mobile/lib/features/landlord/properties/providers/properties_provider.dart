import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/properties_repository.dart';
import '../data/models/property_model.dart';

final propertiesRepositoryProvider = Provider((ref) => PropertiesRepository(ref.read(apiClientProvider)));

final propertiesListProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(propertiesRepositoryProvider);
  return repo.getProperties();
});

final propertyDetailProvider = FutureProvider.autoDispose.family<PropertyModel, String>((ref, id) async {
  final repo = ref.watch(propertiesRepositoryProvider);
  return repo.getProperty(id);
});
