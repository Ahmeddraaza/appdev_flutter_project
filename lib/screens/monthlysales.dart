import 'package:flutter/material.dart';
import 'dart:math';

class MonthlySalesGraphCard extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> labels;

  const MonthlySalesGraphCard({
    Key? key,
    required this.title,
    required this.data,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fallback for empty data or invalid values
    final validData = data.isNotEmpty ? data : [0.0];
    final maxDataValue = validData.reduce(max);
    final adjustedMaxValue = maxDataValue > 0 ? maxDataValue : 1; // Avoid division by zero

    return Center(
      child: Container(
        width: 340,
        height: 296,
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  "\$${validData.reduce((a, b) => a + b).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212529),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F4CB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_upward,
                        size: 12,
                        color: Color(0xFF62912C),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "5.6%",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF62912C),
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
              "Total sales this Year",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal Bar Chart
            Expanded(
              child: Center(
                child: ListView.builder(
                  itemCount: validData.length,
                  itemBuilder: (context, index) {
                    final maxBarWidth = 150; // Maximum width for bars
                    final barWidth =
                        (validData[index] / adjustedMaxValue) * maxBarWidth;
                    final colorPalette = [
                      Colors.purple,
                      Colors.blue,
                      Colors.red,
                      Colors.green,
                      Colors.orange
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              labels.isNotEmpty ? labels[index] : "N/A",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 16,
                            width: barWidth.isFinite ? barWidth : 0.0, // Handle NaN or Infinite
                            decoration: BoxDecoration(
                              color: colorPalette[index % colorPalette.length],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "\$${validData[index].toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF212529),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
