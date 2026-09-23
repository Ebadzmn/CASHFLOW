import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../home_controller.dart';

class TransactionContent extends StatelessWidget {
  const TransactionContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TransactionController>()
        ? Get.find<TransactionController>()
        : Get.put(TransactionController());

    return SafeArea(
      bottom: false,
      child: Column(
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
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    try {
                      Get.find<HomeController>().changeTabIndex(0);
                    } catch (e) {
                      Get.back();
                    }
                  },
                ),
                const Expanded(
                  child: Text(
                    'History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
          ),

          // Segmented Control
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Obx(
              () => _SegmentSwitch(
                selectedIndex: controller.selectedIndex.value,
                onChanged: (index) {
                  controller.changeFilter(index);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Obx(() {
              return RefreshIndicator(
                onRefresh: controller.fetchTransactions,
                color: const Color(0xFF56CCF2),
                backgroundColor: const Color(0xFF16253A),
                child: _buildHistoryList(context, controller),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    TransactionController controller,
  ) {
    if (controller.isLoading.value && controller.filteredTransactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 100, left: 10, right: 10),
        children: const [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator(color: Color(0xFF56CCF2))),
        ],
      );
    }

    if (controller.filteredTransactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 100, left: 10, right: 10),
        children: const [
          SizedBox(height: 220),
          Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 100, left: 10, right: 10),
      itemCount: controller.filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.filteredTransactions[index];
        return _TransactionItem(
          title: transaction.title,
          subtitle: transaction.subtitle,
          amount: transaction.amount,
          isIncome: transaction.isIncome,
          trailingText: transaction.trailingText,
        );
      },
    );
  }
}

class _SegmentSwitch extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentSwitch({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final segmentWidth = width / 3;

          // Calculate alignment based on index: 0 -> -1.0, 1 -> 0.0, 2 -> 1.0
          final alignment = Alignment(
            selectedIndex == 0 ? -1.0 : (selectedIndex == 1 ? 0.0 : 1.0),
            0.0,
          );

          return Stack(
            children: [
              // Animated Background Indicator
              AnimatedAlign(
                alignment: alignment,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  width: segmentWidth,
                  height: double.infinity,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16253A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Text Labels
              Row(
                children: [
                  _buildSegment('All', 0),
                  _buildSegment('Income', 1),
                  _buildSegment('Expense', 2),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegment(String text, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final String trailingText;

  const _TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16253A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF27AE60).withOpacity(0.2) // Green tint
                  : const Color(0xFFEB5757).withOpacity(0.2), // Red tint
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_outward
                  : Icons
                        .call_received, // Not exact, using standard icons for now
              // Design shows arrow up-right for income, arrow down-left for expense
              // Let's refine icons
              color: isIncome
                  ? const Color(0xFF27AE60)
                  : const Color(0xFFEB5757),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      amount,
                      style: TextStyle(
                        color: isIncome
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFEB5757),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      trailingText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
