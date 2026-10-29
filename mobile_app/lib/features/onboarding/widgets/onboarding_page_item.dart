import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPageItem extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String description;

  const OnboardingPageItem({
    super.key,
    required this.illustration,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration,
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : AppColors.textLightPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
