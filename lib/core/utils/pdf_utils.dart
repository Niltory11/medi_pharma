import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../models/sale_model.dart';
import '../../models/medicine_model.dart';
import 'date_utils.dart';

class PdfUtils {
  /// Generate a sales report PDF and open it
  static Future<void> generateSalesReport(List<Sale> sales) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Pharmacy Sales Report',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text('Generated: ${AppDateUtils.formatWithTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            pw.Divider(),
          ],
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: ['Sale ID', 'Date', 'Sold By', 'Items', 'Total (₦)'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.teal100),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerRight,
            },
            data: sales.map((s) => [
              s.id.substring(0, 8),
              AppDateUtils.format(s.date),
              s.soldBy,
              s.items.length.toString(),
              s.grandTotal.toStringAsFixed(2),
            ]).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Grand Total: ₦${sales.fold(0.0, (sum, s) => sum + s.grandTotal).toStringAsFixed(2)}',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    await _saveAndOpen(pdf, 'sales_report');
  }

  /// Generate an inventory / stock report PDF and open it
  static Future<void> generateInventoryReport(
      List<Medicine> medicines) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Pharmacy Inventory Report',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text('Generated: ${AppDateUtils.formatWithTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            pw.Divider(),
          ],
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Name',
              'Category',
              'Qty',
              'Price (₦)',
              'Expiry',
              'Status'
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.teal100),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
            },
            data: medicines.map((m) {
              String status = 'OK';
              if (m.isExpired) status = 'EXPIRED';
              else if (m.isNearExpiry) status = 'NEAR EXPIRY';
              else if (m.isLowStock) status = 'LOW STOCK';

              return [
                m.name,
                m.category,
                m.quantity.toString(),
                m.price.toStringAsFixed(2),
                AppDateUtils.format(m.expiryDate),
                status,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await _saveAndOpen(pdf, 'inventory_report');
  }

  static Future<void> _saveAndOpen(pw.Document pdf, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}