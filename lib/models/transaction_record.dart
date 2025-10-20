import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class TransactionRecord extends HiveObject {
  @HiveField(0)
  int accountKey; // store account box key (index/key) to reference Account

  @HiveField(1)
  int? categoryKey; // reference category by key

  @HiveField(2)
  double amount;

  @HiveField(3)
  String type; // 'income' or 'expense'

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? note;

  @HiveField(6)
  bool isRecurring;

  @HiveField(7)
  String? recurringRule;

  @HiveField(8)
  List<int>? tagKeys; // list of tag keys

  @HiveField(9)
  DateTime createdAt;

  TransactionRecord({
    required this.accountKey,
    this.categoryKey,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.recurringRule,
    this.tagKeys,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
