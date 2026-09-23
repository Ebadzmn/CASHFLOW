import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';
import 'premium_plans_controller.dart';

class PremiumPlansPage extends StatelessWidget {
  const PremiumPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<PremiumPlansController>()
        ? Get.find<PremiumPlansController>()
        : Get.put(PremiumPlansController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Purchase Premium Plans',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Title Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Text(
                      'Choose Your Plan',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unlock powerful features to manage your business finances.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Obx(() {
                      final statusText = controller.isLoadingProducts.value
                          ? 'Loading plans...'
                          : controller.isPurchasing.value
                          ? 'Processing purchase...'
                          : controller.isRestoringPurchases.value
                          ? 'Restoring purchases...'
                          : controller.isSubscribed.value
                          ? 'Subscription active'
                          : '';

                      if (statusText.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: Text(
                            statusText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                    // Tab Bar
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.togglePlan(false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !controller.isYearly.value
                                        ? const Color(
                                            0xFF152643,
                                          ) // Dark blue selection
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Monthly',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: !controller.isYearly.value
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.togglePlan(true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: controller.isYearly.value
                                        ? const Color(0xFF152643)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Yearly',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: controller.isYearly.value
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '-20%',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Pricing Cards List
              Expanded(
                child: Obx(
                  () => ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    children: [
                      _buildPricingCard(
                        title: 'Starter',
                        price: '\$0',
                        priceSubtitle: '',
                        subtitle:
                            'User acquisition, data capture, upsell funnel',
                        buttonLabel: 'Purchase',
                        onPressed: null,
                        features: [
                          {
                            'text': 'Basic income & expense tracking (limited)',
                            'included': true,
                          },
                          {'text': 'Manual categories', 'included': true},
                          {'text': 'Limited receipt uploads', 'included': true},
                          {'text': 'Summary reports only', 'included': true},
                          {'text': 'No audit tools', 'included': false},
                          {'text': 'No priority support', 'included': false},
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Monthly / Yearly Basic Growth Card
                      _buildPricingCard(
                        title: controller.isYearly.value
                            ? 'Yearly Basic Growth'
                            : 'Monthly Basic Growth',
                        price: controller.getProductPrice(
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyBasicProductId
                              : PremiumPlansController.monthlyBasicProductId,
                          controller.isYearly.value ? '\$299.99' : '\$29.99',
                        ),
                        priceSubtitle: controller.isYearly.value ? '/year' : '/month',
                        subtitle: 'Solopreneurs, freelancers, small businesses',
                        buttonLabel: _getButtonLabel(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyBasicProductId
                              : PremiumPlansController.monthlyBasicProductId,
                        ),
                        onPressed: _getButtonAction(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyBasicProductId
                              : PremiumPlansController.monthlyBasicProductId,
                          controller.isYearly.value
                              ? 'Yearly Basic Growth'
                              : 'Monthly Basic Growth',
                        ),
                        onCardTap: _getButtonAction(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyBasicProductId
                              : PremiumPlansController.monthlyBasicProductId,
                          controller.isYearly.value
                              ? 'Yearly Basic Growth'
                              : 'Monthly Basic Growth',
                        ),
                        features: [
                          {
                            'text': 'Unlimited income & expense tracking',
                            'included': true,
                          },
                          {'text': 'Receipt scanning (OCR)', 'included': true},
                          {
                            'text': 'IRS-standard expense categories',
                            'included': true,
                          },
                          {'text': 'Mileage tracking', 'included': true},
                          {'text': 'Monthly P&L report', 'included': true},
                          {
                            'text': 'Audit warnings (flags only)',
                            'included': true,
                          },
                          {'text': 'Email support', 'included': true},
                        ],
                      ),
                      const SizedBox(height: 30),

                      // PRO - Professional Card
                      _buildPricingCard(
                        title: controller.isYearly.value
                            ? 'Yearly Pro Professional'
                            : 'Monthly Pro Professional',
                        price: controller.getProductPrice(
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyProProductId
                              : PremiumPlansController.monthlyProProductId,
                          controller.isYearly.value ? '\$599' : '\$59',
                        ),
                        priceSubtitle: controller.isYearly.value ? '/year' : '/mon',
                        subtitle:
                            'High-income earners, contractors, serious compliance',
                        isRecommended: true,
                        buttonLabel: _getButtonLabel(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyProProductId
                              : PremiumPlansController.monthlyProProductId,
                        ),
                        onPressed: _getButtonAction(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyProProductId
                              : PremiumPlansController.monthlyProProductId,
                          controller.isYearly.value
                              ? 'Yearly Pro Professional'
                              : 'Monthly Pro Professional',
                        ),
                        onCardTap: _getButtonAction(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyProProductId
                              : PremiumPlansController.monthlyProProductId,
                          controller.isYearly.value
                              ? 'Yearly Pro Professional'
                              : 'Monthly Pro Professional',
                        ),
                        features: [
                          {'text': 'Advanced reports', 'included': true},
                          {'text': 'Schedule C summaries', 'included': true},
                          {'text': 'Quarterly tax estimates', 'included': true},
                          {'text': 'Export to CPA (CSV/PDF)', 'included': true},
                          {
                            'text': 'AI expense categorization',
                            'included': true,
                          },
                          {'text': 'Priority email support', 'included': true},
                        ],
                      ),
                      const SizedBox(height: 30),

                      // ELITE - Power User Card
                      _buildPricingCard(
                        title: controller.isYearly.value
                            ? 'Yearly Elite Power User'
                            : 'Monthly Elite Power User',
                        price: controller.getProductPrice(
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyEliteProductId
                              : PremiumPlansController.monthlyEliteProductId,
                          controller.isYearly.value ? '\$999' : '\$99',
                        ),
                        priceSubtitle: controller.isYearly.value ? '/year' : '/mon',
                        subtitle: 'Companies, LLCs, multiple businesses',
                        buttonLabel: _getButtonLabel(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyEliteProductId
                              : PremiumPlansController.monthlyEliteProductId,
                        ),
                        onPressed: _getButtonAction(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyEliteProductId
                              : PremiumPlansController.monthlyEliteProductId,
                          controller.isYearly.value
                              ? 'Yearly Elite Power User'
                              : 'Monthly Elite Power User',
                        ),
                        onCardTap: _getButtonAction(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyEliteProductId
                              : PremiumPlansController.monthlyEliteProductId,
                          controller.isYearly.value
                              ? 'Yearly Elite Power User'
                              : 'Monthly Elite Power User',
                        ),
                        features: [
                          {'text': 'Audit-readiness system', 'included': true},
                          {
                            'text': 'IRS-mapped expense locking',
                            'included': true,
                          },
                          {
                            'text': 'AI audit risk indicators',
                            'included': true,
                          },
                          {
                            'text': 'Red-flag detection alerts',
                            'included': true,
                          },
                          {
                            'text': 'Income discrepancy monitoring',
                            'included': true,
                          },
                          {'text': 'Audit-ready binder PDF', 'included': true},
                          {'text': 'CPA share-access link', 'included': true},
                          {'text': 'Priority chat support', 'included': true},
                        ],
                      ),
                      const SizedBox(height: 30),

                      // CASHFLOWIQ SHIELD - Audit Defense Card
                      _buildPricingCard(
                        title: controller.isYearly.value
                            ? 'Yearly Shield Audit Defense'
                            : 'Monthly Shield Audit Defense',
                        price: controller.getProductPrice(
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyShieldProductId
                              : PremiumPlansController.monthlyShieldProductId,
                          controller.isYearly.value ? '\$1499' : '\$149',
                        ),
                        priceSubtitle: controller.isYearly.value ? '/year' : '/mon',
                        subtitle: 'Companies, LLCs, multiple businesses',
                        buttonLabel: _getButtonLabel(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyShieldProductId
                              : PremiumPlansController.monthlyShieldProductId,
                        ),
                        onPressed: _getButtonAction(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyShieldProductId
                              : PremiumPlansController.monthlyShieldProductId,
                          controller.isYearly.value
                              ? 'Yearly Shield Audit Defense'
                              : 'Monthly Shield Audit Defense',
                        ),
                        onCardTap: _getButtonAction(
                          controller,
                          controller.isYearly.value
                              ? PremiumPlansController.yearlyShieldProductId
                              : PremiumPlansController.monthlyShieldProductId,
                          controller.isYearly.value
                              ? 'Yearly Shield Audit Defense'
                              : 'Monthly Shield Audit Defense',
                        ),
                        features: [
                          {
                            'text': 'All Elite features included',
                            'included': true,
                          },
                          {
                            'text':
                                'IRS & state audit defense via licensed partner',
                            'included': true,
                          },
                          {
                            'text': 'IRS notice upload & handling',
                            'included': true,
                          },
                          {
                            'text': 'Audit response preparation',
                            'included': true,
                          },
                          {
                            'text': 'Professional representation',
                            'included': true,
                          },
                          {'text': 'AI audit risk score', 'included': true},
                          {
                            'text':
                                'Misclassification & high-risk deduction alerts',
                            'included': true,
                          },
                          {
                            'text': 'Document request checklist',
                            'included': true,
                          },
                          {
                            'text': 'Business tax exposure dashboard',
                            'included': true,
                          },
                          {'text': 'Priority human support', 'included': true},
                        ],
                      ),
                      const SizedBox(height: 30),

                      if (_shouldShowRestorePurchasesButton()) ...[
                        Center(
                          child: TextButton.icon(
                            onPressed: controller.restorePurchases,
                            icon: const Icon(
                              Icons.restore,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              'Restore Purchases',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            'Already subscribed on your Apple account? Restore it here.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Subscription automatically renews unless canceled at least 24 hours before renewal.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Renewal charges will be billed to your Apple ID account.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          context.push(Routes.EULA),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                      ),
                                      child: Text(
                                        'Terms of Use (EULA)',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          context.push(Routes.PRIVACY),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                      ),
                                      child: Text(
                                        'Privacy Policy',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String priceSubtitle,
    required String subtitle,
    required VoidCallback? onPressed,
    VoidCallback? onCardTap,
    required List<Map<String, dynamic>> features,
    String buttonLabel = 'Purchase',
    bool isRecommended = false,
  }) {
    final cardContent = Stack(
      children: [
        // The Card Background Image
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/Pricing_card.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // The Card Outline
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
        ),
        // The Content
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.layers,
                  color: Color(0xFF152643),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (priceSubtitle.isNotEmpty)
                    Text(
                      priceSubtitle,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: features.map((feature) {
                  return _buildFeatureItem(
                    feature['text'] as String,
                    feature['included'] as bool,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onPressed == null
                        ? Colors.white24
                        : const Color(0xFF0288D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final tappableCard = GestureDetector(
      onTap: onCardTap,
      behavior: HitTestBehavior.opaque,
      child: cardContent,
    );

    if (!isRecommended) {
      return tappableCard;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(padding: const EdgeInsets.only(top: 16.0), child: tappableCard),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF152643),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recommended',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.electric_bolt, color: Colors.white, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text, bool isIncluded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isIncluded ? Icons.check : Icons.close,
            color: isIncluded ? Colors.white : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: isIncluded ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: isIncluded ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonLabel(PremiumPlansController controller, String productId) {
    if (controller.isSubscribed.value && controller.activeProductId.value == productId) {
      return 'Subscribed';
    }
    if (controller.isPurchasing.value) {
      return 'Processing...';
    }
    return 'Purchase';
  }

  VoidCallback? _getButtonAction(
    PremiumPlansController controller,
    String productId,
    String planTitle,
  ) {
    if (controller.isSubscribed.value && controller.activeProductId.value == productId) {
      return null;
    }
    if (controller.isPurchasing.value || controller.isLoadingProducts.value) {
      return null;
    }
    return () => controller.purchasePlan(productId, planTitle);
  }

  bool _shouldShowRestorePurchasesButton() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }
}
