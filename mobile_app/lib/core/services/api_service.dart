class ApiService {
  /// AI Assistant query handler for intelligent finance recommendations
  Future<String> queryAiAssistant(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final lower = prompt.toLowerCase();

    if (lower.contains('save') || lower.contains('how much')) {
      return "Based on financial best practices (50/30/20 rule), aim to allocate at least 20% of your income to savings and emergency funds. Track your weekly savings guard goals in ArthIQ to build financial resilience!";
    } else if (lower.contains('forecast') || lower.contains('future')) {
      return "ArthIQ projects your end-of-month cashflow dynamically based on your recorded transactions in TiDB Cloud. Check the Financial Forecast tab to review your 30-day projection.";
    } else if (lower.contains('unusual') || lower.contains('dining') || lower.contains('spend')) {
      return "Tip: Review your Category Budgets to identify categories exceeding 80% limit. You can use the Rebalance tool to shift surplus funds from low-spend categories.";
    } else if (lower.contains('rebalance') || lower.contains('budget')) {
      return "You can use the 'Rebalance Budgets' feature in the Budgets screen to atomically transfer budget allocations between two categories whenever your priorities change.";
    } else {
      return "ArthIQ AI Assistant is monitoring your cashflow. Record your daily transactions and category limits to get real-time savings insights and warnings!";
    }
  }
}
