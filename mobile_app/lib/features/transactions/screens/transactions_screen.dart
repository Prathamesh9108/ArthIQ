import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../widgets/transaction_item_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  FinanceTimeframe _selectedTimeframe = FinanceTimeframe.month;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finance = context.watch<FinanceProvider>();

    final allFiltered = finance.filteredTransactions;
    final selectedTypeFilter = finance.selectedFilter;

    // Filter by timeframe
    final transactions = _selectedTimeframe == FinanceTimeframe.all
        ? allFiltered
        : allFiltered.where((t) {
            final now = DateTime.now();
            switch (_selectedTimeframe) {
              case FinanceTimeframe.week:
                final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
                return !t.date.isBefore(startOfWeek);
              case FinanceTimeframe.month:
                final startOfMonth = DateTime(now.year, now.month, 1);
                return !t.date.isBefore(startOfMonth);
              case FinanceTimeframe.year:
                final startOfYear = DateTime(now.year, 1, 1);
                return !t.date.isBefore(startOfYear);
              case FinanceTimeframe.all:
                return true;
            }
          }).toList();

    // Calculate Inflow (+), Outflow (-), Net (+/-) for currently viewed timeframe
    final periodIncome = transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final periodExpense = transactions.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
    final periodNet = periodIncome - periodExpense;
    final isNetPositive = periodNet >= 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            onPressed: () => Navigator.pushNamed(context, RouteNames.addTransaction),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timeframe Segmented Switcher [Week] [Month] [Year] [All]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildTimeTab('Week', FinanceTimeframe.week),
                    _buildTimeTab('Month', FinanceTimeframe.month),
                    _buildTimeTab('Year', FinanceTimeframe.year),
                    _buildTimeTab('All', FinanceTimeframe.all),
                  ],
                ),
              ),
            ),

            // Live (+ / -) Calculation Ribbon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    // Income (+)
                    Row(
                      children: [
                        const Icon(Icons.add_circle_rounded, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          '+${CurrencyHelper.format(periodIncome)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 14, width: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    // Expense (-)
                    Row(
                      children: [
                        const Icon(Icons.remove_circle_rounded, size: 14, color: Color(0xFFFF6B81)),
                        const SizedBox(width: 4),
                        Text(
                          '-${CurrencyHelper.format(periodExpense)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6B81),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 14, width: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    // Net (+/-)
                    Row(
                      children: [
                        Text(
                          'Net: ',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                          ),
                        ),
                        Text(
                          '${isNetPositive ? '+' : '-'}${CurrencyHelper.format(periodNet.abs())}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isNetPositive ? const Color(0xFF0F9D58) : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Type Filter Pills [All] [Expenses] [Income]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  _buildTypeFilterPill('All', selectedTypeFilter == 'All', () => finance.setFilter('All')),
                  const SizedBox(width: 8),
                  _buildTypeFilterPill('Expenses', selectedTypeFilter == 'Expenses', () => finance.setFilter('Expenses')),
                  const SizedBox(width: 8),
                  _buildTypeFilterPill('Income', selectedTypeFilter == 'Income', () => finance.setFilter('Income')),
                ],
              ),
            ),

            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: AppTextField(
                hintText: 'Search transactions...',
                controller: _searchController,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                onChanged: (val) => finance.setSearchQuery(val),
              ),
            ),

            const SizedBox(height: 4),

            // Transaction List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => finance.syncWithBackend(),
                child: transactions.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions found for ${_selectedTimeframe.fullLabel.toLowerCase()}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(context, RouteNames.addTransaction),
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
                        ],
                      )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (context, idx) => Divider(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return Dismissible(
                            key: Key(tx.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              final messenger = ScaffoldMessenger.of(context);
                              final confirmed = await _confirmDelete(tx);
                              if (confirmed == true) {
                                final success = await finance.deleteTransaction(tx.id);
                                if (!success && mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(finance.errorMessage ?? 'Failed to delete transaction from database.'),
                                      backgroundColor: AppColors.expenseRed,
                                    ),
                                  );
                                  return false;
                                }
                                return true;
                              }
                              return false;
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.expenseRed.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Transaction "${tx.title}" deleted from TiDB Cloud'),
                                  backgroundColor: AppColors.primaryDark,
                                ),
                              );
                            },
                            child: TransactionItemTile(
                              transaction: tx,
                              onTap: () => _openEditTransaction(tx),
                              onEdit: () => _openEditTransaction(tx),
                              onDelete: () => _handleDelete(tx),
                            ),
                          );
                        },
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: const Color(0xFF063326),
        child: const Icon(Icons.add_rounded, size: 28),
        onPressed: () => Navigator.pushNamed(context, RouteNames.addTransaction),
      ),
    );
  }

  Widget _buildTimeTab(String label, FinanceTimeframe timeframe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedTimeframe == timeframe;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeframe = timeframe),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF063326)
                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilterPill(String title, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.25))
                : (isDark ? AppColors.darkCard : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.primary : AppColors.primaryDark)
                    : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openEditTransaction(TransactionModel tx) {
    Navigator.pushNamed(
      context,
      RouteNames.editTransaction,
      arguments: tx,
    );
  }

  Future<void> _handleDelete(TransactionModel tx) async {
    final confirmed = await _confirmDelete(tx);
    if (confirmed == true && mounted) {
      final finance = context.read<FinanceProvider>();
      final success = await finance.deleteTransaction(tx.id);
      if (mounted) {
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

  Future<bool?> _confirmDelete(TransactionModel tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
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
  }
}
