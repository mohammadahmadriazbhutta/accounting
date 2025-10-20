import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/profile_model.dart';
import 'customer_list_screen.dart'; // next phase

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  bool _obscurePin = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(labelText: "Company Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _companyPhoneController,
                  decoration: const InputDecoration(labelText: "Company Phone"),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _pinController,
                  obscureText: _obscurePin,
                  decoration: InputDecoration(
                    labelText: "PIN",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePin = !_obscurePin),
                    ),
                  ),
                  validator: (v) => v!.length < 4 ? "Minimum 4 digits" : null,
                ),
                TextFormField(
                  controller: _confirmPinController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: "Confirm PIN",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) =>
                      v != _pinController.text ? "PINs do not match" : null,
                ),
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: "Security Question",
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _answerController,
                  decoration: const InputDecoration(labelText: "Answer"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _saveProfile,
                  child: const Text("Continue", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = ProfileModel(
      companyName: _companyNameController.text,
      companyPhone: _companyPhoneController.text,
      pin: _pinController.text,
      securityQuestion: _questionController.text,
      answer: _answerController.text,
    );

    final box = Hive.box<ProfileModel>('profile');
    await box.clear(); // Only one profile
    await box.add(profile);

    Get.offAll(() => const CustomerListScreen());
  }
}
