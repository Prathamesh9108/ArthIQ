import 'package:flutter/material.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/category_icon_badge.dart';

class TransactionItemTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const TransactionItemTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.isExpense;
    final hasActions = showActions && (onEdit != null || onDelete != null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        children: [
          // Tappable transaction info
          Expanded(
            child: InkWell(
              onTap: onTap ?? onEdit,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    CategoryIconBadge(
                      category: transaction.category,
                      size: 46,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 12),
                    // Title & Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            transaction.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Amount & Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isExpense ? '-' : '+'}${CurrencyHelper.format(transaction.amount)}',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isExpense
                                ? (isDark ? const Color(0xFFFF7675) : const Color(0xFFE55039))
                                : AppColors.incomeGreen,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppFormatters.formatDate(transaction.date),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons (Edit & Delete) separated from tile gesture
          if (hasActions) ...[
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  Tooltip(
                    message: 'Edit transaction',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.16)
                                : AppColors.primary.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: isDark ? AppColors.primary : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onEdit != null && onDelete != null) const SizedBox(width: 8),
                if (onDelete != null)
                  Tooltip(
                    message: 'Delete transaction',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFFFF7675) : const Color(0xFFE55039))
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: isDark ? const Color(0xFFFF7675) : const Color(0xFFE55039),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
