import 'dart:io';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ChatRoomSummary> createOrGetRoom() async {
    final response = await _apiClient.post(ApiEndpoints.chatCreateRoom);
    final data = _extractData(response.data);

    if (data is Map<String, dynamic>) {
      return ChatRoomSummary.fromJson(data);
    }

    if (data is Map) {
      return ChatRoomSummary.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    return const ChatRoomSummary(
      id: '',
      label: 'Admin Chat',
      avatarUrl: null,
      participants: <ChatParticipant>[],
      lastMessage: null,
      createdAt: null,
      updatedAt: null,
    );
  }

  Future<ChatRoomPageResult> getMyRooms({int page = 1, int limit = 10}) async {
    final response = await _apiClient.get(
      ApiEndpoints.chatMyRooms,
      query: <String, dynamic>{'page': page, 'limit': limit},
    );

    return ChatRoomPageResult.fromResponse(response.data);
  }

  Future<ChatMessagePageResult> getRoomMessages(
    String chatRoomId, {
    int page = 1,
    int limit = 10,
    String sortOrder = 'desc',
  }) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.chat}/$chatRoomId/messages',
      query: <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortOrder': sortOrder,
      },
    );

    return ChatMessagePageResult.fromResponse(response.data);
  }

  Future<ChatMessageItem?> sendMessage({
    required String chatRoomId,
    required String messageType,
    String? content,
    String? clientMessageId,
    File? file,
  }) async {
    final fields = <String, dynamic>{
      'messageType': messageType,
      if (content != null && content.trim().isNotEmpty)
        'content': content.trim(),
      if (clientMessageId != null && clientMessageId.trim().isNotEmpty)
        'clientMessageId': clientMessageId.trim(),
    };

    final response = file == null
        ? await _apiClient.post(
            '${ApiEndpoints.chatSendMessage}/$chatRoomId',
            body: fields,
          )
        : await _apiClient.postMultipart(
            '${ApiEndpoints.chatSendMessage}/$chatRoomId',
            fields: fields,
            files: {'file': file},
          );

    return _extractMessage(response.data);
  }

  Future<void> markAsRead(String chatRoomId) async {
    await _apiClient.patch('${ApiEndpoints.chat}/$chatRoomId/mark-read');
  }

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['data'] ?? response;
    }

    if (response is Map) {
      final map = response.map((key, value) => MapEntry(key.toString(), value));
      return map['data'] ?? map;
    }

    return response;
  }

  ChatMessageItem? _extractMessage(dynamic response) {
    final data = _extractData(response);

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['data'] ?? data['chatMessage'];
      if (message is Map<String, dynamic>) {
        return ChatMessageItem.fromJson(message);
      }

      if (message is Map) {
        return ChatMessageItem.fromJson(
          message.map((key, value) => MapEntry(key.toString(), value)),
        );
      }

      if (_looksLikeMessageMap(data)) {
        return ChatMessageItem.fromJson(data);
      }
    }

    if (data is Map) {
      final map = data.map((key, value) => MapEntry(key.toString(), value));
      if (_looksLikeMessageMap(map)) {
        return ChatMessageItem.fromJson(map);
      }
    }

    return null;
  }

  bool _looksLikeMessageMap(Map<String, dynamic> data) {
    return data.containsKey('content') ||
        data.containsKey('messageType') ||
        data.containsKey('sender') ||
        data.containsKey('createdAt') ||
        data.containsKey('_id') ||
        data.containsKey('id');
  }
}
