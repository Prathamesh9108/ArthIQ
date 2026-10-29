import 'package:flutter/material.dart';

class AppConstants {
  // Brand
  static const String appTitle = 'ArthIQ';
  static const String brandSlogan = 'Your Money · Your Smarter Future';

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_profile';
  static const String keyThemeMode = 'app_theme_mode';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyTransactions = 'stored_transactions';
  static const String keyBudgets = 'stored_budgets';
  static const String keySavings = 'stored_savings';
  static const String keyAutoSaveEnabled = 'auto_save_enabled';

  // Transaction Categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Rent',
    'Entertainment',
    'Health',
    'Groceries',
    'Education',
    'Investments',
    'Others',
  ];

  static const List<String> incomeCategories = [
    'Salary Credit',
    'Freelance',
    'Investments & Dividends',
    'Rental Income',
    'Cashback & Rewards',
    'Other Income',
  ];

  // Payment Modes
  static const List<String> paymentModes = [
    'UPI (GPay / PhonePe)',
    'Bank Account (HDFC/SBI)',
    'Credit Card',
    'Debit Card',
    'Cash Wallet',
    'UPI',
    'Bank Transfer',
    'Net Banking',
    'Cash',
  ];

  // Category Colors
  static const Map<String, Color> categoryColorMap = {
    'Food & Dining': Color(0xFFFF9F43),
    'Transport': Color(0xFF54A0FF),
    'Shopping': Color(0xFFFF6B81),
    'Bills & Utilities': Color(0xFFFECA57),
    'Rent': Color(0xFF10AC84),
    'Entertainment': Color(0xFF5F27CD),
    'Salary Credit': Color(0xFF1DD1A1),
    'Freelance': Color(0xFF00D2D3),
    'Health': Color(0xFFFF7675),
    'Groceries': Color(0xFF00D2D3),
    'Education': Color(0xFF5F27CD),
    'Investments': Color(0xFF48DBFB),
    'Investment': Color(0xFF48DBFB),
    'Investments & Dividends': Color(0xFF48DBFB),
    'Rental Income': Color(0xFF1DD1A1),
    'Cashback & Rewards': Color(0xFFFF9FF3),
    'Other Income': Color(0xFF54A0FF),
    'Others': Color(0xFF8395A7),
  };

  // Category Icons
  static const Map<String, IconData> categoryIconMap = {
    'Food & Dining': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Bills & Utilities': Icons.receipt_long_rounded,
    'Rent': Icons.home_rounded,
    'Entertainment': Icons.movie_filter_rounded,
    'Salary Credit': Icons.account_balance_wallet_rounded,
    'Freelance': Icons.work_rounded,
    'Health': Icons.favorite_rounded,
    'Groceries': Icons.local_grocery_store_rounded,
    'Education': Icons.school_rounded,
    'Investments': Icons.trending_up_rounded,
    'Investment': Icons.trending_up_rounded,
    'Investments & Dividends': Icons.trending_up_rounded,
    'Rental Income': Icons.domain_rounded,
    'Cashback & Rewards': Icons.card_giftcard_rounded,
    'Other Income': Icons.attach_money_rounded,
    'Others': Icons.category_rounded,
  };
}
