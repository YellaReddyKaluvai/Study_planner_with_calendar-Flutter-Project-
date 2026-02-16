import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TetrisPage extends StatefulWidget {
  const TetrisPage({super.key});

  @override
  State<TetrisPage> createState() => _TetrisPageState();
}

class _TetrisPageState extends State<TetrisPage> {
  // Board dimensions
  static const int rows = 20;
  static const int cols = 10;

  // Game state
  List<List<Color?>> board =
      List.generate(rows, (_) => List.filled(cols, null));
  int score = 0;
  bool isGameOver = false;
  bool isPaused = false;
  Timer? _timer;

  // Current Piece
  List<Point<int>> currentPiece = [];
  Color currentColor = Colors.cyan;
  Point<int> currentPos = const Point(0, 4);

  // Shapes (relative coordinates)
  final List<List<Point<int>>> shapes = [
    [
      const Point(0, 0),
      const Point(0, 1),
      const Point(0, 2),
      const Point(0, 3)
    ], // I
    [
      const Point(0, 0),
      const Point(1, 0),
      const Point(0, 1),
      const Point(1, 1)
    ], // O
    [
      const Point(0, 0),
      const Point(1, 0),
      const Point(1, 1),
      const Point(2, 1)
    ], // S
    [
      const Point(0, 1),
      const Point(1, 1),
      const Point(1, 0),
      const Point(2, 0)
    ], // Z
    [
      const Point(0, 0),
      const Point(1, 0),
      const Point(2, 0),
      const Point(2, 1)
    ], // L
    [
      const Point(0, 1),
      const Point(1, 1),
      const Point(2, 1),
      const Point(2, 0)
    ], // J
    [
      const Point(0, 1),
      const Point(1, 0),
      const Point(1, 1),
      const Point(1, 2)
    ], // T
  ];

  final List<Color> colors = [
    Colors.cyan,
    Colors.yellow,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.blue,
    Colors.purple
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      board = List.generate(rows, (_) => List.filled(cols, null));
      score = 0;
      isGameOver = false;
      isPaused = false;
      _spawnPiece();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!isPaused && !isGameOver) {
        _moveDown();
      }
    });
  }

  void _spawnPiece() {
    final random = Random();
    int index = random.nextInt(shapes.length);
    currentPiece = List.from(shapes[index]);
    currentColor = colors[index];
    currentPos = const Point(0, 4);

    if (!_isValidMove(currentPos, currentPiece)) {
      setState(() {
        isGameOver = true;
        _timer?.cancel();
      });
    }
  }

  bool _isValidMove(Point<int> pos, List<Point<int>> piece) {
    for (var point in piece) {
      int r = pos.x + point.x;
      int c = pos.y + point.y;
      if (r < 0 ||
          r >= rows ||
          c < 0 ||
          c >= cols ||
          (r >= 0 && board[r][c] != null)) {
        return false;
      }
    }
    return true;
  }

  void _moveDown() {
    if (_isValidMove(Point(currentPos.x + 1, currentPos.y), currentPiece)) {
      setState(() {
        currentPos = Point(currentPos.x + 1, currentPos.y);
      });
    } else {
      _lockPiece();
    }
  }

  void _lockPiece() {
    setState(() {
      for (var point in currentPiece) {
        int r = currentPos.x + point.x;
        int c = currentPos.y + point.y;
        if (r >= 0 && r < rows && c >= 0 && c < cols) {
          board[r][c] = currentColor;
        }
      }
      _clearLines();
      _spawnPiece();
    });
  }

  void _clearLines() {
    int linesCleared = 0;
    for (int r = rows - 1; r >= 0; r--) {
      if (board[r].every((cell) => cell != null)) {
        board.removeAt(r);
        board.insert(0, List.filled(cols, null));
        linesCleared++;
        r++; // Check same row again as it's now a new row
      }
    }
    if (linesCleared > 0) {
      score += linesCleared * 100;
    }
  }

  void _moveLeft() {
    if (!isPaused &&
        !isGameOver &&
        _isValidMove(Point(currentPos.x, currentPos.y - 1), currentPiece)) {
      setState(() {
        currentPos = Point(currentPos.x, currentPos.y - 1);
      });
    }
  }

  void _moveRight() {
    if (!isPaused &&
        !isGameOver &&
        _isValidMove(Point(currentPos.x, currentPos.y + 1), currentPiece)) {
      setState(() {
        currentPos = Point(currentPos.x, currentPos.y + 1);
      });
    }
  }

  void _rotate() {
    if (isPaused || isGameOver) return;
    List<Point<int>> newPiece = [];
    for (var point in currentPiece) {
      newPiece.add(Point(point.y, -point.x)); // 90 degree rotation
    }

    // Normalize to handle offsets from rotation center (simplified)
    // A better rotation system (SRS) is complex, using simple pivot here
    if (_isValidMove(currentPos, newPiece)) {
      setState(() {
        currentPiece = newPiece;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tetris"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Score: $score", style: const TextStyle(fontSize: 18)),
          ),
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () => setState(() => isPaused = !isPaused),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startGame,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E17), Color(0xFF161B28)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: cols / rows,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 2),
                      color: Colors.black54,
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                      ),
                      itemCount: rows * cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ cols;
                        int c = index % cols;
                        Color? cellColor = board[r][c];

                        // Draw current piece
                        if (cellColor == null) {
                          for (var point in currentPiece) {
                            if (currentPos.x + point.x == r &&
                                currentPos.y + point.y == c) {
                              cellColor = currentColor;
                              break;
                            }
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: cellColor ?? Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Controls
            if (isGameOver)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("GAME OVER",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 40),
                      onPressed: _moveLeft,
                    ),
                    IconButton(
                      icon: const Icon(Icons.rotate_right,
                          color: Colors.white, size: 40),
                      onPressed: _rotate,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 40),
                      onPressed: _moveRight,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward,
                          color: Colors.white, size: 40),
                      onPressed: _moveDown,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
