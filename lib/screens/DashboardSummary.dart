import 'package:flutter/material.dart';

class DashboardSummary extends StatelessWidget {
  final double revenue;
  final int totalOrders;
  final String revenueChange;
  final String ordersChange;

  const DashboardSummary({
    Key? key,
    required this.revenue,
    required this.totalOrders,
    required this.revenueChange,
    required this.ordersChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Adjust height for cards
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16), // Add padding
        children: [
          // Revenue Card
          _buildSummaryCard(
            title: "Revenue",
            value: "\$${revenue.toStringAsFixed(2)}",
            percentageChange: revenueChange,
            icon: Icons.monetization_on,
            backgroundColor: const Color(0xFFE1F4CB),
            iconColor: const Color(0xFF62912C),
          ),
          const SizedBox(width: 16), // Add spacing between cards

          // Total Orders Card
          _buildSummaryCard(
            title: "Total Orders",
            value: "$totalOrders",
            percentageChange: ordersChange,
            icon: Icons.shopping_cart,
            backgroundColor: const Color(0xFFDDEBFF),
            iconColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String percentageChange,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: 180, // Adjust card width
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212529),
            ),
          ),
          const SizedBox(height: 8),
          // Percentage Change
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 12,
                  color: iconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  percentageChange,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w600,
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
