import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/dialogs/rebalance_budget_dialog.dart';
import '../../../shared/dialogs/add_budget_dialog.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/category_budget_tile.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finance = context.watch<FinanceProvider>();

    final totalSpent = finance.totalBudgetSpent;
    final totalBudget = finance.monthlyBudgetLimit;
    final budgetPercentage = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final percentageString = '${(budgetPercentage * 100).toInt()}%';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Add Category Budget',
            onPressed: () => _openAddBudgetDialog(context, finance),
          ),
          if (finance.budgets.length >= 2)
            IconButton(
              icon: const Icon(Icons.sync_alt_rounded, color: AppColors.primary),
              tooltip: 'Rebalance Budgets',
              onPressed: () => _openRebalanceDialog(context, finance),
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
                // Monthly Budget Hero Card
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monthly Budget',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
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
                      const SizedBox(height: 12),
                      Text(
                        '${CurrencyHelper.format(totalSpent)} / ${CurrencyHelper.format(totalBudget)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppColors.textLightPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: budgetPercentage,
                          minHeight: 10,
                          backgroundColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spent so far: ${CurrencyHelper.format(totalSpent)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                            ),
                          ),
                          Text(
                            'Remaining: ${CurrencyHelper.format(totalBudget - totalSpent > 0 ? totalBudget - totalSpent : 0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Category Budgets Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category Budgets',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openAddBudgetDialog(context, finance),
                      icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                      label: const Text(
                        'Add Budget',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Category List or Empty State
                finance.budgets.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: finance.budgets.length,
                          separatorBuilder: (context, idx) => Divider(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final budget = finance.budgets[index];
                            return CategoryBudgetTile(
                              budget: budget,
                              onTap: () => _openRebalanceDialog(context, finance),
                            );
                          },
                        ),
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
                              Icons.pie_chart_outline_rounded,
                              size: 40,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No budgets configured yet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Set category limits to track expenses in TiDB Cloud.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _openAddBudgetDialog(context, finance),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Category Budget'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: const Color(0xFF063326),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 28),

                // Manage Budgets Button
                if (finance.budgets.isNotEmpty) ...[
                  PrimaryButton(
                    text: 'Rebalance Budgets',
                    icon: const Icon(Icons.sync_alt_rounded, size: 20),
                    onPressed: () => _openRebalanceDialog(context, finance),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAddBudgetDialog(BuildContext context, FinanceProvider finance) {
    showDialog(
      context: context,
      builder: (ctx) => AddBudgetDialog(
        existingCategories: finance.budgets.map((b) => b.category).toList(),
        onSaveBudget: (category, limit) async {
          final success = await finance.setBudget(category: category, limit: limit);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success
                    ? 'Saved budget of ₹${limit.toInt()} for $category'
                    : 'Failed to save budget to TiDB'),
                backgroundColor: success ? AppColors.primaryDark : AppColors.expenseRed,
              ),
            );
          }
        },
      ),
    );
  }

  void _openRebalanceDialog(BuildContext context, FinanceProvider finance) {
    if (finance.budgets.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 2 category budgets are needed to rebalance')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => RebalanceBudgetDialog(
        budgets: finance.budgets,
        onRebalance: (from, to, amount) async {
          final success = await finance.rebalanceBudget(
            fromCategory: from,
            toCategory: to,
            amount: amount,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success
                    ? 'Rebalanced ₹${amount.toInt()} from $from to $to'
                    : 'Rebalance failed'),
                backgroundColor: success ? AppColors.primaryDark : AppColors.expenseRed,
              ),
            );
          }
        },
      ),
    );
  }
}
