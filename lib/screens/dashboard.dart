import 'package:accounting/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';
import '../controllers/theme_controller.dart';
// import 'customer_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Box<CustomerModel> customerBox;
  late Box<TransactionModel> transactionBox;
  double totalCredit = 0;
  double totalDebit = 0;
  double netBalance = 0;
  List<TransactionModel> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    customerBox = Hive.box<CustomerModel>('customers');
    transactionBox = Hive.box<TransactionModel>('transactions');
    _calculateTotals();
  }

  void _calculateTotals() {
    final allTx = transactionBox.values.toList();

    totalCredit = allTx
        .where((t) => t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
    totalDebit = allTx
        .where((t) => !t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
    netBalance = totalCredit - totalDebit;
    recentTransactions = allTx.reversed.take(5).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                themeController.isDarkMode.value
                    ? Icons.wb_sunny_outlined
                    : Icons.dark_mode_outlined,
                color: Colors.orange,
              ),
            ),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _calculateTotals(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryCard(
                    "Total Credit",
                    totalCredit,
                    Colors.green.shade400,
                  ),
                  _buildSummaryCard(
                    "Total Debit",
                    totalDebit,
                    Colors.red.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                "Net Balance",
                netBalance,
                Colors.orange.shade400,
              ),
              const SizedBox(height: 25),

              // Customers Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "View Reports",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Get.to(() => const ReportsScreen()),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                "Recent Transactions",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),

              if (recentTransactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No recent transactions found."),
                  ),
                )
              else
                ...recentTransactions.map((tx) {
                  final color = tx.isCredit
                      ? Colors.green.shade400
                      : Colors.red.shade400;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(
                          tx.isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: color,
                        ),
                      ),
                      title: Text(tx.note),
                      subtitle: Text(
                        "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                      ),
                      trailing: Text(
                        "${tx.isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
