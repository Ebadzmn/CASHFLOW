import 'dart:io';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class IncomeRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> createTransaction({
    required String endpoint,
    required Map<String, String> fields,
    File? image,
  }) async {
    final response = await _apiClient.postMultipart(
      endpoint,
      fields: fields,
      files: image == null ? null : {'image': image},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }

    return <String, dynamic>{'data': data};
  }

  Future<Map<String, dynamic>> createIncome({
    required Map<String, String> fields,
    File? image,
  }) {
    return createTransaction(
      endpoint: ApiEndpoints.income,
      fields: fields,
      image: image,
    );
  }

  Future<Map<String, dynamic>> createExpense({
    required Map<String, String> fields,
    File? image,
  }) {
    return createTransaction(
      endpoint: ApiEndpoints.expense,
      fields: fields,
      image: image,
    );
  }

  Future<Map<String, dynamic>> createBankTransaction({
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.bankTransaction,
      body: body,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }

    return <String, dynamic>{'data': data};
  }

  Future<List<Map<String, dynamic>>> fetchIncomeList() {
    return _fetchMonthlySummaryList(ApiEndpoints.income);
  }

  Future<List<Map<String, dynamic>>> fetchExpenseList() {
    return _fetchMonthlySummaryList(ApiEndpoints.expense);
  }

  Future<List<Map<String, dynamic>>> fetchIncomeHistory() {
    return _fetchPaginatedHistory(ApiEndpoints.incomeHistory);
  }

  Future<List<Map<String, dynamic>>> fetchExpenseHistory() {
    return _fetchPaginatedHistory(ApiEndpoints.expenseHistory);
  }

  Future<List<Map<String, dynamic>>> _fetchMonthlySummaryList(
    String endpoint,
  ) async {
    final response = await _apiClient.get(endpoint);
    final data = response.data;

    final rawList = data is Map<String, dynamic> ? data['data'] : data;

    if (rawList is! List) {
      return <Map<String, dynamic>>[];
    }

    return rawList
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchPaginatedHistory(
    String endpoint,
  ) async {
    const limit = 100;
    var page = 1;
    var totalPages = 1;
    final items = <Map<String, dynamic>>[];

    do {
      final response = await _apiClient.get(
        endpoint,
        query: <String, dynamic>{'page': page, 'limit': limit},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        break;
      }

      final rawList = data['data'];
      final pagination = data['pagination'];

      if (rawList is List) {
        items.addAll(
          rawList.whereType<Map>().map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        );
      }

      if (pagination is Map<String, dynamic>) {
        totalPages = _toInt(pagination['totalPage']) ?? totalPages;
      }

      page += 1;
    } while (page <= totalPages);

    return items;
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
