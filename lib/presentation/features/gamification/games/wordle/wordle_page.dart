import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/gamification_provider.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  static const List<String> _wordList = [
    'REACT', 'FLAME', 'BRAIN', 'STUDY', 'FOCUS',
    'SWIFT', 'GRADE', 'LEARN', 'NOTES', 'LOGIC',
  ];

  late String _targetWord;
  final int _maxAttempts = 6;
  final int _wordLength = 5;

  List<String> _guesses = [];
  String _currentGuess = '';
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _targetWord = (_wordList..shuffle()).first;
  }

  void _onKeyPressed(String key) {
    if (_gameOver) return;
    if (key == 'ENTER') {
      if (_currentGuess.length == _wordLength) {
        final won = _currentGuess == _targetWord;
        setState(() {
          _guesses.add(_currentGuess);
          if (won || _guesses.length >= _maxAttempts) {
            _gameOver = true;
            _showResultDialog(won);
          }
          _currentGuess = '';
        });
      }
    } else if (key == 'DEL') {
      if (_currentGuess.isNotEmpty) {
        setState(() => _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1));
      }
    } else {
      if (_currentGuess.length < _wordLength) {
        setState(() => _currentGuess += key);
      }
    }
  }

  void _showResultDialog(bool won) {
    // XP: 50 for winning; bonus for fewer guesses; 0 for losing
    int xpEarned = 0;
    if (won) {
      final guessCount = _guesses.length;
      xpEarned = guessCount <= 3 ? 70 : (guessCount <= 5 ? 50 : 30);
    }

    if (xpEarned > 0) {
      context.read<GamificationProvider>().addXP(xpEarned);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        title: Text(
          won ? '🎉 Excellent!' : '😞 Game Over',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              won
                  ? 'You guessed "$_targetWord" in ${_guesses.length} tries!'
                  : 'The word was "$_targetWord".',
              style: const TextStyle(color: Colors.white70),
            ),
            if (xpEarned > 0) ...[
              const SizedBox(height: 8),
              Text('+$xpEarned XP earned!',
                  style: const TextStyle(
                      color: Color(0xFF00F0FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
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

  void _resetGame() {
    setState(() {
      _targetWord = (_wordList..shuffle()).first;
      _guesses = [];
      _currentGuess = '';
      _gameOver = false;
    });
  }

  Color _getKeyColor(String char) {
    Color color = Colors.grey.withOpacity(0.3);
    for (var guess in _guesses) {
      for (int i = 0; i < _wordLength; i++) {
        if (i < guess.length && guess[i] == char) {
          if (_targetWord[i] == char) return Colors.green;
          if (_targetWord.contains(char)) color = Colors.orangeAccent;
          else if (color != Colors.orangeAccent) color = Colors.grey.withOpacity(0.1);
        }
      }
    }
    return color;
  }

  Widget _buildRow(int rowIndex) {
    String word = '';
    if (rowIndex < _guesses.length) {
      word = _guesses[rowIndex];
    } else if (rowIndex == _guesses.length) {
      word = _currentGuess.padRight(_wordLength, ' ');
    } else {
      word = '     ';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_wordLength, (i) {
          String char = i < word.length ? word[i].trim() : '';
          Color color = Colors.transparent;
          Color borderColor = Colors.grey;

          if (rowIndex < _guesses.length) {
            if (char.isNotEmpty && _targetWord[i] == char) {
              color = Colors.green; borderColor = Colors.green;
            } else if (char.isNotEmpty && _targetWord.contains(char)) {
              color = Colors.orangeAccent; borderColor = Colors.orangeAccent;
            } else {
              color = Colors.grey.withOpacity(0.2); borderColor = Colors.grey.withOpacity(0.2);
            }
          }

          return Container(
            margin: const EdgeInsets.all(4),
            width: 50, height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(char,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          );
        }),
      ),
    );
  }

  Widget _buildKeyboard() {
    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(children: [
        ...rows.map((row) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.split('').map((c) => _buildKey(c)).toList(),
        )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildActionButton('ENTER', Colors.blueAccent),
          _buildActionButton('DEL', Colors.redAccent),
        ]),
      ]),
    );
  }

  Widget _buildKey(String char) {
    return GestureDetector(
      onTap: () => _onKeyPressed(char),
      child: Container(
        margin: const EdgeInsets.all(3),
        width: 35, height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _getKeyColor(char),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(char,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return GestureDetector(
      onTap: () => _onKeyPressed(label),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 70, height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: const Text('Wordle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _resetGame)],
      ),
      body: Column(children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_maxAttempts, (i) => _buildRow(i)),
            ),
          ),
        ),
        _buildKeyboard(),
      ]),
    );
  }
}
