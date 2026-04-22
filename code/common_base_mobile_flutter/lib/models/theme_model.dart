import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontScale = 1.0;

  double get fontScale => _fontScale;

  String get fontScaleLabel {
    if (_fontScale <= 0.85) return '小';
    if (_fontScale <= 1.0) return '标准';
    if (_fontScale <= 1.15) return '大';
    return '超大';
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final scale = prefs.getDouble('font_scale') ?? 1.0;
    final modeIndex = prefs.getInt('theme_mode') ?? 2;
    _fontScale = scale;
    _themeMode = ThemeMode.values[modeIndex.clamp(0, 2)];
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', scale);
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return '亮色主题';
      case ThemeMode.dark:
        return '暗色主题';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}
