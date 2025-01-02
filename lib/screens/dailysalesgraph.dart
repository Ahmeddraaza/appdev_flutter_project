import 'package:flutter/material.dart';
import 'dart:math';

class DailySalesGraphCard extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> labels;
  final double previousWeekTotal;

  const DailySalesGraphCard({
    Key? key,
    required this.title,
    required this.data,
    required this.labels,
    required this.previousWeekTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure data is valid
    final validData = data.isNotEmpty ? data : [0.0];
    final maxDataValue = validData.reduce(max);

    // Fallback to prevent division by zero
    final adjustedMaxValue = maxDataValue > 0 ? maxDataValue : 1;

    double currentWeekTotal = validData.reduce((a, b) => a + b);
    double percentageChange =
        ((currentWeekTotal - previousWeekTotal) / (previousWeekTotal > 0 ? previousWeekTotal : 1)) * 100;

    return Center(
      child: Container(
        width: 340,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
            // Title Section
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 16),

            // Summary Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${currentWeekTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212529),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: percentageChange >= 0
                        ? const Color(0xFFE1F4CB)
                        : const Color(0xFFFFE1E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        percentageChange >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: percentageChange >= 0
                            ? const Color(0xFF62912C)
                            : const Color(0xFFFF4D4F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${percentageChange.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          color: percentageChange >= 0
                              ? const Color(0xFF62912C)
                              : const Color(0xFFFF4D4F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Subtext
            const Text(
              "Compared to the previous week",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 16),

            // Vertical Bar Chart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(validData.length, (index) {
                final barHeight = (validData[index] / adjustedMaxValue) * 120; // Scale bar height
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "\$${validData[index].toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: _getBarColor(index),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Function to provide different colors for each bar
  Color _getBarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.yellow,
    ];
    return colors[index % colors.length];
  }
}
