import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_model.dart';
import '../../providers/medicine_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import 'add_medicine_screen.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;
  const MedicineDetailScreen({super.key, required this.medicine});

  Color get _statusColor {
    if (medicine.isExpired) return AppColors.expired;
    if (medicine.isNearExpiry) return AppColors.nearExpiry;
    return AppColors.healthy;
  }

  String get _statusLabel {
    if (medicine.isExpired) return 'Expired';
    if (medicine.isNearExpiry) return 'Near Expiry';
    return 'Good';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AddMedicineScreen(medicine: medicine)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Medicine'),
                  content: Text(
                      'Are you sure you want to delete ${medicine.name}?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context
                    .read<MedicineProvider>()
                    .deleteMedicine(medicine.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, color: _statusColor, size: 14),
                  const SizedBox(width: 8),
                  Text(_statusLabel,
                      style: TextStyle(
                          color: _statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  if (!medicine.isExpired)
                    Text(
                        '  •  ${AppDateUtils.daysUntilExpiry(medicine.expiryDate)} days left',
                        style: TextStyle(color: _statusColor)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow('Name', medicine.name),
                    _DetailRow('Category', medicine.category),
                    _DetailRow('Quantity', '${medicine.quantity} pcs'),
                    _DetailRow(
                        'Price', '৳${medicine.price.toStringAsFixed(2)}'),
                    _DetailRow('Expiry Date',
                        AppDateUtils.format(medicine.expiryDate)),
                    _DetailRow('Low Stock Alert',
                        'Below ${medicine.lowStockThreshold} pcs'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}