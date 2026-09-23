import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/privacy_policy_response.dart';
import '../models/terms_conditions_response.dart';

class LegalRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<TermsConditionItem>> getTermsList() async {
    final response = await _apiClient.get(ApiEndpoints.termsConditions);
    final data = response.data;
    final items = data is Map<String, dynamic> ? data['data'] : null;

    if (items is! List) {
      return <TermsConditionItem>[];
    }

    return items
        .whereType<Map>()
        .map(
          (item) => TermsConditionItem.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.id.isNotEmpty && item.title.isNotEmpty)
        .toList();
  }

  Future<TermsConditionDetails> getTermDetails(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.termsConditions}/$id');
    final data = response.data;
    final item = data is Map<String, dynamic> ? data['data'] : null;

    if (item is! Map) {
      throw StateError('Invalid term details response');
    }

    return TermsConditionDetails.fromJson(
      item.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Future<List<PrivacyPolicyItem>> getPrivacyPolicyList() async {
    final response = await _apiClient.get(ApiEndpoints.privacyPolicy);
    final data = response.data;
    final items = data is Map<String, dynamic> ? data['data'] : null;

    if (items is! List) {
      return <PrivacyPolicyItem>[];
    }

    return items
        .whereType<Map>()
        .map(
          (item) => PrivacyPolicyItem.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.id.isNotEmpty && item.title.isNotEmpty)
        .toList();
  }

  Future<PrivacyPolicyDetails> getPrivacyPolicyDetails(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.privacyPolicy}/$id');
    final data = response.data;
    final item = data is Map<String, dynamic> ? data['data'] : null;

    if (item is! Map) {
      throw StateError('Invalid privacy policy details response');
    }

    return PrivacyPolicyDetails.fromJson(
      item.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}