import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/sales_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../core/constants/app_colors.dart';
import '../sales/sales_history_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();
    final medProvider = context.watch<MedicineProvider>();

    // Last 7 days revenue
    final now = DateTime.now();
    final revenueByDay = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final total = salesProvider.sales
          .where((s) =>
      s.date.year == day.year &&
          s.date.month == day.month &&
          s.date.day == day.day)
          .fold<double>(0, (sum, s) => sum + s.grandTotal);
      return total;
    });

    final maxRevenue =
    revenueByDay.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Sales',
                    value: '${salesProvider.sales.length}',
                    icon: Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Revenue',
                    value:
                    '৳${salesProvider.sales.fold<double>(0, (s, sale) => s + sale.grandTotal).toStringAsFixed(0)}',
                    icon: Icons.monetization_on,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Medicines',
                    value: '${medProvider.medicines.length}',
                    icon: Icons.medication,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Expired',
                    value: '${medProvider.expired.length}',
                    icon: Icons.warning,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Revenue — Last 7 Days',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Bar Chart
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxRevenue * 1.2,
                  barGroups: List.generate(7, (i) {
                    final day =
                    now.subtract(Duration(days: 6 - i));
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: revenueByDay[i],
                          color: AppColors.primary,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          final day = now.subtract(
                              Duration(days: 6 - val.toInt()));
                          final labels = [
                            'Mon','Tue','Wed','Thu','Fri','Sat','Sun'
                          ];
                          return Text(
                            labels[day.weekday - 1],
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard(
      {required this.label,
        required this.value,
        required this.icon,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}