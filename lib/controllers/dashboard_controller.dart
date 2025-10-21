import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class DashboardController extends GetxController {
  late Box<CustomerModel> customerBox;
  late Box<TransactionModel> transactionBox;

  var totalCredit = 0.0.obs;
  var totalDebit = 0.0.obs;
  var netBalance = 0.0.obs;
  var recentTransactions = <TransactionModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initBoxes();
  }

  void _initBoxes() {
    try {
      customerBox = Hive.box<CustomerModel>('customers');
      transactionBox = Hive.box<TransactionModel>('transactions');
      calculateTotals();
    } catch (e) {
      print('Dashboard Hive error: $e');
      recentTransactions.clear();
      isLoading.value = false;
    }
  }

  void calculateTotals() {
    try {
      final allTx = transactionBox.values.toList();
      totalCredit.value = allTx
          .where((t) => t.isCredit)
          .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
      totalDebit.value = allTx
          .where((t) => !t.isCredit)
          .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
      netBalance.value = totalCredit.value - totalDebit.value;
      recentTransactions.value = allTx.reversed.take(5).toList();
    } catch (e) {
      print('Calculate totals error: $e');
      totalCredit.value = 0;
      totalDebit.value = 0;
      netBalance.value = 0;
      recentTransactions.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
