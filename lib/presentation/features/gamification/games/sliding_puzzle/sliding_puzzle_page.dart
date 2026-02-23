import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../providers/gamification_provider.dart';

class SlidingPuzzlePage extends StatefulWidget {
  const SlidingPuzzlePage({super.key});

  @override
  State<SlidingPuzzlePage> createState() => _SlidingPuzzlePageState();
}

class _SlidingPuzzlePageState extends State<SlidingPuzzlePage> {
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  bool isSolved = false;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _scramble();
  }

  void _scramble() {
    tiles.shuffle();
    while (!_isSolvable() || _checkWin()) tiles.shuffle();
    setState(() { isSolved = false; _moves = 0; });
  }

  bool _isSolvable() {
    int inversions = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] > tiles[j] && tiles[i] != 0 && tiles[j] != 0) inversions++;
      }
    }
    return inversions % 2 == 0;
  }

  bool _checkWin() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return true;
  }

  void _moveTile(int index) {
    if (isSolved) return;
    int emptyIndex = tiles.indexOf(0);
    int row = index ~/ 3, col = index % 3;
    int emptyRow = emptyIndex ~/ 3, emptyCol = emptyIndex % 3;

    if ((row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1)) {
      setState(() {
        int temp = tiles[index];
        tiles[index] = tiles[emptyIndex];
        tiles[emptyIndex] = temp;
        _moves++;
        if (_checkWin()) {
          isSolved = true;
          _showWinDialog();
        }
      });
    }
  }

  void _showWinDialog() {
    // XP: 35 base + up to 15 bonus for solving in fewer moves
    final bonus = _moves <= 30 ? 15 : (_moves <= 50 ? 8 : 0);
    final xpEarned = 35 + bonus;
    context.read<GamificationProvider>().addXP(xpEarned);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        title: const Text('Puzzle Solved! 🧩', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Solved in $_moves moves!',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('+$xpEarned XP earned!',
                style: const TextStyle(
                    color: Color(0xFF00F0FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            if (bonus > 0)
              Text('(+$bonus efficiency bonus!)',
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _scramble(); },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sliding Puzzle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text('Moves: $_moves',
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _scramble),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E17), Color(0xFF161B28)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                if (tiles[index] == 0) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () => _moveTile(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '${tiles[index]}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
