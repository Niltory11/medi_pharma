import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_model.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sales_provider.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/common/custom_button.dart';
import 'add_medicine_screen.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;
  final bool isAdmin;

  const MedicineDetailsScreen(
      {super.key, required this.medicine, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color statusColor = Colors.green;
    String statusLabel = 'In Stock';
    if (medicine.isExpired) {
      statusColor = Colors.red;
      statusLabel = 'Expired';
    } else if (medicine.isNearExpiry) {
      statusColor = Colors.deepOrange;
      statusLabel = 'Near Expiry';
    } else if (medicine.isLowStock) {
      statusColor = Colors.orange;
      statusLabel = 'Low Stock';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        AddMedicineScreen(existing: medicine)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.medication,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medicine.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(medicine.category,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(statusLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details
          _DetailCard(children: [
            _DetailRow(label: 'Price', value: '₦${medicine.price.toStringAsFixed(2)}'),
            _DetailRow(label: 'Quantity', value: '${medicine.quantity} units'),
            _DetailRow(
                label: 'Low Stock Threshold',
                value: '${medicine.lowStockThreshold} units'),
            _DetailRow(
                label: 'Expiry Date',
                value: AppDateUtils.format(medicine.expiryDate)),
            _DetailRow(
                label: 'Days Until Expiry',
                value: medicine.isExpired
                    ? 'Expired'
                    : '${AppDateUtils.daysUntilExpiry(medicine.expiryDate)} days'),
          ]),
          const SizedBox(height: 20),

          // Add to cart
          if (!medicine.isExpired && medicine.quantity > 0)
            CustomButton(
              label: 'Add to Cart',
              icon: Icons.shopping_cart_outlined,
              onPressed: () {
                context
                    .read<SalesProvider>()
                    .addToCart(medicine, 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${medicine.name} added to cart'),
                      backgroundColor: Colors.green),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Medicine'),
        content:
        Text('Are you sure you want to delete "${medicine.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
              const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<MedicineProvider>().deleteMedicine(medicine.id);
      Navigator.pop(context);
    }
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i < children.length - 1)
                Divider(height: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withOpacity(0.15)),
            ],
          );
        }),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}