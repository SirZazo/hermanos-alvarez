import 'package:flutter/material.dart';

class AppColors {
  // ---------------------------------------------------------------------------
  // MARCA BASE ACTUAL
  // ---------------------------------------------------------------------------

  static const Color primary = Color(0xFF123F86);
  static const Color primaryDark = Color(0xFF0D2F67);
  static const Color primaryDeep = Color(0xFF09254F);

  static const Color secondary = Color(0xFF2E5FA7);
  static const Color secondarySoft = Color(0xFF6F90BF);

  // Acentos de marca
  static const Color accent = Color(0xFFD8E96A);
  static const Color accentHover = Color(0xFFC9DC55);
  static const Color accentSoft = Color(0xFFE8F3A6);

  // ---------------------------------------------------------------------------
  // NUEVA IDENTIDAD VISUAL
  // ---------------------------------------------------------------------------

  // Verde corporativo / herencia
  static const Color heritageGreen = Color(0xFF174D2C);
  static const Color heritageGreenDark = Color(0xFF103A22);
  static const Color heritageGreenSoft = Color(0xFF3F7350);

  // Mantenemos el lima como acento
  static const Color heritageAccent = Color(0xFFD8E96A);

  // Fondos cálidos
  static const Color heritageBackground = Color(0xFFF4F0E6);
  static const Color heritageBackgroundSoft = Color(0xFFFAF7F0);
  static const Color heritageSurface = Color(0xFFFFFDF8);

  // Bordes cálidos
  static const Color heritageBorder = Color(0xFFD9D4C8);

  // ---------------------------------------------------------------------------
  // TEXTO GENERAL
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF223028);
  static const Color textSecondary = Color(0xFF5F6F67);
  static const Color textMuted = Color(0xFF7E8C84);

  // ---------------------------------------------------------------------------
  // FONDOS ACTUALES
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundSoft = Color(0xFFEEF3F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8FAFC);

  // Fondos de composición
  static const Color pageBackground = Color(0xFFF3F6FA);
  static const Color sectionBackground = Color(0xFFEDF2F7);

  // ---------------------------------------------------------------------------
  // SUPERFICIES
  // ---------------------------------------------------------------------------

  static const Color cardBackground = Color.fromRGBO(255, 255, 255, 0.96);
  static const Color cardBackgroundSoft = Color.fromRGBO(255, 255, 255, 0.82);

  // ---------------------------------------------------------------------------
  // BORDES Y SOMBRAS
  // ---------------------------------------------------------------------------

  static const Color border = Color(0xFFD8E1EA);
  static const Color borderStrong = Color(0xFFB7C7D8);

  static const Color shadowSoft = Color.fromRGBO(9, 37, 79, 0.06);
  static const Color shadowMedium = Color.fromRGBO(9, 37, 79, 0.10);

  // ---------------------------------------------------------------------------
  // BÁSICOS
  // ---------------------------------------------------------------------------

  static const Color white = Colors.white;

  // ---------------------------------------------------------------------------
  // NAVBAR ACTUAL
  // ---------------------------------------------------------------------------

  static const Color navBackground = Color(0xFF123F86);
  static const Color navInnerBackground = Color.fromRGBO(255, 255, 255, 0.10);
  static const Color navBorder = Color.fromRGBO(255, 255, 255, 0.08);

  static const Color navText = Color(0xFFF7FAFD);
  static const Color navTextSoft = Color(0xFFD7E3F0);

  static const Color navActiveBackground = Color.fromRGBO(255, 255, 255, 0.10);
  static const Color navActiveText = Color(0xFFD8E96A);

  static const Color navIcon = Color(0xFFD8E96A);

  // ---------------------------------------------------------------------------
  // HERO / OVERLAYS
  // ---------------------------------------------------------------------------

  static const Color heroOverlay = Color.fromRGBO(9, 37, 79, 0.52);

  // ---------------------------------------------------------------------------
  // BOTONES
  // ---------------------------------------------------------------------------

  static const Color buttonPrimary = Color(0xFFD8E96A);
  static const Color buttonPrimaryHover = Color(0xFFC9DC55);
  static const Color buttonTextDark = Color(0xFF24332C);

  static const Color buttonSecondaryBorder = Color.fromRGBO(
    255,
    255,
    255,
    0.28,
  );
  static const Color buttonSecondaryBackground = Color.fromRGBO(
    255,
    255,
    255,
    0.08,
  );
  static const Color buttonSecondaryText = Color(0xFFF7FAFD);
}
