import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine_model.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/common/loading_widget.dart';

class ExpiryTrackerScreen extends StatefulWidget {
  const ExpiryTrackerScreen({super.key});

  @override
  State<ExpiryTrackerScreen> createState() => _ExpiryTrackerScreenState();
}

class _ExpiryTrackerScreenState extends State<ExpiryTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MedicineProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiry Tracker',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: 'Near Expiry (${prov.nearExpiry.length})'),
            Tab(text: 'Expired (${prov.expired.length})'),
          ],
        ),
      ),
      body: prov.medicines.isEmpty
          ? const LoadingWidget()
          : TabBarView(
        controller: _tab,
        children: [
          _ExpiryList(
            medicines: prov.nearExpiry,
            emptyMessage: 'No near-expiry medicines 🎉',
            badgeColor: Colors.deepOrange,
          ),
          _ExpiryList(
            medicines: prov.expired,
            emptyMessage: 'No expired medicines 🎉',
            badgeColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _ExpiryList extends StatelessWidget {
  final List<Medicine> medicines;
  final String emptyMessage;
  final Color badgeColor;

  const _ExpiryList({
    required this.medicines,
    required this.emptyMessage,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green.withOpacity(0.6)),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicines.length,
      itemBuilder: (_, i) => _ExpiryCard(
        medicine: medicines[i],
        badgeColor: badgeColor,
      ),
    );
  }
}

class _ExpiryCard extends StatelessWidget {
  final Medicine medicine;
  final Color badgeColor;

  const _ExpiryCard({required this.medicine, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    final daysLeft = AppDateUtils.daysUntilExpiry(medicine.expiryDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication, color: badgeColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(medicine.category,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text('Expires: ${AppDateUtils.format(medicine.expiryDate)}',
                    style: TextStyle(fontSize: 12, color: badgeColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  medicine.isExpired
                      ? 'EXPIRED'
                      : '$daysLeft days',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Text('Qty: ${medicine.quantity}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}