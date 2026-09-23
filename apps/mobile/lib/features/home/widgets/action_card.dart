import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget trailing;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.text,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF16253A), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blueAccent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
