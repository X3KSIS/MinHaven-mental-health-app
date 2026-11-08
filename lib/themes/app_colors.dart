import 'package:flutter/material.dart';

/// Theme-aware neutral colours for text, cards, borders and backgrounds.
///
/// Use these instead of hard-coded `Colors.black87`, `Colors.grey[600]`,
/// `Colors.white` etc. so screens adapt to dark mode. Each light value matches
/// the colour it replaces, so light mode looks exactly as before.
///
/// ```dart
/// Text('Title', style: TextStyle(color: context.textPrimary));
/// Container(color: context.cardColor);
/// ```
extension AppColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ---------- Text & icons ----------
  /// Strongest text (light: black).
  Color get textStrong => isDarkMode ? Colors.white : Colors.black;

  /// Headings and main body text (light: black87).
  Color get textPrimary =>
      isDarkMode ? const Color(0xDEFFFFFF) : Colors.black87;

  /// Secondary text (light: grey 700).
  Color get textSecondary =>
      isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

  /// Subtitles, captions, secondary icons (light: grey 600).
  Color get textMuted =>
      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

  /// Faint text such as dates and footnotes (light: grey 500).
  Color get textFaint => Colors.grey.shade500;

  /// Hints, chevrons and disabled states (light: grey 400).
  Color get textHint =>
      isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;

  /// Text and icons placed on a `primary` coloured background.
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;

  // ---------- Surfaces ----------
  /// Main page background (light: white).
  Color get background =>
      isDarkMode ? Colors.grey.shade900 : Colors.white;

  /// Slightly tinted page background (light: grey 50).
  Color get pageBackground =>
      isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;

  /// Cards, tiles, dialogs and input fields (light: white).
  Color get cardColor =>
      isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

  /// Subtle fills: chat bubbles, chips, inactive containers (light: grey 100).
  Color get subtleFill =>
      isDarkMode ? const Color(0xFF333333) : Colors.grey.shade100;

  // ---------- Lines ----------
  /// Dividers, light borders and progress-bar tracks (light: grey 200).
  Color get divider =>
      isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade200;

  /// Stronger borders and handles (light: grey 300).
  Color get borderStrong =>
      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
}
