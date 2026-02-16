import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  // 6 pairs of icons for a 4x3 grid
  final List<IconData> _icons = [
    Icons.science,
    Icons.menu_book,
    Icons.calculate,
    Icons.computer,
    Icons.language,
    Icons.brush,
    Icons.science,
    Icons.menu_book,
    Icons.calculate,
    Icons.computer,
    Icons.language,
    Icons.brush,
  ];

  List<bool> _flipped = [];
  List<bool> _matched = [];
  int _prevIndex = -1;
  bool _lockBoard = false;
  int _score = 0;
  int _tries = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    _icons.shuffle();
    _flipped = List.generate(12, (_) => false);
    _matched = List.generate(12, (_) => false);
    _prevIndex = -1;
    _lockBoard = false;
    _score = 0;
    _tries = 0;
    setState(() {});
  }

  void _flipCard(int index) {
    if (_lockBoard || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;
    });

    if (_prevIndex == -1) {
      _prevIndex = index;
    } else {
      _lockBoard = true;
      _tries++;
      if (_icons[index] == _icons[_prevIndex]) {
        // Match
        setState(() {
          _matched[index] = true;
          _matched[_prevIndex] = true;
          _score += 100;
          _lockBoard = false;
          _prevIndex = -1;
        });
        _checkWin();
      } else {
        // No Match
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _flipped[index] = false;
              _flipped[_prevIndex] = false;
              _lockBoard = false;
              _prevIndex = -1;
            });
          }
        });
      }
    }
  }

  void _checkWin() {
    if (_matched.every((element) => element)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Memory Master!"),
          content: Text("You won in $_tries tries!\nScore: $_score"),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Memory Match"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Tries: $_tries",
                    style: const TextStyle(fontSize: 16)))
          ]),
      extendBodyBehindAppBar: true,
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E17), Color(0xFF161B28)],
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _flipCard(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                                color: _flipped[index] || _matched[index]
                                    ? AppTheme.primary
                                    : Colors.white12,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  if (_flipped[index] || _matched[index])
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                ]),
                            child: _flipped[index] || _matched[index]
                                ? Icon(_icons[index],
                                    size: 40, color: Colors.white)
                                : const Icon(Icons.question_mark,
                                    size: 40, color: Colors.white24),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ))),
    );
  }
}
