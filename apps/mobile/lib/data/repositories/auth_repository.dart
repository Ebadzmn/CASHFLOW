import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/profile_response.dart';
import '../models/login_response.dart';
import '../models/signup_response.dart';
import '../models/verify_email_response.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<SignupResponse> signUp(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.signup, body: data);

    return SignupResponse.fromJson(response.data);
  }

  Future<ProfileResponse> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);

    return ProfileResponse.fromJson(response.data);
  }

  Future<ProfileResponse> updateProfile({
    required String name,
    File? image,
  }) async {
    final fields = <String, dynamic>{};
    final trimmedName = name.trim();

    if (trimmedName.isNotEmpty) {
      fields['name'] = trimmedName;
    }

    final response = await _apiClient.patchMultipart(
      ApiEndpoints.profile,
      fields: fields.isEmpty ? null : fields,
      files: image == null ? null : {'image': image},
    );

    return ProfileResponse.fromJson(response.data);
  }

  Future<VerifyEmailResponse> verifyEmail({
    required String email,
    required int oneTimeCode,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyEmail,
      body: {'email': email, 'oneTimeCode': oneTimeCode},
    );

    // Check if token is in headers (e.g., authorization or token header)
    String? tokenFromHeader;
    final authHeader = response.headers.value('authorization') ??
        response.headers.value('token') ??
        response.headers.value('reset-token');
    if (authHeader != null && authHeader.isNotEmpty) {
      tokenFromHeader = authHeader.replaceFirst('Bearer ', '').trim();
    }

    return VerifyEmailResponse.fromJson(
      response.data,
      tokenFromHeader: tokenFromHeader,
    );
  }

  Future<VerifyEmailResponse> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      body: {'email': email},
    );

    return VerifyEmailResponse.fromJson(response.data);
  }

  Future<VerifyEmailResponse> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final cleanToken = resetToken.replaceFirst('Bearer ', '').trim();
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      body: {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $cleanToken',
        },
      ),
    );

    return VerifyEmailResponse.fromJson(response.data);
  }

  Future<VerifyEmailResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.changePassword,
      body: {
        'currentPassword': currentPassword,
        'oldPassword': currentPassword,
        'newPassword': newPassword,
        'password': newPassword,
      },
    );

    return VerifyEmailResponse.fromJson(response.data);
  }

  Future<LoginResponse> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.refreshToken,
      body: {'refreshToken': refreshToken},
    );

    return LoginResponse.fromJson(response.data);
  }
}
