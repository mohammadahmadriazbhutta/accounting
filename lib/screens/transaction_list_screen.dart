import 'package:accounting/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class TransactionListScreen extends StatefulWidget {
  final CustomerModel customer;

  const TransactionListScreen({super.key, required this.customer});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Box<TransactionModel> transactionBox;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<TransactionModel>('transactions');
  }

  @override
  Widget build(BuildContext context) {
    final customerTx = transactionBox.values
        .where((tx) => tx.customerId == widget.customer.key)
        .toList()
        .reversed
        .toList();

    final totalCredit = customerTx
        .where((tx) => tx.isCredit)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final totalDebit = customerTx
        .where((tx) => !tx.isCredit)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final balance = totalCredit - totalDebit;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("${widget.customer.name}'s Transactions"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          await Get.to(() => AddTransactionScreen(customer: widget.customer));
          setState(() {});
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Summary Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryItem("Credit", totalCredit, Colors.green),
                    _summaryItem("Debit", totalDebit, Colors.red),
                    _summaryItem(
                      "Balance",
                      balance,
                      balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            // Transaction List
            Expanded(
              child: customerTx.isEmpty
                  ? const Center(
                      child: Text(
                        "No transactions yet",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: customerTx.length,
                      itemBuilder: (context, index) {
                        final tx = customerTx[index];
                        final color = tx.isCredit
                            ? Colors.green
                            : Colors.redAccent;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: color.withOpacity(0.15),
                              child: Icon(
                                tx.isCredit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: color,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              tx.note?.isNotEmpty == true
                                  ? tx.note!
                                  : 'No note',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            trailing: Text(
                              "${tx.isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () async {
                              await Get.to(
                                () => AddTransactionScreen(
                                  customer: widget.customer,
                                  editTransaction: tx,
                                ),
                              );
                              setState(() {});
                            },
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

  Widget _summaryItem(String title, double value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
