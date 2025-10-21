import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../widgets/summary_card.dart';
import '../widgets/monthly_bar_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());
    const monthNames = [
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
      appBar: AppBar(title: const Text("Reports"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + Month Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Monthly Report",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  DropdownButton<int>(
                    value: controller.selectedMonth.value,
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text(monthNames[i]),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) controller.changeMonth(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: "Credit",
                      value: controller.totalCredit.value,
                      color: Colors.green.shade400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SummaryCard(
                      title: "Debit",
                      value: controller.totalDebit.value,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SummaryCard(
                title: "Net Balance",
                value: controller.balance.value,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 25),

              // Chart
              Expanded(child: MonthlyBarChart(data: controller.monthlyData)),
            ],
          );
        }),
      ),
    );
  }
}
