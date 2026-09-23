import 'package:flutter/material.dart';

class BlurredCardOverlay extends StatelessWidget {
  final Widget child;
  final bool isPro;
  final String title;
  final String subtitle;

  const BlurredCardOverlay({
    super.key,
    required this.child,
    required this.isPro,
    this.title = 'Audit Risk Analysis',
    this.subtitle = 'Unlock full AI compliance & risk breakdown',
  });

  @override
  Widget build(BuildContext context) {
    // Feature lock is temporarily disabled to unlock all features directly
    const bool isLockFeatureDisabled = true;

    if (isPro || isLockFeatureDisabled) {
      return child;
    }

    return Stack(
      children: [
        // The underlying card (slightly dimmed when locked)
        Opacity(
          opacity: 0.45,
          child: child,
        ),

        // Lock & Premium CTA Overlay (kept intact for when feature lock is re-enabled)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}
