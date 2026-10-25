import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, amoled, system }
enum AccentColor { cyan, blue, emerald, purple, orange }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _appThemeMode = AppThemeMode.dark;
  AccentColor _accentColor = AccentColor.cyan;
  bool _highContrast = false;
  double _fontScale = 1.0;

  AppThemeMode get appThemeMode => _appThemeMode;
  AccentColor get accentColor => _accentColor;
  bool get isHighContrast => _highContrast;
  double get fontScale => _fontScale;

  bool get isDarkMode {
    if (_appThemeMode == AppThemeMode.dark || _appThemeMode == AppThemeMode.amoled) {
      return true;
    }
    if (_appThemeMode == AppThemeMode.light) {
      return false;
    }
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  bool get isAmoled => _appThemeMode == AppThemeMode.amoled;

  ThemeMode get themeMode {
    switch (_appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Color get primaryAccentColor {
    switch (_accentColor) {
      case AccentColor.cyan:
        return const Color(0xFF06B6D4);
      case AccentColor.blue:
        return const Color(0xFF3B82F6);
      case AccentColor.emerald:
        return const Color(0xFF10B981);
      case AccentColor.purple:
        return const Color(0xFF8B5CF6);
      case AccentColor.orange:
        return const Color(0xFFF97316);
    }
  }

  void setThemeMode(AppThemeMode mode) {
    _appThemeMode = mode;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _appThemeMode = isDark ? AppThemeMode.dark : AppThemeMode.light;
    notifyListeners();
  }

  void setAccentColor(AccentColor color) {
    _accentColor = color;
    notifyListeners();
  }

  void toggleHighContrast(bool value) {
    _highContrast = value;
    notifyListeners();
  }

  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }
}
