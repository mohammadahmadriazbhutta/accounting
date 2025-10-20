import 'package:accounting/models/profile_model.dart';
import 'package:accounting/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/customer_model.dart';
import 'models/transaction_model.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(ProfileModelAdapter());
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<ProfileModel>('profile');
    await Hive.openBox<CustomerModel>('customers');
    await Hive.openBox<TransactionModel>('transactions');
  } catch (e, stackTrace) {
    print('Hive initialization error: $e\n$stackTrace');
    // Optionally show an error screen or exit
  }

class MyApp extends StatelessWidget {
  final ThemeController themeController;
  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Account Manager',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.orange,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.orange,
          brightness: Brightness.dark,
        ),
        themeMode: themeController.theme,
        home: const DashboardScreen(),
      ),
    );
  }
}
