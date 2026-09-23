import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'notice_controller.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key, required this.pageTitle});

  final String pageTitle;

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final NoticeController controller = Get.find<NoticeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                      Expanded(
                        child: Text(
                          widget.pageTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: Text(
                          'Loading notices...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    if (controller.noticeList.isEmpty) {
                      return Center(
                        child: Text(
                          controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value
                              : 'No notices found',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: Colors.white,
                      onRefresh: controller.loadNotices,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                        itemCount: controller.noticeList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final notice = controller.noticeList[index];
                          return _NoticeListTile(
                            type: controller.displayType(notice),
                            date: controller.formatDate(notice.createdAt),
                            isDownloading: controller.isDownloading.value,
                            onTap: () =>
                                controller.downloadAndOpenNotice(notice),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeListTile extends StatelessWidget {
  final String type;
  final String date;
  final bool isDownloading;
  final VoidCallback onTap;

  const _NoticeListTile({
    required this.type,
    required this.date,
    required this.isDownloading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: isDownloading ? null : onTap,
            icon: isDownloading
                ? const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 18),
            label: Text(isDownloading ? 'Downloading...' : 'Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
