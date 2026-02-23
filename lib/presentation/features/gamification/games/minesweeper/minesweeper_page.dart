import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/gamification_provider.dart';

class MinesweeperPage extends StatefulWidget {
  const MinesweeperPage({super.key});

  @override
  State<MinesweeperPage> createState() => _MinesweeperPageState();
}

class _MinesweeperPageState extends State<MinesweeperPage> {
  final int rows = 12;
  final int cols = 9;
  final int totalMines = 15;

  List<List<int>> board = [];
  List<List<bool>> revealed = [];
  List<List<bool>> flagged = [];
  bool gameOver = false;
  bool won = false;
  bool _xpAwarded = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      board = List.generate(rows, (_) => List.filled(cols, 0));
      revealed = List.generate(rows, (_) => List.filled(cols, false));
      flagged = List.generate(rows, (_) => List.filled(cols, false));
      gameOver = false;
      won = false;
      _xpAwarded = false;
      _placeMines();
      _calculateNumbers();
    });
  }

  void _placeMines() {
    int placed = 0;
    final random = Random();
    while (placed < totalMines) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);
      if (board[r][c] != -1) { board[r][c] = -1; placed++; }
    }
  }

  void _calculateNumbers() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c] == -1) continue;
        int count = 0;
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            int nr = r + i, nc = c + j;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc] == -1) count++;
          }
        }
        board[r][c] = count;
      }
    }
  }

  void _reveal(int r, int c) {
    if (gameOver || revealed[r][c] || flagged[r][c]) return;
    setState(() {
      revealed[r][c] = true;
      if (board[r][c] == -1) {
        gameOver = true;
        _awardXP(false);
        _showGameOverDialog(false);
      } else if (board[r][c] == 0) {
        _revealNeighbors(r, c);
      }
      _checkWin();
    });
  }

  void _revealNeighbors(int r, int c) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int nr = r + i, nc = c + j;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && !revealed[nr][nc]) {
          _reveal(nr, nc);
        }
      }
    }
  }

  void _toggleFlag(int r, int c) {
    if (gameOver || revealed[r][c]) return;
    setState(() => flagged[r][c] = !flagged[r][c]);
  }

  void _checkWin() {
    int unveiled = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!revealed[r][c]) unveiled++;
      }
    }
    if (unveiled == totalMines) {
      won = true;
      gameOver = true;
      _awardXP(true);
      _showGameOverDialog(true);
    }
  }

  void _awardXP(bool success) {
    if (_xpAwarded) return;
    _xpAwarded = true;
    final xp = success ? 45 : 5;
    context.read<GamificationProvider>().addXP(xp);
  }

  void _showGameOverDialog(bool success) {
    final xp = success ? 45 : 5;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        title: Text(
          success ? '🎉 Victory!' : '💥 Game Over',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              success ? 'You cleared the minefield!' : 'You hit a mine!',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '+$xp XP earned!',
              style: const TextStyle(
                  color: Color(0xFF00F0FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _resetGame(); },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Color _getNumberColor(int n) {
    switch (n) {
      case 1: return Colors.blueAccent;
      case 2: return Colors.greenAccent;
      case 3: return Colors.redAccent;
      case 4: return Colors.deepPurpleAccent;
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Minesweeper'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _resetGame)],
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                int r = index ~/ cols, c = index % cols;
                return GestureDetector(
                  onTap: () => _reveal(r, c),
                  onLongPress: () => _toggleFlag(r, c),
                  child: Container(
                    decoration: BoxDecoration(
                      color: revealed[r][c]
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white10),
                    ),
                    alignment: Alignment.center,
                    child: revealed[r][c]
                        ? (board[r][c] == -1
                            ? const Icon(Icons.emergency, color: Colors.red, size: 20)
                            : (board[r][c] > 0
                                ? Text('${board[r][c]}',
                                    style: TextStyle(
                                        color: _getNumberColor(board[r][c]),
                                        fontWeight: FontWeight.bold))
                                : null))
                        : (flagged[r][c]
                            ? const Icon(Icons.flag, color: Colors.orange, size: 20)
                            : null),
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
