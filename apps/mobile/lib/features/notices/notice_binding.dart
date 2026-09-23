import 'package:get/get.dart';

import 'notice_controller.dart';

class NoticeBinding extends Bindings {
  NoticeBinding({required this.noticeType});

  final String noticeType;

  @override
  void dependencies() {
    if (Get.isRegistered<NoticeController>()) {
      Get.delete<NoticeController>();
    }
    Get.lazyPut(() => NoticeController(noticeType: noticeType));
  }
}
