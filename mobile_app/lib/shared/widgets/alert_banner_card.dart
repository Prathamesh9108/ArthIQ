import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AlertBannerCard extends StatelessWidget {
  final String title;
  final String message;
  final Color iconColor;
  final IconData icon;
  final VoidCallback? onTap;

  const AlertBannerCard({
    super.key,
    required this.title,
    required this.message,
    required this.iconColor,
    required this.icon,
    this.onTap,
  });

  factory AlertBannerCard.budgetWarning({
    required String message,
    VoidCallback? onTap,
  }) {
    return AlertBannerCard(
      title: 'Budget Alert',
      message: message,
      iconColor: const Color(0xFFFECA57),
      icon: Icons.warning_amber_rounded,
      onTap: onTap,
    );
  }

  factory AlertBannerCard.goalAchieved({
    required String message,
    VoidCallback? onTap,
  }) {
    return AlertBannerCard(
      title: 'Goal Achieved!',
      message: message,
      iconColor: AppColors.primary,
      icon: Icons.check_circle_rounded,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textLightPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
