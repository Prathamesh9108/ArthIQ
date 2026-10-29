import 'package:flutter/material.dart';
import '../../../core/models/budget_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../shared/widgets/category_icon_badge.dart';

class CategoryBudgetTile extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;

  const CategoryBudgetTile({
    super.key,
    required this.budget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = budget.percentage;
    final percentageStr = '${(percentage * 100).toInt()}%';

    Color progressColor;
    if (percentage >= 0.90) {
      progressColor = const Color(0xFFFF6B81); // warning red/coral
    } else if (percentage >= 0.75) {
      progressColor = const Color(0xFFFECA57); // yellow warning
    } else {
      progressColor = AppColors.primary; // healthy green
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                CategoryIconBadge(category: budget.category, size: 42, iconSize: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            budget.category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${CurrencyHelper.format(budget.spent)} / ${CurrencyHelper.format(budget.limit)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                percentageStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: progressColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Linear progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 6,
                          backgroundColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
