import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/chat_socket_service.dart';
import '../../data/models/chat_models.dart';
import '../../data/repositories/chat_repository.dart';
import '../profile/profile_controller.dart';

class ChatAttachmentDraft {
  final File file;
  final String name;
  final String messageType;

  const ChatAttachmentDraft({
    required this.file,
    required this.name,
    required this.messageType,
  });

  bool get isImage => messageType == 'image';
}

class ChatActionResult {
  final bool success;
  final String message;

  const ChatActionResult({required this.success, required this.message});
}

class ExpertSupportController extends GetxController {
  static const int _pageSize = 10;

  final ChatRepository _chatRepository = ChatRepository();
  final ChatSocketService _chatSocketService = Get.find<ChatSocketService>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final ImagePicker _imagePicker = ImagePicker();

  final chatRoomId = ''.obs;
  final rooms = <ChatRoomSummary>[].obs;
  final messagesList = <ChatMessageItem>[].obs;
  final currentPage = 1.obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final isLoadingMore = false.obs;
  final isLoadingRooms = false.obs;
  final isCreatingRoom = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final selectedAttachment = Rxn<ChatAttachmentDraft>();
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final Set<String> _messageKeys = <String>{};
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;
  StreamSubscription<Map<String, dynamic>>? _readReceiptSubscription;
  Timer? _pendingSyncTimer;
  bool _isBootstrapping = false;

  @override
  void onInit() {
    super.onInit();
    _socketSubscription = _chatSocketService.messageStream.listen(
      _handleSocketMessage,
      onError: (Object error, StackTrace stackTrace) {
        Get.log('Chat socket stream error: $error');
      },
      onDone: () {
        Get.log('Chat socket stream closed');
      },
      cancelOnError: false,
    );
    _readReceiptSubscription = _chatSocketService.readReceiptStream.listen(
      _handleMessagesRead,
      onError: (Object error, StackTrace stackTrace) {
        Get.log('Chat read-receipt stream error: $error');
      },
      onDone: () {
        Get.log('Chat read-receipt stream closed');
      },
      cancelOnError: false,
    );
    unawaited(bootstrapChat());
  }

  String get currentUserName =>
      _profileController.userProfile.value?.name ?? '';

  String get currentUserEmail =>
      _profileController.userProfile.value?.email ?? '';

  String? get currentUserImage => _profileController.profileImageUrl;

  ChatRoomSummary? get activeRoom {
    final activeId = chatRoomId.value;
    for (final room in rooms) {
      if (room.id == activeId) {
        return room;
      }
    }
    return null;
  }

  String get activeRoomLabel => activeRoom?.displayName ?? 'Admin Chat';

  String get activeRoomPreview =>
      activeRoom?.previewText ?? 'Connected to support';

  Future<void> bootstrapChat() async {
    if (_isBootstrapping) {
      return;
    }

    _isBootstrapping = true;
    isCreatingRoom.value = true;
    errorMessage.value = '';

    try {
      await _ensureProfileLoaded();
      await _chatSocketService.connect();

      final room = await _chatRepository.createOrGetRoom();
      if (room.id.isNotEmpty) {
        chatRoomId.value = room.id;
        _chatSocketService.joinRoom(room.id);
      }

      await Future.wait([loadMyRooms(), loadMessages(reset: true)]);

      await markCurrentRoomAsRead();
    } catch (error) {
      errorMessage.value = 'Failed to load chat';
      Get.log('Chat bootstrap failed: $error');
    } finally {
      isCreatingRoom.value = false;
      _isBootstrapping = false;
    }
  }

  Future<void> refreshChat() async {
    if (chatRoomId.value.isEmpty) {
      await bootstrapChat();
      return;
    }

    await Future.wait([
      loadMyRooms(),
      refreshLatestMessages(),
      markCurrentRoomAsRead(),
    ]);
  }

  Future<void> loadMyRooms() async {
    isLoadingRooms.value = true;

    try {
      final result = await _chatRepository.getMyRooms(page: 1, limit: 10);
      rooms.assignAll(result.rooms);
    } catch (error) {
      Get.log('Chat rooms load failed: $error');
      rooms.clear();
    } finally {
      isLoadingRooms.value = false;
    }
  }

  Future<void> selectRoom(String roomId) async {
    if (roomId.isEmpty || roomId == chatRoomId.value) {
      return;
    }

    final previousRoomId = chatRoomId.value;
    if (previousRoomId.isNotEmpty) {
      _chatSocketService.leaveRoom(previousRoomId);
    }

    chatRoomId.value = roomId;
    _chatSocketService.joinRoom(roomId);

    await loadMessages(reset: true);
    await markCurrentRoomAsRead();
  }

  Future<void> loadMessages({required bool reset}) async {
    final roomId = chatRoomId.value;
    if (roomId.isEmpty) {
      return;
    }

    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
      errorMessage.value = '';
      messagesList.clear();
      _messageKeys.clear();
    }

    isLoading.value = true;

    try {
      final result = await _chatRepository.getRoomMessages(
        roomId,
        page: currentPage.value,
        limit: _pageSize,
        sortOrder: 'desc',
      );

      final normalized = result.messages.reversed.toList();
      if (reset) {
        messagesList.assignAll(normalized);
      } else {
        messagesList.addAll(normalized);
      }

      _syncMessageKeys();
      hasMore.value = result.hasMore;

      if (reset) {
        _scrollToBottom();
      }
    } catch (error) {
      Get.log('Chat messages load failed: $error');
      if (messagesList.isEmpty) {
        errorMessage.value = 'Failed to load messages';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOlderMessages() async {
    if (chatRoomId.value.isEmpty || !hasMore.value || isLoadingMore.value) {
      return;
    }

    final previousOffset = scrollController.hasClients
        ? scrollController.position.pixels
        : 0.0;
    final previousMaxExtent = scrollController.hasClients
        ? scrollController.position.maxScrollExtent
        : 0.0;

    isLoadingMore.value = true;

    try {
      final nextPage = currentPage.value + 1;
      final result = await _chatRepository.getRoomMessages(
        chatRoomId.value,
        page: nextPage,
        limit: _pageSize,
        sortOrder: 'desc',
      );

      final normalized = result.messages.reversed.toList();
      final filtered = normalized
          .where((message) => !_messageKeys.contains(message.messageKey))
          .toList();

      if (filtered.isNotEmpty) {
        messagesList.insertAll(0, filtered);
      }

      currentPage.value = nextPage;
      hasMore.value = result.hasMore || normalized.length >= _pageSize;
      _syncMessageKeys();
      _preserveScrollPosition(previousOffset, previousMaxExtent);
    } catch (error) {
      Get.log('Chat load more failed: $error');
      Get.snackbar(
        'Error',
        'Failed to load older messages',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshLatestMessages() async {
    if (chatRoomId.value.isEmpty || isLoading.value || isLoadingMore.value) {
      return;
    }

    try {
      final result = await _chatRepository.getRoomMessages(
        chatRoomId.value,
        page: 1,
        limit: _pageSize,
        sortOrder: 'desc',
      );

      final normalized = result.messages.reversed.toList();
      final freshMessages = normalized
          .where((message) => !_messageKeys.contains(message.messageKey))
          .toList();

      if (freshMessages.isEmpty) {
        return;
      }

      final wasAtBottom = _isNearBottom();
      for (final incoming in freshMessages) {
        _mergeIncomingMessage(
          incoming.copyWith(
            roomId: incoming.roomId.isNotEmpty
                ? incoming.roomId
                : chatRoomId.value,
            isPending: false,
          ),
        );
      }
      _syncMessageKeys();
      hasMore.value = result.hasMore || hasMore.value;

      if (wasAtBottom) {
        _scrollToBottom();
      }

      await markCurrentRoomAsRead();
    } catch (error) {
      Get.log('Chat refresh failed: $error');
    }
  }

  Future<ChatActionResult> sendMessage() async {
    if (isSending.value) {
      return const ChatActionResult(
        success: false,
        message: 'Please wait while the current message is sending.',
      );
    }

    final roomId = chatRoomId.value;
    if (roomId.isEmpty) {
      return const ChatActionResult(
        success: false,
        message: 'Chat room is not ready yet.',
      );
    }

    final text = messageController.text.trim();
    final attachment = selectedAttachment.value;

    if (text.isEmpty && attachment == null) {
      return const ChatActionResult(
        success: false,
        message: 'Type a message or attach a file.',
      );
    }

    final clientMessageId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final previousText = messageController.text;
    final previousAttachment = selectedAttachment.value;
    final messageType = attachment?.messageType ?? 'text';

    final optimisticMessage = ChatMessageItem.pending(
      roomId: roomId,
      senderName: currentUserName.isNotEmpty ? currentUserName : 'You',
      senderEmail: currentUserEmail,
      senderImage: currentUserImage ?? '',
      senderRole: 'user',
      content: text,
      messageType: messageType,
      clientMessageId: clientMessageId,
      localFilePath: attachment?.file.path,
      localFileName: attachment?.name,
    );

    isSending.value = true;
    _insertOptimisticMessage(optimisticMessage);
    messageController.clear();
    selectedAttachment.value = null;

    try {
      ChatMessageItem? sentMessage;

      if (attachment == null) {
        final sentOnSocket = await _chatSocketService.sendTextMessage(
          chatRoomId: roomId,
          content: text,
          clientMessageId: clientMessageId,
        );

        if (!sentOnSocket) {
          throw Exception('Socket is not connected. Please try again.');
        }

          _schedulePendingSync();
      } else {
        sentMessage = await _chatRepository.sendMessage(
          chatRoomId: roomId,
          messageType: messageType,
          content: text.isEmpty ? null : text,
          clientMessageId: clientMessageId,
          file: attachment.file,
        );
      }

      if (sentMessage != null) {
        _mergeIncomingMessage(
          sentMessage.copyWith(
            roomId: roomId,
            clientMessageId: clientMessageId,
            isPending: false,
          ),
        );
      }

      await markCurrentRoomAsRead();
      _scrollToBottom();

      return const ChatActionResult(
        success: true,
        message: 'Message sent successfully',
      );
    } catch (error) {
      _removeMessageByClientMessageId(clientMessageId);
      messageController.text = previousText;
      selectedAttachment.value = previousAttachment;
      Get.log('Chat send failed: $error');

      return ChatActionResult(
        success: false,
        message: _errorMessage(error, fallback: 'Failed to send message'),
      );
    } finally {
      isSending.value = false;
      _syncMessageKeys();
    }
  }

  Future<void> markCurrentRoomAsRead() async {
    final roomId = chatRoomId.value;
    if (roomId.isEmpty) {
      return;
    }

    try {
      await _chatRepository.markAsRead(roomId);
      _chatSocketService.emitMarkRead(roomId);
    } catch (error) {
      Get.log('Mark read failed: $error');
    }
  }

  Future<void> showAttachmentOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.white),
                title: const Text(
                  'Attach Image',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(pickImageAttachment());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImageAttachment() async {
    try {
      final result = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (result == null || result.path.isEmpty) {
        return;
      }

      final name = result.name.isNotEmpty
          ? result.name
          : result.path.split('/').last;

      selectedAttachment.value = ChatAttachmentDraft(
        file: File(result.path),
        name: name,
        messageType: 'image',
      );
    } catch (error) {
      Get.log('Attachment pick failed: $error');
      Get.snackbar(
        'Error',
        'Failed to pick attachment',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearAttachment() {
    selectedAttachment.value = null;
  }

  void _handleSocketMessage(Map<String, dynamic> payload) {
    final message = ChatMessageItem.fromJson(payload);

    final hasContent = message.content.trim().isNotEmpty;
    final hasAttachment = (message.attachmentUrl?.trim().isNotEmpty ?? false);
    final hasIdentity = message.id.trim().isNotEmpty;
    if (!hasContent && !hasAttachment && !hasIdentity) {
      return;
    }

    if (chatRoomId.value.isNotEmpty &&
        message.roomId.isNotEmpty &&
        message.roomId != chatRoomId.value) {
      return;
    }

    final roomId = chatRoomId.value.isEmpty ? message.roomId : chatRoomId.value;
    final normalizedIncoming = message.copyWith(
      roomId: roomId,
      isPending: false,
    );

    final merged = _mergeIncomingMessage(normalizedIncoming);
    if (merged) {
      _syncMessageKeys();

      final isMine = normalizedIncoming.isMineFor(
        currentUserName: currentUserName,
        currentUserEmail: currentUserEmail,
      );

      if (!isMine) {
        unawaited(markCurrentRoomAsRead());
      }
    }
  }

  void _handleMessagesRead(Map<String, dynamic> payload) {
    final roomId =
        (payload['chatRoomId'] ?? payload['roomId'] ?? '').toString().trim();
    if (roomId.isEmpty || roomId != chatRoomId.value) {
      return;
    }

    final readAt = DateTime.now();
    var changed = false;

    for (var index = 0; index < messagesList.length; index++) {
      final message = messagesList[index];
      final isMine = message.isMineFor(
        currentUserName: currentUserName,
        currentUserEmail: currentUserEmail,
      );

      if (!isMine || message.isRead) {
        continue;
      }

      messagesList[index] = message.copyWith(readAt: readAt);
      changed = true;
    }

    if (changed) {
      _syncMessageKeys();
    }
  }

  bool _mergeIncomingMessage(ChatMessageItem incoming) {
    final pendingIndex = _findPendingMessageIndex(incoming);
    if (pendingIndex != -1) {
      messagesList[pendingIndex] = _mergePendingWithIncoming(
        messagesList[pendingIndex],
        incoming,
      );
      return true;
    }

    if (_messageKeys.contains(incoming.messageKey)) {
      return false;
    }

    final isMine = incoming.isMineFor(
      currentUserName: currentUserName,
      currentUserEmail: currentUserEmail,
    );

    if (isMine && _replaceByContentSignature(incoming)) {
      return true;
    }

    messagesList.add(incoming);

    if (_isNearBottom()) {
      _scrollToBottom();
    }

    return true;
  }

  bool _replaceByContentSignature(ChatMessageItem incoming) {
    for (var index = messagesList.length - 1; index >= 0; index--) {
      final candidate = messagesList[index];
      if (!candidate.isPending) {
        continue;
      }

      final sameType = candidate.messageType == incoming.messageType;
      final sameContent =
          _normalizeMatchText(candidate.content) ==
          _normalizeMatchText(incoming.content);
        final sameAttachment =
          _normalizeNullableText(candidate.localFileName) ==
          _normalizeNullableText(incoming.localFileName);

      if (sameType && sameContent && sameAttachment) {
        messagesList[index] = incoming.copyWith(
          roomId: incoming.roomId,
          isPending: false,
        );
        return true;
      }
    }

    return false;
  }

  int _findPendingMessageIndex(ChatMessageItem incoming) {
    if (incoming.clientMessageId != null &&
        incoming.clientMessageId!.isNotEmpty) {
      for (var index = messagesList.length - 1; index >= 0; index--) {
        final message = messagesList[index];
        if (message.isPending &&
            message.clientMessageId == incoming.clientMessageId) {
          return index;
        }
      }
    }

    for (var index = messagesList.length - 1; index >= 0; index--) {
      final message = messagesList[index];
      if (!message.isPending) {
        continue;
      }

      if (message.messageType == incoming.messageType &&
          _normalizeMatchText(message.content) ==
              _normalizeMatchText(incoming.content) &&
          _normalizeNullableText(message.localFileName) ==
              _normalizeNullableText(incoming.localFileName)) {
        return index;
      }
    }

    return -1;
  }

  void _insertOptimisticMessage(ChatMessageItem message) {
    messagesList.add(message);
    _syncMessageKeys();
    if (_isNearBottom()) {
      _scrollToBottom();
    }
  }

  ChatMessageItem _mergePendingWithIncoming(
    ChatMessageItem pending,
    ChatMessageItem incoming,
  ) {
    return pending.copyWith(
      id: incoming.id.isNotEmpty ? incoming.id : pending.id,
      roomId: incoming.roomId.isNotEmpty ? incoming.roomId : pending.roomId,
      content: incoming.content.isNotEmpty ? incoming.content : pending.content,
      createdAt: incoming.createdAt ?? pending.createdAt,
      readAt: incoming.readAt ?? pending.readAt,
      messageType: incoming.messageType.isNotEmpty
          ? incoming.messageType
          : pending.messageType,
      clientMessageId: incoming.clientMessageId ?? pending.clientMessageId,
      isPending: false,
      localFilePath: pending.localFilePath,
      localFileName: pending.localFileName,
      attachmentUrl: incoming.attachmentUrl ?? pending.attachmentUrl,
      senderName: pending.senderName,
      senderEmail: pending.senderEmail,
      senderImage: pending.senderImage,
      senderId: pending.senderId,
      senderRole: pending.senderRole,
    );
  }

  void _removeMessageByClientMessageId(String clientMessageId) {
    messagesList.removeWhere(
      (message) => message.clientMessageId == clientMessageId,
    );
    _syncMessageKeys();
  }

  void _syncMessageKeys() {
    _messageKeys
      ..clear()
      ..addAll(messagesList.map((message) => message.messageKey));
  }

  void _schedulePendingSync() {
    _pendingSyncTimer?.cancel();
    _pendingSyncTimer = Timer(const Duration(milliseconds: 900), () {
      if (chatRoomId.value.isEmpty) {
        return;
      }
      unawaited(refreshLatestMessages());
    });
  }

  String _normalizeMatchText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeNullableText(String? value) {
    return value?.trim() ?? '';
  }

  bool _isNearBottom() {
    if (!scrollController.hasClients) {
      return true;
    }

    return scrollController.position.pixels >=
        math.max(0.0, scrollController.position.maxScrollExtent - 120.0);
  }

  void _scrollToBottom() {
    _scrollToBottomWithRetry();
  }

  void _scrollToBottomWithRetry({int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        if (attempt < 4) {
          _scrollToBottomWithRetry(attempt: attempt + 1);
        }
        return;
      }

      final maxExtent = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(maxExtent);

      if (attempt < 2) {
        _scrollToBottomWithRetry(attempt: attempt + 1);
      }
    });
  }

  void _preserveScrollPosition(
    double previousOffset,
    double previousMaxExtent,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }

      final newMaxExtent = scrollController.position.maxScrollExtent;
      final delta = newMaxExtent - previousMaxExtent;
      final targetOffset = (previousOffset + delta).clamp(0.0, newMaxExtent);
      scrollController.jumpTo(targetOffset);
    });
  }

  Future<void> _ensureProfileLoaded() async {
    if (_profileController.userProfile.value != null) {
      return;
    }

    try {
      await _profileController.fetchProfile(showLoading: false);
    } catch (_) {
      // Keep chat usable even if profile refresh fails.
    }
  }

  String _errorMessage(Object error, {required String fallback}) {
    final message = error.toString().trim();
    if (message.isEmpty) {
      return fallback;
    }

    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    if (chatRoomId.value.isNotEmpty) {
      _chatSocketService.leaveRoom(chatRoomId.value);
    }
    _pendingSyncTimer?.cancel();
    super.onClose();
  }
}
