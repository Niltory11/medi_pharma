import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';
import '../../models/sale_model.dart';
import '../../core/utils/date_utils.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  DateTimeRange? _range;

  List<Sale> _filter(List<Sale> all) {
    if (_range == null) return all;
    return all.where((s) {
      return s.date
          .isAfter(_range!.start.subtract(const Duration(seconds: 1))) &&
          s.date.isBefore(_range!.end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<SalesProvider>().sales;
    final filtered = _filter(all);
    final totalRevenue = filtered.fold(0.0, (s, e) => s + e.grandTotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            tooltip: 'Filter by date',
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _range,
              );
              if (picked != null) setState(() => _range = picked);
            },
          ),
          if (_range != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear filter',
              onPressed: () => setState(() => _range = null),
            ),
        ],
      ),
      body: Column(
        children: [
          // Summary strip
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _range != null
                          ? '${AppDateUtils.format(_range!.start)} – ${AppDateUtils.format(_range!.end)}'
                          : 'All Time',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Text('${filtered.length} transactions',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(
                  '₦${totalRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No sales in this period'))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _SaleCard(sale: filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_outlined, color: Colors.green),
        ),
        title: Text('Sale #${sale.id.substring(0, 8)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
            '${AppDateUtils.formatWithTime(sale.date)} • ${sale.soldBy}',
            style: const TextStyle(fontSize: 12)),
        trailing: Text('₦${sale.grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 15)),
        children: sale.items.map((item) {
          // items may be SaleItem or _MinimalSaleItem
          final data = (item as dynamic);
          final name = data is Map ? data['medicineName'] : data.medicine?.name ?? '';
          final qty = data is Map ? data['quantity'] : data.quantity;
          final total = data is Map ? data['total'] : data.total;

          return ListTile(
            dense: true,
            leading: const Icon(Icons.medication_outlined, size: 18),
            title: Text('$name', style: const TextStyle(fontSize: 13)),
            trailing: Text('×$qty  ₦${(total as num).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
      ),
    );
  }
}