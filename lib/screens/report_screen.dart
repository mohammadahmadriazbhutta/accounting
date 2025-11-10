import 'package:accounting/screens/add_transaction_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class ReportScreen extends StatefulWidget {
  final CustomerModel? customer; // optional — null means full app report

  const ReportScreen({super.key, this.customer});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Box<TransactionModel> transactionBox;
  int selectedMonth = DateTime.now().month;
  double totalCredit = 0;
  double totalDebit = 0;
  double balance = 0;
  List<Map<String, dynamic>> monthlyData = [];

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<TransactionModel>('transactions');
    _generateReport();
  }

  void _generateReport() {
    totalCredit = 0;
    totalDebit = 0;
    monthlyData.clear();

    final transactions = transactionBox.values.where((tx) {
      bool monthMatch = tx.date.month == selectedMonth;
      bool customerMatch =
          widget.customer == null || tx.customerName == widget.customer!.name;
      return monthMatch && customerMatch;
    }).toList();

    for (var tx in transactions) {
      if (tx.isCredit) {
        totalCredit += tx.amount;
      } else {
        totalDebit += tx.amount;
      }
    }

    balance = totalCredit - totalDebit;

    final Map<int, double> dailyTotals = {};
    for (var tx in transactions) {
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
    final monthNames = [
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

    return Scaffold(
      backgroundColor: const Color(0xfff7f9fc),
      appBar: AppBar(
        title: Text(
          widget.customer == null
              ? "Overall Report"
              : "${widget.customer!.name}'s Report",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0072ff), Color(0xff00c6ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Month: ${monthNames[selectedMonth - 1]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedMonth,
                      items: List.generate(12, (i) {
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text(monthNames[i]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedMonth = val);
                          _generateReport();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Credit",
                    totalCredit,
                    Colors.greenAccent.shade400,
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    "Debit",
                    totalDebit,
                    Colors.redAccent.shade400,
                    Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              "Net Balance",
              balance,
              Colors.orangeAccent.shade400,
              Icons.account_balance_wallet,
            ),
            const SizedBox(height: 25),

            // Chart
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: monthlyData.isEmpty
                    ? const Center(
                        child: Text(
                          "No transactions for this month",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                              barGroups: monthlyData.map((e) {
                                final amount = (e['amount'] ?? 0).toDouble();
                                return BarChartGroupData(
                                  x: e['day'],
                                  barRods: [
                                    BarChartRodData(
                                      toY: amount,
                                      gradient: LinearGradient(
                                        colors: amount >= 0
                                            ? [Colors.green, Colors.teal]
                                            : [Colors.red, Colors.orange],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      width: 10,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/add_transaction', arguments: widget.customer);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Transaction"),
        backgroundColor: const Color(0xff0072ff),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
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
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
