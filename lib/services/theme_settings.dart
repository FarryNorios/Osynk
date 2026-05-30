import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Color _seedColor = Colors.deepPurple;
  Color get seedColor => _seedColor;

  Locale? _locale;
  Locale? get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _save();
    notifyListeners();
  }

  void setSeedColor(Color color) {
    _seedColor = color;
    _save();
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    _locale = locale;
    _save();
    notifyListeners();
  }

  // ─── Persistence ───

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt('themeMode');
      if (modeIndex != null && modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[modeIndex];
      }
      final colorValue = prefs.getInt('seedColor');
      if (colorValue != null) {
        _seedColor = Color(colorValue);
      }
      final localeCode = prefs.getString('locale');
      if (localeCode != null) {
        _locale = Locale(localeCode);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load theme settings: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', _themeMode.index);
      await prefs.setInt('seedColor', _seedColor.toARGB32());
      if (_locale != null) {
        await prefs.setString('locale', _locale!.languageCode);
      } else {
        await prefs.remove('locale');
      }
    } catch (e) {
      debugPrint('Failed to save theme settings: $e');
    }
  }
}
