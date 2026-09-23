import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import 'terms_and_conditions_controller.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final TermsAndConditionsController controller =
      Get.find<TermsAndConditionsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTerms();
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
                          'Terms & Conditions',
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
                            'Loading terms...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (controller.termsList.isEmpty) {
                        return Center(
                          child: Text(
                            controller.errorMessage.value.isNotEmpty
                                ? controller.errorMessage.value
                                : 'No terms found',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: Colors.white,
                        onRefresh: controller.loadTerms,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(24.0),
                          itemCount: controller.termsList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = controller.termsList[index];
                            return _TermListTile(
                              title: item.title,
                              onTap: () {
                                context.push(
                                  Routes.TERMS_DETAILS.replaceFirst(
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

class _TermListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _TermListTile({required this.title, required this.onTap});

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
