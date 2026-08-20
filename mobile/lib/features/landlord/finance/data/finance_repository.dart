import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class FinanceRepository {
  final ApiClient _client;
  FinanceRepository(this._client);

  Future<Map<String, dynamic>> getRevenueReport({
    String period = 'monthly',
    int? year,
    int? month,
    String? propertyId,
    String? unitId,
  }) async {
    final params = <String, dynamic>{
      'period': period,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (propertyId != null) 'property_id': propertyId,
      if (unitId != null) 'unit_id': unitId,
    };
    final response = await _client.get(ApiEndpoints.financeReport, queryParameters: params);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> getLeaseReport({int? year, String? propertyId}) async {
    final params = <String, dynamic>{
      'type': 'lease',
      if (year != null) 'year': year,
      if (propertyId != null) 'property_id': propertyId,
    };
    final response = await _client.get(ApiEndpoints.financeReport, queryParameters: params);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> getExpiryReport({int? daysAhead, String? propertyId}) async {
    final params = <String, dynamic>{
      'type': 'expiry',
      if (daysAhead != null) 'days_ahead': daysAhead,
      if (propertyId != null) 'property_id': propertyId,
    };
    final response = await _client.get(ApiEndpoints.financeReport, queryParameters: params);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> getDebtReport({String? propertyId}) async {
    final params = <String, dynamic>{
      'type': 'debts',
      if (propertyId != null) 'property_id': propertyId,
    };
    final response = await _client.get(ApiEndpoints.financeReport, queryParameters: params);
    return response.data['data'] ?? {};
  }
}
