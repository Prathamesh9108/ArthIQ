import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/components/arthiq_illustrations.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _incomeController = TextEditingController(text: '20000');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final auth = context.read<AuthProvider>();
      final income = double.tryParse(_incomeController.text) ?? 20000.0;
      final success = await auth.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        income,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: ArthIqLogoWidget(size: 56)),
                const SizedBox(height: 20),
                Text(
                  'Start Your Journey',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set your income and initial target to unlock AI insights.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Full Name',
                  hintText: 'Rahul Sharma',
                  controller: _nameController,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hintText: 'rahul@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hintText: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) => val == null || val.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Monthly Income (₹)',
                  hintText: '20000',
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Enter monthly income' : null,
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: 'Complete & Get Started',
                  isLoading: auth.isLoading,
                  onPressed: _onRegister,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
