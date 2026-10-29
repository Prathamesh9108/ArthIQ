import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/primary_button.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Wallets & Accounts'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Header
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aggregated Net Worth',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF063326),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyHelper.format(finance.totalBalance + finance.totalSavings),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF063326),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available: ${CurrencyHelper.format(finance.totalBalance)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF063326)),
                        ),
                        Text(
                          'Saved: ${CurrencyHelper.format(finance.totalSavings)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF063326)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Linked Accounts & UPI',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildAccountTile(
                context,
                title: 'Primary Account (Bank / UPI)',
                subtitle: 'Active Operating Cashflow',
                amount: finance.totalBalance,
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF54A0FF),
              ),
              const SizedBox(height: 10),
              _buildAccountTile(
                context,
                title: 'Savings Guard Vault',
                subtitle: '${finance.savingsGoals.length} Active Goals in TiDB Cloud',
                amount: finance.totalSavings,
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Link New Bank / UPI Account',
                icon: const Icon(Icons.add_link_rounded, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account aggregator flow launched via Setu / Account Aggregator')),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyHelper.format(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: amount < 0 ? AppColors.expenseRed : (isDark ? Colors.white : AppColors.textLightPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
