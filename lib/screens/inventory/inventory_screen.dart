import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine_model.dart';
import '../../widgets/common/loading_widget.dart';
import 'add_medicine_screen.dart';
import '../../screens/inventory/medicine_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _query = '';
  String _filter = 'All';
  final _filters = ['All', 'Low Stock', 'Near Expiry', 'Expired'];

  List<Medicine> _filtered(MedicineProvider prov) {
    List<Medicine> list = _query.isNotEmpty ? prov.search(_query) : prov.medicines;
    switch (_filter) {
      case 'Low Stock':
        list = list.where((m) => m.isLowStock).toList();
        break;
      case 'Near Expiry':
        list = list.where((m) => m.isNearExpiry).toList();
        break;
      case 'Expired':
        list = list.where((m) => m.isExpired).toList();
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MedicineProvider>();
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;
    final list = _filtered(prov);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Medicine',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddMedicineScreen())),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = _filter == _filters[i];
                return ChoiceChip(
                  label: Text(_filters[i]),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = _filters[i]),
                );
              },
            ),
          ),
          Expanded(
            child: prov.medicines.isEmpty
                ? const LoadingWidget(message: 'Loading medicines...')
                : list.isEmpty
                ? const Center(child: Text('No medicines found'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) =>
                  _MedicineCard(medicine: list[i], isAdmin: isAdmin),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final bool isAdmin;

  const _MedicineCard({required this.medicine, required this.isAdmin});

  Color _statusColor() {
    if (medicine.isExpired) return Colors.red;
    if (medicine.isNearExpiry) return Colors.deepOrange;
    if (medicine.isLowStock) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.medication, color: color),
        ),
        title: Text(medicine.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${medicine.category} • Qty: ${medicine.quantity}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₦${medicine.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                medicine.isExpired
                    ? 'Expired'
                    : medicine.isNearExpiry
                    ? 'Near Expiry'
                    : medicine.isLowStock
                    ? 'Low Stock'
                    : 'OK',
                style:
                TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MedicineDetailsScreen(
                  medicine: medicine, isAdmin: isAdmin)),
        ),
      ),
    );
  }
}