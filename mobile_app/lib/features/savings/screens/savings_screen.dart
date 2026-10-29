import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/dialogs/add_goal_dialog.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/savings_goal_tile.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finance = context.watch<FinanceProvider>();

    final totalSavings = finance.totalSavings;
    final totalTarget = finance.totalSavingsTarget;
    final percentage = totalTarget > 0 ? (totalSavings / totalTarget).clamp(0.0, 1.0) : 0.0;
    final percentageString = '${(percentage * 100).toInt()}%';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Savings Guard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Add Savings Goal',
            onPressed: () => _openAddGoalDialog(context, finance),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => finance.syncWithBackend(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Total Savings Card
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Savings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyHelper.format(totalSavings),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              percentageString,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Target: ${CurrencyHelper.format(totalTarget)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 10,
                          backgroundColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Goals Grid or Empty State
                finance.savingsGoals.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: finance.savingsGoals.length,
                        itemBuilder: (context, index) {
                          final goal = finance.savingsGoals[index];
                          return SavingsGoalTile(
                            goal: goal,
                            onDeposit: () => _depositFunds(context, finance, goal.id),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 40,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No savings goals yet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create savings goals to track your financial safety net.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _openAddGoalDialog(context, finance),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Create First Goal'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: const Color(0xFF063326),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 18),

                // Auto-save toggle card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto-save',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Save ₹${finance.savingsConfig.weeklyAutoSaveAmount.toInt()} every week',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: finance.savingsConfig.autoSaveEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          finance.toggleAutoSave(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Motivational Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryContainer.withOpacity(0.4) : const Color(0xFFE8F9F3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF063326),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Building Financial Resilience",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF063326),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Every deposit is stored securely in TiDB Cloud and helps you achieve financial independence.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textDarkSecondary : const Color(0xFF0E4A38),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Add New Goal Button
                PrimaryButton(
                  text: 'Add New Savings Goal',
                  icon: const Icon(Icons.add_task_rounded, size: 20),
                  onPressed: () => _openAddGoalDialog(context, finance),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAddGoalDialog(BuildContext context, FinanceProvider finance) {
    showDialog(
      context: context,
      builder: (ctx) => AddGoalDialog(
        onAddGoal: (title, target, initial, iconType) async {
          final success = await finance.addSavingsGoal(
            title: title,
            targetAmount: target,
            initialAmount: initial,
            iconType: iconType,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Created goal: $title' : 'Failed to save goal to TiDB'),
                backgroundColor: success ? AppColors.primaryDark : AppColors.expenseRed,
              ),
            );
          }
        },
      ),
    );
  }

  void _depositFunds(BuildContext context, FinanceProvider finance, String goalId) async {
    final success = await finance.contributeToGoal(goalId, 500);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Deposited ₹500 to savings goal!' : 'Contribution failed'),
          backgroundColor: success ? AppColors.primaryDark : AppColors.expenseRed,
        ),
      );
    }
  }
}
