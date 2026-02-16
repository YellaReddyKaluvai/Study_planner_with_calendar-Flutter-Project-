import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class SlidingPuzzlePage extends StatefulWidget {
  const SlidingPuzzlePage({super.key});

  @override
  State<SlidingPuzzlePage> createState() => _SlidingPuzzlePageState();
}

class _SlidingPuzzlePageState extends State<SlidingPuzzlePage> {
  // 3x3 puzzle: 1-8 and 0 representing empty
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  bool isSolved = false;

  @override
  void initState() {
    super.initState();
    _scramble();
  }

  void _scramble() {
    tiles.shuffle();
    while (!_isSolvable() || _checkWin()) {
      tiles.shuffle();
    }
    setState(() {
      isSolved = false;
    });
  }

  // Count inversions to check if puzzle is solvable
  bool _isSolvable() {
    int inversions = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] > tiles[j] && tiles[i] != 0 && tiles[j] != 0) {
          inversions++;
        }
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
    // Check adjacency (up, down, left, right)
    int row = index ~/ 3;
    int col = index % 3;
    int emptyRow = emptyIndex ~/ 3;
    int emptyCol = emptyIndex % 3;

    if ((row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1)) {
      setState(() {
        // Swap
        int temp = tiles[index];
        tiles[index] = tiles[emptyIndex];
        tiles[emptyIndex] = temp;

        if (_checkWin()) {
          isSolved = true;
          _showWinDialog();
        }
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Puzzle Solved!"),
        content: const Text("Great job organizing your mind!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _scramble();
            },
            child: const Text("Play Again"),
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
        title: const Text("Sliding Puzzle"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
                if (tiles[index] == 0) {
                  return const SizedBox.shrink(); // Empty tile
                }
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
                              offset: const Offset(0, 4))
                        ]),
                    child: Text(
                      "${tiles[index]}",
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
