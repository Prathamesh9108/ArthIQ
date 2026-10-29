import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../models/savings_model.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'alert', 'goal', 'bill', 'system'
  final DateTime timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> getNotifications() => List.unmodifiable(_notifications);

  /// Generates dynamic notifications strictly based on real database records in TiDB Cloud
  void generateAlertsFromRealData({
    required List<BudgetModel> budgets,
    required List<SavingsGoalModel> savingsGoals,
  }) {
    _notifications.clear();

    // 1. Check for real budget warnings
    for (final b in budgets) {
      if (b.limit > 0 && (b.spent / b.limit) >= 0.85) {
        final pct = (b.spent / b.limit * 100).toInt();
        _notifications.add(
          NotificationItem(
            id: 'notif_budget_${b.id}',
            title: 'Budget Alert: ${b.category}',
            message: 'You have utilized $pct% of your ₹${b.limit.toInt()} budget.',
            type: 'alert',
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // 2. Check for real savings achievements
    for (final g in savingsGoals) {
      if (g.isCompleted) {
        _notifications.add(
          NotificationItem(
            id: 'notif_goal_${g.id}',
            title: 'Savings Goal Achieved! 🎉',
            message: 'Congratulations! You reached your target for "${g.title}" (₹${g.targetAmount.toInt()}).',
            type: 'goal',
            timestamp: DateTime.now(),
          ),
        );
      }
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
      ),
    );
    if (kDebugMode) {
      debugPrint('[Notification] $title: $message');
    }
  }
}
