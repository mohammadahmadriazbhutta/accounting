import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 0)
class ProfileModel extends HiveObject {
  @HiveField(0)
  String companyName;

  @HiveField(1)
  String companyPhone;

  @HiveField(2)
  String pin;

  @HiveField(3)
  String securityQuestion;

  @HiveField(4)
  String answer;

  ProfileModel({
    required this.companyName,
    required this.companyPhone,
    required this.pin,
    required this.securityQuestion,
    required this.answer,
  });
}
