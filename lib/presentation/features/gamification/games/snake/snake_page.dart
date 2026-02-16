import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class SnakePage extends StatefulWidget {
  const SnakePage({super.key});

  @override
  State<SnakePage> createState() => _SnakePageState();
}

enum Direction { up, down, left, right }

class _SnakePageState extends State<SnakePage> {
  // Grid settings
  final int squaresPerRow = 20;
  final int squaresPerCol = 30;

  // Game state
  List<int> snake = [45, 44, 43];
  int food = 0;
  Direction direction = Direction.right;
  bool isPlaying = false;
  Timer? timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    generateFood();
  }

  void startGame() {
    setState(() {
      snake = [45, 44, 43];
      isPlaying = true;
      score = 0;
      direction = Direction.right;
    });
    const duration = Duration(milliseconds: 200);
    timer = Timer.periodic(duration, (Timer timer) {
      moveSnake();
    });
  }

  void generateFood() {
    food = Random().nextInt(squaresPerRow * squaresPerCol);
    if (snake.contains(food)) {
      generateFood();
    }
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case Direction.up:
          if (snake.first < squaresPerRow) {
            gameOver();
            return;
          }
          snake.insert(0, snake.first - squaresPerRow);
          break;
        case Direction.down:
          if (snake.first >= (squaresPerRow * squaresPerCol) - squaresPerRow) {
            gameOver();
            return;
          }
          snake.insert(0, snake.first + squaresPerRow);
          break;
        case Direction.left:
          if (snake.first % squaresPerRow == 0) {
            gameOver();
            return;
          }
          snake.insert(0, snake.first - 1);
          break;
        case Direction.right:
          if ((snake.first + 1) % squaresPerRow == 0) {
            gameOver();
            return;
          }
          snake.insert(0, snake.first + 1);
          break;
      }

      if (snake.first == food) {
        score += 10;
        generateFood();
      } else {
        snake.removeLast();
      }

      // Check collision with self
      if (snake.sublist(1).contains(snake.first)) {
        gameOver();
      }
    });
  }

  void gameOver() {
    timer?.cancel();
    setState(() {
      isPlaying = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B28),
          title: const Text("Game Over", style: TextStyle(color: Colors.white)),
          content: Text("Score: $score",
              style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startGame();
              },
              child: const Text("Play Again",
                  style: TextStyle(color: AppTheme.primary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Exit", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: const Text("Snake"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Score: $score",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != Direction.up && details.delta.dy > 0) {
                  direction = Direction.down;
                } else if (direction != Direction.down &&
                    details.delta.dy < 0) {
                  direction = Direction.up;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != Direction.left && details.delta.dx > 0) {
                  direction = Direction.right;
                } else if (direction != Direction.right &&
                    details.delta.dx < 0) {
                  direction = Direction.left;
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: squaresPerRow * squaresPerCol,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: squaresPerRow,
                ),
                itemBuilder: (context, index) {
                  if (snake.contains(index)) {
                    // Head is different color
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: index == snake.first
                            ? AppTheme.primary
                            : AppTheme.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }
                  if (index == food) {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
          ),
          if (!isPlaying)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: startGame,
                  child: const Text("Start Game",
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
