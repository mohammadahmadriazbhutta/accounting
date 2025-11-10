import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../models/transaction_model.dart';
import '../models/customer_model.dart';

class UpcomingPaymentsScreen extends StatefulWidget {
  const UpcomingPaymentsScreen({super.key});

  @override
  State<UpcomingPaymentsScreen> createState() => _UpcomingPaymentsScreenState();
}

class _UpcomingPaymentsScreenState extends State<UpcomingPaymentsScreen> {
  final DashboardController controller = Get.find<DashboardController>();
  CustomerModel? selectedCustomer;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    if (controller.customers == null || controller.customers!.isEmpty) {
      controller.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Upcoming Payments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await controller.loadData();
              setState(() {});
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        final upcomingTransactions = controller.recentTransactions
            .where((tx) => tx.date.isAfter(now))
            .where(
              (tx) =>
                  selectedCustomer == null ||
                  tx.customerName == selectedCustomer!.name,
            )
            .toList();

        final allCustomers = controller.customers ?? [];

        final filteredCustomers = allCustomers
            .where(
              (c) =>
                  c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  c.phone.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

        double remainingAmount = selectedCustomer?.remaining ?? 0.0;

        return Column(
          children: [
            const SizedBox(height: 10),

            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search customer by name or phone...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // 🧾 Customer List
            if (filteredCustomers.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    final isSelected = selectedCustomer?.key == customer.key;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCustomer = isSelected
                              ? null
                              : filteredCustomers[index];
                        });
                      },
                      child: Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade700
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              customer.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              customer.phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No customers found.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            if (selectedCustomer != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customer: ${selectedCustomer!.name}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Remaining Payment: Rs. ${remainingAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: upcomingTransactions.isEmpty
                  ? const Center(
                      child: Text(
                        'No upcoming payments found.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: upcomingTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = upcomingTransactions[index];
                        final Color typeColor = tx.isCredit
                            ? Colors.green.shade600
                            : Colors.red.shade600;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    tx.isCredit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: typeColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.customerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Amount: Rs. ${tx.amount.toStringAsFixed(2)}',
                                      ),
                                      Text(
                                        'Due Date: ${tx.date.toLocal().toString().split(' ')[0]}',
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await _markAsDone(tx);
                                  },
                                  child: const Text(
                                    'Mark Done',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _markAsDone(TransactionModel tx) async {
    // 🟢 Update customer's remaining amount
    final customer = controller.customers?.firstWhereOrNull(
      (c) => c.name == tx.customerName,
    );
    if (customer != null) {
      customer.remaining = (customer.remaining - tx.amount).clamp(
        0.0,
        double.infinity,
      );
      await customer.save();
    }

    final doneTransaction = TransactionModel(
      amount: tx.amount,
      isCredit: tx.isCredit,
      date: DateTime.now(),
      note: "Payment cleared for ${tx.customerName}",
      customerName: tx.customerName,
      customerPhone: tx.customerPhone,
      customerId: tx.customerId,
      customerKey: tx.customerKey,
      paymentType: tx.paymentType,
    );

    await controller.addTransaction(doneTransaction);
    controller.recentTransactions.remove(tx);
    await controller.loadData();

    Get.snackbar(
      "Payment Done ✅",
      "Transaction marked completed for ${tx.customerName}",
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    setState(() {});
  }
}
