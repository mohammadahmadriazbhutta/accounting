import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 1) // 👈 changed from 2 → 1
class CustomerModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  double totalAmount;

  CustomerModel({
    required this.name,
    required this.phone,
    this.totalAmount = 0.0,
  });
}
