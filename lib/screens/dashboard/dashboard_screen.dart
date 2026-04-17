import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/low_stock_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../inventory/inventory_screen.dart';
import '../sales/sales_screen.dart';
import '../expiry/expiry_tracker_screen.dart';
import '../reports/report_screen.dart';
import '../../screens/auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardHome(),
    InventoryScreen(),
    SalesScreen(),
    ExpiryTrackerScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Inventory'),
          NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale),
              label: 'Sales'),
          NavigationDestination(
              icon: Icon(Icons.schedule_outlined),
              selectedIcon: Icon(Icons.schedule),
              label: 'Expiry'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Reports'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final med = context.watch<MedicineProvider>();
    final sales = context.watch<SalesProvider>();

    final todaySales = sales.sales.where((s) {
      final now = DateTime.now();
      return s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day;
    }).toList();

    final todayRevenue =
    todaySales.fold(0.0, (sum, s) => sum + s.grandTotal);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Welcome, ${auth.user?.username ?? ''}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: med.medicines.isEmpty
          ? const LoadingWidget(message: 'Loading data...')
          : RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  title: 'Total Stock',
                  value: med.medicines.length.toString(),
                  icon: Icons.medication,
                  color: Colors.teal,
                ),
                StatCard(
                  title: 'Low Stock',
                  value: med.lowStock.length.toString(),
                  icon: Icons.warning_amber,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'Near Expiry',
                  value: med.nearExpiry.length.toString(),
                  icon: Icons.schedule,
                  color: Colors.deepOrange,
                ),
                StatCard(
                  title: "Today's Sales",
                  value: '₦${todayRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Low stock alerts
            if (med.lowStock.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Low Stock Alerts',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${med.lowStock.length} items',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              ...med.lowStock.take(5).map(
                    (m) => LowStockCard(medicine: m),
              ),
            ],

            // Near expiry alerts
            if (med.nearExpiry.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Near Expiry',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${med.nearExpiry.length} items',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              ...med.nearExpiry.take(5).map(
                    (m) => LowStockCard(medicine: m),
              ),
            ],
          ],
        ),
      ),
    );
  }
}