import 'dart:ui';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/customer_model.dart';

class CustomerListController extends GetxController {
  var customers = <CustomerModel>[].obs;
  var isLoading = false.obs;

  late Box<CustomerModel> customerBox;

  @override
  void onInit() {
    super.onInit();
    customerBox = Hive.box<CustomerModel>('customers');
    loadCustomers();
  }

  void loadCustomers() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400)); // small delay
    customers.assignAll(customerBox.values.toList());
    isLoading.value = false;
  }

  void deleteCustomer(CustomerModel customer) {
    customer.delete();
    loadCustomers();
    Get.snackbar(
      "Deleted",
      "Customer removed successfully",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color.fromARGB(60, 255, 0, 0),
    );
  }
}
