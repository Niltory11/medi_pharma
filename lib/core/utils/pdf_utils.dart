import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/sale_item_model.dart';
import 'date_utils.dart';

class PdfUtils {
  static Future<void> generateReceipt(
      List items, double total, String soldBy) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('Pharmacy Receipt',
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.Text(
                  'Date: ${AppDateUtils.formatWithTime(DateTime.now())}'),
              pw.Text('Sold By: $soldBy'),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Items
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Medicine',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Qty',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Price',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Total',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...items.map((item) {
                    final si = item as SaleItem;
                    return pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(si.medicine.name)),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('${si.quantity}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                              '৳${si.medicine.price.toStringAsFixed(2)}')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                              '৳${si.total.toStringAsFixed(2)}')),
                    ]);
                  }),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Grand Total:',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text('৳${total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold)),
                  ]),
              pw.SizedBox(height: 16),
              pw.Center(child: pw.Text('Thank you for your purchase!')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save());
  }
}