import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final CustomerModel? customer;
  final TransactionModel? editTransaction;

  const AddTransactionScreen({Key? key, this.customer, this.editTransaction})
    : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isCredit = true;
  CustomerModel? selectedCustomer;
  PaymentType _selectedPaymentType = PaymentType.cash;

  late Box<CustomerModel> customerBox;
  late Box<TransactionModel> transactionBox;

  @override
  void initState() {
    super.initState();
    customerBox = Hive.box<CustomerModel>('customers');
    transactionBox = Hive.box<TransactionModel>('transactions');

    if (widget.customer != null) {
      selectedCustomer = widget.customer;
    }

    if (widget.editTransaction != null) {
      final tx = widget.editTransaction!;
      _amountController.text = tx.amount.toString();
      _noteController.text = tx.note;
      _isCredit = tx.isCredit;
      _selectedPaymentType = tx.paymentType;

      if (customerBox.isNotEmpty) {
        selectedCustomer = customerBox.values.firstWhere(
          (c) => c.key == tx.customerKey,
          orElse: () => customerBox.values.first,
        );
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCustomer == null) {
      Get.snackbar(
        'Error',
        'Please select or add a customer',
        backgroundColor: Colors.red.withOpacity(0.1),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final tx = TransactionModel(
      customerKey: selectedCustomer!.key,
      amount: double.parse(_amountController.text),
      isCredit: _isCredit,
      date: DateTime.now(),
      note: _noteController.text.trim(),
      customerName: selectedCustomer!.name,
      customerPhone: selectedCustomer!.phone,
      customerId: selectedCustomer!.key.toString(),
      paymentType: _selectedPaymentType,
    );

    await transactionBox.add(tx);

    Get.snackbar(
      'Transaction Added ✅',
      'Transaction for ${selectedCustomer!.name} saved successfully!',
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
      borderRadius: 12,
    );

    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed('/dashboard');
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final noteController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Add New Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogTextField('Name', nameController),
            const SizedBox(height: 8),
            _dialogTextField('Phone', phoneController, isPhone: true),
            const SizedBox(height: 8),
            _dialogTextField('Note (optional)', noteController),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please enter name and phone');
                return;
              }

              final newCustomer = CustomerModel(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                note: noteController.text.trim(),
                createdAt: DateTime.now(),
              );

              await customerBox.add(newCustomer);
              setState(() {});
              Get.back();
              Get.snackbar('Success', 'New customer added');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogTextField(
    String label,
    TextEditingController controller, {
    bool isPhone = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = customerBox.values.toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Enter Transaction Details",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Customer Dropdown
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<CustomerModel>(
                                isExpanded: true,
                                value: selectedCustomer,
                                decoration: _inputDecoration('Select Customer'),
                                items: customers
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text('${c.name} (${c.phone})'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => selectedCustomer = val),
                                validator: (val) => val == null
                                    ? 'Please select a customer'
                                    : null,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.person_add,
                              color: Colors.blue,
                            ),
                            tooltip: 'Add New Customer',
                            onPressed: _showAddCustomerDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        decoration: _inputDecoration('Amount'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter amount' : null,
                      ),
                      const SizedBox(height: 16),

                      // Payment Type Dropdown
                      DropdownButtonFormField<PaymentType>(
                        value: _selectedPaymentType,
                        decoration: _inputDecoration('Payment Type'),
                        items: PaymentType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedPaymentType = val!),
                      ),
                      const SizedBox(height: 16),

                      // Note Field
                      TextFormField(
                        controller: _noteController,
                        decoration: _inputDecoration('Note (optional)'),
                      ),
                      const SizedBox(height: 16),

                      // Credit/Debit
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Credit'),
                              value: true,
                              groupValue: _isCredit,
                              onChanged: (v) => setState(() => _isCredit = v!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Debit'),
                              value: false,
                              groupValue: _isCredit,
                              onChanged: (v) => setState(() => _isCredit = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: _saveTransaction,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Save Transaction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 1.5),
      ),
    );
  }
}
