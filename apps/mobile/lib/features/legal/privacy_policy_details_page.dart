import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'privacy_policy_controller.dart';

class PrivacyPolicyDetailsPage extends StatefulWidget {
  final String privacyId;

  const PrivacyPolicyDetailsPage({super.key, required this.privacyId});

  @override
  State<PrivacyPolicyDetailsPage> createState() =>
      _PrivacyPolicyDetailsPageState();
}

class _PrivacyPolicyDetailsPageState extends State<PrivacyPolicyDetailsPage> {
  final PrivacyPolicyController controller =
      Get.find<PrivacyPolicyController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPrivacyDetails(widget.privacyId);
    });
  }

  @override
  void dispose() {
    controller.clearSelectedPrivacy();
    super.dispose();
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
                          'Privacy Policy Details',
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
                      if (controller.detailsLoading.value) {
                        return const Center(
                          child: Text(
                            'Loading details...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final privacy = controller.selectedPrivacy.value;
                      if (privacy == null) {
                        return const Center(
                          child: Text(
                            'Failed to load details',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                privacy.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Html(
                                data: privacy.description.isNotEmpty
                                    ? privacy.description
                                    : '<p>No description available.</p>',
                                style: {
                                  'body': Style(
                                    color: Colors.white70,
                                    fontSize: FontSize(14),
                                    lineHeight: const LineHeight(1.5),
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                  'p': Style(
                                    color: Colors.white70,
                                    fontSize: FontSize(14),
                                    lineHeight: const LineHeight(1.5),
                                  ),
                                  'li': Style(
                                    color: Colors.white70,
                                    fontSize: FontSize(14),
                                    lineHeight: const LineHeight(1.5),
                                  ),
                                },
                              ),
                            ],
                          ),
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