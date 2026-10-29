import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'ArthIQ';
  static const String appTagline = 'Spend Smart. Save Better.';
  static const String appSubTagline = 'AI-Powered Personal Finance Management';
  static const String appVersion = '1.0.0+1';

  // Currency & Locales
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';
  static const String defaultLocale = 'en_IN';

  // Animation Durations
  static const Duration splashDelay = Duration(milliseconds: 2400);
  static const Duration shortAnimation = Duration(milliseconds: 250);
  static const Duration mediumAnimation = Duration(milliseconds: 400);

  // Pagination & Limits
  static const int defaultPageSize = 20;
  static const double defaultMaxBudgetAlertThreshold = 0.85; // 85%

  // Navigation Key
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
