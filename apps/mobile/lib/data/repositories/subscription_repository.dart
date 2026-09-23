import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/subscription_models.dart';

class SubscriptionRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// POST /subscription/verify
  Future<SubscriptionVerificationResponse> verifySubscription({
    required String transactionId,
    required String productId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.subscriptionVerify,
      body: {
        'transactionId': transactionId,
        'productId': productId,
      },
    );

    return SubscriptionVerificationResponse.fromJson(response.data);
  }

  /// GET /subscription/status
  Future<SubscriptionVerificationResponse> getSubscriptionStatus() async {
    final response = await _apiClient.get(ApiEndpoints.subscriptionStatus);

    return SubscriptionVerificationResponse.fromJson(response.data);
  }

  /// POST /subscription/restore
  Future<SubscriptionVerificationResponse> restoreSubscription({
    required String originalTransactionId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.subscriptionRestore,
      body: {
        'originalTransactionId': originalTransactionId,
      },
    );

    return SubscriptionVerificationResponse.fromJson(response.data);
  }

  /// GET /subscription/history
  Future<SubscriptionHistoryResponse> getSubscriptionHistory() async {
    final response = await _apiClient.get(ApiEndpoints.subscriptionHistory);

    return SubscriptionHistoryResponse.fromJson(response.data);
  }
}
