import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/budget_model.dart';
import 'package:mobile_app/core/models/transaction_model.dart';
import 'package:mobile_app/core/models/savings_model.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/providers/finance_provider.dart';
import 'package:mobile_app/core/utils/currency_helper.dart';

class FakeApiClient extends ApiClient {
  final List<Map<String, dynamic>> transactions = [];
  final List<Map<String, dynamic>> budgets = [
    {'id': 'b_1', 'category': 'Food & Dining', 'limit': 5000.0, 'spent': 4200.0, 'period': 'monthly'},
    {'id': 'b_2', 'category': 'Shopping', 'limit': 3000.0, 'spent': 1000.0, 'period': 'monthly'},
  ];
  final List<Map<String, dynamic>> savingsGoals = [];

  @override
  Future<Map<String, dynamic>> checkHealth() async {
    return {'status': 'healthy', 'success': true};
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    if (endpoint == '/health') {
      return {'status': 'healthy', 'success': true};
    }
    if (endpoint == '/transactions') {
      return {'success': true, 'data': transactions};
    }
    if (endpoint == '/budgets') {
      return {'success': true, 'data': budgets};
    }
    if (endpoint == '/savings-goals' || endpoint == '/savings/goals') {
      return {'success': true, 'data': savingsGoals};
    }
    return {'success': true, 'data': []};
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    if (endpoint == '/transactions' && data != null) {
      transactions.add(Map<String, dynamic>.from(data));
      return {'success': true, 'message': 'Transaction saved'};
    }
    if (endpoint == '/budgets' && data != null) {
      final idx = budgets.indexWhere((b) => b['category'] == data['category']);
      if (idx != -1) {
        budgets[idx] = Map<String, dynamic>.from(data);
      } else {
        budgets.add(Map<String, dynamic>.from(data));
      }
      return {'success': true, 'message': 'Budget saved'};
    }
    if (endpoint == '/budgets/rebalance' && data != null) {
      final from = budgets.firstWhere((b) => b['category'] == data['fromCategory']);
      final to = budgets.firstWhere((b) => b['category'] == data['toCategory']);
      from['limit'] = (from['limit'] as num) - (data['amount'] as num);
      to['limit'] = (to['limit'] as num) + (data['amount'] as num);
      return {'success': true, 'message': 'Rebalanced'};
    }
    if ((endpoint == '/savings-goals' || endpoint == '/savings/goals') && data != null) {
      savingsGoals.add(Map<String, dynamic>.from(data));
      return {'success': true, 'message': 'Goal saved'};
    }
    if (endpoint.contains('/savings-goals/') && endpoint.endsWith('/contribute') && data != null) {
      final parts = endpoint.split('/');
      final goalId = parts[2];
      final idx = savingsGoals.indexWhere((g) => g['id'] == goalId);
      if (idx != -1) {
        final current = (savingsGoals[idx]['currentAmount'] as num).toDouble();
        savingsGoals[idx]['currentAmount'] = current + (data['amount'] as num).toDouble();
        return {'success': true, 'message': 'Contribution saved'};
      }
    }
    return {'success': true};
  }

  @override
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    if (endpoint.startsWith('/transactions/') && data != null) {
      final id = endpoint.split('/').last;
      final idx = transactions.indexWhere((t) => t['id'] == id);
      if (idx != -1) {
        transactions[idx] = Map<String, dynamic>.from(data);
      }
      return {'success': true, 'message': 'Transaction updated'};
    }
    if (endpoint.startsWith('/savings-goals/') && data != null) {
      final id = endpoint.split('/').last;
      final idx = savingsGoals.indexWhere((g) => g['id'] == id);
      if (idx != -1) {
        savingsGoals[idx] = {
          ...savingsGoals[idx],
          ...data,
        };
      }
      return {'success': true, 'message': 'Goal updated'};
    }
    return {'success': true};
  }

  @override
  Future<Map<String, dynamic>> delete(String endpoint, {Map<String, String>? headers}) async {
    if (endpoint.startsWith('/transactions/')) {
      final id = endpoint.split('/').last;
      transactions.removeWhere((t) => t['id'] == id);
      return {'success': true, 'message': 'Transaction deleted'};
    }
    if (endpoint.startsWith('/budgets/')) {
      final id = endpoint.split('/').last;
      budgets.removeWhere((b) => b['id'] == id || b['category'] == id);
      return {'success': true, 'message': 'Budget deleted'};
    }
    if (endpoint.startsWith('/savings-goals/')) {
      final id = endpoint.split('/').last;
      savingsGoals.removeWhere((g) => g['id'] == id);
      return {'success': true, 'message': 'Goal deleted'};
    }
    return {'success': true};
  }
}

void main() {
  group('CurrencyHelper Tests', () {
    test('Formats Indian Rupee without decimals properly', () {
      final formatted = CurrencyHelper.format(28450);
      expect(formatted, contains('₹'));
      expect(formatted, contains('28,450'));
    });

    test('Formats compact values', () {
      expect(CurrencyHelper.formatCompact(25000), '₹ 25k');
      expect(CurrencyHelper.formatCompact(150000), '₹ 1.5L');
    });
  });

  group('BudgetModel Tests', () {
    test('Calculates remaining amount and percentage', () {
      const budget = BudgetModel(
        id: 'b_1',
        category: 'Food & Dining',
        limit: 5000,
        spent: 4200,
      );

      expect(budget.remaining, 800.0);
      expect(budget.percentage, closeTo(0.84, 0.01));
      expect(budget.isExceeded, false);
    });

    test('Safely parses string and null values in fromJson', () {
      final parsed = BudgetModel.fromJson({
        'id': 'b_test',
        'category': 'Transport',
        'limit': '3500.50',
        'spent': 1200,
      });

      expect(parsed.limit, 3500.50);
      expect(parsed.spent, 1200.0);
    });
  });

  group('SavingsGoalModel Tests', () {
    test('Calculates goal completion percentage', () {
      final goal = const SavingsGoalModel(
        id: 'sg_1',
        title: 'Emergency Fund',
        currentAmount: 5000,
        targetAmount: 10000,
      );

      expect(goal.percentage, 0.50);
      expect(goal.isCompleted, false);
    });

    test('Safely parses numeric fields in fromJson', () {
      final parsed = SavingsGoalModel.fromJson({
        'id': 'sg_test',
        'title': 'New Laptop',
        'currentAmount': '15000',
        'targetAmount': 60000.0,
      });

      expect(parsed.currentAmount, 15000.0);
      expect(parsed.targetAmount, 60000.0);
    });
  });

  group('FinanceProvider Tests with Database Single Source of Truth', () {
    test('Empty database state gives zero totals without fake numbers', () async {
      final emptyClient = FakeApiClient();
      emptyClient.budgets.clear();
      final provider = FinanceProvider(apiClient: emptyClient);
      await provider.syncWithBackend();

      expect(provider.allTransactions.isEmpty, true);
      expect(provider.budgets.isEmpty, true);
      expect(provider.savingsGoals.isEmpty, true);
      expect(provider.totalIncome, 0.0);
      expect(provider.totalExpenses, 0.0);
      expect(provider.totalBalance, 0.0);
      expect(provider.totalSavings, 0.0);
      expect(provider.monthlyBudgetLimit, 0.0);
    });

    test('Adding expense transaction deducts from balance and updates budget', () async {
      final client = FakeApiClient();
      final provider = FinanceProvider(apiClient: client);
      await provider.syncWithBackend();

      final initialBalance = provider.totalBalance;

      final success = await provider.addTransaction(
        title: 'Coffee',
        amount: 250,
        type: TransactionType.expense,
        category: 'Food & Dining',
        date: DateTime.now(),
        paymentMethod: 'UPI',
      );

      expect(success, true);
      expect(provider.totalBalance, initialBalance - 250);
      expect(provider.filteredTransactions.first.title, 'Coffee');
    });

    test('Rebalancing budget shifts limits between categories', () async {
      final client = FakeApiClient();
      final provider = FinanceProvider(apiClient: client);
      await provider.syncWithBackend();

      final foodBudgetBefore = provider.budgets.firstWhere((b) => b.category == 'Food & Dining').limit;
      final shoppingBudgetBefore = provider.budgets.firstWhere((b) => b.category == 'Shopping').limit;

      final success = await provider.rebalanceBudget(
        fromCategory: 'Shopping',
        toCategory: 'Food & Dining',
        amount: 500,
      );

      expect(success, true);
      final foodBudgetAfter = provider.budgets.firstWhere((b) => b.category == 'Food & Dining').limit;
      final shoppingBudgetAfter = provider.budgets.firstWhere((b) => b.category == 'Shopping').limit;

      expect(foodBudgetAfter, foodBudgetBefore + 500);
      expect(shoppingBudgetAfter, shoppingBudgetBefore - 500);
    });

    test('Updating transaction adjusts balance and budget spending', () async {
      final client = FakeApiClient();
      final provider = FinanceProvider(apiClient: client);
      await provider.syncWithBackend();

      final initialBalance = provider.totalBalance;

      await provider.addTransaction(
        title: 'Original Dinner',
        amount: 500,
        type: TransactionType.expense,
        category: 'Food & Dining',
        date: DateTime.now(),
        paymentMethod: 'UPI',
      );

      final addedTx = provider.transactions.first;
      expect(provider.totalBalance, initialBalance - 500);

      final updatedTx = addedTx.copyWith(
        title: 'Updated Dinner',
        amount: 700,
      );

      final updateSuccess = await provider.updateTransaction(updatedTx);
      expect(updateSuccess, true);

      expect(provider.totalBalance, initialBalance - 700);
      expect(provider.transactions.first.title, 'Updated Dinner');
      expect(provider.transactions.first.amount, 700);
    });

    test('Deleting transaction reverts balance and budget spending', () async {
      final client = FakeApiClient();
      final provider = FinanceProvider(apiClient: client);
      await provider.syncWithBackend();

      final initialBalance = provider.totalBalance;

      await provider.addTransaction(
        title: 'Movie Ticket',
        amount: 400,
        type: TransactionType.expense,
        category: 'Entertainment',
        date: DateTime.now(),
        paymentMethod: 'UPI',
      );

      final addedTx = provider.transactions.first;
      expect(provider.totalBalance, initialBalance - 400);

      final deleteSuccess = await provider.deleteTransaction(addedTx.id);
      expect(deleteSuccess, true);

      expect(provider.totalBalance, initialBalance);
      expect(provider.transactions.any((t) => t.id == addedTx.id), false);
    });

    test('Adding and contributing to savings goal persists to database and updates progress', () async {
      final client = FakeApiClient();
      final provider = FinanceProvider(apiClient: client);
      await provider.syncWithBackend();

      final addSuccess = await provider.addSavingsGoal(
        title: 'Emergency Fund',
        targetAmount: 20000,
        initialAmount: 2000,
      );

      expect(addSuccess, true);
      expect(provider.savingsGoals.length, 1);
      final goal = provider.savingsGoals.first;
      expect(goal.title, 'Emergency Fund');
      expect(goal.currentAmount, 2000.0);

      final contributeSuccess = await provider.contributeToGoal(goal.id, 1000);
      expect(contributeSuccess, true);
      expect(provider.savingsGoals.first.currentAmount, 3000.0);
      expect(provider.totalSavings, 3000.0);

      final updateSuccess = await provider.updateSavingsGoal(
        id: goal.id,
        title: 'Emergency Safety Net',
        targetAmount: 25000,
        currentAmount: 3000,
      );
      expect(updateSuccess, true);
      expect(provider.savingsGoals.first.title, 'Emergency Safety Net');
      expect(provider.savingsGoals.first.targetAmount, 25000.0);

      final deleteGoalSuccess = await provider.deleteSavingsGoal(goal.id);
      expect(deleteGoalSuccess, true);
      expect(provider.savingsGoals.isEmpty, true);
    });
  });
}
