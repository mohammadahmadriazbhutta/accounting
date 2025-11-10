import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../models/customer_model.dart';

class ReportController extends GetxController {
  late Box<TransactionModel> transactionBox;
  late Box<CustomerModel> customerBox;

  RxInt selectedMonth = DateTime.now().month.obs;
  RxDouble totalCredit = 0.0.obs;
  RxDouble totalDebit = 0.0.obs;
  RxDouble balance = 0.0.obs;
  RxList<Map<String, dynamic>> monthlyData = <Map<String, dynamic>>[].obs;

  final List<String> monthNames = const [
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

  @override
  void onInit() {
    super.onInit();
    transactionBox = Hive.box<TransactionModel>('transactions');
    customerBox = Hive.box<CustomerModel>('customers');
    _generateReport();
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    _generateReport();
  }

  void _generateReport() {
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

    monthlyData.value =
        dailyTotals.entries
            .map((e) => {'day': e.key, 'amount': e.value})
            .toList()
          ..sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
  }
}
