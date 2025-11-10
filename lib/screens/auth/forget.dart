import 'package:accounting/controllers/auth_controller.dart';
import 'package:accounting/models/user_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPinController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  bool _obscurePin = true;

  String? _securityQuestion;
  bool _questionLoaded = false;

  Future<void> _fetchQuestion() async {
    final box = Hive.box<UserModel>('users');
    final user = box.values.firstWhereOrNull(
      (u) => u.phone == _phoneController.text.trim(),
    );

    if (user != null) {
      setState(() {
        _securityQuestion = user.question;
        _questionLoaded = true;
      });
    } else {
      setState(() {
        _securityQuestion = null;
        _questionLoaded = false;
      });
      Get.snackbar(
        "Error",
        "No user found with this phone number",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Reset PIN",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🌈 Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Icon(Icons.lock_reset, color: Colors.white, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "Forgot Your PIN?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Answer your security question to reset your PIN",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🧾 Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // 🔹 Phone Field with Fetch Button
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _fetchQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Fetch"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 🔹 Auto-Fetched Question (Read-only)
                  if (_questionLoaded && _securityQuestion != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.help_outline,
                            color: Colors.indigoAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _securityQuestion!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_questionLoaded) const SizedBox(height: 14),

                  // 🔹 Security Answer Field
                  _buildTextField(
                    controller: _answerController,
                    label: "Security Answer",
                    icon: Icons.question_answer,
                  ),

                  const SizedBox(height: 14),

                  // 🔹 New PIN Field
                  _buildTextField(
                    controller: _newPinController,
                    label: "New PIN",
                    icon: Icons.lock,
                    obscureText: _obscurePin,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePin = !_obscurePin;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🌟 Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _resetPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Reset PIN",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧩 Reusable Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigoAccent),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ✅ Reset PIN Logic
  Future<void> _resetPin() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await authController.resetPin(
      _phoneController.text.trim(),
      _answerController.text.trim(),
      _newPinController.text.trim(),
    );

    if (error != null) {
      Get.snackbar("Error", error, backgroundColor: Colors.red);
    } else {
      Get.back();
      Get.snackbar(
        "Success",
        "PIN Reset Successfully",
        backgroundColor: Colors.green,
      );
    }
  }
}
