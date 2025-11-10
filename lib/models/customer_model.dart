import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 1)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  String note;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String address;

  /// ✅ New field for tracking customer's remaining payment
  @HiveField(6)
  double remaining;

  CustomerModel({
    required this.name,
    required this.phone,
    this.totalAmount = 0.0,
    this.note = '',
    required this.createdAt,
    this.address = '',
    this.remaining = 0.0, // Default remaining amount
  });
}
