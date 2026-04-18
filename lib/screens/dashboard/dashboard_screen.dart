import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sales_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/low_stock_card.dart';
import '../auth/login_screen.dart';
import '../inventory/inventory_screen.dart';
import '../sales/sales_screen.dart';
import '../expiry/expiry_tracker_screen.dart';
import '../reports/report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final _screens = const [
    _DashboardHome(),
    InventoryScreen(),
    SalesScreen(),
    ExpiryTrackerScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Inventory'),
          BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale_outlined),
              activeIcon: Icon(Icons.point_of_sale),
              label: 'Sales'),
          BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Expiry'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
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
    final medicines = context.watch<MedicineProvider>();
    final sales = context.watch<SalesProvider>();
    final user = context.watch<AuthProvider>().user;

    final todaySales = sales.sales.where((s) {
      final now = DateTime.now();
      return s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day;
    }).toList();

    final todayRevenue =
    todaySales.fold<double>(0, (sum, s) => sum + s.grandTotal);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Welcome, ${user?.username ?? ''}',
                style:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stat Cards
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  title: 'Total Medicines',
                  value: '${medicines.medicines.length}',
                  icon: Icons.medication,
                  color: AppColors.primary,
                ),
                StatCard(
                  title: 'Low Stock',
                  value: '${medicines.lowStock.length}',
                  icon: Icons.warning_amber,
                  color: AppColors.warning,
                ),
                StatCard(
                  title: 'Near Expiry',
                  value: '${medicines.nearExpiry.length}',
                  icon: Icons.timer_outlined,
                  color: AppColors.danger,
                ),
                StatCard(
                  title: "Today's Revenue",
                  value: '৳${todayRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: AppColors.secondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Low Stock Section
            const Text('Low Stock Medicines',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            medicines.lowStock.isEmpty
                ? const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle,
                    color: AppColors.secondary),
                title: Text('All medicines are well stocked'),
              ),
            )
                : Column(
              children: medicines.lowStock
                  .map((m) => LowStockCard(medicine: m))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}