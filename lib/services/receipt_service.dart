import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../controllers/dashboard_controller.dart';
import '../models/transaction_model.dart';
import '../models/customer_model.dart';

class ReceiptService {
  static Future<String> generateReceipt(DashboardController controller) async {
    final pdf = pw.Document();
    final transactionsBox = await Hive.openBox<TransactionModel>(
      'transactions',
    );
    final customerBox = await Hive.openBox<CustomerModel>('customers');

    final transactions = transactionsBox.values.toList();
    final customers = customerBox.values.toList();

    final totalCredit = controller.totalCredit.value;
    final totalDebit = controller.totalDebit.value;
    final netBalance = controller.netBalance.value;
    final totalRemaining = controller.totalRemainingPayments.value;

    final date = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (pw.Context context) => [
          // Header
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'Accounting App - Full Report',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Generated on ${date.toLocal()}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          // Summary Section
          pw.SizedBox(height: 10),
          pw.Text(
            '📊 Summary Overview',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.indigo,
            ),
          ),
          pw.SizedBox(height: 8),
          _summaryRow('Total Credit', totalCredit),
          _summaryRow('Total Debit', totalDebit),
          _summaryRow('Net Balance', netBalance),
          _summaryRow('Remaining Payments', totalRemaining),

          pw.Divider(thickness: 1.5),
          pw.SizedBox(height: 12),

          // Customer Summary
          pw.Text(
            '👥 Customer Overview',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 6),
          ...customers.map(
            (c) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "${c.name} (${c.phone})",
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    "Remaining: Rs. ${c.remaining.toStringAsFixed(2)}",
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 12),
          pw.Divider(thickness: 1.5),
          pw.SizedBox(height: 8),

          // Transactions Table
          pw.Text(
            '🧾 Transactions',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.deepOrange900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Customer', 'Type', 'Amount', 'Date', 'Note'],
            data: transactions.map((tx) {
              return [
                tx.customerName,
                tx.isCredit ? 'Credit' : 'Debit',
                "Rs. ${tx.amount.toStringAsFixed(2)}",
                tx.date.toLocal().toString().split(' ')[0],
                tx.note,
              ];
            }).toList(),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.centerLeft,
          ),

          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              '© ${DateTime.now().year} Accounting App - All Rights Reserved',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/Accounting_Report_${date.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static pw.Widget _summaryRow(String label, double value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            "Rs. ${value.toStringAsFixed(2)}",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
