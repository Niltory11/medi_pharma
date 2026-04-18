import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'date_utils.dart';

class PdfUtils {
  static Future<void> generateReceipt(
      List<Map<String, dynamic>> items, double total, String soldBy) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('PHARMACY RECEIPT',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text('Pharmacy Management System',
                      style: const pw.TextStyle(fontSize: 12)),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.Text(
                    'Date: ${AppDateUtils.formatWithTime(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.Text('Sold By: $soldBy',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.Divider(),
                pw.SizedBox(height: 8),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration:
                      const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _cell('Medicine', bold: true),
                        _cell('Qty', bold: true),
                        _cell('Price', bold: true),
                        _cell('Total', bold: true),
                      ],
                    ),
                    ...items.map((item) {
                      return pw.TableRow(children: [
                        _cell(item['name'] as String),
                        _cell('${item['quantity']}'),
                        _cell('BDT ${(item['price'] as double).toStringAsFixed(2)}'),
                        _cell('BDT ${(item['total'] as double).toStringAsFixed(2)}'),
                      ]);
                    }),
                  ],
                ),

                pw.SizedBox(height: 16),
                pw.Divider(thickness: 1.5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('GRAND TOTAL:',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('BDT ${total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Center(
                  child: pw.Text('Thank you for your purchase!',
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      debugPrint('PDF Error: $e');
    }
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}