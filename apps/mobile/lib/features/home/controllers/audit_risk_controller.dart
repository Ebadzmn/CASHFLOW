import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuditRiskController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  final riskCount = 0.obs;
  final riskLevel = 'No Risk'.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(fetchAuditRisk());
  }

  Future<void> fetchAuditRisk() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiClient.get(ApiEndpoints.auditRisk);
      final count = _readAuditRiskCount(response.data);

      riskCount.value = count;
      riskLevel.value = _mapRiskLevel(count);
    } catch (error) {
      riskCount.value = 0;
      riskLevel.value = 'No Risk';
      errorMessage.value = 'Failed to load audit risk';
      Get.log('Audit risk fetch failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  double get riskProgress {
    final normalizedCount = riskCount.value.clamp(0, 10).toDouble();
    return 1 - (normalizedCount / 10);
  }

  Color get riskColor {
    switch (riskLevel.value) {
      case 'Low':
        return const Color(0xFF27AE60);
      case 'Moderate':
        return const Color(0xFFF2994A);
      case 'High':
        return const Color(0xFFEB5757);
      case 'Critical':
        return const Color(0xFFB91C1C);
      case 'No Risk':
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _mapRiskLevel(int count) {
    if (count <= 0) {
      return 'No Risk';
    }

    if (count <= 3) {
      return 'Low';
    }

    if (count <= 6) {
      return 'Moderate';
    }

    if (count <= 9) {
      return 'High';
    }

    return 'Critical';
  }

  int _readAuditRiskCount(dynamic data) {
    final payload = _readPayload(data);

    if (payload is Map<String, dynamic>) {
      return _toInt(payload['count']) ?? 0;
    }

    if (payload is Map) {
      return _toInt(payload['count']) ?? 0;
    }

    return _toInt(payload) ?? 0;
  }

  dynamic _readPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }

    if (data is Map) {
      return data['data'] ?? data;
    }

    return data;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }
}
