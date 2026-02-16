import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../shared/glass_container.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  List<String> _board = List.filled(9, '');
  bool _isPlayerTurn = true; // Player is X
  String _winner = '';

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _isPlayerTurn = true;
      _winner = '';
    });
  }

  void _checkWinner() {
    // Win conditions
    const wins = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6] // Diagonals
    ];

    for (var w in wins) {
      if (_board[w[0]] != '' &&
          _board[w[0]] == _board[w[1]] &&
          _board[w[1]] == _board[w[2]]) {
        setState(() {
          _winner = _board[w[0]];
        });
        return;
      }
    }

    if (!_board.contains('') && _winner == '') {
      setState(() {
        _winner = 'Draw';
      });
    }
  }

  void _aiMove() {
    if (_winner != '') return;

    // Simple AI: Random empty spot
    List<int> emptySpots = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') emptySpots.add(i);
    }

    if (emptySpots.isNotEmpty) {
      final random = Random();
      int index = emptySpots[random.nextInt(emptySpots.length)];
      setState(() {
        _board[index] = 'O';
        _isPlayerTurn = true;
      });
      _checkWinner();
    }
  }

  void _handleTap(int index) {
    if (_board[index] != '' || !_isPlayerTurn || _winner != '') return;

    setState(() {
      _board[index] = 'X';
      _isPlayerTurn = false;
    });

    _checkWinner();

    if (_winner == '') {
      Future.delayed(const Duration(milliseconds: 500), _aiMove);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tic-Tac-Toe"),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_winner != '')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      _winner == 'Draw' ? "It's a Draw!" : "Winner: $_winner",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _handleTap(index),
                          child: GlassContainer(
                            color: _board[index] == ''
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white.withOpacity(0.1),
                            child: Center(
                              child: Text(
                                _board[index],
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _board[index] == 'X'
                                      ? AppTheme.primary
                                      : AppTheme.secondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_winner != '')
                  ElevatedButton(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary),
                    child: const Text("Play Again",
                        style: TextStyle(color: Colors.black)),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
