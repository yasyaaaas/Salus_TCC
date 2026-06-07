import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color blue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFF60A5FA);
  static const Color blueSurface = Color(0xFFEFF6FF);
  static const Color blueDark = Color(0xFF1E3A8A);
  static const Color blueDeep = Color(0xFF172554);

  // Gradiente azul
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
  );
  static const LinearGradient blueGradientSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
  );

  static const Color mint = Color(0xFF059669);
  static const Color mintLight = Color(0xFF34D399);
  static const Color mintSurface = Color(0xFFECFDF5);
  static const Color mintDark = Color(0xFF065F46);

  // Gradiente verde
  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF047857), Color(0xFF059669), Color(0xFF10B981)],
  );

  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFF1F5F9);
  static const Color surfaceHigh = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color urgencyHigh = Color(0xFFDC2626);
  static const Color urgencyHighSurface = Color(0xFFFEF2F2);
  static const Color urgencyHighBorder = Color(0xFFFECACA);

  static const Color urgencyMedium = Color(0xFFD97706);
  static const Color urgencyMediumSurface = Color(0xFFFFFBEB);
  static const Color urgencyMediumBorder = Color(0xFFFDE68A);

  static const Color urgencyLow = Color(0xFF059669);
  static const Color urgencyLowSurface = Color(0xFFECFDF5);
  static const Color urgencyLowBorder = Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningText = Color(0xFF92400E);

  static const Color glassWhite = Color(0x26FFFFFF);
  static const Color glassDark = Color(0x0D000000);
}