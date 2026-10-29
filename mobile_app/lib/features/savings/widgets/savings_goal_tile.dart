import 'package:flutter/material.dart';
import '../../../core/models/savings_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_helper.dart';

class SavingsGoalTile extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback onDeposit;

  const SavingsGoalTile({
    super.key,
    required this.goal,
    required this.onDeposit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEmergency = goal.iconType == 'emergency';
    final accentColor = isEmergency ? const Color(0xFF10B981) : const Color(0xFF54A0FF);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEmergency ? Icons.savings_outlined : Icons.track_changes_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.primary),
                onPressed: onDeposit,
                tooltip: 'Add Funds',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            goal.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${CurrencyHelper.format(goal.currentAmount)} of ${CurrencyHelper.format(goal.targetAmount)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.percentage,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
