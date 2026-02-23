import 'package:flutter/material.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  // Game state
  final String _targetWord =
      "REACT"; // In a real app, pick randomly from a list
  final int _maxAttempts = 6;
  final int _wordLength = 5;

  List<String> _guesses = [];
  String _currentGuess = "";
  bool _gameOver = false;

  void _onKeyPressed(String key) {
    if (_gameOver) return;

    if (key == 'ENTER') {
      if (_currentGuess.length == _wordLength) {
        setState(() {
          _guesses.add(_currentGuess);
          if (_currentGuess == _targetWord) {
            _gameOver = true;
            _showResultDialog(true);
          } else if (_guesses.length >= _maxAttempts) {
            _gameOver = true;
            _showResultDialog(false);
          }
          _currentGuess = "";
        });
      }
    } else if (key == 'DEL') {
      if (_currentGuess.isNotEmpty) {
        setState(() {
          _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
        });
      }
    } else {
      if (_currentGuess.length < _wordLength) {
        setState(() {
          _currentGuess += key;
        });
      }
    }
  }

  void _showResultDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(won ? "Excellent!" : "Game Over"),
        content: Text(
            won ? "You guessed $_targetWord!" : "The word was $_targetWord."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _guesses = [];
      _currentGuess = "";
      _gameOver = false;
      _gameOver = false;
      // Also pick new word here
    });
  }

  Color _getKeyColor(String char) {
    // Check if char is in any guess and what its status is
    Color color = Colors.grey.withOpacity(0.3);
    for (var guess in _guesses) {
      for (int i = 0; i < _wordLength; i++) {
        if (guess[i] == char) {
          if (_targetWord[i] == char) return Colors.green; // Exact match
          if (_targetWord.contains(char))
            color = Colors.orangeAccent; // Wrong spot
          else if (color != Colors.orangeAccent)
            color = Colors.grey.withOpacity(0.1); // Not in word
        }
      }
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: const Text("Wordle"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetGame),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(_maxAttempts, (i) => _buildRow(i)),
                ],
              ),
            ),
          ),
          _buildKeyboard(),
        ],
      ),
    );
  }

  Widget _buildRow(int rowIndex) {
    String word = "";
    if (rowIndex < _guesses.length) {
      word = _guesses[rowIndex];
    } else if (rowIndex == _guesses.length) {
      word = _currentGuess.padRight(_wordLength, " ");
    } else {
      word = "     ";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_wordLength, (i) {
        String char = word[i].trim();
        Color color = Colors.transparent;
        Color borderColor = Colors.grey;

        if (rowIndex < _guesses.length) {
          if (char.isNotEmpty && _targetWord[i] == char) {
            color = Colors.green;
            borderColor = Colors.green;
          } else if (char.isNotEmpty && _targetWord.contains(char)) {
            color = Colors.orangeAccent;
            borderColor = Colors.orangeAccent;
          } else {
            color = Colors.grey.withOpacity(0.2);
            borderColor = Colors.grey.withOpacity(0.2);
          }
        }

        return Container(
          margin: const EdgeInsets.all(4),
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            char,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeyboard() {
    const keys = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"];

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ...keys.map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.split('').map((char) {
                  return _buildKey(char);
                }).toList(),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton("ENTER", Colors.blueAccent),
              _buildActionButton("DEL", Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildKey(String char) {
    return GestureDetector(
      onTap: () => _onKeyPressed(char),
      child: Container(
        margin: const EdgeInsets.all(3),
        width: 35,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _getKeyColor(char),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(char,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return GestureDetector(
      onTap: () => _onKeyPressed(label),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 70,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
