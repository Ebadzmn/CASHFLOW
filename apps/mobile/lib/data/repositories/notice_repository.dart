import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/notice_response.dart';

class NoticeRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<NoticeItem>> getNotices({String? type}) async {
    final response = await _apiClient.get(
      ApiEndpoints.notices,
      query: type == null || type.trim().isEmpty
          ? null
          : <String, dynamic>{'type': type.trim()},
    );
    final data = response.data;
    final items = data is Map<String, dynamic> ? data['data'] : data;

    if (items is! List) {
      return <NoticeItem>[];
    }

    final notices = items
        .whereType<Map>()
        .map(
          (item) => NoticeItem.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.id.isNotEmpty && item.documentUrl.isNotEmpty)
        .toList();

    notices.sort((left, right) {
      final leftDate = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final rightDate =
          right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return rightDate.compareTo(leftDate);
    });

    return notices;
  }
}
