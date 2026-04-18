import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/medicine_model.dart';

class ExpiryTrackerScreen extends StatelessWidget {
  const ExpiryTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicineProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Expiry Tracker')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.primary,
              tabs: [
                Tab(text: 'Near Expiry (30 days)'),
                Tab(text: 'Expired'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ExpiryList(
                      medicines: provider.nearExpiry,
                      color: AppColors.nearExpiry,
                      emptyMsg: 'No near-expiry medicines 🎉'),
                  _ExpiryList(
                      medicines: provider.expired,
                      color: AppColors.expired,
                      emptyMsg: 'No expired medicines 🎉'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryList extends StatelessWidget {
  final List<Medicine> medicines;
  final Color color;
  final String emptyMsg;

  const _ExpiryList(
      {required this.medicines,
        required this.color,
        required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      return Center(
          child: Text(emptyMsg,
              style: const TextStyle(fontSize: 16, color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: medicines.length,
      itemBuilder: (_, i) {
        final m = medicines[i];
        final days = AppDateUtils.daysUntilExpiry(m.expiryDate);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(Icons.timer, color: color),
            ),
            title: Text(m.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
                '${m.category} • Exp: ${AppDateUtils.format(m.expiryDate)}'),
            trailing: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                days < 0 ? 'Expired' : '$days days',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}