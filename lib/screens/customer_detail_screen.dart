import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerKey;
  const CustomerDetailScreen({super.key, required this.customerKey});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Box<CustomerModel> customerBox;
  late Box<TransactionModel> transactionBox;

  CustomerModel? customer;
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    customerBox = Hive.box<CustomerModel>('customers');
    transactionBox = Hive.box<TransactionModel>('transactions');
    _loadData();
  }

  void _loadData() {
    customer = customerBox.get(widget.customerKey);
    transactions = transactionBox.values
        .where((t) => t.customerKey == widget.customerKey)
        .toList()
        .reversed
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (customer == null) {
      return const Scaffold(body: Center(child: Text("Customer not found")));
    }

    return Scaffold(
      appBar: AppBar(title: Text(customer!.name), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade400,
        onPressed: () async {
          await Get.to(
            () => AddTransactionScreen(customerKey: widget.customerKey),
          );
          _loadData(); // refresh after adding
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBalanceCard(isDark),
            const SizedBox(height: 16),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text("No transactions yet"))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final color = tx.isCredit
                            ? Colors.green.shade600
                            : Colors.red.shade600;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            title: Text(
                              tx.note,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                              style: TextStyle(color: Colors.grey.shade500),
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade400,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            "${customer!.totalAmount.toStringAsFixed(2)} PKR",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
