import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// XP required to complete level N → level N+1
/// Formula: level 1 needs 100 XP, each subsequent level grows by 50% (rounded)
/// Level 1: 100, Level 2: 150, Level 3: 225, Level 4: 338, ...
int xpRequiredForLevel(int level) {
  // Base XP for level 1 is 100; each level multiplies by 1.5 (capped at 5000)
  double xp = 100 * (1 + (level - 1) * 0.5);
  return xp.toInt().clamp(100, 5000);
}

/// Total XP needed to REACH a given level (cumulative sum)
int totalXpToReachLevel(int level) {
  if (level <= 1) return 0;
  int total = 0;
  for (int i = 1; i < level; i++) {
    total += xpRequiredForLevel(i);
  }
  return total;
}

class GamificationProvider extends ChangeNotifier {
  int _totalXP = 0;
  Map<String, int> _highScores = {};

  // Fired when user levels up - UI can listen and show toast
  int? _lastLevelUp;

  GamificationProvider() {
    _loadData();
  }

  int get totalXP => _totalXP;
  int get currentXP => _totalXP; // backward compat alias
  Map<String, int> get highScores => _highScores;
  int? get lastLevelUp => _lastLevelUp;

  /// Current level derived from total XP using incremental thresholds
  int get currentLevel {
    int level = 1;
    while (_totalXP >= totalXpToReachLevel(level + 1)) {
      level++;
    }
    return level;
  }

  /// XP from the start of the current level (not cumulative)
  int get xpInCurrentLevel {
    return _totalXP - totalXpToReachLevel(currentLevel);
  }

  /// XP needed to finish the current level
  int get xpForNextLevel => xpRequiredForLevel(currentLevel);

  /// XP label: e.g. "340 / 450 XP"
  String get xpLabel => '$xpInCurrentLevel / $xpForNextLevel XP';

  /// Progress fraction [0.0, 1.0] for the current level
  double get levelProgress {
    final needed = xpForNextLevel;
    if (needed == 0) return 1.0;
    return (xpInCurrentLevel / needed).clamp(0.0, 1.0);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalXP = prefs.getInt('user_total_xp') ?? prefs.getInt('user_xp') ?? 0;

    _highScores = {};
    for (final key in prefs.getKeys()) {
      if (key.startsWith('highscore_')) {
        final gameName = key.replaceAll('highscore_', '');
        _highScores[gameName] = prefs.getInt(key) ?? 0;
      }
    }
    notifyListeners();
  }

  /// Award XP and check for level-up. Returns XP actually awarded.
  Future<int> addXP(int amount) async {
    final oldLevel = currentLevel;
    _totalXP += amount;
    final newLevel = currentLevel;

    if (newLevel > oldLevel) {
      _lastLevelUp = newLevel;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_total_xp', _totalXP);

    return amount;
  }

  /// Clear the level-up notification after the UI has shown it
  void clearLevelUp() {
    _lastLevelUp = null;
    notifyListeners();
  }

  Future<void> updateHighScore(String gameName, int score) async {
    final currentHigh = _highScores[gameName] ?? 0;
    if (score > currentHigh) {
      _highScores[gameName] = score;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highscore_$gameName', score);
    }
  }

  int getHighScore(String gameName) => _highScores[gameName] ?? 0;
}
