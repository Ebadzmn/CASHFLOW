import 'package:intl/intl.dart';

class ChatParticipant {
  final String id;
  final String name;
  final String email;
  final String image;
  final String role;

  const ChatParticipant({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.role,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: _readText(json['id'] ?? json['_id']),
      name: _readText(json['name'] ?? json['fullName'] ?? json['displayName']),
      email: _readText(json['email']),
      image: _readText(json['image'] ?? json['avatar'] ?? json['photo']),
      role: _readText(json['role'] ?? json['type']),
    );
  }
}

class ChatMessagePreview {
  final String content;
  final DateTime? createdAt;

  const ChatMessagePreview({required this.content, required this.createdAt});

  factory ChatMessagePreview.fromJson(Map<String, dynamic> json) {
    return ChatMessagePreview(
      content: _readText(json['content'] ?? json['text'] ?? json['message']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  String get timeLabel => _formatTime(createdAt);
}

class ChatRoomSummary {
  final String id;
  final String label;
  final String? avatarUrl;
  final List<ChatParticipant> participants;
  final ChatMessagePreview? lastMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatRoomSummary({
    required this.id,
    required this.label,
    required this.avatarUrl,
    required this.participants,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoomSummary.fromJson(Map<String, dynamic> json) {
    final participants = _readParticipants(json['participants']);
    final adminParticipant = _readAdminParticipant(json, participants);

    return ChatRoomSummary(
      id: _readText(json['id'] ?? json['_id']),
      label: _readRoomLabel(json),
      avatarUrl: _readAvatarUrl(json, adminParticipant),
      participants: participants,
      lastMessage: _readLastMessage(json['lastMessage']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  String get displayName => label.isNotEmpty ? label : 'Admin Chat';

  String get previewText {
    final text = lastMessage?.content.trim() ?? '';
    return text.isEmpty ? 'No messages yet' : text;
  }

  String get timeLabel {
    return _formatTime(updatedAt ?? lastMessage?.createdAt ?? createdAt);
  }
}

class ChatRoomPageResult {
  final List<ChatRoomSummary> rooms;
  final int currentPage;
  final int totalPage;

  const ChatRoomPageResult({
    required this.rooms,
    required this.currentPage,
    required this.totalPage,
  });

  bool get hasMore => currentPage < totalPage;

  factory ChatRoomPageResult.fromResponse(dynamic response) {
    final data = _extractData(response);
    final items = _extractMapList(data);
    final rooms = items.map(ChatRoomSummary.fromJson).toList()
      ..sort((left, right) {
        final leftDate =
            left.updatedAt ?? left.lastMessage?.createdAt ?? left.createdAt;
        final rightDate =
            right.updatedAt ?? right.lastMessage?.createdAt ?? right.createdAt;
        return (rightDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
          leftDate ?? DateTime.fromMillisecondsSinceEpoch(0),
        );
      });

    final pagination = _extractPagination(data);
    final currentPage =
        _readInt(pagination['currentPage'] ?? pagination['page']) ?? 1;
    final totalPage =
        _readInt(pagination['totalPage'] ?? pagination['totalPages']) ?? 1;

    return ChatRoomPageResult(
      rooms: rooms,
      currentPage: currentPage,
      totalPage: totalPage <= 0 ? 1 : totalPage,
    );
  }
}

class ChatMessageItem {
  final String id;
  final String roomId;
  final String content;
  final String senderName;
  final String senderImage;
  final String senderEmail;
  final String senderId;
  final String senderRole;
  final DateTime? createdAt;
  final DateTime? readAt;
  final String messageType;
  final String? clientMessageId;
  final bool isPending;
  final String? localFilePath;
  final String? localFileName;
  final String? attachmentUrl;

  const ChatMessageItem({
    required this.id,
    required this.roomId,
    required this.content,
    required this.senderName,
    required this.senderImage,
    required this.senderEmail,
    required this.senderId,
    required this.senderRole,
    required this.createdAt,
    required this.readAt,
    required this.messageType,
    required this.clientMessageId,
    required this.isPending,
    required this.localFilePath,
    required this.localFileName,
    required this.attachmentUrl,
  });

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    final sender = _extractSender(json);
    final messageType = _readText(
      json['messageType'] ?? json['type'] ?? json['kind'],
    ).toLowerCase().trim();

    return ChatMessageItem(
      id: _readText(json['id'] ?? json['_id']),
      roomId: _readRoomId(json),
      content: _readText(json['content'] ?? json['text'] ?? json['message']),
      senderName: _readText(
        sender['name'] ?? sender['fullName'] ?? sender['displayName'],
      ),
      senderImage: _readText(
        sender['image'] ?? sender['avatar'] ?? sender['photo'],
      ),
      senderEmail: _readText(sender['email']),
      senderId: _readText(sender['id'] ?? sender['_id']),
      senderRole: _readText(sender['role'] ?? sender['type']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      readAt: _parseDate(json['readAt'] ?? json['seenAt'] ?? json['read_at']),
      messageType: messageType.isEmpty ? 'text' : messageType,
      clientMessageId:
          _readText(
            json['clientMessageId'] ?? json['client_message_id'],
          ).isEmpty
          ? null
          : _readText(json['clientMessageId'] ?? json['client_message_id']),
      isPending: false,
      localFilePath: null,
        localFileName:
          _readText(json['fileName'] ?? json['filename']).isEmpty
          ? null
          : _readText(json['fileName'] ?? json['filename']),
      attachmentUrl:
          _readText(
            json['fileUrl'] ?? json['attachmentUrl'] ?? json['attachment'],
          ).isEmpty
          ? null
          : _readText(
              json['fileUrl'] ?? json['attachmentUrl'] ?? json['attachment'],
            ),
    );
  }

  factory ChatMessageItem.pending({
    required String roomId,
    required String senderName,
    required String senderEmail,
    required String senderImage,
    required String senderRole,
    required String content,
    required String messageType,
    required String clientMessageId,
    String? localFilePath,
    String? localFileName,
  }) {
    return ChatMessageItem(
      id: clientMessageId,
      roomId: roomId,
      content: content,
      senderName: senderName,
      senderImage: senderImage,
      senderEmail: senderEmail,
      senderId: 'local',
      senderRole: senderRole,
      createdAt: DateTime.now(),
      readAt: null,
      messageType: messageType,
      clientMessageId: clientMessageId,
      isPending: true,
      localFilePath: localFilePath,
      localFileName: localFileName,
      attachmentUrl: null,
    );
  }

  ChatMessageItem copyWith({
    String? id,
    String? roomId,
    String? content,
    String? senderName,
    String? senderImage,
    String? senderEmail,
    String? senderId,
    String? senderRole,
    DateTime? createdAt,
    DateTime? readAt,
    String? messageType,
    String? clientMessageId,
    bool? isPending,
    String? localFilePath,
    String? localFileName,
    String? attachmentUrl,
    bool clearLocalFilePath = false,
    bool clearLocalFileName = false,
    bool clearAttachmentUrl = false,
  }) {
    return ChatMessageItem(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      senderEmail: senderEmail ?? this.senderEmail,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      messageType: messageType ?? this.messageType,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      isPending: isPending ?? this.isPending,
      localFilePath: clearLocalFilePath
          ? null
          : (localFilePath ?? this.localFilePath),
      localFileName: clearLocalFileName
          ? null
          : (localFileName ?? this.localFileName),
      attachmentUrl: clearAttachmentUrl
          ? null
          : (attachmentUrl ?? this.attachmentUrl),
    );
  }

  String get messageKey {
    if (id.isNotEmpty) {
      return id;
    }

    return '${senderId}_${senderEmail}_${createdAt?.millisecondsSinceEpoch ?? 0}_$content';
  }

  bool isMineFor({
    required String currentUserName,
    required String currentUserEmail,
  }) {
    final role = senderRole.toLowerCase();
    if (role.contains('admin') || role.contains('support')) {
      return false;
    }

    final normalizedCurrentName = currentUserName.trim().toLowerCase();
    final normalizedCurrentEmail = currentUserEmail.trim().toLowerCase();
    final normalizedSenderName = senderName.trim().toLowerCase();
    final normalizedSenderEmail = senderEmail.trim().toLowerCase();

    if (normalizedCurrentEmail.isNotEmpty &&
        normalizedSenderEmail.isNotEmpty &&
        normalizedCurrentEmail == normalizedSenderEmail) {
      return true;
    }

    if (normalizedCurrentName.isNotEmpty &&
        normalizedSenderName.isNotEmpty &&
        normalizedCurrentName == normalizedSenderName) {
      return true;
    }

    if (role.contains('user') ||
        role.contains('client') ||
        role.contains('me')) {
      return true;
    }

    return false;
  }

  String get formattedTime => _formatTime(createdAt);

  bool get isRead => readAt != null;

  bool get hasAttachment => attachmentUrl != null || localFilePath != null;

  bool get isImage => messageType == 'image';

  bool get isPdf => messageType == 'pdf';

  String get attachmentLabel {
    final fileName = localFileName?.trim() ?? '';
    if (fileName.isNotEmpty) {
      return fileName;
    }

    final remoteName = attachmentUrl?.split('/').last.trim() ?? '';
    if (remoteName.isNotEmpty) {
      return remoteName;
    }

    switch (messageType) {
      case 'image':
        return 'Image';
      case 'pdf':
        return 'PDF file';
      default:
        return 'Attachment';
    }
  }
}

class ChatMessagePageResult {
  final List<ChatMessageItem> messages;
  final int currentPage;
  final int totalPage;
  final bool? hasMoreOverride;

  const ChatMessagePageResult({
    required this.messages,
    required this.currentPage,
    required this.totalPage,
    this.hasMoreOverride,
  });

  bool get hasMore => hasMoreOverride ?? (currentPage < totalPage);

  factory ChatMessagePageResult.fromResponse(dynamic response) {
    final responseMap = response is Map<String, dynamic>
        ? response
        : response is Map
        ? _toStringKeyMap(response)
        : <String, dynamic>{};
    final dataNode = responseMap['data'];
    final dataMap = dataNode is Map<String, dynamic>
        ? dataNode
        : dataNode is Map
        ? _toStringKeyMap(dataNode)
        : <String, dynamic>{};

    final items = _extractMapList(response);
    final messages = items.map(ChatMessageItem.fromJson).toList();

    final pagination = _extractPagination(response);
    final currentPage =
        _readInt(pagination['currentPage'] ?? pagination['page']) ?? 1;
    final totalPageValue = _readInt(
      pagination['totalPage'] ??
          pagination['totalPages'] ??
          pagination['lastPage'] ??
          pagination['pages'] ??
          pagination['pageCount'],
    );

    final limitValue = _readInt(
      pagination['limit'] ??
          pagination['perPage'] ??
          responseMap['limit'] ??
          dataMap['limit'],
    );
    final totalCountValue = _readInt(
      pagination['total'] ??
          pagination['totalCount'] ??
          pagination['count'] ??
          responseMap['total'] ??
          responseMap['totalCount'] ??
          responseMap['count'] ??
          dataMap['total'] ??
          dataMap['totalCount'] ??
          dataMap['count'],
    );

    int resolvedTotalPage = totalPageValue ?? 1;
    if ((totalPageValue == null || totalPageValue <= 0) &&
        totalCountValue != null &&
        totalCountValue > 0 &&
        limitValue != null &&
        limitValue > 0) {
      resolvedTotalPage = (totalCountValue / limitValue).ceil();
    }

    final hasNextValue = _readBool(
      pagination['hasNextPage'] ??
          pagination['hasMore'] ??
          pagination['hasNext'] ??
          responseMap['hasNextPage'] ??
          responseMap['hasMore'] ??
          responseMap['hasNext'] ??
          dataMap['hasNextPage'] ??
          dataMap['hasMore'] ??
          dataMap['hasNext'],
    );
    final isLastValue = _readBool(
      pagination['isLastPage'] ??
          pagination['isLast'] ??
          responseMap['isLastPage'] ??
          dataMap['isLastPage'],
    );
    final hasMoreOverride =
        hasNextValue ?? (isLastValue == null ? null : !isLastValue);

    return ChatMessagePageResult(
      messages: messages,
      currentPage: currentPage,
      totalPage: resolvedTotalPage <= 0 ? 1 : resolvedTotalPage,
      hasMoreOverride: hasMoreOverride,
    );
  }
}

Map<String, dynamic> _toStringKeyMap(Map source) {
  return source.map((key, value) => MapEntry(key.toString(), value));
}

dynamic _extractData(dynamic response) {
  if (response is List) {
    return <String, dynamic>{'data': response};
  }

  if (response is Map<String, dynamic>) {
    return response['data'] ?? response;
  }

  if (response is Map) {
    final map = _toStringKeyMap(response);
    final nested = map['data'];
    if (nested is Map) {
      return _toStringKeyMap(nested);
    }

    return map;
  }

  return <String, dynamic>{};
}

List<Map<String, dynamic>> _extractMapList(dynamic response) {
  final data = response is Map<String, dynamic>
      ? response['data'] ?? response
      : response is Map
      ? _toStringKeyMap(response)['data'] ?? response
      : response;

  if (data is List) {
    return data.whereType<Map>().map(_toStringKeyMap).toList();
  }

  if (data is Map<String, dynamic>) {
    final keys = <String>[
      'data',
      'messages',
      'items',
      'records',
      'rows',
      'results',
      'chatMessages',
      'chat_messages',
      'list',
    ];

    for (final key in keys) {
      final items = data[key];
      if (items is List) {
        return items.whereType<Map>().map(_toStringKeyMap).toList();
      }
    }

    for (final value in data.values) {
      if (value is List && value.isNotEmpty && value.first is Map) {
        return value.whereType<Map>().map(_toStringKeyMap).toList();
      }
    }
  }

  return <Map<String, dynamic>>[];
}

Map<String, dynamic> _extractPagination(dynamic response) {
  final data = response is Map<String, dynamic>
      ? response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response
      : response is Map
      ? _toStringKeyMap(response)
      : <String, dynamic>{};

  final pagination = data['pagination'];
  if (pagination is Map<String, dynamic>) {
    return pagination;
  }

  if (pagination is Map) {
    return _toStringKeyMap(pagination);
  }

  return <String, dynamic>{};
}

String _readRoomLabel(Map<String, dynamic> json) {
  const keys = <String>[
    'roomName',
    'chatName',
    'name',
    'title',
    'subject',
    'label',
    'conversationName',
  ];

  for (final key in keys) {
    final value = _readText(json[key]);
    if (value.isNotEmpty) {
      return value;
    }
  }

  final admin = json['admin'];
  if (admin is Map) {
    final normalized = _toStringKeyMap(admin);
    final adminName = _readText(
      normalized['name'] ??
          normalized['fullName'] ??
          normalized['displayName'] ??
          normalized['title'],
    );
    if (adminName.isNotEmpty) {
      return adminName;
    }
  }

  return 'Admin Chat';
}

String? _readAvatarUrl(
  Map<String, dynamic> json,
  ChatParticipant? adminParticipant,
) {
  const keys = <String>[
    'avatarUrl',
    'avatar',
    'image',
    'photo',
    'roomAvatar',
    'profileImage',
  ];

  for (final key in keys) {
    final value = _readText(json[key]);
    if (value.isNotEmpty) {
      return value;
    }
  }

  final admin = json['admin'];
  if (admin is Map) {
    final normalized = _toStringKeyMap(admin);
    final adminImage = _readText(
      normalized['image'] ?? normalized['avatar'] ?? normalized['photo'],
    );
    if (adminImage.isNotEmpty) {
      return adminImage;
    }
  }

  final participantImage = adminParticipant?.image.trim() ?? '';
  return participantImage.isEmpty ? null : participantImage;
}

List<ChatParticipant> _readParticipants(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => ChatParticipant.fromJson(_toStringKeyMap(item)))
        .toList();
  }

  if (value is Map) {
    final normalized = _toStringKeyMap(value);
    final nested = normalized['data'];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((item) => ChatParticipant.fromJson(_toStringKeyMap(item)))
          .toList();
    }

    return [ChatParticipant.fromJson(normalized)];
  }

  return <ChatParticipant>[];
}

ChatParticipant? _readAdminParticipant(
  Map<String, dynamic> json,
  List<ChatParticipant> participants,
) {
  for (final participant in participants) {
    final role = participant.role.toLowerCase();
    if (role.contains('admin') || role.contains('support')) {
      return participant;
    }
  }

  final admin = json['admin'];
  if (admin is Map) {
    return ChatParticipant.fromJson(_toStringKeyMap(admin));
  }

  return null;
}

ChatMessagePreview? _readLastMessage(dynamic value) {
  if (value is Map<String, dynamic>) {
    return ChatMessagePreview.fromJson(value);
  }

  if (value is Map) {
    return ChatMessagePreview.fromJson(_toStringKeyMap(value));
  }

  return null;
}

Map<String, dynamic> _extractSender(Map<String, dynamic> json) {
  final sender =
      json['sender'] ??
      json['user'] ??
      json['author'] ??
      json['createdBy'] ??
      json['messageFrom'];

  if (sender is Map<String, dynamic>) {
    return sender;
  }

  if (sender is Map) {
    return _toStringKeyMap(sender);
  }

  final admin = json['admin'];
  if (admin is Map<String, dynamic>) {
    return admin;
  }

  if (admin is Map) {
    return _toStringKeyMap(admin);
  }

  return <String, dynamic>{};
}

String _readRoomId(Map<String, dynamic> json) {
  final candidates = <dynamic>[
    json['chatRoomId'],
    json['roomId'],
    json['conversationId'],
    json['chatRoom'],
    json['room'],
    json['conversation'],
  ];

  for (final candidate in candidates) {
    final id = _extractIdString(candidate);
    if (id.isNotEmpty) {
      return id;
    }
  }

  return '';
}

String _extractIdString(dynamic value) {
  if (value == null) {
    return '';
  }

  if (value is String || value is num || value is bool) {
    return _readText(value);
  }

  if (value is Map) {
    final normalized = _toStringKeyMap(value);
    final nestedCandidates = <dynamic>[
      normalized['id'],
      normalized['_id'],
      normalized['chatRoomId'],
      normalized['roomId'],
      normalized['conversationId'],
      normalized['value'],
      normalized['room'],
      normalized['chatRoom'],
    ];

    for (final nested in nestedCandidates) {
      if (identical(nested, value)) {
        continue;
      }

      final id = _extractIdString(nested);
      if (id.isNotEmpty) {
        return id;
      }
    }
  }

  return '';
}

String _readText(dynamic value) {
  if (value == null) {
    return '';
  }

  if (value is String) {
    return value.trim();
  }

  if (value is num || value is bool) {
    return value.toString().trim();
  }

  return value.toString().trim();
}

int? _readInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value.trim());
  }

  return null;
}

bool? _readBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }

  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value)?.toLocal();
  }

  if (value is int) {
    final milliseconds = value < 1000000000000 ? value * 1000 : value;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    ).toLocal();
  }

  if (value is num) {
    final intValue = value.toInt();
    final milliseconds = intValue < 1000000000000 ? intValue * 1000 : intValue;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    ).toLocal();
  }

  return null;
}

String _formatTime(DateTime? date) {
  if (date == null) {
    return '';
  }

  return DateFormat('hh:mm a').format(date.toLocal());
}
