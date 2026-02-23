import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationProvider extends ChangeNotifier {
  int _currentXP = 0;
  Map<String, int> _highScores = {};

  GamificationProvider() {
    _loadData();
  }

  int get currentXP => _currentXP;
  Map<String, int> get highScores => _highScores;

  // Level Calculation: Level = 1 + (XP / 100)
  int get currentLevel => 1 + (_currentXP ~/ 100);

  // XP needed for next level
  int get xpForNextLevel => (currentLevel * 100);

  // Progress (0.0 to 1.0) towards next level
  double get levelProgress {
    int currentLevelBaseXP = (currentLevel - 1) * 100;
    int xpInThisLevel = _currentXP - currentLevelBaseXP;
    return xpInThisLevel / 100.0;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentXP = prefs.getInt('user_xp') ?? 0;

    // Load high scores
    // We'll store high scores as "highscore_gameName"
    _highScores = {};
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('highscore_')) {
        String gameName = key.replaceAll('highscore_', '');
        _highScores[gameName] = prefs.getInt(key) ?? 0;
      }
    }
    notifyListeners();
  }

  Future<void> addXP(int amount) async {
    _currentXP += amount;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_xp', _currentXP);
  }

  Future<void> updateHighScore(String gameName, int score) async {
    int currentHigh = _highScores[gameName] ?? 0;
    if (score > currentHigh) {
      _highScores[gameName] = score;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highscore_$gameName', score);
    }
  }

  int getHighScore(String gameName) {
    return _highScores[gameName] ?? 0;
  }
}
