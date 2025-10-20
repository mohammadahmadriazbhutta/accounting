import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/profile_model.dart';
import 'profile_setup_screen.dart';
import 'customer_list_screen.dart'; // We'll create later

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    await Future.delayed(const Duration(seconds: 2)); // small splash delay
    final box = Hive.box<ProfileModel>('profile');
    if (box.isNotEmpty) {
      Get.off(() => const CustomerListScreen());
    } else {
      Get.off(() => const ProfileSetupScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Text(
          "Account Manager",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
