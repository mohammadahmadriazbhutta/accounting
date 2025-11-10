import 'package:accounting/controllers/auth_controller.dart';
import 'package:accounting/models/user_model.dart';
import 'package:accounting/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _answerController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  bool _obscurePin = true;
  bool _obscureConfirm = true;

  // ✅ Security question dropdown items
  final List<String> _questions = [
    "Your mother's name?",
    "Your father's name?",
    "Your childhood best friend?",
  ];

  String? _selectedQuestion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
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
                  Icon(Icons.person_add_alt_1, color: Colors.white, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "Create Your Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Set your secure 4-digit PIN",
                    style: TextStyle(color: Colors.white70),
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
                  _buildTextField(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _pinController,
                    label: "PIN",
                    icon: Icons.lock,
                    obscureText: _obscurePin,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePin = !_obscurePin),
                    ),
                    validator: (v) =>
                        v!.length < 4 ? "PIN must be at least 4 digits" : null,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _confirmPinController,
                    label: "Confirm PIN",
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirm,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) =>
                        v != _pinController.text ? "PINs do not match" : null,
                  ),
                  const SizedBox(height: 14),

                  // 🔽 Security Question Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedQuestion,
                    items: _questions
                        .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedQuestion = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Security Question",
                      prefixIcon: const Icon(
                        Icons.help_outline,
                        color: Colors.indigoAccent,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null ? "Please select a security question" : null,
                  ),

                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _answerController,
                    label: "Answer",
                    icon: Icons.question_answer,
                  ),
                  const SizedBox(height: 30),

                  // 🌟 Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Get.off(() => const LoginScreen()),
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.indigoAccent),
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

  // 🧩 Reusable Input
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ?? (v) => v!.isEmpty ? "Required" : null,
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

  // ✅ Sign Up Logic
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final newUser = UserModel(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      pin: _pinController.text.trim(),
      question: _selectedQuestion ?? '',
      answer: _answerController.text.trim(),
    );

    final error = await authController.signUp(newUser);
    if (error != null) {
      Get.snackbar("Error", error, backgroundColor: Colors.red);
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }
}
