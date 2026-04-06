import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../entities/transaction_entity.dart';
import '../entities/transaction_type.dart';
import '../entities/transaction_category.dart';

class ExportTransactionsCsv {
  Future<void> call(List<TransactionEntity> transactions) async {
    if (transactions.isEmpty) return;

    debugPrint('Exporting ${transactions.length} transactions to CSV...');

    final List<List<String>> rows = [
      ['Date', 'Type', 'Category', 'Amount', 'Notes'],
    ];

    for (final t in transactions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(t.date),
        t.type == TransactionType.income ? 'Income' : 'Expense',
        t.category.label,
        t.amount.toStringAsFixed(2),
        t.notes ?? '',
      ]);
    }

    final String csvContent =
        '\uFEFF${rows.map((row) => row.map(_toCsvValue).join(',')).join('\r\n')}';

    final directory = await getTemporaryDirectory();
    final fileName = 'finn_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);

    await file.writeAsString(csvContent, flush: true);
    debugPrint('CSV file written to: $filePath');

    await Share.shareXFiles([
      XFile(file.path, mimeType: 'text/csv'),
    ], subject: 'Finn Transactions Export');
  }

  String _toCsvValue(dynamic value) {
    final String stringValue = value.toString();
    if (stringValue.contains(',') ||
        stringValue.contains('"') ||
        stringValue.contains('\n')) {
      return '"${stringValue.replaceAll('"', '""')}"';
    }
    return stringValue;
  }
}
