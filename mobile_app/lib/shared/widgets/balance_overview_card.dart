import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/providers/finance_provider.dart';
import 'sparkline_chart.dart';

class BalanceOverviewCard extends StatelessWidget {
  final double totalBalance;
  final double income;
  final double expenses;
  final double savings;
  final String percentageChange;
  final FinanceTimeframe selectedTimeframe;
  final ValueChanged<FinanceTimeframe>? onTimeframeChanged;
  final PeriodCalculation? periodCalculation;

  const BalanceOverviewCard({
    super.key,
    required this.totalBalance,
    required this.income,
    required this.expenses,
    required this.savings,
    this.percentageChange = '+12% vs last period',
    this.selectedTimeframe = FinanceTimeframe.month,
    this.onTimeframeChanged,
    this.periodCalculation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use period calculation if provided, else fall back to legacy props
    final activeIncome = periodCalculation != null ? periodCalculation!.income : income;
    final activeExpenses = periodCalculation != null ? periodCalculation!.expenses : expenses;
    final activeNet = periodCalculation != null ? periodCalculation!.net : (income - expenses);
    final isNetPositive = activeNet >= 0;
    final savingsRate = periodCalculation?.savingsRate ??
        (activeIncome > 0 ? ((activeNet / activeIncome) * 100).clamp(-100.0, 100.0) : 0.0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance header row with sparkline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyHelper.format(totalBalance),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 13,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          percentageChange,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Sparkline graph
              SparklineChart(
                data: totalBalance == 0.0
                    ? const [0, 0, 0, 0, 0, 0, 0]
                    : [
                        totalBalance * 0.7,
                        totalBalance * 0.8,
                        totalBalance * 0.75,
                        totalBalance * 0.9,
                        totalBalance * 0.85,
                        totalBalance * 0.95,
                        totalBalance,
                      ],
                width: 90,
                height: 48,
                lineColor: AppColors.primary,
                showGlow: true,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Timeframe Selector Pill Bar: [Week] [Month] [Year]
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildTimeframeTab(
                  context,
                  timeframe: FinanceTimeframe.week,
                  label: 'This Week',
                  isSelected: selectedTimeframe == FinanceTimeframe.week,
                ),
                _buildTimeframeTab(
                  context,
                  timeframe: FinanceTimeframe.month,
                  label: 'This Month',
                  isSelected: selectedTimeframe == FinanceTimeframe.month,
                ),
                _buildTimeframeTab(
                  context,
                  timeframe: FinanceTimeframe.year,
                  label: 'This Year',
                  isSelected: selectedTimeframe == FinanceTimeframe.year,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3 Metric Pills: Income (+), Expenses (-), Net Cashflow (+/-)
          Row(
            children: [
              // Income (+)
              Expanded(
                child: _buildMetricItem(
                  context,
                  title: 'Income (+)',
                  amountString: '+ ${CurrencyHelper.format(activeIncome)}',
                  icon: Icons.add_circle_outline_rounded,
                  iconColor: const Color(0xFF10B981),
                  amountColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFF10B981).withOpacity(0.12),
                ),
              ),
              const SizedBox(width: 8),

              // Expenses (-)
              Expanded(
                child: _buildMetricItem(
                  context,
                  title: 'Expense (-)',
                  amountString: '- ${CurrencyHelper.format(activeExpenses)}',
                  icon: Icons.remove_circle_outline_rounded,
                  iconColor: const Color(0xFFFF6B81),
                  amountColor: const Color(0xFFFF6B81),
                  bgColor: const Color(0xFFFF6B81).withOpacity(0.12),
                ),
              ),
              const SizedBox(width: 8),

              // Net (=)
              Expanded(
                child: _buildMetricItem(
                  context,
                  title: 'Net (+/-)',
                  amountString: '${isNetPositive ? '+' : '-'} ${CurrencyHelper.format(activeNet.abs())}',
                  icon: isNetPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  iconColor: isNetPositive ? const Color(0xFF00B894) : const Color(0xFFD63031),
                  amountColor: isNetPositive ? const Color(0xFF00B894) : const Color(0xFFD63031),
                  bgColor: (isNetPositive ? const Color(0xFF00B894) : const Color(0xFFD63031)).withOpacity(0.12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Period Net Flow summary banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isNetPositive
                  ? const Color(0xFF10B981).withOpacity(0.08)
                  : const Color(0xFFFF6B81).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isNetPositive
                    ? const Color(0xFF10B981).withOpacity(0.2)
                    : const Color(0xFFFF6B81).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isNetPositive ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                  size: 14,
                  color: isNetPositive ? const Color(0xFF10B981) : const Color(0xFFFF6B81),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isNetPositive
                        ? 'Net Cashflow: +${CurrencyHelper.format(activeNet.abs())} (${savingsRate.toStringAsFixed(0)}% saved)'
                        : 'Net Deficit: -${CurrencyHelper.format(activeNet.abs())} (Expenses exceeded income)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isNetPositive ? const Color(0xFF0F9D58) : const Color(0xFFE53935),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeTab(
    BuildContext context, {
    required FinanceTimeframe timeframe,
    required String label,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onTimeframeChanged != null) {
            onTimeframeChanged!(timeframe);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String amountString,
    required IconData icon,
    required Color iconColor,
    required Color amountColor,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardLight.withOpacity(0.4) : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amountString,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
