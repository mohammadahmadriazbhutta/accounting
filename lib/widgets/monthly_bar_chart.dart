import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No transactions for this month"));
    }

    // ✅ Sort and safely convert
    final sortedData = List<Map<String, dynamic>>.from(data)
      ..sort((a, b) {
        final aMonth = int.tryParse(a['month'].toString()) ?? 0;
        final bMonth = int.tryParse(b['month'].toString()) ?? 0;
        return aMonth.compareTo(bMonth);
      });

    // ✅ Convert to bar groups
    final barGroups = sortedData.map((e) {
      final month = int.tryParse(e['month'].toString()) ?? 0;
      final amount = double.tryParse(e['amount'].toString()) ?? 0.0;

      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: amount >= 0 ? Colors.green : Colors.red,
            width: _calculateBarWidth(sortedData.length),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final maxY = barGroups.isNotEmpty
        ? barGroups
              .map((e) => e.barRods.first.toY)
              .reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 220,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _calculateChartWidth(context, sortedData.length),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY + (maxY * 0.2),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final month = value.toInt();
                          return Text(
                            _getMonthAbbr(month),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Adjust bar width based on number of entries
  double _calculateBarWidth(int count) {
    if (count <= 6) return 18;
    if (count <= 10) return 14;
    if (count <= 15) return 10;
    return 8; // more bars → thinner
  }

  /// ✅ Adjust total chart width dynamically
  double _calculateChartWidth(BuildContext context, int count) {
    final baseWidth = MediaQuery.of(context).size.width;
    if (count <= 6) return baseWidth;
    return count * 45; // expand only when needed
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
