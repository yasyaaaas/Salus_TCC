import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Azul-céu - fluxo de autenticação e chat
  static const Color blue = Color(0xFF2196F3);
  static const Color blueLight = Color(0xFFB3E5FC);
  static const Color blueSurface = Color(0xFFE3F2FD);
  static const Color blueDark = Color(0xFF0D47A1);

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
  );

  static const LinearGradient blueGradientSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF047857), Color(0xFF059669), Color(0xFF10B981)],
  );

  // Verde-limão - fluxo de exames e localização
  static const Color mint = Color(0xFF8BC34A);
  static const Color mintLight = Color(0xFFDCEDC8);
  static const Color mintSurface = Color(0xFFF1F8E9);
  static const Color mintDark = Color(0xFF33691E);

  // Neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F7FF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceHigh = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFFAAAAAA);

  //  Escala de Manchester
  // Usada para classificação de urgência no chatbot
  // Referência: Sistema de Triagem de Manchester (STM)

  /// Nível 1 - Imediato (vermelho)
  /// Risco de vida imediato, atendimento em 0 minutos
  static const Color manchesterRed = Color(0xFFD32F2F);
  static const Color manchesterRedSurface = Color(0xFFFFEBEE);

  /// Nível 2 - Muito urgente (laranja)
  /// Situação de risco, atendimento em até 15 minutos
  static const Color manchesterOrange = Color(0xFFE64A19);
  static const Color manchesterOrangeSurface = Color(0xFFFBE9E7);

  /// Nível 3 - Urgente (amarelo)
  /// Condição importante mas estável, atendimento em até 60 minutos
  static const Color manchesterYellow = Color(0xFFF9A825);
  static const Color manchesterYellowSurface = Color(0xFFFFF8E1);

  /// Nível 4 - Pouco urgente (verde)
  /// Condição semi-urgente, atendimento em até 120 minutos
  static const Color manchesterGreen = Color(0xFF388E3C);
  static const Color manchesterGreenSurface = Color(0xFFE8F5E9);

  /// Nível 5 - Não urgente (azul)
  /// Condição não urgente, atendimento em até 240 minutos
  static const Color manchesterBlue = Color(0xFF1565C0);
  static const Color manchesterBlueSurface = Color(0xFFE3F2FD);

  // Aliases semânticos (mantidos para retrocompatibilidade)
  static const Color urgencyHigh = manchesterRed;
  static const Color urgencyHighSurface = manchesterRedSurface;
  static const Color urgencyHighBorder = Color(0xFFFFCDD2);

  static const Color urgencyMedium = manchesterOrange;
  static const Color urgencyMediumSurface = manchesterOrangeSurface;
  static const Color urgencyMediumBorder = Color(0xFFFFCCBC);

  static const Color urgencyLow = manchesterGreen;
  static const Color urgencyLowSurface = manchesterGreenSurface;
  static const Color urgencyLowBorder = Color(0xFFA5D6A7);

  // Alertas clínicos (exames)
  static const Color alertOrange = Color(0xFFFFF3E0);
  static const Color alertOrangeBorder = Color(0xFFFF9800);
  static const Color alertOrangeText = Color(0xFF7A4200);
  static const Color warningText = Color(0xFF7A6000);


  static const Color warning = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningPhrase = Color(0xFF92400E);

  static const Color glassWhite = Color(0x26FFFFFF);
  static const Color glassDark = Color(0x0D000000);

  // Sombras padrão (uso em cards e botões para dar profundidade)
  static const Color shadowSoft = Color(0x14000000);
  static const Color shadowMedium = Color(0x1F000000);

  // Realce decorativo extra (bolhas de fundo, detalhes)
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentPurpleSurface = Color(0xFFF3E8FF);
  static const Color cardBorderLight = Color(0xFFF0F0F5);
}