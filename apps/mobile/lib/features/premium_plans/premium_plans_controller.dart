import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/services/storage_service.dart';
import '../../data/repositories/subscription_repository.dart';
import '../profile/profile_controller.dart';

class PlanProductInfo {
  final String id;
  final String name;
  final bool isYearly;

  const PlanProductInfo({
    required this.id,
    required this.name,
    required this.isYearly,
  });
}

class PremiumPlansController extends GetxController {
  // Product IDs for Apple StoreKit & Google Play Store
  static const String monthlyBasicProductId = 'com.cashflowIQ.MonthlyBasic';
  static const String monthlyProProductId = 'com.proProfessional.month';
  static const String monthlyEliteProductId = 'com.elitePoweruser.month';
  static const String monthlyShieldProductId = 'com.shieldAuditDefense.month';

  static const String yearlyBasicProductId = 'com.cashflowIQ.YearlyBasic';
  static const String yearlyProProductId = 'com.proProfessional.yearly';
  static const String yearlyEliteProductId = 'com.elitePoweruser.yearly';
  static const String yearlyShieldProductId = 'com.shieldAuditDefense.yearly';

  static const List<PlanProductInfo> allPlans = [
    PlanProductInfo(
      id: monthlyBasicProductId,
      name: 'Monthly Basic Growth',
      isYearly: false,
    ),
    PlanProductInfo(
      id: monthlyProProductId,
      name: 'Monthly Pro Professional',
      isYearly: false,
    ),
    PlanProductInfo(
      id: monthlyEliteProductId,
      name: 'Monthly Elite Power User',
      isYearly: false,
    ),
    PlanProductInfo(
      id: monthlyShieldProductId,
      name: 'Monthly Shield Audit Defense',
      isYearly: false,
    ),
    PlanProductInfo(
      id: yearlyBasicProductId,
      name: 'Yearly Basic Growth',
      isYearly: true,
    ),
    PlanProductInfo(
      id: yearlyProProductId,
      name: 'Yearly Pro Professional',
      isYearly: true,
    ),
    PlanProductInfo(
      id: yearlyEliteProductId,
      name: 'Yearly Elite Power User',
      isYearly: true,
    ),
    PlanProductInfo(
      id: yearlyShieldProductId,
      name: 'Yearly Shield Audit Defense',
      isYearly: true,
    ),
  ];

  static const Set<String> productIds = {
    monthlyBasicProductId,
    monthlyProProductId,
    monthlyEliteProductId,
    monthlyShieldProductId,
    yearlyBasicProductId,
    yearlyProProductId,
    yearlyEliteProductId,
    yearlyShieldProductId,
  };

  final StorageService _storageService = Get.find<StorageService>();
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  final RxMap<String, ProductDetails> productsMap = <String, ProductDetails>{}.obs;
  final isLoadingProducts = true.obs;
  final isPurchasing = false.obs;
  final isRestoringPurchases = false.obs;
  final isSubscribed = false.obs;
  final activeProductId = ''.obs;
  final isYearly = false.obs;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  @override
  void onInit() {
    super.onInit();
    isSubscribed.value = _storageService.isSubscribed();
    activeProductId.value = _storageService.getActiveProductId() ?? '';
    _subscribeToPurchaseUpdates();
    unawaited(_loadProductsCatalog());
    unawaited(checkBackendSubscriptionStatus());
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }

  void togglePlan(bool yearly) {
    isYearly.value = yearly;
  }

  ProductDetails? getProduct(String productId) {
    return productsMap[productId];
  }

  String getProductPrice(String productId, String fallbackPrice) {
    final details = productsMap[productId];
    return details?.price ?? fallbackPrice;
  }

  Future<void> _loadProductsCatalog() async {
    isLoadingProducts.value = true;
    Get.log('PremiumPlans: loading product catalog: $productIds');

    try {
      final available = await _inAppPurchase.isAvailable();
      Get.log('PremiumPlans: store available = $available');
      if (!available) {
        Get.log('PremiumPlans: store unavailable, skipping product query');
        _showSnackbar(
          'Store Unavailable',
          'The store is not available on this device right now.',
        );
        return;
      }

      final response = await _inAppPurchase.queryProductDetails(productIds);

      Get.log(
        'PremiumPlans: queryProductDetails response => found=${response.productDetails.length}, notFound=${response.notFoundIDs}, error=${response.error?.message ?? 'none'}',
      );

      if (response.error != null) {
        Get.log(
          'PremiumPlans: store query error details => ${response.error!.message}',
        );
        _showSnackbar('Product Query Warning', response.error!.message);
      }

      final map = <String, ProductDetails>{};
      for (final details in response.productDetails) {
        map[details.id] = details;
        Get.log('PremiumPlans: loaded product => ${details.id} (${details.title}) price: ${details.price}');
      }
      productsMap.assignAll(map);
    } catch (error) {
      Get.log('Failed to load subscription catalog: $error');
      _showSnackbar(
        'Product Unavailable',
        'Unable to load subscription details from the store.',
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void _subscribeToPurchaseUpdates() {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        isPurchasing.value = false;
        isRestoringPurchases.value = false;
        Get.log('Purchase stream error: $error');
      },
    );
  }

  Future<void> purchasePlan(String productId, String planTitle) async {
    Get.log(
      'PremiumPlans: purchasePlan tapped => id=$productId, title=$planTitle, subscribed=${isSubscribed.value}',
    );

    if (isSubscribed.value && activeProductId.value == productId) {
      _showSnackbar(
        'Subscription Active',
        '$planTitle is already unlocked on this device.',
      );
      return;
    }

    if (isPurchasing.value || isRestoringPurchases.value) {
      return;
    }

    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      _showSnackbar(
        'Store Unavailable',
        'The store is not available on this device right now.',
      );
      return;
    }

    final details = productsMap[productId];
    if (details == null) {
      Get.log('PremiumPlans: product details null for $productId, attempting direct buyParam fallback if store permits');
    }

    isPurchasing.value = true;

    try {
      if (details != null) {
        await _inAppPurchase.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: details),
        );
      } else {
        // Fallback: Re-query store dynamically for this specific product ID
        final response = await _inAppPurchase.queryProductDetails({productId});
        if (response.productDetails.isNotEmpty) {
          final dynamicDetails = response.productDetails.first;
          productsMap[productId] = dynamicDetails;
          await _inAppPurchase.buyNonConsumable(
            purchaseParam: PurchaseParam(productDetails: dynamicDetails),
          );
        } else {
          isPurchasing.value = false;
          _showSnackbar(
            'Product Not Found',
            'Product ID $productId was not returned by App Store Connect.',
          );
        }
      }
    } on PlatformException catch (error) {
      isPurchasing.value = false;
      Get.log(
        'PremiumPlans: PlatformException while starting purchase => code=${error.code}, message=${error.message}',
      );
      _showSnackbar(
        'Purchase Failed',
        error.message ?? 'Unable to start the purchase flow.',
      );
    } catch (error) {
      isPurchasing.value = false;
      Get.log('Purchase start failed: $error');
      _showSnackbar(
        'Purchase Failed',
        'Unable to start the purchase flow right now.',
      );
    }
  }

  // Convenience methods for each plan
  Future<void> purchaseMonthlyBasic() => purchasePlan(monthlyBasicProductId, 'Monthly Basic Growth');
  Future<void> purchaseMonthlyPro() => purchasePlan(monthlyProProductId, 'Monthly Pro Professional');
  Future<void> purchaseMonthlyElite() => purchasePlan(monthlyEliteProductId, 'Monthly Elite Power User');
  Future<void> purchaseMonthlyShield() => purchasePlan(monthlyShieldProductId, 'Monthly Shield Audit Defense');

  Future<void> purchaseYearlyBasic() => purchasePlan(yearlyBasicProductId, 'Yearly Basic Growth');
  Future<void> purchaseYearlyPro() => purchasePlan(yearlyProProductId, 'Yearly Pro Professional');
  Future<void> purchaseYearlyElite() => purchasePlan(yearlyEliteProductId, 'Yearly Elite Power User');
  Future<void> purchaseYearlyShield() => purchasePlan(yearlyShieldProductId, 'Yearly Shield Audit Defense');

  Future<void> restorePurchases() async {
    if (isPurchasing.value || isRestoringPurchases.value) {
      return;
    }

    isRestoringPurchases.value = true;

    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        _showSnackbar(
          'Restore Purchases',
          'The store is not available on this device right now.',
        );
        return;
      }

      await _inAppPurchase.restorePurchases();

      _showSnackbar(
        'Restoring Purchases',
        'Checking Apple App Store for your active subscriptions...',
      );
    } catch (error) {
      Get.log('Restore purchases failed: $error');
      _showSnackbar('Restore Failed', 'Unable to restore purchases right now.');
    } finally {
      isRestoringPurchases.value = false;
    }
  }

  Future<void> checkBackendSubscriptionStatus() async {
    try {
      final status = await _subscriptionRepository.getSubscriptionStatus();
      if (status.success && status.data != null) {
        if (status.data!.premium) {
          isSubscribed.value = true;
          await _storageService.saveSubscriptionState(isSubscribed: true);
        }
      }
    } catch (e) {
      Get.log('Failed to fetch backend subscription status: $e');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      Get.log(
        'PremiumPlans: purchase update => product=${purchase.productID}, status=${purchase.status}, pendingComplete=${purchase.pendingCompletePurchase}',
      );
      switch (purchase.status) {
        case PurchaseStatus.pending:
          isPurchasing.value = true;
          break;
        case PurchaseStatus.purchased:
          final valid = await _validatePurchase(purchase);
          if (valid) {
            await _unlockSubscription(purchase);
          } else {
            _showSnackbar(
              'Purchase Failed',
              'The purchase could not be verified.',
            );
          }
          break;
        case PurchaseStatus.restored:
          await _handleRestorePurchase(purchase);
          break;
        case PurchaseStatus.canceled:
          _showSnackbar(
            'Purchase Cancelled',
            'The purchase was cancelled before completion.',
          );
          break;
        case PurchaseStatus.error:
          Get.log(
            'PremiumPlans: purchase error => ${purchase.error?.code}: ${purchase.error?.message}',
          );
          _showSnackbar(
            'Purchase Failed',
            purchase.error?.message ?? 'The purchase failed.',
          );
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }

    isPurchasing.value = false;
    isRestoringPurchases.value = false;
  }

  Future<bool> _validatePurchase(PurchaseDetails purchase) async {
    if (!productIds.contains(purchase.productID)) {
      Get.log(
        'PremiumPlans: validation warning - unknown product ID ${purchase.productID}',
      );
    }
    return true;
  }

  Future<void> _unlockSubscription(PurchaseDetails purchase) async {
    Get.log('PremiumPlans: unlocking subscription for ${purchase.productID}');

    final transactionId = purchase.purchaseID ?? purchase.verificationData.serverVerificationData;

    try {
      final verifyResponse = await _subscriptionRepository.verifySubscription(
        transactionId: transactionId,
        productId: purchase.productID,
      );

      Get.log('Backend subscription verify success: ${verifyResponse.message}');
    } catch (e) {
      Get.log('Backend verification API call warning (local fallback will apply): $e');
    }

    isSubscribed.value = true;
    activeProductId.value = purchase.productID;

    final planInfo = allPlans.firstWhere(
      (p) => p.id == purchase.productID,
      orElse: () => PlanProductInfo(
        id: purchase.productID,
        name: 'Premium Plan',
        isYearly: false,
      ),
    );

    await _storageService.saveSubscriptionState(
      isSubscribed: true,
      productId: purchase.productID,
      plan: planInfo.name,
    );

    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      unawaited(profileCtrl.fetchProfile(showLoading: false));
    }

    _showSnackbar(
      'Subscription Activated',
      '${planInfo.name} is now active on your account!',
    );
  }

  Future<void> _handleRestorePurchase(PurchaseDetails purchase) async {
    final originalTransactionId = purchase.purchaseID ?? purchase.verificationData.serverVerificationData;

    try {
      final restoreResponse = await _subscriptionRepository.restoreSubscription(
        originalTransactionId: originalTransactionId,
      );

      Get.log('Backend subscription restore response: ${restoreResponse.message}');
    } catch (e) {
      Get.log('Backend restore API call warning (local fallback will apply): $e');
    }

    await _unlockSubscription(purchase);
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFF16253A),
      colorText: Colors.white,
    );
  }
}
