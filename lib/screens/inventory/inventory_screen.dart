import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/medicine_model.dart';
import '../../core/utils/date_utils.dart';
import 'add_medicine_screen.dart';
import 'medicine_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicineProvider>();
    final list =
    _query.isEmpty ? provider.medicines : provider.search(_query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddMedicineScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Medicine List
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No medicines found'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: list.length,
              itemBuilder: (_, i) =>
                  _MedicineCard(medicine: list[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const _MedicineCard({required this.medicine});

  Color get _expiryColor {
    if (medicine.isExpired) return AppColors.expired;
    if (medicine.isNearExpiry) return AppColors.nearExpiry;
    return AppColors.healthy;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MedicineDetailScreen(medicine: medicine)),
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child:
          const Icon(Icons.medication, color: AppColors.primary),
        ),
        title: Text(medicine.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${medicine.category} • Exp: ${AppDateUtils.format(medicine.expiryDate)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('৳${medicine.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _expiryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${medicine.quantity} pcs',
                  style: TextStyle(
                      fontSize: 12,
                      color: _expiryColor,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}