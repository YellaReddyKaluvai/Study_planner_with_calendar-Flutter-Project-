import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gamification_provider.dart';
import '../../shared/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'games/tic_tac_toe/tic_tac_toe_page.dart';
import 'games/2048/game_2048_page.dart';
import 'games/sudoku/sudoku_page.dart';
import 'games/snake/snake_page.dart';
import 'games/memory/memory_game_page.dart';
import 'games/minesweeper/minesweeper_page.dart';
import 'games/sliding_puzzle/sliding_puzzle_page.dart';
import 'games/tetris/tetris_page.dart';
import 'games/wordle/wordle_page.dart';
import 'games/tower_stack/tower_stack_page.dart';

/// XP awarded per game (flat + can be multiplied by score)
class _GameInfo {
  final String name;
  final IconData icon;
  final Color color;
  final int baseXP; // XP per play
  final Widget Function(BuildContext) builder;

  const _GameInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.baseXP,
    required this.builder,
  });
}

class GameCenterPage extends StatefulWidget {
  const GameCenterPage({super.key});

  @override
  State<GameCenterPage> createState() => _GameCenterPageState();
}

class _GameCenterPageState extends State<GameCenterPage> {
  final List<_GameInfo> _games = [
    _GameInfo(
      name: '2048',
      icon: Icons.grid_4x4,
      color: const Color(0xFFEDC22E),
      baseXP: 30,
      builder: (_) => const Game2048Page(),
    ),
    _GameInfo(
      name: 'Sudoku',
      icon: Icons.grid_on,
      color: const Color(0xFF536DFE),
      baseXP: 50,
      builder: (_) => const SudokuPage(),
    ),
    _GameInfo(
      name: 'Snake',
      icon: Icons.timeline,
      color: const Color(0xFF00C853),
      baseXP: 20,
      builder: (_) => const SnakePage(),
    ),
    _GameInfo(
      name: 'Memory',
      icon: Icons.flip,
      color: const Color(0xFFFFAB40),
      baseXP: 40,
      builder: (_) => const MemoryGamePage(),
    ),
    _GameInfo(
      name: 'Tic-Tac-Toe',
      icon: Icons.close,
      color: const Color(0xFFFF5252),
      baseXP: 25,
      builder: (_) => const TicTacToePage(),
    ),
    _GameInfo(
      name: 'Minesweeper',
      icon: Icons.flag,
      color: const Color(0xFFE040FB),
      baseXP: 45,
      builder: (_) => const MinesweeperPage(),
    ),
    _GameInfo(
      name: 'Sliding Puzzle',
      icon: Icons.image,
      color: const Color(0xFF40C4FF),
      baseXP: 35,
      builder: (_) => const SlidingPuzzlePage(),
    ),
    _GameInfo(
      name: 'Tetris',
      icon: Icons.view_quilt,
      color: const Color(0xFF7C4DFF),
      baseXP: 30,
      builder: (_) => const TetrisPage(),
    ),
    _GameInfo(
      name: 'Wordle',
      icon: Icons.abc,
      color: const Color(0xFF69F0AE),
      baseXP: 50,
      builder: (_) => const WordlePage(),
    ),
    _GameInfo(
      name: 'Tower Stack',
      icon: Icons.layers,
      color: const Color(0xFFFF6E40),
      baseXP: 20,
      builder: (_) => const TowerStackPage(),
    ),
  ];

  void _openGame(_GameInfo game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: game.builder),
    ).then((_) {
      // After returning from any game, check if a level-up happened
      final gameProv = context.read<GamificationProvider>();
      if (gameProv.lastLevelUp != null) {
        _showLevelUpDialog(gameProv.lastLevelUp!);
        gameProv.clearLevelUp();
      }
    });
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Level Up!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You reached Level $newLevel',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<GamificationProvider>(
                builder: (context, gp, _) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Game Center',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Level badge + XP
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.primary, Colors.blueAccent],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Level ${gp.currentLevel}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              gp.xpLabel,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              '${gp.totalXP} total XP',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // XP progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: gp.levelProgress,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.secondary),
                            minHeight: 7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(gp.levelProgress * 100).toInt()}% to Level ${gp.currentLevel + 1}  •  need ${gp.xpForNextLevel - gp.xpInCurrentLevel} more XP',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final game = _games[index];
                    return GestureDetector(
                      onTap: () => _openGame(game),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: game.color.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(game.icon,
                                  color: game.color, size: 32),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              game.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '+${game.baseXP} XP',
                              style: TextStyle(
                                color: game.color.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
