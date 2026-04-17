import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sales_provider.dart';
import '../../models/medicine_model.dart';
import '../../widgets/common/loading_widget.dart';
import 'cart_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _query = '';

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
    final cart = context.watch<SalesProvider>().cart;

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Sales', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${cart.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'New Sale'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _NewSaleTab(
              query: _query, onSearch: (v) => setState(() => _query = v)),
          const _SalesHistoryTab(),
        ],
      ),
    );
  }
}

// ── New Sale tab ──────────────────────────────────────────────────────────────

class _NewSaleTab extends StatelessWidget {
  final String query;
  final ValueChanged<String> onSearch;

  const _NewSaleTab({required this.query, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MedicineProvider>();
    final List<Medicine> list = query.isNotEmpty
        ? prov.search(query)
        : prov.medicines.where((m) => !m.isExpired && m.quantity > 0).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search medicines to sell...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: onSearch,
          ),
        ),
        Expanded(
          child: prov.medicines.isEmpty
              ? const LoadingWidget()
              : list.isEmpty
              ? const Center(child: Text('No available medicines'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _SaleMedicineCard(list[i]),
          ),
        ),
      ],
    );
  }
}

class _SaleMedicineCard extends StatefulWidget {
  final Medicine medicine;
  const _SaleMedicineCard(this.medicine);

  @override
  State<_SaleMedicineCard> createState() => _SaleMedicineCardState();
}

class _SaleMedicineCardState extends State<_SaleMedicineCard> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.medication, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.medicine.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                      '₦${widget.medicine.price.toStringAsFixed(2)} • Stock: ${widget.medicine.quantity}',
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Row(
              children: [
                _QtyBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (_qty > 1) setState(() => _qty--);
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('$_qty',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                _QtyBtn(
                    icon: Icons.add,
                    onTap: () {
                      if (_qty < widget.medicine.quantity)
                        setState(() => _qty++);
                    }),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<SalesProvider>()
                        .addToCart(widget.medicine, _qty);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${widget.medicine.name} added'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 1)));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

// ── Sales History tab ─────────────────────────────────────────────────────────

class _SalesHistoryTab extends StatelessWidget {
  const _SalesHistoryTab();

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SalesProvider>().sales;

    if (sales.isEmpty) {
      return const Center(child: Text('No sales yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sales.length,
      itemBuilder: (_, i) {
        final sale = sales[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_outlined, color: Colors.green),
            ),
            title: Text('Sale #${sale.id.substring(0, 8)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
                '${sale.date.toString().substring(0, 16)} • ${sale.soldBy}'),
            trailing: Text('₦${sale.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green)),
          ),
        );
      },
    );
  }
}