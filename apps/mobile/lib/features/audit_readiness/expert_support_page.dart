import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_endpoints.dart';
import '../../data/models/chat_models.dart';
import 'expert_support_controller.dart';

class ExpertSupportPage extends GetView<ExpertSupportController> {
  const ExpertSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: Obx(() {
          final isInitialLoading =
              controller.isCreatingRoom.value ||
              (controller.isLoading.value && controller.messagesList.isEmpty);

          if (isInitialLoading) {
            return _buildLoadingState(
              title: 'Connecting to support...',
              subtitle:
                  'Preparing your chat room and loading the latest messages.',
            );
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.messagesList.isEmpty) {
            return _buildErrorState(controller.errorMessage.value);
          }

          return Column(
            children: [
              _buildHeader(context),
              _buildRoomSummaryCard(),
              // _buildRoomsSection(),
              Expanded(
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        final isNearTop = notification.metrics.pixels <= 120;
                        final hasScrolledFromTop =
                          notification.metrics.pixels > 0;
                        final shouldLoad =
                            controller.hasMore.value &&
                            !controller.isLoadingMore.value;

                        if (shouldLoad &&
                          hasScrolledFromTop &&
                            isNearTop &&
                            (notification is ScrollUpdateNotification ||
                                notification is OverscrollNotification ||
                                notification is ScrollEndNotification)) {
                          unawaited(controller.loadOlderMessages());
                        }
                        return false;
                      },
                      child: controller.messagesList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: controller.scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                16,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller.messagesList.length,
                              itemBuilder: (context, index) {
                                final message = controller.messagesList[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        index ==
                                            controller.messagesList.length - 1
                                        ? 0
                                        : 18,
                                  ),
                                  child: _buildMessageBubble(context, message),
                                );
                              },
                            ),
                    ),
                    if (controller.isLoadingMore.value)
                      const Positioned(
                        top: 6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xCC1F2937),
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: Text(
                                'Loading older messages...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildComposer(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Expert Support',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.refreshChat,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomSummaryCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF16253A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildAvatarImage(
                  controller.activeRoom?.avatarUrl,
                  fallbackIcon: Icons.support_agent,
                  fallbackColor: const Color(0xFF56CCF2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.activeRoomLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.activeRoomPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.55),
                ),
              ),
              child: const Text(
                'Live',
                style: TextStyle(
                  color: Color(0xFF27AE60),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildRoomsSection() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Obx(
  //       () => Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Text(
  //                 'Your Rooms',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //               if (controller.isLoadingRooms.value)
  //                 const Text(
  //                   'Loading...',
  //                   style: TextStyle(color: Colors.white54, fontSize: 11),
  //                 ),
  //             ],
  //           ),
  //           const SizedBox(height: 10),
  //           if (controller.rooms.isEmpty && !controller.isLoadingRooms.value)
  //             Container(
  //               width: double.infinity,
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withValues(alpha: 0.05),
  //                 borderRadius: BorderRadius.circular(16),
  //                 border: Border.all(
  //                   color: Colors.white.withValues(alpha: 0.08),
  //                 ),
  //               ),
  //               child: const Text(
  //                 'No previous rooms yet.',
  //                 style: TextStyle(color: Colors.white60, fontSize: 12),
  //               ),
  //             )
  //           else
  //             SizedBox(
  //               height: 128,
  //               child: ListView.separated(
  //                 scrollDirection: Axis.horizontal,
  //                 physics: const BouncingScrollPhysics(),
  //                 itemCount: controller.rooms.length,
  //                 separatorBuilder: (_, __) => const SizedBox(width: 12),
  //                 itemBuilder: (context, index) {
  //                   final room = controller.rooms[index];
  //                   final isSelected = room.id == controller.chatRoomId.value;
  //                   return _buildRoomCard(room, isSelected);
  //                 },
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMessageBubble(BuildContext context, ChatMessageItem message) {
    final isMine = message.isMineFor(
      currentUserName: controller.currentUserName,
      currentUserEmail: controller.currentUserEmail,
    );
    final senderLabel = isMine
        ? 'You'
        : (message.senderName.isNotEmpty ? message.senderName : 'Admin');
    final bubbleColor = isMine
        ? const Color(0xFF2F80ED).withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.05);
    final borderColor = isMine
        ? const Color(0xFF2F80ED).withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.14);
    final content = message.content.trim();

    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          senderLabel,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: isMine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine) ...[
              _buildAvatarCircle(
                message.senderImage.isNotEmpty
                    ? _resolveImageUrl(message.senderImage)
                    : controller.activeRoom?.avatarUrl,
                fallbackIcon: Icons.support_agent,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMine
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottomRight: isMine
                        ? Radius.zero
                        : const Radius.circular(16),
                  ),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (content.isNotEmpty)
                      Text(
                        content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    if (message.hasAttachment) ...[
                      if (content.isNotEmpty) const SizedBox(height: 10),
                      _buildAttachmentPreview(context, message),
                    ],
                    if (message.isPending) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Sending...',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isMine) ...[
              const SizedBox(width: 10),
              _buildAvatarCircle(
                controller.currentUserImage,
                fallbackIcon: Icons.person,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.only(
            left: isMine ? 0 : 50,
            right: isMine ? 50 : 0,
          ),
          child: Row(
            mainAxisAlignment: isMine
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.formattedTime,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              if (isMine) ...[
                const SizedBox(width: 8),
                Text(
                  message.isPending
                      ? 'Sending'
                      : (message.isRead ? 'Read' : 'Sent'),
                  style: TextStyle(
                    color: message.isRead
                        ? const Color(0xFF56CCF2)
                        : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentPreview(
    BuildContext context,
    ChatMessageItem message,
  ) {
    if (message.isImage) {
      final imagePath = message.localFilePath;
      final imageUrl = message.attachmentUrl;
      final heroTag = 'chat-image-${message.messageKey}';

      if (imagePath != null && imagePath.isNotEmpty) {
        return _buildTappableImagePreview(
          heroTag: heroTag,
          image: FileImage(File(imagePath)),
          title: message.attachmentLabel,
          sourceLabel: 'Local image',
          onTap: () => _showImagePreview(
            context: context,
            imageProvider: FileImage(File(imagePath)),
            heroTag: heroTag,
            title: message.attachmentLabel,
            sourceLabel: 'Local image',
          ),
        );
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        return _buildTappableImagePreview(
          heroTag: heroTag,
          image: NetworkImage(imageUrl),
          title: message.attachmentLabel,
          sourceLabel: 'Chat image',
          onTap: () => _showImagePreview(
            context: context,
            imageProvider: NetworkImage(imageUrl),
            heroTag: heroTag,
            title: message.attachmentLabel,
            sourceLabel: 'Chat image',
          ),
        );
      }
    }

    if (message.isPdf) {
      return _buildFileTile(
        icon: Icons.picture_as_pdf,
        label: message.attachmentLabel,
      );
    }

    return _buildFileTile(
      icon: Icons.attachment,
      label: message.attachmentLabel,
    );
  }

  Widget _buildTappableImagePreview({
    required String heroTag,
    required ImageProvider image,
    required String title,
    required String sourceLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildFileTile(icon: Icons.image, label: title),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0x33000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          sourceLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.open_in_full,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImagePreview({
    required BuildContext context,
    required ImageProvider imageProvider,
    required String heroTag,
    required String title,
    required String sourceLabel,
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Image preview',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sourceLabel,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: heroTag,
                      child: InteractiveViewer(
                        minScale: 0.9,
                        maxScale: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: double.infinity,
                              height: 280,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Unable to load image',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Text(
                    'Pinch to zoom and drag to inspect the image.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildFileTile({required IconData icon, required String label}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16253A).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.selectedAttachment.value != null)
              _buildAttachmentChip(controller.selectedAttachment.value!),
            Row(
              children: [
                IconButton(
                  onPressed: controller.isSending.value
                      ? null
                      : () => controller.showAttachmentOptions(context),
                  icon: const Icon(Icons.attach_file, color: Colors.white70),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) async {
                        final result = await controller.sendMessage();
                        _showSendResult(result);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: controller.isSending.value
                      ? null
                      : () async {
                          final result = await controller.sendMessage();
                          _showSendResult(result);
                        },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: controller.isSending.value
                          ? const Color(0xFF2F80ED).withValues(alpha: 0.5)
                          : const Color(0xFF2F80ED),
                      shape: BoxShape.circle,
                    ),
                    child: controller.isSending.value
                        ? const Padding(
                            padding: EdgeInsets.all(11.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentChip(ChatAttachmentDraft attachment) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(Icons.image, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: controller.clearAttachment,
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(
    String? imageUrl, {
    required IconData fallbackIcon,
    Color fallbackColor = Colors.white,
  }) {
    final resolved = _resolveImageUrl(imageUrl);
    if (resolved == null) {
      return Icon(fallbackIcon, color: fallbackColor, size: 22);
    }

    return Image.network(
      resolved,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Icon(fallbackIcon, color: fallbackColor, size: 22),
    );
  }

  Widget _buildAvatarCircle(
    String? imageUrl, {
    required IconData fallbackIcon,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildAvatarImage(
          imageUrl,
          fallbackIcon: fallbackIcon,
          fallbackColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingState({required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Color(0xFF56CCF2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFEB5757),
                size: 36,
              ),
              const SizedBox(height: 14),
              const Text(
                'Failed to load chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.bootstrapChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56CCF2),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No messages yet. Start the conversation with Admin.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }

  void _showSendResult(ChatActionResult result) {
    Get.snackbar(
      result.success ? 'Success' : 'Error',
      result.message,
      backgroundColor: result.success ? Colors.green : Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  String? _resolveImageUrl(String? image) {
    final value = image?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return '${ApiEndpoints.baseUrl}$value';
  }
}
