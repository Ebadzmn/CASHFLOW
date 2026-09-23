class VerifyEmailResponse {
  final bool success;
  final String message;
  final String? token;
  final dynamic data;

  VerifyEmailResponse({
    required this.success,
    required this.message,
    this.token,
    this.data,
  });

  factory VerifyEmailResponse.fromJson(
    Map<String, dynamic> json, {
    String? tokenFromHeader,
  }) {
    String? extractedToken = tokenFromHeader;

    if (json['token'] != null) {
      extractedToken = json['token'].toString();
    } else if (json['resetToken'] != null) {
      extractedToken = json['resetToken'].toString();
    } else if (json['data'] is Map && json['data']['token'] != null) {
      extractedToken = json['data']['token'].toString();
    } else if (json['data'] is Map && json['data']['resetToken'] != null) {
      extractedToken = json['data']['resetToken'].toString();
    } else if (json['data'] is String && (json['data'] as String).isNotEmpty) {
      extractedToken = json['data'] as String;
    }

    return VerifyEmailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: extractedToken,
      data: json['data'],
    );
  }
}

