import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0C0D11);
  static const surface = Color(0xFF16171D);
  static const surfaceBorder = Color(0xFF24252E);
  static const surfaceElevated = Color(0xFF1F202A);
  
  // Primary Pink/Coral Accents
  static const primaryCoral = Color(0xFFFF9E9E);
  static const primaryCoralDark = Color(0xFFE57B7B);
  static const onCoralText = Color(0xFF1E0A0A);
  
  // Brand Red Shield Color
  static const brandRed = Color(0xFFE53341);
  
  // Status & Priority Colors
  static const criticalRed = Color(0xFFEF4444);
  static const highPriorityAmber = Color(0xFFF59E0B);
  static const trustGreen = Color(0xFF34D399);
  static const lowPriorityGrey = Color(0xFF6B7280);

  // Text Colors
  static const textPrimary = Color(0xFFF3F3F5);
  static const textSecondary = Color(0xFF8E8F9A);
  static const textMuted = Color(0xFF5A5B66);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCoral,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.criticalRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryCoral, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCoral,
          foregroundColor: AppColors.onCoralText,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        disabledColor: AppColors.surface,
        selectedColor: AppColors.primaryCoral,
        secondarySelectedColor: AppColors.primaryCoral,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
    );
  }
}
