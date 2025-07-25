import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ClockType {
  sliding, fading, gyro, rotatingRing, orbital, text, cornerRotation
}

class ClockTheme with ChangeNotifier {
  final ClockType type;
  final Function _saveCallback;
  
  Color _backgroundColor;
  Color _primaryColor;
  Color _glowColor;
  String _fontFamily;

  ClockTheme({
    required this.type,
    required Color backgroundColor,
    required Color primaryColor,
    required Color glowColor,
    String fontFamily = 'RobotoMono',
    required Function saveCallback,
  })  : _backgroundColor = backgroundColor,
        _primaryColor = primaryColor,
        _glowColor = glowColor,
        _fontFamily = fontFamily,
        _saveCallback = saveCallback;

  // Getters
  Color get backgroundColor => _backgroundColor;
  Color get primaryColor => _primaryColor;
  Color get glowColor => _glowColor;
  String get fontFamily => _fontFamily;

  // Setters
  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
    _saveCallback();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
    _saveCallback();
  }

  void setGlowColor(Color color) {
    _glowColor = color;
    notifyListeners();
    _saveCallback();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
    _saveCallback();
  }
}

class ThemeProvider with ChangeNotifier {
  ClockType _activeClock = ClockType.sliding;
  late Map<ClockType, ClockTheme> _themes;

  ClockType get activeClock => _activeClock;
  ClockTheme get activeTheme => _themes[_activeClock]!;
  
  // NEW: Helper to get the theme for any clock type, not just the active one.
  // This is needed for the live previews in the theme selection screen.
  ClockTheme activeThemeFor(ClockType type) => _themes[type]!;

  ThemeProvider() {
    _themes = {
      for (var type in ClockType.values)
        type: ClockTheme(
          type: type,
          backgroundColor: const Color(0xFF1a1a1a),
          primaryColor: Colors.white,
          glowColor: Colors.cyan,
          saveCallback: () => _saveSettingsFor(type), // Save the specific theme that changed
        )
    };
    _loadSettings();
  }

  void setActiveClock(ClockType type) {
    if (_activeClock != type) {
      _activeClock = type;
      _saveActiveClockType();
      notifyListeners();
    }
  }

  // NEW: Resets the theme for a specific clock back to its default values.
  void resetThemeToDefault(ClockType type) {
    _themes[type]!._backgroundColor = const Color(0xFF1a1a1a);
    _themes[type]!._primaryColor = Colors.white;
    _themes[type]!._glowColor = Colors.cyan;
    _themes[type]!._fontFamily = 'RobotoMono';
    
    _saveSettingsFor(type); // Save the reset values
    notifyListeners();
  }

  // --- Persistence Logic ---

  // NEW: Saves the settings for a specific clock type.
  Future<void> _saveSettingsFor(ClockType type) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = _themes[type]!;
    await prefs.setInt('${theme.type.name}_bg', theme.backgroundColor.value);
    await prefs.setInt('${theme.type.name}_primary', theme.primaryColor.value);
    await prefs.setInt('${theme.type.name}_glow', theme.glowColor.value);
    await prefs.setString('${theme.type.name}_font', theme.fontFamily);
  }
  
  Future<void> _saveActiveClockType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activeClock', _activeClock.index);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final activeIndex = prefs.getInt('activeClock') ?? 0;
    _activeClock = ClockType.values[activeIndex];

    for (var type in ClockType.values) {
      final theme = _themes[type]!;
      theme._backgroundColor = Color(prefs.getInt('${type.name}_bg') ?? theme.backgroundColor.value);
      theme._primaryColor = Color(prefs.getInt('${type.name}_primary') ?? theme.primaryColor.value);
      theme._glowColor = Color(prefs.getInt('${type.name}_glow') ?? theme.glowColor.value);
      theme._fontFamily = prefs.getString('${type.name}_font') ?? theme.fontFamily;
    }
    notifyListeners();
  }
}
