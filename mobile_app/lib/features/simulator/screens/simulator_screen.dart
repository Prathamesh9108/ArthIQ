import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/primary_button.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  double _diningCut = 20.0; // 20%
  double _shoppingCut = 15.0; // 15%
  double _additionalAutoSave = 500.0; // weekly
  bool _includeVacation = false;
  final double _vacationCost = 15000.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finance = context.watch<FinanceProvider>();

    // Baseline from real database records
    final diningSpent = finance.getCategorySpent('Food & Dining');
    final shoppingSpent = finance.getCategorySpent('Shopping');
    final baseDining = diningSpent > 0
        ? diningSpent
        : (finance.budgets.any((b) => b.category == 'Food & Dining')
            ? finance.budgets.firstWhere((b) => b.category == 'Food & Dining').limit
            : 0.0);
    final baseShopping = shoppingSpent > 0
        ? shoppingSpent
        : (finance.budgets.any((b) => b.category == 'Shopping')
            ? finance.budgets.firstWhere((b) => b.category == 'Shopping').limit
            : 0.0);

    // Calculations
    final monthlyDiningSavings = baseDining * (_diningCut / 100);
    final monthlyShoppingSavings = baseShopping * (_shoppingCut / 100);
    final monthlyAutoSaveBoost = _additionalAutoSave * 4;
    final totalMonthlyExtraSavings = monthlyDiningSavings + monthlyShoppingSavings + monthlyAutoSaveBoost;
    final sixMonthSavings = (totalMonthlyExtraSavings * 6) - (_includeVacation ? _vacationCost : 0.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('What-If Budget Simulator'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result Card
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Simulated 6-Month Net Extra Savings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF063326),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyHelper.format(sixMonthSavings),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Color(0xFF063326),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Extra Monthly Buffer: +${CurrencyHelper.format(totalMonthlyExtraSavings)}/mo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0A4F3C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Adjust Spending Scenarios',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Scenario 1: Dining out cut
              _buildSliderCard(
                title: 'Cut Dining Out by ${_diningCut.toInt()}%',
                subtitle: 'Saves ${CurrencyHelper.format(monthlyDiningSavings)} / month',
                value: _diningCut,
                min: 0,
                max: 50,
                divisions: 10,
                onChanged: (val) => setState(() => _diningCut = val),
              ),
              const SizedBox(height: 14),

              // Scenario 2: Shopping cut
              _buildSliderCard(
                title: 'Cut Shopping by ${_shoppingCut.toInt()}%',
                subtitle: 'Saves ${CurrencyHelper.format(monthlyShoppingSavings)} / month',
                value: _shoppingCut,
                min: 0,
                max: 50,
                divisions: 10,
                onChanged: (val) => setState(() => _shoppingCut = val),
              ),
              const SizedBox(height: 14),

              // Scenario 3: Auto-save increment
              _buildSliderCard(
                title: 'Boost Weekly Auto-save by ₹${_additionalAutoSave.toInt()}',
                subtitle: 'Additional ${CurrencyHelper.format(monthlyAutoSaveBoost)} saved monthly',
                value: _additionalAutoSave,
                min: 0,
                max: 2000,
                divisions: 20,
                onChanged: (val) => setState(() => _additionalAutoSave = val),
              ),
              const SizedBox(height: 14),

              // Scenario 4: Vacation toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Vacation Trip (₹15,000)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textLightPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Simulate one-time holiday expense impact',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _includeVacation,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _includeVacation = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Apply Strategy to My Budgets',
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Simulation applied! Budget targets and auto-save updated.'),
                      backgroundColor: AppColors.primaryDark,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textLightPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
