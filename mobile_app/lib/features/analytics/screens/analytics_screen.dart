import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../shared/widgets/income_expense_bar_chart.dart';
import '../../../shared/widgets/spending_donut_chart.dart';
import '../../../shared/widgets/primary_button.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finance = context.watch<FinanceProvider>();
    final selectedTimeframe = finance.selectedTimeframe;

    final calculation = finance.getCalculationForPeriod(selectedTimeframe);
    final chartData = finance.getChartDataForTimeframe(selectedTimeframe);

    final isPositive = calculation.isPositive;
    final totalFlow = calculation.income + calculation.expenses;
    final incomeRatio = totalFlow > 0 ? (calculation.income / totalFlow) : 0.5;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Analytics & Cashflow'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe Toggle [Weekly] [Monthly] [Yearly]
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTimeframePill(
                        context,
                        title: 'Weekly',
                        isSelected: selectedTimeframe == FinanceTimeframe.week,
                        onTap: () => finance.setTimeframe(FinanceTimeframe.week),
                      ),
                    ),
                    Expanded(
                      child: _buildTimeframePill(
                        context,
                        title: 'Monthly',
                        isSelected: selectedTimeframe == FinanceTimeframe.month,
                        onTap: () => finance.setTimeframe(FinanceTimeframe.month),
                      ),
                    ),
                    Expanded(
                      child: _buildTimeframePill(
                        context,
                        title: 'Yearly',
                        isSelected: selectedTimeframe == FinanceTimeframe.year,
                        onTap: () => finance.setTimeframe(FinanceTimeframe.year),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // + / - Cashflow Calculation Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedTimeframe.fullLabel} Calculation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textLightPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPositive
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : const Color(0xFFFF6B81).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPositive ? 'Surplus' : 'Deficit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPositive ? const Color(0xFF0F9D58) : const Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Income (+) & Expense (-) side by side
                    Row(
                      children: [
                        // Inflow (+)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.add_circle_rounded,
                                      size: 15,
                                      color: Color(0xFF10B981),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Inflow (+)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '+ ${CurrencyHelper.format(calculation.income)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Outflow (-)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B81).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF6B81).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.remove_circle_rounded,
                                      size: 15,
                                      color: Color(0xFFFF6B81),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Outflow (-)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '- ${CurrencyHelper.format(calculation.expenses)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFF6B81),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Net Flow Equation Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardLight : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Net Result (+ / -)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${isPositive ? '+' : '-'} ${CurrencyHelper.format(calculation.net.abs())}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: isPositive ? const Color(0xFF0F9D58) : const Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Savings Rate',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${calculation.savingsRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: isPositive ? AppColors.primaryDark : const Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Cashflow Proportion bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 8,
                        child: Row(
                          children: [
                            Expanded(
                              flex: (incomeRatio * 100).toInt().clamp(1, 99),
                              child: Container(color: const Color(0xFF10B981)),
                            ),
                            Expanded(
                              flex: ((1 - incomeRatio) * 100).toInt().clamp(1, 99),
                              child: Container(color: const Color(0xFFFF6B81)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Expenses vs Income Chart Card
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
                          '${selectedTimeframe.label} Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textLightPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            _buildLegendDot(AppColors.primary, 'Income (+)'),
                            const SizedBox(width: 12),
                            _buildLegendDot(const Color(0xFFFF7675), 'Expense (-)'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    IncomeExpenseBarChart(
                      data: chartData,
                      height: 160,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Top Spending Categories Card
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
                    Text(
                      'Top Spending Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                      ),
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
                                  'Record expenses to see category breakdown',
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

              // Link to Financial Forecast
              PrimaryButton(
                text: 'View Financial Forecast & AI Projections',
                icon: const Icon(Icons.auto_graph_rounded, size: 20),
                onPressed: () => Navigator.pushNamed(context, RouteNames.forecast),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframePill(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? const Color(0xFF063326)
                  : (isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textDarkMuted),
        ),
      ],
    );
  }
}
