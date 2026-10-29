import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/balance_overview_card.dart';
import '../../../shared/widgets/spending_donut_chart.dart';
import '../../../shared/widgets/custom_bottom_nav.dart';
import '../../../shared/widgets/alert_banner_card.dart';
import '../widgets/dashboard_header.dart';
import '../../transactions/widgets/transaction_item_tile.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/models/budget_model.dart';
import '../../../core/utils/currency_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, RouteNames.transactions).then((_) {
          if (mounted) setState(() => _currentIndex = 0);
        });
        break;
      case 2:
        Navigator.pushNamed(context, RouteNames.analytics).then((_) {
          if (mounted) setState(() => _currentIndex = 0);
        });
        break;
      case 3:
        Navigator.pushNamed(context, RouteNames.settings).then((_) {
          if (mounted) setState(() => _currentIndex = 0);
        });
        break;
    }
  }

  void _onAddTransaction() {
    Navigator.pushNamed(context, RouteNames.addTransaction);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final finance = context.watch<FinanceProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final user = auth.user;
    final transactions = finance.allTransactions.take(4).toList();

    // Check if any category has exceeded 80% of limit
    BudgetModel? warningBudget;
    for (final b in finance.budgets) {
      if (b.limit > 0 && (b.spent / b.limit) >= 0.8) {
        warningBudget = b;
        break;
      }
    }

    final budgetPercent = finance.monthlyBudgetLimit > 0
        ? (finance.totalBudgetSpent / finance.monthlyBudgetLimit * 100).toInt()
        : 0;
    final budgetSub = finance.budgets.isEmpty ? 'Set budgets' : '$budgetPercent% used';
    final savingsSub = finance.totalSavings > 0
        ? '${CurrencyHelper.format(finance.totalSavings)} saved'
        : 'Start saving';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: _buildDrawer(context, user?.name ?? 'Rahul Sharma', user?.email ?? 'rahul@gmail.com'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => finance.syncWithBackend(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                DashboardHeader(
                  userName: user?.name.split(' ').first ?? 'Rahul',
                  onThemeToggle: () => themeProvider.toggleTheme(),
                  onNotificationTap: () {
                    Navigator.pushNamed(context, RouteNames.notifications);
                  },
                  onMenuTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                const SizedBox(height: 16),

                // Backend Connection Status Banner
                if (!finance.isBackendConnected) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B81).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF6B81).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off_rounded, color: Color(0xFFFF6B81), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Backend Offline',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFF6B81)),
                              ),
                              Text(
                                'Cannot connect to TiDB Cloud backend server.',
                                style: TextStyle(fontSize: 11, color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => finance.syncWithBackend(),
                          child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ],

                // Total Balance Card with Week / Month / Year (+ / -) calculations
                BalanceOverviewCard(
                  totalBalance: finance.totalBalance,
                  income: finance.totalIncome,
                  expenses: finance.totalExpenses,
                  savings: finance.totalSavings,
                  selectedTimeframe: finance.selectedTimeframe,
                  onTimeframeChanged: (tf) => finance.setTimeframe(tf),
                  periodCalculation: finance.currentPeriodCalculation,
                ),
                const SizedBox(height: 18),

                // Proactive Budget Alert Banner (Dynamic from real TiDB records)
                if (warningBudget != null) ...[
                  AlertBannerCard.budgetWarning(
                    message: 'You have spent ${(warningBudget.spent / warningBudget.limit * 100).toInt()}% of your ${warningBudget.category} budget this month.',
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.budgets);
                    },
                  ),
                  const SizedBox(height: 20),
                ] else if (finance.budgets.isEmpty) ...[
                  AlertBannerCard(
                    title: 'Set Monthly Budgets',
                    message: 'Stay ahead of expenses by tracking category limits.',
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: AppColors.primary,
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.budgets);
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Quick Feature Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        context,
                        title: 'Budgets',
                        subtitle: budgetSub,
                        icon: Icons.pie_chart_outline_rounded,
                        color: const Color(0xFFFECA57),
                        onTap: () => Navigator.pushNamed(context, RouteNames.budgets),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionTile(
                        context,
                        title: 'Savings Guard',
                        subtitle: savingsSub,
                        icon: Icons.shield_outlined,
                        color: AppColors.primary,
                        onTap: () => Navigator.pushNamed(context, RouteNames.savings),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionTile(
                        context,
                        title: 'AI Assistant',
                        subtitle: 'Ask queries',
                        icon: Icons.smart_toy_outlined,
                        color: const Color(0xFF54A0FF),
                        onTap: () => Navigator.pushNamed(context, RouteNames.aiAssistant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Spending Overview Section
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spending Overview',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, RouteNames.analytics),
                            child: const Text(
                              'Analytics',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      finance.spendingBreakdown.isNotEmpty
                          ? SpendingDonutChart(data: finance.spendingBreakdown)
                          : Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.pie_chart_outline_rounded,
                                    size: 36,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No expense transactions yet',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add expenses to visualize breakdown',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.transactions);
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Transactions list card / Empty state
                transactions.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (context, idx) => Divider(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            return TransactionItemTile(
                              transaction: tx,
                              onTap: () {
                                _showTransactionDetails(context, tx);
                              },
                              onEdit: () {
                                Navigator.pushNamed(context, RouteNames.editTransaction, arguments: tx);
                              },
                              onDelete: () {
                                _confirmDeleteTransaction(context, tx);
                              },
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
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No transactions yet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textLightPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your transactions will be saved to TiDB Cloud.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _onAddTransaction,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Transaction'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: const Color(0xFF063326),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        onAddPressed: _onAddTransaction,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, String name, String email) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF101A2C) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textLightPrimary,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),

            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  _buildDrawerTile(Icons.dashboard_rounded, 'Dashboard', () => Navigator.pop(context)),
                  _buildDrawerTile(Icons.receipt_long_rounded, 'Transactions', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.transactions);
                  }),
                  _buildDrawerTile(Icons.pie_chart_rounded, 'Budgets', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.budgets);
                  }),
                  _buildDrawerTile(Icons.savings_rounded, 'Savings Guard', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.savings);
                  }),
                  _buildDrawerTile(Icons.account_balance_wallet_rounded, 'Wallets', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.wallets);
                  }),
                  _buildDrawerTile(Icons.bar_chart_rounded, 'Analytics', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.analytics);
                  }),
                  _buildDrawerTile(Icons.timeline_rounded, 'Financial Forecast', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.forecast);
                  }),
                  _buildDrawerTile(Icons.tune_rounded, 'What-If Simulator', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.simulator);
                  }),
                  _buildDrawerTile(Icons.smart_toy_rounded, 'AI Assistant', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.aiAssistant);
                  }),
                  _buildDrawerTile(Icons.settings_rounded, 'Settings', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.settings);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(icon, color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.textLightPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionModel tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Detail',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              tx.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${tx.category} • ${tx.paymentMethod}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
              ),
            ),
            if (tx.note != null && tx.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${tx.note}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Amount: ${tx.isExpense ? '-' : '+'}${CurrencyHelper.format(tx.amount)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: tx.isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
                      side: BorderSide(color: isDark ? AppColors.primary : AppColors.primaryDark),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, RouteNames.editTransaction, arguments: tx);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expenseRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDeleteTransaction(context, tx);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTransaction(BuildContext context, TransactionModel tx) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.expenseRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.expenseRed,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Transaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${tx.title}" (${CurrencyHelper.format(tx.amount)})? This will revert its effect on your balance and budget.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final finance = context.read<FinanceProvider>();
      final success = await finance.deleteTransaction(tx.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Transaction "${tx.title}" deleted from TiDB Cloud'
                : (finance.errorMessage ?? 'Failed to delete transaction from database')),
            backgroundColor: success ? AppColors.primaryDark : AppColors.expenseRed,
          ),
        );
      }
    }
  }
}
