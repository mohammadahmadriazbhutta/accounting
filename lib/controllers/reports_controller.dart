import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class ReportsController extends GetxController {
  late Box<TransactionModel> transactionBox;
  late Box<CustomerModel> customerBox;

  var selectedMonth = DateTime.now().month.obs;
  var totalCredit = 0.0.obs;
  var totalDebit = 0.0.obs;
  var balance = 0.0.obs;
  var monthlyData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    transactionBox = Hive.box<TransactionModel>('transactions');
    customerBox = Hive.box<CustomerModel>('customers');
    generateReport();
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    generateReport();
  }

  void generateReport() {
    totalCredit.value = 0;
    totalDebit.value = 0;
    monthlyData.clear();

    final transactions = transactionBox.values.toList();

    for (var tx in transactions) {
      if (tx.date.month == selectedMonth.value) {
        if (tx.isCredit) {
          totalCredit.value += tx.amount;
        } else {
          totalDebit.value += tx.amount;
        }
      }
    }

    balance.value = totalCredit.value - totalDebit.value;

    final Map<int, double> dailyTotals = {};
    for (var tx in transactions.where(
      (t) => t.date.month == selectedMonth.value,
    )) {
      final day = tx.date.day;
      dailyTotals[day] =
          (dailyTotals[day] ?? 0) + (tx.isCredit ? tx.amount : -tx.amount);
    }

    monthlyData.assignAll(
      dailyTotals.entries.map((e) => {'day': e.key, 'amount': e.value}).toList()
        ..sort((a, b) => (a['day'] as int).compareTo(b['day'] as int)),
    );
  }
}
