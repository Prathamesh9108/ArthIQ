import 'package:flutter/material.dart';
import '../../core/models/budget_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_helper.dart';

class RebalanceBudgetDialog extends StatefulWidget {
  final List<BudgetModel> budgets;
  final Function(String fromCategory, String toCategory, double amount) onRebalance;

  const RebalanceBudgetDialog({
    super.key,
    required this.budgets,
    required this.onRebalance,
  });

  @override
  State<RebalanceBudgetDialog> createState() => _RebalanceBudgetDialogState();
}

class _RebalanceBudgetDialogState extends State<RebalanceBudgetDialog> {
  late String _fromCategory;
  late String _toCategory;
  double _amount = 500.0;

  @override
  void initState() {
    super.initState();
    _fromCategory = widget.budgets.isNotEmpty ? widget.budgets.first.category : '';
    _toCategory = widget.budgets.length > 1 ? widget.budgets[1].category : _fromCategory;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.sync_alt_rounded, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'Rebalance Budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shift spending limits from surplus categories to prevent overspending.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Transfer From',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _fromCategory,
              dropdownColor: isDark ? AppColors.darkCard : Colors.white,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
              items: widget.budgets.map((b) {
                return DropdownMenuItem(
                  value: b.category,
                  child: Text('${b.category} (Limit: ${CurrencyHelper.format(b.limit)})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _fromCategory = val);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Transfer To',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _toCategory,
              dropdownColor: isDark ? AppColors.darkCard : Colors.white,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
              items: widget.budgets.map((b) {
                return DropdownMenuItem(
                  value: b.category,
                  child: Text('${b.category} (Limit: ${CurrencyHelper.format(b.limit)})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _toCategory = val);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Amount to Shift: ${CurrencyHelper.format(_amount)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textLightPrimary,
              ),
            ),
            Slider(
              value: _amount,
              min: 100,
              max: 2000,
              divisions: 19,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _amount = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
          ),
        ),
        ElevatedButton(
          onPressed: _fromCategory == _toCategory
              ? null
              : () {
                  widget.onRebalance(_fromCategory, _toCategory, _amount);
                  Navigator.pop(context);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: const Color(0xFF063326),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Apply Rebalance'),
        ),
      ],
    );
  }
}
