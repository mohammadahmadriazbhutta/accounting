import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type; // 'cash', 'bank', 'wallet'

  @HiveField(2)
  double openingBalance;

  @HiveField(3)
  DateTime createdAt;

  Account({
    required this.name,
    required this.type,
    this.openingBalance = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
