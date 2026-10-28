import 'package:flutter/material.dart';

/// Central color palette for Personal Eco Tracker.
///
/// Shared colors keep the application visually consistent while
/// different sections use their own accent colors.
abstract final class AppColors {
  AppColors._();

  // ---------- Main Brand ----------
  static const Color primary = Color(0xFF00695C); // Deep Teal
  static const Color secondary = Color(0xFF1976D2); // Professional Blue

  // ---------- Section Colors ----------

  // Energy
  static const Color energy = Color(0xFFF57C00); // Orange

  // Waste
  static const Color waste = Color(0xFF7B1FA2); // Purple

  // Eco / Habits
  static const Color eco = Color(0xFF388E3C); // Green

  // ---------- Eco Green Accent Ramp ----------

  static const Color green400 = Color(0xFF66BB6A);
  static const Color green300 = Color(0xFF81C784);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color lightGreen50 = Color(0xFFF1F8E9);

  static const Color green800 = Color(0xFF2E7D32);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green600 = Color(0xFF43A047);
  static const Color green500 = Color(0xFF4CAF50);
  static const Color green200 = Color(0xFFA5D6A7);
  static const Color green50 = Color(0xFFE8F5E9);

  static const Color lightGreen700 = Color(0xFF689F38);

  // ---------- Background & Surface ----------

  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color inputFill = Color(0xFFF5F7FA);
  static const Color border = Color(0xFFE0E6EA);

  // ---------- Text ----------

  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color textMuted = Color(0xFF90A4AE);

  // ---------- Status ----------

  static const Color error = Color(0xFFC62828);
  static const Color success = Color(0xFF388E3C);
}
