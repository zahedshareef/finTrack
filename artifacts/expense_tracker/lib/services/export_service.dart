import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart';

class ExportService {
  Future<void> exportTransactionsCSV(
    List<AppTransaction> transactions,
    List<Account> accounts,
    List<Category> categories,
  ) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Type', 'Amount', 'Category', 'Account', 'Note'],
      ...transactions.map((t) {
        final account = accounts.firstWhere((a) => a.id == t.accountId, orElse: () => Account(id: '', name: 'Unknown', balance: 0, currency: '', colorValue: 0, type: '', createdAt: DateTime.now()));
        final category = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => Category(id: '', name: 'Unknown', icon: '', colorValue: 0, isIncome: false));
        return [
          DateFormat('yyyy-MM-dd').format(t.date),
          t.isIncome ? 'Income' : 'Expense',
          t.amount,
          category.name,
          account.name,
          t.note,
        ];
      }),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(csv.codeUnits);
    await Share.shareXFiles(
      [XFile.fromData(bytes, name: 'transactions.csv', mimeType: 'text/csv')],
      subject: 'Expense Tracker - Transactions Export',
    );
  }

  Future<void> exportTransactionsPDF(
    List<AppTransaction> transactions,
    List<Account> accounts,
    List<Category> categories,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Transaction Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Generated: ${dateFormat.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Date', 'Type', 'Amount', 'Category', 'Account', 'Note'],
            data: transactions.map((t) {
              final account = accounts.firstWhere((a) => a.id == t.accountId, orElse: () => Account(id: '', name: 'Unknown', balance: 0, currency: '', colorValue: 0, type: '', createdAt: DateTime.now()));
              final category = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => Category(id: '', name: 'Unknown', icon: '', colorValue: 0, isIncome: false));
              return [
                dateFormat.format(t.date),
                t.isIncome ? 'Income' : 'Expense',
                '${t.isIncome ? '+' : '-'}${t.amount.toStringAsFixed(2)}',
                category.name,
                account.name,
                t.note,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            border: pw.TableBorder.all(width: 0.5),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'transactions.pdf');
  }
}
