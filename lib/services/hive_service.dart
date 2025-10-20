import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class HiveService {
  static final Box<TransactionModel> _box = Hive.box<TransactionModel>(
    'transactions',
  );

  static List<TransactionModel> getAllTransactions() => _box.values.toList();

  static Future<void> addTransaction(TransactionModel t) async {
    await _box.add(t);
  }

  static Future<void> deleteTransaction(int index) async {
    await _box.deleteAt(index);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}
