import 'package:accounting/screens/customer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? editCustomer;

  const AddCustomerScreen({Key? key, this.editCustomer}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editCustomer != null) {
      _nameController.text = widget.editCustomer!.name;
      _phoneController.text = widget.editCustomer!.phone;
      _noteController.text = widget.editCustomer!.note;
      _addressController.text = widget.editCustomer!.address;
    }
  }

  Future<void> saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final box = await Hive.openBox<CustomerModel>('customers');
    CustomerModel savedCustomer;

    if (widget.editCustomer != null) {
      widget.editCustomer!
        ..name = _nameController.text.trim()
        ..phone = _phoneController.text.trim()
        ..note = _noteController.text.trim()
        ..address = _addressController.text.trim();
      await widget.editCustomer!.save();
      savedCustomer = widget.editCustomer!;

      Get.snackbar(
        "Updated ✅",
        "Customer details updated successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 12,
      );
    } else {
      final newCustomer = CustomerModel(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        note: _noteController.text.trim(),
        address: _addressController.text.trim(),
        createdAt: DateTime.now(),
      );
      final key = await box.add(newCustomer);
      savedCustomer = box.get(key)!;

      Get.snackbar(
        "Saved ✅",
        "Customer added successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 12,
      );
    }

    await Future.delayed(const Duration(seconds: 1));
    Get.off(() => CustomerDetailScreen(customer: savedCustomer));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editCustomer != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Customer' : 'Add Customer',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          isEditing
                              ? "Update Customer Details"
                              : "Enter Customer Details",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 25),

                        _buildTextField(
                          controller: _nameController,
                          label: "Customer Name",
                          icon: Icons.person,
                          validator: (value) => value == null || value.isEmpty
                              ? "Enter name"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) => value == null || value.isEmpty
                              ? "Enter phone number"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _addressController,
                          label: "Address",
                          icon: Icons.location_on,
                          validator: (value) => value == null || value.isEmpty
                              ? "Enter address"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _noteController,
                          label: "Notes (optional)",
                          icon: Icons.note,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          onPressed: saveCustomer,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            isEditing ? 'Update' : 'Save',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 1.5),
        ),
      ),
    );
  }
}
