import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MonthlyFinanceData {
  final String month;
  final double income;
  final double expense;

  const MonthlyFinanceData({
    required this.month,
    required this.income,
    required this.expense,
  });

  String get label => month;
}

class IncomeExpenseBarChart extends StatelessWidget {
  final List<MonthlyFinanceData> data;
  final double height;

  const IncomeExpenseBarChart({
    super.key,
    required this.data,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final maxVal = data.fold(1.0, (prev, e) => max(prev, max(e.income, e.expense)));

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final incomeHeight = (item.income / maxVal) * (height - 35);
          final expenseHeight = (item.expense / maxVal) * (height - 35);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Income Bar (Mint Green)
                  Container(
                    width: 10,
                    height: max(4.0, incomeHeight),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Expense Bar (Coral / Orange)
                  Container(
                    width: 10,
                    height: max(4.0, expenseHeight),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7675),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.month,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
