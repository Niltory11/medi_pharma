import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../core/constants/app_colors.dart';

class LowStockCard extends StatelessWidget {
  final Medicine medicine;

  const LowStockCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.warning,
          child: Icon(Icons.warning_amber, color: Colors.white, size: 20),
        ),
        title: Text(medicine.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Category: ${medicine.category}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${medicine.quantity} left',
              style: const TextStyle(
                  color: AppColors.danger, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}