import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/services/shared_prefs_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPrefsService.getInstance();
    final savedMode = prefs.themeMode;
    if (savedMode == 'dark') {
      state = ThemeMode.dark;
    } else if (savedMode == 'system') {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPrefsService.getInstance();
    String modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    if (mode == ThemeMode.system) modeString = 'system';
    await prefs.setThemeMode(modeString);
  }
}
