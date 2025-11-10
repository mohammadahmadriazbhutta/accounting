import 'package:accounting/controllers/auth_controller.dart';
import 'package:accounting/screens/addcustomerscreen.dart';
import 'package:accounting/services/backup_service.dart';
import 'package:accounting/services/receipt_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/theme_controller.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/customer_list_screen.dart';
import '../screens/report_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/upcoming_payments_screen.dart';
import '../widgets/summary_card.dart';
import '../widgets/monthly_bar_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardController controller;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(DashboardController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                themeController.theme.value == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white,
              ),
            ),
            onPressed: () => themeController.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Get.to(() => const ProfileSetupScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Get.find<AuthController>().logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
        backgroundColor: Colors.blue.shade700,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 💰 Summary Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: "Credit",
                            value: controller.totalCredit.value,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: 16,
                            elevation: 6,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SummaryCard(
                            title: "Debit",
                            value: controller.totalDebit.value,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: 16,
                            elevation: 6,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: "Net Balance",
                            value: controller.netBalance.value,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB74D), Color(0xFFFB8C00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: 16,
                            elevation: 6,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SummaryCard(
                            title: "Remaining Payments",
                            value: controller.totalRemainingPayments.value,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: 16,
                            elevation: 6,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Monthly Overview",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    controller.monthlyData.isEmpty
                        ? const Center(
                            child: Text(
                              "No data for this month",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        : MonthlyBarChart(data: controller.monthlyData),

                    const SizedBox(height: 30),
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 🔹 Single Clean Quick Action Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildActionButton(
                          icon: Icons.backup,
                          label: "Backup Data",
                          color: Colors.orange,
                          onTap: () async {
                            try {
                              final path = await BackupService.createBackup();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "✅ Backup created successfully!\nSaved at: $path",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e, stack) {
                              print("❌ Backup error: $e");
                              print(stack);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("❌ Backup failed: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.person_add,
                          label: "Add Customer",
                          color: Colors.blue,
                          onTap: () => Get.to(() => const AddCustomerScreen()),
                        ),
                        _buildActionButton(
                          icon: Icons.event,
                          label: "Upcoming Payments",
                          color: Colors.teal,
                          onTap: () =>
                              Get.to(() => const UpcomingPaymentsScreen()),
                        ),
                        _buildActionButton(
                          icon: Icons.bar_chart,
                          label: "Reports",
                          color: Colors.purple,
                          onTap: () => Get.to(() => const ReportScreen()),
                        ),
                        _buildActionButton(
                          icon: Icons.people,
                          label: "Customers",
                          color: Colors.green,
                          onTap: () => Get.to(() => const CustomerListScreen()),
                        ),
                        _buildActionButton(
                          icon: Icons.receipt_long,
                          label: "Generate Receipt",
                          color: Colors.indigo,
                          onTap: () async {
                            try {
                              final path = await ReceiptService.generateReceipt(
                                controller,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "✅ Receipt generated successfully!\nSaved at: $path",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e, stack) {
                              print("❌ Receipt generation failed: $e");
                              print(stack);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "❌ Failed to generate receipt: $e",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, _darken(color, 0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
