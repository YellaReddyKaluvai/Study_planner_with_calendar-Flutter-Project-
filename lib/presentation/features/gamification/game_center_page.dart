import 'package:flutter/material.dart';
import '../../shared/glass_container.dart';
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

class GameCenterPage extends StatelessWidget {
  const GameCenterPage({super.key});

  final List<Map<String, dynamic>> _games = const [
    {
      'name': '2048',
      'icon': Icons.grid_4x4,
      'color': Color(0xFFEDC22E),
      'route': '/2048'
    },
    {
      'name': 'Sudoku',
      'icon': Icons.grid_on,
      'color': Color(0xFF536DFE),
      'route': '/sudoku'
    },
    {
      'name': 'Snake',
      'icon': Icons.timeline,
      'color': Color(0xFF00C853),
      'route': '/snake'
    },
    {
      'name': 'Memory',
      'icon': Icons.flip,
      'color': Color(0xFFFFAB40),
      'route': null
    },
    {
      'name': 'Tic-Tac-Toe',
      'icon': Icons.close,
      'color': Color(0xFFFF5252),
      'route': '/tictactoe'
    },
    {
      'name': 'Minesweeper',
      'icon': Icons.flag,
      'color': Color(0xFFE040FB),
      'route': null
    },
    {
      'name': 'Sliding Puzzle',
      'icon': Icons.image,
      'color': Color(0xFF40C4FF),
      'route': null
    },
    {
      'name': 'Tetris',
      'icon': Icons.view_quilt,
      'color': Color(0xFF7C4DFF),
      'route': null
    },
    {
      'name': 'Wordle',
      'icon': Icons.abc,
      'color': Color(0xFF69F0AE),
      'route': null
    },
    {
      'name': 'Tower Stack',
      'icon': Icons.layers,
      'color': Color(0xFFFF6E40),
      'route': null
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Transparent background to let main gradient show
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Game Center",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final game = _games[index];
                    return GestureDetector(
                      onTap: () {
                        if (game['name'] == 'Tic-Tac-Toe') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TicTacToePage()));
                        } else if (game['name'] == '2048') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Game2048Page()));
                        } else if (game['name'] == 'Sudoku') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SudokuPage()));
                        } else if (game['name'] == 'Snake') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SnakePage()));
                        } else if (game['name'] == 'Memory') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MemoryGamePage()));
                        } else if (game['name'] == 'Minesweeper') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MinesweeperPage()));
                        } else if (game['name'] == 'Sliding Puzzle') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SlidingPuzzlePage()));
                        } else if (game['name'] == 'Tetris') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TetrisPage()));
                        } else if (game['name'] == 'Wordle') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WordlePage()));
                        } else if (game['name'] == 'Tower Stack') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const TowerStackPage()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("${game['name']} coming soon!")),
                          );
                        }
                      },
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (game['color'] as Color).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                game['icon'] as IconData,
                                color: game['color'] as Color,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              game['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
