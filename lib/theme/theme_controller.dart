import 'package:flutter/material.dart';

/// Global theme controller to toggle Light, Dark, or System mode.
class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.system})
      : _themeMode = initialMode;

  static final ThemeController instance = ThemeController();

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }
}
