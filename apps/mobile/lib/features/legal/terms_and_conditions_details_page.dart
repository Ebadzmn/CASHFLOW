import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'terms_and_conditions_controller.dart';

class TermsAndConditionsDetailsPage extends StatefulWidget {
  final String termId;

  const TermsAndConditionsDetailsPage({super.key, required this.termId});

  @override
  State<TermsAndConditionsDetailsPage> createState() =>
      _TermsAndConditionsDetailsPageState();
}

class _TermsAndConditionsDetailsPageState
    extends State<TermsAndConditionsDetailsPage> {
  final TermsAndConditionsController controller =
      Get.find<TermsAndConditionsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTermDetails(widget.termId);
    });
  }

  @override
  void dispose() {
    controller.clearSelectedTerm();
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
                          'Terms Details',
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

                      final term = controller.selectedTerm.value;
                      if (term == null) {
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
                                term.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Html(
                                data: term.description.isNotEmpty
                                    ? term.description
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