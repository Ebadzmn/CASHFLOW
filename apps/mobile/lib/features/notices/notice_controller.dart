import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/network/api_client.dart';
import '../../data/models/notice_response.dart';
import '../../data/repositories/notice_repository.dart';

class NoticeController extends GetxController {
  NoticeController({required this.noticeType});

  final NoticeRepository _noticeRepository = NoticeRepository();
  final ApiClient _apiClient = ApiClient.instance;
  final String noticeType;

  final noticeList = <NoticeItem>[].obs;
  final isLoading = false.obs;
  final isDownloading = false.obs;
  final selectedFile = Rxn<File>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadNotices());
  }

  Future<void> loadNotices() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final notices = await _noticeRepository.getNotices(type: noticeType);
      noticeList.assignAll(notices);
    } catch (error) {
      errorMessage.value = 'Failed to load notices';
      Get.snackbar(
        'Error',
        'Failed to load notices',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadAndOpenNotice(NoticeItem notice) async {
    if (notice.documentUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'Failed to download file',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDownloading.value = true;

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${directory.path}/notice_$timestamp.pdf';
      final file = File(path);

      await _apiClient.download(notice.documentUrl, path);

      if (!await file.exists() || await file.length() == 0) {
        throw const FileSystemException('Downloaded file is empty');
      }

      selectedFile.value = file;

      final openResult = await OpenFilex.open(file.path);
      if (openResult.type != ResultType.done) {
        Get.snackbar(
          'Saved',
          'PDF saved to: ${file.path}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        'Failed to download file',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Unknown date';
    }

    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String displayType(NoticeItem notice) {
    final type = notice.type.trim();
    if (type.isEmpty) {
      return 'IRS Notice';
    }

    return type;
  }
}
