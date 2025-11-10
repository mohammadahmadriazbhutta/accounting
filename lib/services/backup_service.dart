import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';

class BackupService {
  static final List<String> boxNames = ['transactions', 'customers', 'profile'];

  static Future<String> createBackup() async {
    try {
      final Map<String, dynamic> allData = {};

      for (var name in boxNames) {
        if (!Hive.isBoxOpen(name)) continue;
        final box = Hive.box(name);
        allData[name] = box.toMap();
      }

      final jsonString = jsonEncode(allData);
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) await dir.create(recursive: true);

      final filePath =
          '${dir.path}/accounting_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      print('✅ Backup saved at: $filePath');
      return filePath;
    } catch (e, s) {
      print('❌ Backup failed: $e');
      print(s);
      rethrow;
    }
  }
}
