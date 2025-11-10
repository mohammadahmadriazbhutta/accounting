import 'package:accounting/controllers/theme_controller.dart';
import 'package:accounting/controllers/auth_controller.dart';
import 'package:accounting/models/profile_model.dart';
import 'package:accounting/models/customer_model.dart';
import 'package:accounting/models/transaction_model.dart';
import 'package:accounting/models/user_model.dart';
import 'package:accounting/screens/auth/forget.dart';
import 'package:accounting/screens/auth/login.dart';
import 'package:accounting/screens/auth/signup.dart';
import 'package:accounting/screens/dashboard.dart';
import 'package:accounting/screens/report_screen.dart';
import 'package:accounting/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize GetStorage for theme & session
  await GetStorage.init();

  // ✅ Initialize Hive database
  await Hive.initFlutter();

  // ✅ Register all model adapters
  Hive.registerAdapter(ProfileModelAdapter());
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(PaymentTypeAdapter());
  Hive.registerAdapter(UserModelAdapter());

  // ✅ Open Hive boxes safely (only once)
  await _openBoxesOnce();

  // ✅ Inject controllers globally
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  runApp(const MyApp());
}

/// ✅ Ensures each Hive box is opened only once
Future<void> _openBoxesOnce() async {
  if (!Hive.isBoxOpen('profile')) {
    await Hive.openBox<ProfileModel>('profile');
  }
  if (!Hive.isBoxOpen('customers')) {
    await Hive.openBox<CustomerModel>('customers');
  }
  if (!Hive.isBoxOpen('transactions')) {
    await Hive.openBox<TransactionModel>('transactions');
  }
  if (!Hive.isBoxOpen('users')) {
    await Hive.openBox<UserModel>('users');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Accounting App',
        navigatorKey: Get.key,

        // ✅ Theme
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.indigo,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigoAccent,
            foregroundColor: Colors.white,
          ),
          fontFamily: 'Poppins',
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(primary: Colors.indigo.shade200),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.white,
          ),
          fontFamily: 'Poppins',
        ),
        themeMode: themeController.theme.value,

        // ✅ Route management
        initialRoute: authController.isLoggedIn.value ? '/dashboard' : '/login',
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/signup', page: () => const SignupScreen()),
          GetPage(name: '/forgot', page: () => const ForgotPinScreen()),
          GetPage(name: '/dashboard', page: () => const DashboardScreen()),
          GetPage(
            name: '/report',
            page: () => const ReportScreen(customer: null),
          ),
          GetPage(
            name: '/add_transaction',
            page: () {
              final CustomerModel? customer = Get.arguments;
              return AddTransactionScreen(customer: customer);
            },
          ),
        ],
      ),
    );
  }
}
