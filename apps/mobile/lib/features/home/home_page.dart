import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../core/widgets/custom_bottom_nav_bar.dart';
import 'widgets/home_header.dart';
import 'widgets/balance_chart_card.dart';
import 'widgets/audit_risk_card.dart';
import 'widgets/blurred_card_overlay.dart';
import '../profile/profile_controller.dart';
import 'widgets/action_card.dart';
import 'widgets/transaction_content.dart';
import 'widgets/stats_content.dart';

import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';
import 'widgets/settings_content.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to extend behind the bottom nav
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Obx(() => _buildBody(context, controller.selectedIndex.value)),
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          selectedIndex: controller.selectedIndex.value,
          onItemSelected: controller.changeTabIndex,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, int index) {
    switch (index) {
      case 0:
        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            color: const Color(0xFF56CCF2),
            backgroundColor: const Color(0xFF16253A),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // Space for bottom nav
              children: [
                const HomeHeader(),
                Obx(
                  () => BlurredCardOverlay(
                    isPro: controller.isPro.value,
                    child: const BalanceChartCard(),
                  ),
                ),
                Obx(() {
                  final profileController = Get.find<ProfileController>();
                  final isUnlocked = profileController.isPremiumUser;

                  return BlurredCardOverlay(
                    isPro: isUnlocked,
                    child: GestureDetector(
                      onTap: () {
                        context.push(Routes.AUDIT_READINESS);
                      },
                      child: const AuditRiskCard(),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                _buildActionList(context),
              ],
            ),
          ),
        );
      case 1:
        return const TransactionContent();
      case 2:
        return const StatsContent();
      case 3:
        return const SettingsContent();
      default:
        return const Center(
          child: Text(
            'Home Content',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
    }
  }

  Widget _buildActionList(BuildContext context) {
    return Column(
      children: [
        // Scan Receipt
        ActionCard(
          icon: Icons.receipt_long,
          text: 'Scan Receipt',
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 20,
            ),
          ),
          onTap: () {
            context.push(Routes.SCAN_RECEIPT);
          },
        ),
        // View Reports
        ActionCard(
          icon: Icons.description,
          text: 'View Reports',
          trailing: const Icon(
            Icons.bar_chart,
            color: Color(0xFFEB5757),
            size: 28,
          ),
          onTap: () {
            controller.changeTabIndex(
              2,
            ); // Navigates to StatsContent (Reports)
          },
        ),
        // Audit Readiness
        ActionCard(
          icon: Icons.check_circle_outline,
          text: 'Audit Readiness',
          trailing: const Icon(
            Icons.pie_chart,
            color: Color(0xFFF2C94C),
            size: 28,
          ),
          onTap: () {
            context.push(Routes.AUDIT_READINESS);
          },
        ),
      ],
    );
  }
}
