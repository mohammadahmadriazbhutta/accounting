import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2) // 👈 keep this one as 2
class TransactionModel extends HiveObject {
  @HiveField(0)
  int customerKey;

  @HiveField(1)
  double amount;

  @HiveField(2)
  bool isCredit;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String note;

  TransactionModel({
    required this.customerKey,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.note,
  });
}
