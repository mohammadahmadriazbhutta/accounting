import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../models/customer_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Box<TransactionModel> transactionBox;
  late Box<CustomerModel> customerBox;
  int selectedMonth = DateTime.now().month;
  double totalCredit = 0;
  double totalDebit = 0;
  double balance = 0;

  List<Map<String, dynamic>> monthlyData = [];

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<TransactionModel>('transactions');
    customerBox = Hive.box<CustomerModel>('customers');
    _generateReport();
  }

  void _generateReport() {
    totalCredit = 0;
    totalDebit = 0;
    monthlyData.clear();

    final transactions = transactionBox.values.toList();

    for (var tx in transactions) {
      if (tx.date.month == selectedMonth) {
        if (tx.isCredit) {
          totalCredit += tx.amount;
        } else {
          totalDebit += tx.amount;
        }
      }
    }

    balance = totalCredit - totalDebit;

    // prepare daily breakdown
    final Map<int, double> dailyTotals = {};
    for (var tx in transactions.where((t) => t.date.month == selectedMonth)) {
      final day = tx.date.day;
      dailyTotals[day] =
          (dailyTotals[day] ?? 0) + (tx.isCredit ? tx.amount : -tx.amount);
    }

    monthlyData =
        dailyTotals.entries
            .map((e) => {'day': e.key, 'amount': e.value})
            .toList()
          ..sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final monthName = [
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
    ][selectedMonth - 1];

    return Scaffold(
      appBar: AppBar(title: const Text("Reports"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Monthly Report",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        [
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
                        ][i],
                      ),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedMonth = val);
                      _generateReport();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Credit",
                    totalCredit,
                    Colors.green.shade400,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryCard(
                    "Debit",
                    totalDebit,
                    Colors.red.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryCard("Net Balance", balance, Colors.orange.shade400),
            const SizedBox(height: 25),

            // Chart
            Expanded(
              child: monthlyData.isEmpty
                  ? const Center(child: Text("No transactions for this month"))
                  : Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTitlesWidget: (value, meta) {
                                    int day = value.toInt();
                                    if (day % 2 != 0) return const SizedBox();
                                    return Text(
                                      day.toString(),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: monthlyData
                                .map(
                                  (e) => BarChartGroupData(
                                    x: e['day'],
                                    barRods: [
                                      BarChartRodData(
                                        toY: e['amount'],
                                        color: e['amount'] >= 0
                                            ? Colors.green
                                            : Colors.red,
                                        width: 8,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
