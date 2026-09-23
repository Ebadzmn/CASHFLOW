import 'package:flutter/material.dart';

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.5), // Outer border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.15), // Top light
            Colors.white.withOpacity(0.05), // Bottom dark
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.1), Colors.transparent],
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            showCursor: !readOnly,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.transparent, // Handled by container
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
