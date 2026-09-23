import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../../data/repositories/income_repository.dart';
import '../../../core/network/api_client.dart';

class StatsController extends GetxController {
  final IncomeRepository _incomeRepository = IncomeRepository();
  final ApiClient _apiClient = ApiClient.instance;

  static const Map<String, Color> _categoryColors = {
    'House': Color(0xFFFF8A80),
    'Food': Color(0xFF66BB6A),
    'Education': Color(0xFF42A5F5),
    'Travel': Color(0xFFAB47BC),
    'Gas': Color(0xFF26A69A),
    'Others': Color(0xFFFFCA28),
  };

  final expenseList = <Map<String, dynamic>>[].obs;
  final categoryMap = <String, double>{}.obs;
  final totalExpense = 0.0.obs;
  final chartData = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isDownloading = false.obs;
  final selectedFormat = 'PDF'.obs;
  final downloadFormat = ''.obs;
  final filePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(fetchExpenseReport());
  }

  Future<void> fetchExpenseReport() async {
    isLoading.value = true;

    try {
      final expenses = await _incomeRepository.fetchExpenseHistory();
      expenseList.assignAll(expenses);

      final groupedTotals = <String, double>{};
      for (final entry in expenses) {
        final category = _readCategory(entry['category']);
        final amount = _toDouble(entry['amount']);

        if (amount == null) {
          continue;
        }

        groupedTotals[category] = (groupedTotals[category] ?? 0) + amount;
      }

      categoryMap.assignAll(groupedTotals);

      final expenseTotal = groupedTotals.values.fold<double>(
        0,
        (sum, value) => sum + value,
      );
      totalExpense.value = expenseTotal;

      final orderedEntries = _orderCategories(groupedTotals);

      chartData.assignAll(
        List.generate(orderedEntries.length, (index) {
          final entry = orderedEntries[index];
          final percentage = expenseTotal == 0
              ? 0.0
              : (entry.value / expenseTotal) * 100;

          return <String, dynamic>{
            'category': entry.key,
            'total': entry.value,
            'percentage': percentage,
            'color': _categoryColors[entry.key] ?? _fallbackColor(index),
          };
        }),
      );
    } catch (_) {
      expenseList.clear();
      categoryMap.clear();
      chartData.clear();
      totalExpense.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadPdfReport() async {
    selectedFormat.value = 'PDF';
    await _downloadAndOpenFile(
      endpoint: '/reports/pdf',
      fileExtension: 'pdf',
      responseType: ResponseType.bytes,
      formatLabel: 'PDF',
    );
  }

  Future<void> downloadCsvReport() async {
    selectedFormat.value = 'CSV';
    await _downloadAndOpenFile(
      endpoint: '/reports/csv',
      fileExtension: 'csv',
      responseType: ResponseType.plain,
      formatLabel: 'CSV',
    );
  }

  Future<void> downloadExcelReport() async {
    selectedFormat.value = 'Excel';
    await _downloadAndOpenFile(
      endpoint: '/reports/excel',
      fileExtension: 'xlsx',
      responseType: ResponseType.bytes,
      formatLabel: 'Excel',
    );
  }

  void setSelectedFormat(String format) {
    selectedFormat.value = format;
  }

  Future<void> _downloadAndOpenFile({
    required String endpoint,
    required String fileExtension,
    required ResponseType responseType,
    required String formatLabel,
  }) async {
    isDownloading.value = true;
    downloadFormat.value = formatLabel;

    try {
      final response = await _apiClient.get(
        endpoint,
        options: Options(
          responseType: responseType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        String msg = 'Failed to generate report (${response.statusCode})';
        if (response.data is Map && response.data['message'] != null) {
          msg = response.data['message'].toString();
        }
        throw Exception(msg);
      }

      // Check if the backend responded with a JSON containing a remote URL
      if (response.data is Map && response.data['url'] != null) {
        final fileUrl = response.data['url'].toString();
        final directory = await getTemporaryDirectory();
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final path = '${directory.path}/report_$timestamp.$fileExtension';
        await _apiClient.download(fileUrl, path);
        filePath.value = path;
        final openResult = await OpenFilex.open(path);
        if (openResult.type != ResultType.done) {
          Get.snackbar(
            'Saved',
            'Report downloaded to: $path',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }
        return;
      }

      final bytes = _extractBytes(response.data);

      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('Empty file response received from server');
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${directory.path}/report_$timestamp.$fileExtension';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      filePath.value = path;

      final openResult = await OpenFilex.open(path);
      if (openResult.type != ResultType.done) {
        Get.snackbar(
          'Saved',
          'Report downloaded to: $path',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }

      return;
    } catch (error) {
      Get.log('Report export failed: $error');
      Get.snackbar(
        'Download Error',
        error.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
      downloadFormat.value = '';
    }
  }

  List<int>? _extractBytes(dynamic data) {
    if (data is List<int>) {
      return data;
    }

    if (data is Uint8List) {
      return data;
    }

    if (data is String) {
      // Check if it's base64 encoded
      try {
        if (data.startsWith('data:')) {
          final base64String = data.split(',').last;
          return base64Decode(base64String);
        }
      } catch (_) {}
      return utf8.encode(data);
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List<int>) {
        return nested;
      }

      if (nested is String) {
        try {
          return base64Decode(nested);
        } catch (_) {
          return utf8.encode(nested);
        }
      }
    }

    return null;
  }

  String _readCategory(dynamic value) {
    final category = value?.toString().trim() ?? '';
    return category.isEmpty ? 'Others' : category;
  }

  List<MapEntry<String, double>> _orderCategories(
    Map<String, double> groupedTotals,
  ) {
    const displayOrder = <String>[
      'House',
      'Food',
      'Education',
      'Travel',
      'Gas',
      'Others',
    ];

    final ordered = <MapEntry<String, double>>[];
    for (final category in displayOrder) {
      final value = groupedTotals[category];
      if (value != null) {
        ordered.add(MapEntry(category, value));
      }
    }

    final remaining =
        groupedTotals.entries
            .where((entry) => !displayOrder.contains(entry.key))
            .toList()
          ..sort((left, right) => left.key.compareTo(right.key));

    ordered.addAll(remaining);
    return ordered;
  }

  Color _fallbackColor(int index) {
    const fallbackColors = <Color>[
      Color(0xFFFF8A80),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFFAB47BC),
      Color(0xFF26A69A),
      Color(0xFFFFCA28),
    ];

    return fallbackColors[index % fallbackColors.length];
  }

  double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }
}
