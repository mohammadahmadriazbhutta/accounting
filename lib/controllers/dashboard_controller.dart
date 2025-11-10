import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class DashboardController extends GetxController {
  var totalCredit = 0.0.obs;
  var totalDebit = 0.0.obs;
  var netBalance = 0.0.obs;
  var totalRemainingPayments = 0.0.obs;
  var isLoading = false.obs;
  var recentTransactions = <TransactionModel>[].obs;
  var monthlyData = <Map<String, dynamic>>[].obs;
  List<CustomerModel>? customers;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading(true);
      await _loadTransactions();
      await _loadCustomers();
      _calculateTotals();
      _calculateMonthlyData();
      _calculateRemainingPayments();
    } finally {
      isLoading(false);
    }
  }

  Future<void> _loadTransactions() async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    recentTransactions.assignAll(box.values.toList());
  }

  Future<void> _loadCustomers() async {
    final box = await Hive.openBox<CustomerModel>('customers');
    customers = box.values.toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.add(transaction);
    recentTransactions.add(transaction);
    _calculateTotals();
    _calculateMonthlyData();
    _calculateRemainingPayments();
  }

  void _calculateTotals() {
    double credit = 0.0;
    double debit = 0.0;

    for (var tx in recentTransactions) {
      if (tx.isCredit) {
        credit += tx.amount;
      } else {
        debit += tx.amount;
      }
    }

    totalCredit.value = credit;
    totalDebit.value = debit;
    netBalance.value = credit - debit;
  }

  void _calculateMonthlyData() {
    Map<String, double> monthly = {};

    for (var tx in recentTransactions) {
      final monthKey = "${tx.date.year}-${tx.date.month}";
      monthly[monthKey] = (monthly[monthKey] ?? 0) + tx.amount;
    }

    monthlyData.assignAll(
      monthly.entries.map((e) => {"month": e.key, "amount": e.value}).toList(),
    );
  }

  // ✅ NEW: Remaining Payments = sum of all customers’ remaining
  void _calculateRemainingPayments() {
    double totalRemaining = 0.0;
    for (var customer in customers ?? []) {
      totalRemaining += customer.remaining;
    }
    totalRemainingPayments.value = totalRemaining;
  }
}
