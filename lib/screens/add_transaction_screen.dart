import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../models/customer_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final int customerKey;
  const AddTransactionScreen({super.key, required this.customerKey});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool isCredit = true;

  late Box<TransactionModel> transactionBox;
  late Box<CustomerModel> customerBox;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<TransactionModel>('transactions');
    customerBox = Hive.box<CustomerModel>('customers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ToggleButtons(
                isSelected: [isCredit, !isCredit],
                onPressed: (index) => setState(() => isCredit = index == 0),
                borderRadius: BorderRadius.circular(12),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Credit (+)"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Debit (-)"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter amount" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Note",
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    "Save Transaction",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveTransaction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final note = _noteController.text.trim().isEmpty
        ? (isCredit ? "Credit" : "Debit")
        : _noteController.text.trim();

    final transaction = TransactionModel(
      customerKey: widget.customerKey,
      amount: amount,
      isCredit: isCredit,
      date: DateTime.now(),
      note: note,
    );

    transactionBox.add(transaction);

    // update customer total
    final customer = customerBox.get(widget.customerKey);
    if (customer != null) {
      customer.totalAmount += isCredit ? amount : -amount;
      customer.save();
    }

    Get.snackbar(
      "Saved",
      "Transaction added successfully!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade400,
      colorText: Colors.white,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      Get.back();
    });
  }
}
