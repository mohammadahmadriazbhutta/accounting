import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/profile_model.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();

    try {
      await Hive.initFlutter();
      Hive.registerAdapter(ProfileModelAdapter());
      Hive.registerAdapter(CustomerModelAdapter());
      Hive.registerAdapter(TransactionModelAdapter());

      await Hive.openBox<ProfileModel>('profile');
      await Hive.openBox<CustomerModel>('customers');
      await Hive.openBox<TransactionModel>('transactions');
    } catch (e) {
      print('Hive initialization error: $e');
    }
  }
}
