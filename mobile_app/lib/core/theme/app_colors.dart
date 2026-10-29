import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents (from ArthIQ Palette)
  static const Color primary = Color(0xFF65E6B4); // Bright Mint Green
  static const Color primaryDark = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFFA7F3D0);
  static const Color primaryContainer = Color(0xFF1B3D36);

  static const Color darkBackground = Color(0xFF101A2C); // Deep Navy Slate
  static const Color lightBackground = Color(0xFFF4F7FB); // Soft Cool White

  static const Color accentPeach = Color(0xFFFFB86B); // Warm Peach / Gold
  static const Color accentBlue = Color(0xFF54A0FF);
  static const Color accentPink = Color(0xFFFF6B81);
  static const Color accentPurple = Color(0xFF5F27CD);
  static const Color accentYellow = Color(0xFFFECA57);

  // Surfaces & Cards - Dark Mode
  static const Color darkCard = Color(0xFF162238);
  static const Color darkCardLight = Color(0xFF1F2E4A);
  static const Color darkSurface = Color(0xFF121E32);
  static const Color darkBorder = Color(0xFF23324C);

  // Surfaces & Cards - Light Mode
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSecondary = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textDarkPrimary = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color textDarkMuted = Color(0xFF64748B);

  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF64748B);
  static const Color textLightMuted = Color(0xFF94A3B8);

  // Status Colors
  static const Color incomeGreen = Color(0xFF1DD1A1);
  static const Color expenseRed = Color(0xFFFF6B81);
  static const Color warning = Color(0xFFFECA57);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF65E6B4), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF162238), Color(0xFF111A29)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x3365E6B4), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
