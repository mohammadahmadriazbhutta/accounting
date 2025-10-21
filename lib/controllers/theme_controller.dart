import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';
  RxBool isDarkMode = false.obs;
  Rx<ThemeMode> theme = ThemeMode.system.obs;

  @override
  void onInit() {
    try {
      isDarkMode.value = _storage.read(_key) ?? false;
      theme.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      print('ThemeController init error: $e');
      isDarkMode.value = false;
      theme.value = ThemeMode.light;
    }
    super.onInit();
  }

  void toggleTheme() {
    try {
      isDarkMode.value = !isDarkMode.value;
      theme.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
      Get.changeThemeMode(theme.value);
      _storage.write(_key, isDarkMode.value);
    } catch (e) {
      print('Theme toggle error: $e');
    }
  }
}
