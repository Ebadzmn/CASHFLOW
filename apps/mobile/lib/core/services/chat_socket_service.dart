import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../network/api_endpoints.dart';
import 'secure_storage_service.dart';

class ChatSocketService extends GetxService {
  final SecureStorageService _storageService = SecureStorageService();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _readReceiptController =
    StreamController<Map<String, dynamic>>.broadcast();

  io.Socket? _socket;
  String? _joinedRoomId;
  bool _isConnecting = false;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream =>
    _readReceiptController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected == true || _isConnecting) {
      return;
    }

    final token = (await _storageService.getAccessToken())?.trim();
    if (token == null || token.isEmpty) {
      Get.log('Skipped socket connect: JWT token missing');
      return;
    }

    _isConnecting = true;
    _resetSocket();

    final socket = io.io(
      ApiEndpoints.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setAuth(<String, dynamic>{'token': token})
          .setExtraHeaders(<String, dynamic>{'Authorization': 'Bearer $token'})
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      _isConnecting = false;
      Get.log('Socket connected: ${socket.id}');
      _joinRoomIfConnected();
    });

    socket.onDisconnect((reason) {
      _isConnecting = false;
      Get.log('Socket disconnected: $reason');
    });

    socket.onConnectError((error) {
      _isConnecting = false;
      Get.log('Connection error: $error');
    });

    socket.onError((error) {
      Get.log('Socket error: $error');
    });

    socket.on('joinedRoom', (dynamic roomId) {
      Get.log('Joined room: $roomId');
    });

    socket.on('roomError', (dynamic message) {
      Get.log('Room error: $message');
    });

    socket.on('messageError', (dynamic error) {
      Get.log('Message error: $error');
    });

    socket.on('readError', (dynamic error) {
      Get.log('Read error: $error');
    });

    socket.on('newMessage', (dynamic payload) {
      final normalized = _normalizePayload(payload);
      if (normalized.isNotEmpty) {
        _messageController.add(normalized);
      }
    });

    socket.on('messagesRead', (dynamic payload) {
      final normalized = _normalizePayload(payload);
      if (normalized.isNotEmpty) {
        _readReceiptController.add(normalized);
      }
    });

    Get.log('Socket connecting to ${ApiEndpoints.socketBaseUrl}');
    socket.connect();
  }

  void joinRoom(String chatRoomId) {
    if (chatRoomId.isEmpty) {
      return;
    }

    _joinedRoomId = chatRoomId;
    _joinRoomIfConnected();
  }

  void leaveRoom(String chatRoomId) {
    if (chatRoomId.isEmpty) {
      return;
    }

    _emitIfConnected('leaveRoom', chatRoomId);
    if (_joinedRoomId == chatRoomId) {
      _joinedRoomId = null;
    }
  }

  void emitMarkRead(String chatRoomId) {
    if (chatRoomId.isEmpty) {
      return;
    }

    _emitIfConnected('markMessagesAsRead', chatRoomId);
  }

  Future<bool> sendTextMessage({
    required String chatRoomId,
    required String content,
    String? clientMessageId,
  }) async {
    return sendMessage(
      chatRoomId: chatRoomId,
      messageType: 'text',
      content: content,
      clientMessageId: clientMessageId,
    );
  }

  Future<bool> sendMessage({
    required String chatRoomId,
    required String messageType,
    String? content,
    String? clientMessageId,
    Map<String, dynamic>? file,
  }) async {
    if (chatRoomId.isEmpty) {
      return false;
    }

    if (_socket?.connected != true) {
      await connect();
    }

    final socket = _socket;
    if (socket == null || !socket.connected) {
      Get.log('Skipped sendMessage because socket is not connected');
      return false;
    }

    final payload = <String, dynamic>{
      'chatRoomId': chatRoomId,
      'messageType': messageType,
      if (content != null && content.trim().isNotEmpty) 'content': content.trim(),
      if (clientMessageId != null && clientMessageId.trim().isNotEmpty)
        'clientMessageId': clientMessageId.trim(),
      if (file != null && file.isNotEmpty) 'file': file,
    };

    socket.emit('sendMessage', payload);
    return true;
  }

  void markMessagesAsRead(String chatRoomId) {
    emitMarkRead(chatRoomId);
  }

  void disconnect() {
    _isConnecting = false;
    _joinedRoomId = null;
    _resetSocket();
  }

  void _joinRoomIfConnected() {
    final roomId = _joinedRoomId;
    if (roomId == null || roomId.isEmpty) {
      return;
    }

    _emitIfConnected('joinRoom', roomId);
  }

  void _emitIfConnected(String event, dynamic payload) {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      Get.log('Skipped emit "$event" because socket is not connected');
      return;
    }

    socket.emit(event, payload);
    if (event == 'joinRoom') {
      Get.log('joinRoom emitted for room=$payload');
    }
  }

  void _resetSocket() {
    _socket?.off('newMessage');
    _socket?.off('messagesRead');
    _socket?.off('joinedRoom');
    _socket?.off('roomError');
    _socket?.off('messageError');
    _socket?.off('readError');
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
  }

  Map<String, dynamic> _normalizePayload(dynamic payload) {
    if (payload is String) {
      final decoded = _decodeJson(payload);
      if (decoded != null) {
        return _normalizePayload(decoded);
      }

      return <String, dynamic>{};
    }

    if (payload is Map<String, dynamic>) {
      return _flattenPayload(payload);
    }

    if (payload is Map) {
      return _flattenPayload(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    if (payload is List && payload.isNotEmpty) {
      for (final item in payload) {
        if (item is Map<String, dynamic>) {
          return _flattenPayload(item);
        }

        if (item is Map) {
          return _flattenPayload(
            item.map((key, value) => MapEntry(key.toString(), value)),
          );
        }

        if (item is String) {
          final decoded = _decodeJson(item);
          if (decoded is Map) {
            return _flattenPayload(
              decoded.map((key, value) => MapEntry(key.toString(), value)),
            );
          }
        }
      }
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _flattenPayload(Map<String, dynamic> payload) {
    final flattened = <String, dynamic>{...payload};

    for (final nestedKey in const [
      'data',
      'message',
      'chatMessage',
      'payload',
    ]) {
      final nested = payload[nestedKey];
      if (nested is Map) {
        final nestedMap = nested.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        flattened.addAll(nestedMap);
      } else if (nested is String) {
        final decoded = _decodeJson(nested);
        if (decoded is Map) {
          final nestedMap = decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          flattened.addAll(nestedMap);
        }
      }
    }

    return flattened;
  }

  dynamic _decodeJson(String value) {
    try {
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    disconnect();
    _readReceiptController.close();
    _messageController.close();
    super.onClose();
  }
}
