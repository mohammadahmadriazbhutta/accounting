import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../screens/report_screen.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final controller = Get.put(DashboardController());

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: "Total Credit",
                      value: controller.totalCredit.value,
                      color: Colors.green.shade400,
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      title: "Total Debit",
                      value: controller.totalDebit.value,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SummaryCard(
                title: "Net Balance",
                value: controller.netBalance.value,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 25),
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
              if (controller.recentTransactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No recent transactions found."),
                  ),
                )
              else
                ...controller.recentTransactions.map((tx) {
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
                      title: Text(tx.note ?? 'No note'),
                      subtitle: Text(
                        tx.date != null
                            ? "${tx.date!.day}/${tx.date!.month}/${tx.date!.year}"
                            : 'No date',
                      ),
                      trailing: Text(
                        "${tx.isCredit ? '+' : '-'}${tx.amount?.toStringAsFixed(2) ?? '0.00'}",
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
        );
      }),
    );
  }
}
