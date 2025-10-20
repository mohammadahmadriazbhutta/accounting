import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type; // 'income' or 'expense'

  @HiveField(2)
  int? parentId; // store parent's key/id (simple approach)

  @HiveField(3)
  DateTime createdAt;

  Category({
    required this.name,
    required this.type,
    this.parentId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
