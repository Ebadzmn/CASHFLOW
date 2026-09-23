class SubscriptionVerificationResponse {
  final bool success;
  final String message;
  final SubscriptionVerificationData? data;

  SubscriptionVerificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SubscriptionVerificationResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionVerificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SubscriptionVerificationData.fromJson(json['data'])
          : null,
    );
  }
}

class SubscriptionVerificationData {
  final bool premium;
  final String? expiresAt;

  SubscriptionVerificationData({
    required this.premium,
    this.expiresAt,
  });

  factory SubscriptionVerificationData.fromJson(Map<String, dynamic> json) {
    return SubscriptionVerificationData(
      premium: json['premium'] ?? false,
      expiresAt: json['expiresAt']?.toString(),
    );
  }
}

class SubscriptionHistoryResponse {
  final bool success;
  final String message;
  final List<SubscriptionHistoryItem> data;

  SubscriptionHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubscriptionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => SubscriptionHistoryItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class SubscriptionHistoryItem {
  final String? purchaseDate;
  final String? expiresAt;
  final String productId;
  final String transactionId;
  final String? originalTransactionId;
  final String? environment;
  final bool revoked;

  SubscriptionHistoryItem({
    this.purchaseDate,
    this.expiresAt,
    required this.productId,
    required this.transactionId,
    this.originalTransactionId,
    this.environment,
    required this.revoked,
  });

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryItem(
      purchaseDate: json['purchaseDate']?.toString(),
      expiresAt: json['expiresAt']?.toString(),
      productId: json['productId'] ?? '',
      transactionId: json['transactionId'] ?? '',
      originalTransactionId: json['originalTransactionId']?.toString(),
      environment: json['environment']?.toString(),
      revoked: json['revoked'] ?? false,
    );
  }
}
