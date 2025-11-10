import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';

class CustomerController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();

  late Box<CustomerModel> customerBox;

  @override
  void onInit() {
    super.onInit();
    customerBox = Hive.box<CustomerModel>('customers');
  }

  void saveCustomer() {
    if (formKey.currentState!.validate()) {
      final newCustomer = CustomerModel(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        note: noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      customerBox.add(newCustomer);

      Get.snackbar(
        "Success",
        "Customer added successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.2),
      );

      clearFields();
      Get.back();
    }
  }

  void clearFields() {
    nameController.clear();
    phoneController.clear();
    noteController.clear();
  }
}
