import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import 'privacy_policy_controller.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final PrivacyPolicyController controller =
      Get.find<PrivacyPolicyController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPrivacyPolicies();
    });
  }

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
                      const Expanded(
                        child: Text(
                          'Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                  child: Obx(
                    () {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Text(
                            'Loading privacy policy...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (controller.privacyList.isEmpty) {
                        return Center(
                          child: Text(
                            controller.errorMessage.value.isNotEmpty
                                ? controller.errorMessage.value
                                : 'No privacy policy found',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: Colors.white,
                        onRefresh: controller.loadPrivacyPolicies,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(24.0),
                          itemCount: controller.privacyList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = controller.privacyList[index];
                            return _PrivacyListTile(
                              title: item.title,
                              onTap: () {
                                context.push(
                                  Routes.PRIVACY_DETAILS.replaceFirst(
                                    ':id',
                                    item.id,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _PrivacyListTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
