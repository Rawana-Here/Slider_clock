// lib/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Theme
  bool _isDarkMode = true;

  // Colors
  Color _backgroundColor = const Color(0xFF0a0a1a);
  Color _primaryColor = const Color(0xFF00FFFF);

  // Font
  String _fontFamily = 'Roboto Mono';

  bool get isDarkMode => _isDarkMode;
  Color get backgroundColor => _backgroundColor;
  Color get primaryColor => _primaryColor;
  String get fontFamily => _fontFamily;

  TextStyle get textStyle => GoogleFonts.getFont(
    _fontFamily,
    color: _isDarkMode ? Colors.white70 : Colors.black87,
  );

  TextStyle get primaryTextStyle => GoogleFonts.getFont(
    _fontFamily,
    color: _primaryColor,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: _primaryColor.withOpacity(0.7),
        blurRadius: 15,
      )
    ]
  );

  SettingsProvider() {
    loadSettings();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    // Simple default theme colors
    if (_isDarkMode) {
      _backgroundColor = const Color(0xFF0a0a1a);
      _primaryColor = const Color(0xFF00FFFF);
    } else {
      _backgroundColor = const Color(0xFFF5F5F5);
      _primaryColor = Colors.blue;
    }
    saveSettings();
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    saveSettings();
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    saveSettings();
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    saveSettings();
    notifyListeners();
  }

  // --- Persistence with SharedPreferences ---

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('backgroundColor', _backgroundColor.value);
    await prefs.setInt('primaryColor', _primaryColor.value);
    await prefs.setString('fontFamily', _fontFamily);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _backgroundColor = Color(prefs.getInt('backgroundColor') ?? const Color(0xFF0a0a1a).value);
    _primaryColor = Color(prefs.getInt('primaryColor') ?? const Color(0xFF00FFFF).value);
    _fontFamily = prefs.getString('fontFamily') ?? 'Roboto Mono';
    notifyListeners();
  }
}