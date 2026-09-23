import 'package:get/get.dart';

import '../../core/services/storage_service.dart';

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  void markOnboardingSeen() {
    _storageService.setHasSeenOnboarding(true);
  }
}
