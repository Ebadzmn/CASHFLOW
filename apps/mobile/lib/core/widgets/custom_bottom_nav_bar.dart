import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      height: 72, // Slightly taller to accommodate the design
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A3353), 
            Color(0xFF0D1A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2), 
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home),
          _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long),
          _buildCenterButton(),
          _buildNavItem(2, Icons.bar_chart_outlined, Icons.bar_chart),
          _buildNavItem(3, Icons.settings_outlined, Icons.settings),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        height: 50,
        child: Icon(
          isSelected ? activeIcon : icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => onItemSelected(4), // 4 representing the center action
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          color: Color(0xFF0D1A2A), // Dark color for the plus icon
          size: 32,
        ),
      ),
    );
  }
}
