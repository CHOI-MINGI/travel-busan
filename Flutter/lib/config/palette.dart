import 'package:flutter/material.dart';

class Palette {
  // Primary Colors
  static const Color primary = Color(0xFF030213);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // Background & Foreground
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF252525); // oklch(0.145 0 0)

  // Card
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF252525);

  // Secondary
  static const Color secondary = Color(0xFFF1F3F9); // oklch(0.95 0.0058 264.53)
  static const Color secondaryForeground = Color(0xFF030213);

  // Muted
  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);

  // Accent
  static const Color accent = Color(0xFFE9EBEF);
  static const Color accentForeground = Color(0xFF030213);

  // Destructive
  static const Color destructive = Color(0xFFD4183D);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  // UI Elements
  static const Color border = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  static const Color inputBackground = Color(0xFFF3F3F5);
  
  // Constants
  static const double radius = 10.0; // 0.625rem

  // Dark Mode (CSS의 .dark 섹션 내용)
  static const Color darkBackground = Color(0xFF252525); // oklch(0.145 0 0)
  static const Color darkForeground = Color(0xFFFAFAFA); // oklch(0.985 0 0)
}
