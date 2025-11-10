import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final LinearGradient? gradient; // ✅ new (optional)
  final Color? color; // still supports simple color
  final double borderRadius;
  final double elevation;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.gradient, // optional gradient
    this.color, // optional color
    this.borderRadius = 12,
    this.elevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient, // ✅ use gradient if available
          color: gradient == null ? color ?? Colors.blueGrey.shade100 : null,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
