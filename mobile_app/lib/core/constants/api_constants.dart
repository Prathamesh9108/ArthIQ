class ApiConstants {
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userProfileEndpoint = '/user/profile';

  static const String transactionsEndpoint = '/transactions';
  static const String transactionDetailEndpoint = '/transactions/';
  static const String uploadReceiptEndpoint = '/transactions/receipt';

  static const String budgetsEndpoint = '/budgets';
  static const String rebalanceBudgetEndpoint = '/budgets/rebalance';

  static const String savingsGoalsEndpoint = '/savings/goals';
  static const String autoSaveConfigEndpoint = '/savings/auto-save';

  static const String forecastEndpoint = '/ai/forecast';
  static const String aiChatEndpoint = '/ai/assistant/chat';
  static const String insightsEndpoint = '/ai/insights';
  static const String simulatorEndpoint = '/ai/simulate';

  static const String syncEndpoint = '/sync';
}
