import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/app_colors.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SalesProvider>().sales;

    return Scaffold(
      appBar: AppBar(title: const Text('Sales History')),
      body: sales.isEmpty
          ? const Center(child: Text('No sales yet'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sales.length,
        itemBuilder: (_, i) {
          final sale = sales[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondary,
                child:
                Icon(Icons.receipt, color: Colors.white, size: 20),
              ),
              title: Text(
                  'Sale — ${AppDateUtils.formatWithTime(sale.date)}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('By: ${sale.soldBy}'),
              trailing: Text(
                  '৳${sale.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              children: sale.items
                  .map((item) => ListTile(
                dense: true,
                title: Text(item.medicine.name),
                trailing: Text(
                    '${item.quantity} × ৳${item.medicine.price.toStringAsFixed(2)} = ৳${item.total.toStringAsFixed(2)}'),
              ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}