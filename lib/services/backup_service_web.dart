import 'dart:convert';
import 'dart:html' as html;
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
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'accounting_backup.json')
        ..click();

      html.Url.revokeObjectUrl(url);
      print('✅ Web backup downloaded');
      return 'Web backup downloaded';
    } catch (e, s) {
      print('❌ Backup failed: $e');
      print(s);
      rethrow;
    }
  }
}
