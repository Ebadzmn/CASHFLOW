class SignupResponse {
  final bool success;
  final String message;
  final SignupData? data;

  SignupResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? SignupData.fromJson(json['data']) : null,
    );
  }
}

class SignupData {
  final String id;
  final String name;
  final String email;
  final String role;
  final String image;
  final String status;
  final String plan;
  final bool verified;

  SignupData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.image,
    required this.status,
    required this.plan,
    required this.verified,
  });

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
      plan: json['plan'] ?? '',
      verified: json['verified'] ?? false,
    );
  }
}
