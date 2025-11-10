import 'package:accounting/screens/addcustomerscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer_model.dart';
import 'report_screen.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  Box<CustomerModel>? customerBox;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    customerBox = await Hive.openBox<CustomerModel>('customers');
    setState(() => isLoading = false);
  }

  void _deleteCustomer(CustomerModel customer) async {
    await customer.delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Customers'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const AddCustomerScreen());
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: customerBox!.listenable(),
        builder: (context, Box<CustomerModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text("No customers added yet"));
          }
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final customer = box.getAt(index)!;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(customer.name),
                  subtitle: Text("Phone: ${customer.phone}"),
                  onTap: () {
                    Get.to(() => CustomerDetailScreen(customer: customer));
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Get.to(
                          () => AddCustomerScreen(editCustomer: customer),
                        );
                        setState(() {});
                      } else if (value == 'delete') {
                        _deleteCustomer(customer);
                      } else if (value == 'report') {
                        Get.to(() => ReportScreen(customer: customer));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('View Report'),
                      ),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
