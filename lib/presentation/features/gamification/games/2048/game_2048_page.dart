import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/gamification_provider.dart';

class Game2048Page extends StatefulWidget {
  const Game2048Page({super.key});

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page> {
  List<List<int>> grid = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  bool isGameOver = false;
  bool _xpAwarded = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      grid = List.generate(4, (_) => List.filled(4, 0));
      score = 0;
      isGameOver = false;
      _xpAwarded = false;
      spawnNewTile();
      spawnNewTile();
    });
  }

  void spawnNewTile() {
    List<Point<int>> emptySpots = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) emptySpots.add(Point(i, j));
      }
    }
    if (emptySpots.isNotEmpty) {
      final randomSpot = emptySpots[Random().nextInt(emptySpots.length)];
      grid[randomSpot.x][randomSpot.y] = Random().nextInt(10) == 0 ? 4 : 2;
    }
  }

  void moveLeft() {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> newRow = [];
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] != 0) newRow.add(grid[i][j]);
      }
      for (int j = 0; j < newRow.length - 1; j++) {
        if (newRow[j] == newRow[j + 1]) {
          newRow[j] *= 2;
          score += newRow[j];
          newRow.removeAt(j + 1);
          newRow.add(0);
        }
      }
      while (newRow.length < 4) newRow.add(0);
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] != newRow[j]) moved = true;
        grid[i][j] = newRow[j];
      }
    }
    if (moved) spawnNewTile();
  }

  void rotateGrid() {
    List<List<int>> newGrid = List.generate(4, (_) => List.filled(4, 0));
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        newGrid[j][3 - i] = grid[i][j];
      }
    }
    grid = newGrid;
  }

  void moveRight() { rotateGrid(); rotateGrid(); moveLeft(); rotateGrid(); rotateGrid(); }
  void moveUp() { rotateGrid(); rotateGrid(); rotateGrid(); moveLeft(); rotateGrid(); }
  void moveDown() { rotateGrid(); moveLeft(); rotateGrid(); rotateGrid(); rotateGrid(); }

  bool checkGameOver() {
    for (var row in grid) { if (row.contains(0)) return false; }
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (i < 3 && grid[i][j] == grid[i + 1][j]) return false;
        if (j < 3 && grid[i][j] == grid[i][j + 1]) return false;
      }
    }
    return true;
  }

  void _onGameOver() {
    if (_xpAwarded) return;
    _xpAwarded = true;
    // 30 base + 1 XP per 100 points scored
    final xpEarned = 30 + (score ~/ 100);
    context.read<GamificationProvider>().addXP(xpEarned);
    context.read<GamificationProvider>().updateHighScore('2048', score);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E2746),
          title: const Text('Game Over!', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: $score',
                  style: const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 8),
              Text('+$xpEarned XP earned!',
                  style: const TextStyle(
                      color: Color(0xFF00F0FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); startGame(); },
              child: const Text('Play Again', style: TextStyle(color: Color(0xFFEDC22E))),
            ),
            TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('Exit', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    });
  }

  void handleSwipe(DragEndDetails details) {
    if (isGameOver) return;
    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;

    setState(() {
      if (dx.abs() > dy.abs()) {
        if (dx > 0) moveRight(); else moveLeft();
      } else {
        if (dy > 0) moveDown(); else moveUp();
      }
      if (checkGameOver()) {
        isGameOver = true;
        _onGameOver();
      }
    });
  }

  Color getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xFFEEE4DA).withOpacity(0.9);
      case 4: return const Color(0xFFEDE0C8).withOpacity(0.9);
      case 8: return const Color(0xFFF2B179);
      case 16: return const Color(0xFFF59563);
      case 32: return const Color(0xFFF67C5F);
      case 64: return const Color(0xFFF65E3B);
      case 128: return const Color(0xFFEDCF72);
      case 256: return const Color(0xFFEDCC61);
      case 512: return const Color(0xFFEDC850);
      case 1024: return const Color(0xFFEDC53F);
      case 2048: return const Color(0xFFEDC22E);
      default: return const Color(0xFFCDC1B4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('2048'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Score: $score',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: startGame),
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
        child: GestureDetector(
          onPanEnd: handleSwipe,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isGameOver)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(10),
                  color: Colors.redAccent,
                  child: const Text('Game Over!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBADA0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (i) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(4, (j) {
                          return Container(
                            width: 70,
                            height: 70,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: getTileColor(grid[i][j]),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              grid[i][j] == 0 ? '' : '${grid[i][j]}',
                              style: TextStyle(
                                fontSize: grid[i][j] > 100 ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: grid[i][j] <= 4
                                    ? const Color(0xFF776E65)
                                    : Colors.white,
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Swipe to move', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}
