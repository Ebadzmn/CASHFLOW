import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';

class AuditReadinessPage extends StatelessWidget {
  const AuditReadinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
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
                          'Audit Readiness',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // Balance back button
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Section
                        Row(
                          children: const [
                            Text(
                              'Audit Defense Pack',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '™',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFeatures: [FontFeature.superscripts()],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Never walk into an audit alone again.',
                          style: TextStyle(
                            color: Colors.white54, // Grey subtitle
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Status Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937).withValues(
                              alpha: 0.6,
                            ), // Semi-transparent dark bg
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Shield Icon with Glow
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00C853,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons
                                      .verified_user_outlined, // Shield check icon
                                  color: Color(0xFF00E676), // Bright Green
                                  size: 64,
                                ),
                              ),
                              const SizedBox(height: 24),

                              const Text(
                                "You're Protected",
                                style: TextStyle(
                                  color: Color(0xFF00E676), // Bright Green
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Active Coverage Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00E676,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF00E676),
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Active Coverage',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Items
                        _buildActionItem(
                          icon: Icons.description_outlined,
                          title: 'IRS Notice Download',
                          showArrow: true,
                          onTap: () => context.push(
                            Routes.NOTICES,
                            extra: const <String, String>{
                              'type': 'IRS Notice',
                              'title': 'IRS Notices',
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionItem(
                          icon: Icons.add,
                          title: 'Case Status',
                          iconColor: Colors.white,
                          iconBgColor: const Color(
                            0xFF2196F3,
                          ), // Blue bg for plus icon
                          showArrow: true,
                          isGlow: true,
                          onTap: () => context.push(
                            Routes.NOTICES,
                            extra: const <String, String>{
                              'type': 'Case Status',
                              'title': 'Case Status',
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionItem(
                          icon: Icons.person_outline,
                          title: 'Expert Support',
                          iconColor: Colors.white,
                          iconBgColor: const Color(0xFF66BB6A), // Green bg
                          showArrow: true,
                          onTap: () => context.push(Routes.EXPERT_SUPPORT),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    Color iconColor = Colors.white70,
    Color? iconBgColor,
    bool showArrow = false,
    bool isGlow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor ?? Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isGlow && iconBgColor != null
                    ? [
                        BoxShadow(
                          color: iconBgColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: iconBgColor != null ? Colors.white : iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
