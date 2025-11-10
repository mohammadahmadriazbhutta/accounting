import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 4)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  String pin;

  @HiveField(3)
  String question;

  @HiveField(4)
  String answer;

  @HiveField(5)
  bool isLoggedIn;

  UserModel({
    required this.name,
    required this.phone,
    required this.pin,
    required this.question,
    required this.answer,
    this.isLoggedIn = false,
  });
}
