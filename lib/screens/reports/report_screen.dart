import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sales_provider.dart';
import '../../core/utils/pdf_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../sales/sales_history_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _exportingSales = false;
  bool _exportingInventory = false;

  @override
  Widget build(BuildContext context) {
    final medProv = context.watch<MedicineProvider>();
    final salesProv = context.watch<SalesProvider>();

    final today = DateTime.now();
    final todaySales = salesProv.sales.where((s) =>
    s.date.year == today.year &&
        s.date.month == today.month &&
        s.date.day == today.day);
    final todayRevenue = todaySales.fold(0.0, (s, e) => s + e.grandTotal);
    final totalRevenue =
    salesProv.sales.fold(0.0, (s, e) => s + e.grandTotal);

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Revenue summary
          _SectionHeader('Revenue Summary'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: "Today's Revenue",
                  value: '₦${todayRevenue.toStringAsFixed(2)}',
                  icon: Icons.today,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Total Revenue',
                  value: '₦${totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Total Sales',
                  value: salesProv.sales.length.toString(),
                  icon: Icons.receipt_long_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: "Today's Txns",
                  value: todaySales.length.toString(),
                  icon: Icons.point_of_sale_outlined,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Inventory summary
          _SectionHeader('Inventory Summary'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Total Medicines',
                  value: medProv.medicines.length.toString(),
                  icon: Icons.medication,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Low Stock',
                  value: medProv.lowStock.length.toString(),
                  icon: Icons.warning_amber,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Near Expiry',
                  value: medProv.nearExpiry.length.toString(),
                  icon: Icons.schedule,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Expired',
                  value: medProv.expired.length.toString(),
                  icon: Icons.error_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Actions
          _SectionHeader('Export Reports'),
          const SizedBox(height: 12),
          CustomButton(
            label: 'View Sales History',
            icon: Icons.history,
            color: Colors.indigo,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Export Sales PDF',
            icon: Icons.picture_as_pdf,
            color: Colors.green,
            isLoading: _exportingSales,
            onPressed: () async {
              setState(() => _exportingSales = true);
              await PdfUtils.generateSalesReport(salesProv.sales);
              if (mounted) setState(() => _exportingSales = false);
            },
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Export Inventory PDF',
            icon: Icons.picture_as_pdf,
            color: Colors.teal,
            isLoading: _exportingInventory,
            onPressed: () async {
              setState(() => _exportingInventory = true);
              await PdfUtils.generateInventoryReport(medProv.medicines);
              if (mounted) setState(() => _exportingInventory = false);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}