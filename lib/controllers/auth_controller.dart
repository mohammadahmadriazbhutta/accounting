import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  late Box<UserModel> _userBox;

  /// Currently logged-in user (reactive)
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// Simple flag for UI binding
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initBox();
  }

  /// ✅ Safely initializes the Hive box
  Future<void> _initBox() async {
    if (!Hive.isBoxOpen('users')) {
      _userBox = await Hive.openBox<UserModel>('users');
    } else {
      _userBox = Hive.box<UserModel>('users');
    }

    // Load last logged-in user if any
    final lastUser = _userBox.values.cast<UserModel?>().firstWhere(
      (u) => u?.isLoggedIn == true,
      orElse: () => null,
    );
    if (lastUser != null) {
      currentUser.value = lastUser;
      isLoggedIn.value = true;
    }
  }

  /// ✅ Registers a new user
  Future<String?> signUp(UserModel user) async {
    final exists = _userBox.values.any((u) => u.phone == user.phone);
    if (exists) return "User with this phone already exists.";

    await _userBox.add(user);
    currentUser.value = user;
    isLoggedIn.value = true;
    user.isLoggedIn = true;
    await user.save();
    return null;
  }

  /// ✅ Logs user in using phone & PIN
  Future<String?> login(String phone, String pin) async {
    try {
      final user = _userBox.values.firstWhere(
        (u) => u.phone == phone && u.pin == pin,
      );
      currentUser.value = user;
      isLoggedIn.value = true;
      user.isLoggedIn = true;
      await user.save();
      return null;
    } catch (e) {
      return "Invalid phone or PIN.";
    }
  }

  /// ✅ Resets PIN using security answer
  Future<String?> resetPin(String phone, String answer, String newPin) async {
    try {
      final user = _userBox.values.firstWhere((u) => u.phone == phone);
      if (user.answer.toLowerCase().trim() != answer.toLowerCase().trim()) {
        return "Incorrect answer.";
      }
      user.pin = newPin;
      await user.save();
      return null;
    } catch (e) {
      return "User not found.";
    }
  }

  /// ✅ Logs out and updates Hive record
  void logout() async {
    if (currentUser.value != null) {
      currentUser.value!.isLoggedIn = false;
      await currentUser.value!.save();
    }
    currentUser.value = null;
    isLoggedIn.value = false;
  }
}
