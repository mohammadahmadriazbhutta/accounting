import 'package:hive/hive.dart';

part 'transaction_model.g.dart'; // Required for Hive code generation

// Define enum for payment types
@HiveType(typeId: 3) // 👈 Give this a unique ID different from the model
enum PaymentType {
  @HiveField(0)
  cash,
  @HiveField(1)
  check,
  @HiveField(2)
  receipt,
}

@HiveType(typeId: 2)
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

  @HiveField(5)
  String customerName;

  @HiveField(6)
  String customerPhone;

  @HiveField(7)
  String customerId;

  @HiveField(8)
  PaymentType paymentType;

  TransactionModel({
    required this.customerKey,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.note,
    required this.customerName,
    required this.customerPhone,
    required this.customerId,
    required this.paymentType,
  });
}
