import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/savings_model.dart';
import '../network/api_client.dart';
import '../../shared/widgets/income_expense_bar_chart.dart';
import '../../shared/widgets/spending_donut_chart.dart';

enum FinanceTimeframe { week, month, year, all }

extension FinanceTimeframeExtension on FinanceTimeframe {
  String get label {
    switch (this) {
      case FinanceTimeframe.week:
        return 'Week';
      case FinanceTimeframe.month:
        return 'Month';
      case FinanceTimeframe.year:
        return 'Year';
      case FinanceTimeframe.all:
        return 'All';
    }
  }

  String get fullLabel {
    switch (this) {
      case FinanceTimeframe.week:
        return 'This Week';
      case FinanceTimeframe.month:
        return 'This Month';
      case FinanceTimeframe.year:
        return 'This Year';
      case FinanceTimeframe.all:
        return 'All Time';
    }
  }
}

class PeriodCalculation {
  final double income;
  final double expenses;
  final double net;
  final int transactionCount;
  final double savingsRate;
  final FinanceTimeframe timeframe;

  const PeriodCalculation({
    required this.income,
    required this.expenses,
    required this.net,
    required this.transactionCount,
    required this.savingsRate,
    required this.timeframe,
  });

  bool get isPositive => net >= 0;
}

class FinanceProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final Uuid _uuid = const Uuid();

  // Primary data storage loaded strictly from TiDB Cloud via backend
  List<TransactionModel> _transactions = [];
  List<BudgetModel> _budgets = [];
  List<SavingsGoalModel> _savingsGoals = [];
  SavingsGuardConfig _savingsConfig = const SavingsGuardConfig();

  bool _isBackendConnected = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Duplicate request prevention flags
  bool _isSavingTransaction = false;
  bool _isSavingBudget = false;
  bool _isSavingGoal = false;
  bool _isRebalancing = false;

  String _selectedFilter = 'All'; // 'All', 'Expenses', 'Income'
  FinanceTimeframe _selectedTimeframe = FinanceTimeframe.month;
  String _searchQuery = '';

  // Getters
  bool get isBackendConnected => _isBackendConnected;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SavingsGuardConfig get savingsConfig => _savingsConfig;
  String get selectedFilter => _selectedFilter;
  FinanceTimeframe get selectedTimeframe => _selectedTimeframe;
  String get searchQuery => _searchQuery;

  // Real database-driven totals (No hardcoded demo numbers)
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpenses;

  double get monthlyBudgetLimit => _budgets.fold(0.0, (sum, b) => sum + b.limit);

  double get totalBudgetSpent => _budgets.fold(0.0, (sum, b) => sum + b.spent);

  double get totalSavings => _savingsGoals.fold(0.0, (sum, g) => sum + g.currentAmount);

  double get totalSavingsTarget => _savingsGoals.fold(0.0, (sum, g) => sum + g.targetAmount);

  PeriodCalculation get currentPeriodCalculation => getCalculationForPeriod(_selectedTimeframe);

  List<TransactionModel> get allTransactions => List.unmodifiable(_transactions);
  List<TransactionModel> get transactions => allTransactions;

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((t) {
      if (_selectedFilter == 'Expenses' && !t.isExpense) return false;
      if (_selectedFilter == 'Income' && !t.isIncome) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = t.title.toLowerCase().contains(query);
        final matchesCat = t.category.toLowerCase().contains(query);
        return matchesTitle || matchesCat;
      }
      return true;
    }).toList();
  }

  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  List<SavingsGoalModel> get savingsGoals => List.unmodifiable(_savingsGoals);

  /// Dynamic spending breakdown for donut charts computed entirely from real transactions
  List<SpendingCategoryData> get spendingBreakdown {
    final expenseMap = <String, double>{};
    double totalExp = 0.0;

    for (final tx in _transactions.where((t) => t.isExpense)) {
      expenseMap[tx.category] = (expenseMap[tx.category] ?? 0.0) + tx.amount;
      totalExp += tx.amount;
    }

    if (totalExp == 0.0) return [];

    const categoryColors = <String, Color>{
      'Food & Dining': Color(0xFFFF9F43),
      'Transport': Color(0xFF54A0FF),
      'Bills & Utilities': Color(0xFFFECA57),
      'Shopping': Color(0xFFFF6B81),
      'Entertainment': Color(0xFFA29BFE),
      'Healthcare': Color(0xFF1DD1A1),
      'Rent': Color(0xFFFF7675),
      'Education': Color(0xFF5f27cd),
      'Investment': Color(0xFF10B981),
    };

    final sortedEntries = expenseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.map((entry) {
      final pct = ((entry.value / totalExp) * 100);
      return SpendingCategoryData(
        label: entry.key,
        percentage: double.parse(pct.toStringAsFixed(1)),
        color: categoryColors[entry.key] ?? const Color(0xFF8395A7),
      );
    }).toList();
  }

  /// Returns real spent amount for a specific category
  double getCategorySpent(String category) {
    return _transactions
        .where((t) => t.isExpense && t.category.toLowerCase() == category.toLowerCase())
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  FinanceProvider({ApiClient? apiClient, bool autoSync = true})
      : _apiClient = apiClient ?? ApiClient() {
    // Start strictly with real database sync - no dummy data initialization
    if (autoSync) {
      syncWithBackend();
    }
  }

  /// Syncs with the Node.js + TiDB Cloud backend as the Single Source of Truth
  Future<bool> syncWithBackend() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final health = await _apiClient.checkHealth();
      if (health['status'] == 'healthy' || health['success'] == true) {
        _isBackendConnected = true;
        if (kDebugMode) {
          debugPrint('🌐 [FinanceProvider] Connected to TiDB Cloud via Backend!');
        }

        // 1. Sync Transactions
        final txRes = await _apiClient.get('/transactions');
        if (txRes['success'] == true && txRes['data'] is List) {
          final List backendList = txRes['data'] as List;
          _transactions = backendList
              .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        // 2. Sync Budgets
        final budgetRes = await _apiClient.get('/budgets');
        if (budgetRes['success'] == true && budgetRes['data'] is List) {
          final List backendBudgets = budgetRes['data'] as List;
          _budgets = backendBudgets
              .map((item) => BudgetModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        // 3. Sync Savings Goals
        final goalsRes = await _apiClient.get('/savings-goals');
        if (goalsRes['success'] == true && goalsRes['data'] is List) {
          final List backendGoals = goalsRes['data'] as List;
          _savingsGoals = backendGoals
              .map((item) => SavingsGoalModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isBackendConnected = false;
        _errorMessage = 'Backend health check failed. Please verify TiDB connection.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isBackendConnected = false;
      _errorMessage = 'Unable to reach backend server ($e).';
      _isLoading = false;
      if (kDebugMode) {
        debugPrint('⚠️ [FinanceProvider] Backend not reachable: $e');
      }
      notifyListeners();
      return false;
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setTimeframe(FinanceTimeframe timeframe) {
    if (_selectedTimeframe != timeframe) {
      _selectedTimeframe = timeframe;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Calculates Total Income (+), Total Expenses (-), Net Cashflow (+/-) and Savings Rate %
  PeriodCalculation getCalculationForPeriod(FinanceTimeframe timeframe) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeframe) {
      case FinanceTimeframe.week:
        // Monday 00:00:00 of the current week
        final dayOffset = now.weekday - 1;
        startDate = DateTime(now.year, now.month, now.day - dayOffset);
        break;
      case FinanceTimeframe.month:
        // 1st of current month
        startDate = DateTime(now.year, now.month, 1);
        break;
      case FinanceTimeframe.year:
        // 1st of January of current year
        startDate = DateTime(now.year, 1, 1);
        break;
      case FinanceTimeframe.all:
        startDate = DateTime(2000, 1, 1);
        break;
    }

    final periodTxs = _transactions.where((t) => !t.date.isBefore(startDate)).toList();

    double income = 0.0;
    double expenses = 0.0;

    for (final tx in periodTxs) {
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expenses += tx.amount;
      }
    }

    final net = income - expenses;
    final savingsRate = income > 0 ? ((net / income) * 100).clamp(-100.0, 100.0) : 0.0;

    return PeriodCalculation(
      income: income,
      expenses: expenses,
      net: net,
      transactionCount: periodTxs.length,
      savingsRate: savingsRate,
      timeframe: timeframe,
    );
  }

  /// Returns transactions belonging to the selected timeframe
  List<TransactionModel> getTransactionsForPeriod(FinanceTimeframe timeframe) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeframe) {
      case FinanceTimeframe.week:
        final dayOffset = now.weekday - 1;
        startDate = DateTime(now.year, now.month, now.day - dayOffset);
        break;
      case FinanceTimeframe.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case FinanceTimeframe.year:
        startDate = DateTime(now.year, 1, 1);
        break;
      case FinanceTimeframe.all:
        return List.unmodifiable(_transactions);
    }

    return _transactions.where((t) => !t.date.isBefore(startDate)).toList();
  }

  /// Returns real bar chart data (income vs expense) grouped by timeframe
  List<MonthlyFinanceData> getChartDataForTimeframe(FinanceTimeframe timeframe) {
    final now = DateTime.now();

    switch (timeframe) {
      case FinanceTimeframe.week:
        // 7 days Mon - Sun of current week
        const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        return List.generate(7, (i) {
          final targetDay = monday.add(Duration(days: i));
          final dayTxs = _transactions.where((t) =>
              t.date.year == targetDay.year &&
              t.date.month == targetDay.month &&
              t.date.day == targetDay.day);
          final inc = dayTxs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
          final exp = dayTxs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
          return MonthlyFinanceData(
            month: dayNames[i],
            income: inc,
            expense: exp,
          );
        });

      case FinanceTimeframe.month:
        // 4 weeks in current month: W1 (1-7), W2 (8-14), W3 (15-21), W4 (22+)
        return List.generate(4, (i) {
          final startDay = i * 7 + 1;
          final endDay = i == 3 ? 31 : (i + 1) * 7;
          final weekTxs = _transactions.where((t) =>
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day >= startDay &&
              t.date.day <= endDay);
          final inc = weekTxs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
          final exp = weekTxs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
          return MonthlyFinanceData(
            month: 'W${i + 1}',
            income: inc,
            expense: exp,
          );
        });

      case FinanceTimeframe.year:
      case FinanceTimeframe.all:
        // 6 months ending at current month
        const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return List.generate(6, (i) {
          final monthIndex = (now.month - 6 + i + 12) % 12 + 1;
          final year = (now.month - 6 + i < 0) ? now.year - 1 : now.year;
          final mTxs = _transactions.where((t) => t.date.year == year && t.date.month == monthIndex);
          final inc = mTxs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
          final exp = mTxs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
          return MonthlyFinanceData(
            month: monthNames[monthIndex - 1],
            income: inc,
            expense: exp,
          );
        });
    }
  }

  Future<void> _syncBudgetsFromBackend() async {
    try {
      final budgetRes = await _apiClient.get('/budgets');
      if (budgetRes['success'] == true && budgetRes['data'] is List) {
        final List backendBudgets = budgetRes['data'] as List;
        _budgets = backendBudgets
            .map((item) => BudgetModel.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Add transaction - strictly persists to TiDB Cloud backend before UI update
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    required String paymentMethod,
    String? note,
    String? receiptPath,
  }) async {
    if (_isSavingTransaction) return false;
    _isSavingTransaction = true;

    final txId = 'tx_${_uuid.v4()}';
    final newTx = TransactionModel(
      id: txId,
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
      note: note,
      receiptPath: receiptPath,
    );

    try {
      final res = await _apiClient.post('/transactions', data: newTx.toJson());
      if (res['success'] == true) {
        // UI updates ONLY after successful backend response
        _transactions.insert(0, newTx);
        if (type == TransactionType.expense) {
          _updateBudgetSpending(category, amount);
        }
        _syncBudgetsFromBackend();
        _errorMessage = null;
        notifyListeners();
        if (kDebugMode) {
          debugPrint('💾 [FinanceProvider] Transaction persisted to TiDB: $title ($txId)');
        }
        return true;
      } else {
        _errorMessage = res['error']?.toString() ?? 'Failed to save transaction to database.';
        if (kDebugMode) {
          debugPrint('⚠️ [FinanceProvider] Backend save rejected: $_errorMessage');
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error saving transaction: $e';
      if (kDebugMode) {
        debugPrint('⚠️ [FinanceProvider] Backend exception: $e');
      }
      notifyListeners();
      return false;
    } finally {
      _isSavingTransaction = false;
    }
  }

  void _updateBudgetSpending(String category, double amount) {
    final index = _budgets.indexWhere((b) => b.category.toLowerCase() == category.toLowerCase());
    if (index != -1) {
      final current = _budgets[index];
      final newSpent = (current.spent + amount).clamp(0.0, double.infinity);
      _budgets[index] = current.copyWith(spent: newSpent);
    }
  }

  /// Update existing transaction - strictly persists to TiDB Cloud before UI update
  Future<bool> updateTransaction(TransactionModel updatedTx) async {
    if (_isSavingTransaction) return false;
    _isSavingTransaction = true;

    final index = _transactions.indexWhere((t) => t.id == updatedTx.id);
    if (index == -1) {
      _isSavingTransaction = false;
      return false;
    }

    final oldTx = _transactions[index];

    try {
      final res = await _apiClient.put('/transactions/${updatedTx.id}', data: updatedTx.toJson());
      if (res['success'] == true) {
        // Rollback old transaction impact on budget
        if (oldTx.isExpense) {
          _updateBudgetSpending(oldTx.category, -oldTx.amount);
        }
        // Apply new transaction impact on budget
        if (updatedTx.isExpense) {
          _updateBudgetSpending(updatedTx.category, updatedTx.amount);
        }

        _transactions[index] = updatedTx;
        _syncBudgetsFromBackend();
        _errorMessage = null;
        notifyListeners();
        if (kDebugMode) {
          debugPrint('💾 [FinanceProvider] Transaction updated in TiDB: ${updatedTx.id}');
        }
        return true;
      } else {
        _errorMessage = res['error']?.toString() ?? 'Failed to update transaction in database.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error updating transaction: $e';
      notifyListeners();
      return false;
    } finally {
      _isSavingTransaction = false;
    }
  }

  /// Delete transaction - strictly persists deletion to TiDB Cloud before UI removal
  Future<bool> deleteTransaction(String id) async {
    if (_isSavingTransaction) return false;
    _isSavingTransaction = true;

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      _isSavingTransaction = false;
      return false;
    }

    final tx = _transactions[index];

    try {
      final res = await _apiClient.delete('/transactions/$id');
      if (res['success'] == true) {
        if (tx.isExpense) {
          _updateBudgetSpending(tx.category, -tx.amount);
        }
        _transactions.removeAt(index);
        _syncBudgetsFromBackend();
        _errorMessage = null;
        notifyListeners();
        if (kDebugMode) {
          debugPrint('🗑️ [FinanceProvider] Transaction removed from TiDB: $id');
        }
        return true;
      } else {
        _errorMessage = res['error']?.toString() ?? 'Failed to delete transaction from database.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error deleting transaction: $e';
      notifyListeners();
      return false;
    } finally {
      _isSavingTransaction = false;
    }
  }

  /// Upsert budget category limit to TiDB Cloud
  Future<bool> setBudget({
    required String category,
    required double limit,
    String period = 'monthly',
  }) async {
    if (_isSavingBudget) return false;
    _isSavingBudget = true;

    final budgetId = 'b_${_uuid.v4()}';
    try {
      final res = await _apiClient.post('/budgets', data: {
        'id': budgetId,
        'category': category,
        'limit': limit,
        'period': period,
      });

      if (res['success'] == true) {
        final existingIdx = _budgets.indexWhere((b) => b.category.toLowerCase() == category.toLowerCase());
        final currentSpent = getCategorySpent(category);
        if (existingIdx != -1) {
          _budgets[existingIdx] = _budgets[existingIdx].copyWith(limit: limit, period: period);
        } else {
          _budgets.add(BudgetModel(
            id: budgetId,
            category: category,
            limit: limit,
            spent: currentSpent,
            period: period,
          ));
        }
        _syncBudgetsFromBackend();
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      _errorMessage = res['error']?.toString() ?? 'Failed to save budget';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Network error saving budget: $e';
      if (kDebugMode) debugPrint('⚠️ [FinanceProvider] Set budget failed: $e');
      notifyListeners();
      return false;
    } finally {
      _isSavingBudget = false;
    }
  }

  /// Delete a budget from TiDB Cloud
  Future<bool> deleteBudget(String idOrCategory) async {
    try {
      final res = await _apiClient.delete('/budgets/$idOrCategory');
      if (res['success'] == true) {
        _budgets.removeWhere((b) => b.id == idOrCategory || b.category.toLowerCase() == idOrCategory.toLowerCase());
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [FinanceProvider] Delete budget failed: $e');
      return false;
    }
  }

  /// Atomically rebalance budget funds in TiDB Cloud
  Future<bool> rebalanceBudget({
    required String fromCategory,
    required String toCategory,
    required double amount,
  }) async {
    if (_isRebalancing) return false;

    final fromIdx = _budgets.indexWhere((b) => b.category == fromCategory);
    final toIdx = _budgets.indexWhere((b) => b.category == toCategory);

    if (fromIdx == -1 || toIdx == -1 || _budgets[fromIdx].limit < amount) {
      return false;
    }

    _isRebalancing = true;
    try {
      final res = await _apiClient.post('/budgets/rebalance', data: {
        'fromCategory': fromCategory,
        'toCategory': toCategory,
        'amount': amount,
      });

      if (res['success'] == true) {
        _budgets[fromIdx] = _budgets[fromIdx].copyWith(limit: _budgets[fromIdx].limit - amount);
        _budgets[toIdx] = _budgets[toIdx].copyWith(limit: _budgets[toIdx].limit + amount);
        _syncBudgetsFromBackend();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [FinanceProvider] Rebalance sync failed: $e');
      return false;
    } finally {
      _isRebalancing = false;
    }
  }

  void toggleAutoSave(bool isEnabled) {
    _savingsConfig = _savingsConfig.copyWith(autoSaveEnabled: isEnabled);
    notifyListeners();
  }

  /// Add savings goal to TiDB Cloud
  Future<bool> addSavingsGoal({
    required String title,
    required double targetAmount,
    double initialAmount = 0.0,
    String iconType = 'goal',
    DateTime? targetDate,
  }) async {
    if (_isSavingGoal) return false;
    _isSavingGoal = true;

    final newGoalId = 'sg_${_uuid.v4()}';
    final newGoal = SavingsGoalModel(
      id: newGoalId,
      title: title,
      currentAmount: initialAmount,
      targetAmount: targetAmount,
      iconType: iconType,
      targetDate: targetDate,
    );

    try {
      final res = await _apiClient.post('/savings-goals', data: newGoal.toJson());
      if (res['success'] == true) {
        _savingsGoals.add(newGoal);
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      _errorMessage = res['error']?.toString() ?? 'Failed to save savings goal';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Network error saving goal: $e';
      if (kDebugMode) debugPrint('⚠️ [FinanceProvider] Save goal sync failed: $e');
      notifyListeners();
      return false;
    } finally {
      _isSavingGoal = false;
    }
  }

  /// Update existing savings goal in TiDB Cloud
  Future<bool> updateSavingsGoal({
    required String id,
    required String title,
    required double targetAmount,
    double? currentAmount,
    String? iconType,
    DateTime? targetDate,
  }) async {
    final idx = _savingsGoals.indexWhere((g) => g.id == id);
    if (idx == -1) return false;

    try {
      final res = await _apiClient.put('/savings-goals/$id', data: {
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'iconType': iconType,
        'targetDate': targetDate?.toIso8601String(),
      });

      if (res['success'] == true) {
        final current = _savingsGoals[idx];
        _savingsGoals[idx] = current.copyWith(
          title: title,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          iconType: iconType,
          targetDate: targetDate,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [FinanceProvider] Goal update sync failed: $e');
      return false;
    }
  }

  /// Contribute funds to savings goal in TiDB Cloud
  Future<bool> contributeToGoal(String goalId, double amount) async {
    if (amount <= 0) return false;
    final idx = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (idx == -1) return false;

    try {
      final res = await _apiClient.post('/savings-goals/$goalId/contribute', data: {
        'amount': amount,
      });

      if (res['success'] == true) {
        final current = _savingsGoals[idx];
        _savingsGoals[idx] = current.copyWith(
          currentAmount: current.currentAmount + amount,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [FinanceProvider] Goal deposit sync failed: $e');
      return false;
    }
  }

  /// Delete savings goal from TiDB Cloud
  Future<bool> deleteSavingsGoal(String goalId) async {
    final idx = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (idx == -1) return false;

    try {
      final res = await _apiClient.delete('/savings-goals/$goalId');
      if (res['success'] == true) {
        _savingsGoals.removeAt(idx);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [FinanceProvider] Goal delete sync failed: $e');
      return false;
    }
  }
}
