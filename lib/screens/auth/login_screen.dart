import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../core/constants/app_colors.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final success = auth.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      context.read<MedicineProvider>().listenToMedicines();
      context.read<SalesProvider>().listenToSales();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_pharmacy,
                      size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('Pharmacy Management',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 6),
                const Text('Sign in to continue',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textLight)),
                const SizedBox(height: 36),

                CustomTextField(
                  label: 'Username',
                  controller: _usernameController,
                 // prefixIcon: Icons.person_outline,
                  validator: (v) =>
                  v!.isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscure,
                 // prefixIcon: Icons.lock,

                  validator: (v) =>
                  v!.isEmpty ? 'Password is required' : null,
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Admin: admin / admin123   Staff: staff / staff123',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 24),

                CustomButton(
                  label: 'Login',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}