import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  UserPreferences _prefs = UserPreferences();
  UserPreferences get prefs => _prefs;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _prefs = UserPreferences(
      darkMode: sp.getBool('darkMode') ?? true,
      notificationsEnabled: sp.getBool('notificationsEnabled') ?? true,
      languageCode: sp.getString('languageCode') ?? 'en',
    );
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _prefs = _prefs.copyWith(darkMode: !_prefs.darkMode);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('darkMode', _prefs.darkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _prefs =
        _prefs.copyWith(notificationsEnabled: !_prefs.notificationsEnabled);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('notificationsEnabled', _prefs.notificationsEnabled);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _prefs = _prefs.copyWith(languageCode: code);
    final sp = await SharedPreferences.getInstance();
    await sp.setString('languageCode', code);
    notifyListeners();
  }
}
