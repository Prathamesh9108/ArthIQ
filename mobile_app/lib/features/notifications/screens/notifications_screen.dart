import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/alert_banner_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finance = context.watch<FinanceProvider>();

    _notificationService.generateAlertsFromRealData(
      budgets: finance.budgets,
      savingsGoals: finance.savingsGoals,
    );

    final notifications = _notificationService.getNotifications();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              child: const Text('Mark all read', style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 48,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications right now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textLightPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You are all caught up! Real alerts will appear here when category budgets exceed 85% or savings goals are completed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: notifications.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  if (notif.type == 'goal') {
                    return AlertBannerCard.goalAchieved(message: notif.message);
                  } else if (notif.type == 'bill') {
                    return AlertBannerCard(
                      title: notif.title,
                      message: notif.message,
                      iconColor: const Color(0xFF54A0FF),
                      icon: Icons.receipt_long_rounded,
                    );
                  } else {
                    return AlertBannerCard.budgetWarning(message: notif.message);
                  }
                },
              ),
      ),
    );
  }
}
