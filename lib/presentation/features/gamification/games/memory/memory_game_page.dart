import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../providers/gamification_provider.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  final List<IconData> _icons = [
    Icons.science, Icons.menu_book, Icons.calculate,
    Icons.computer, Icons.language, Icons.brush,
    Icons.science, Icons.menu_book, Icons.calculate,
    Icons.computer, Icons.language, Icons.brush,
  ];

  List<bool> _flipped = [];
  List<bool> _matched = [];
  int _prevIndex = -1;
  bool _lockBoard = false;
  int _score = 0;
  int _tries = 0;
  bool _xpAwarded = false;

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
    _xpAwarded = false;
    setState(() {});
  }

  void _flipCard(int index) {
    if (_lockBoard || _flipped[index] || _matched[index]) return;

    setState(() => _flipped[index] = true);

    if (_prevIndex == -1) {
      _prevIndex = index;
    } else {
      _lockBoard = true;
      _tries++;
      if (_icons[index] == _icons[_prevIndex]) {
        setState(() {
          _matched[index] = true;
          _matched[_prevIndex] = true;
          _score += 100;
          _lockBoard = false;
          _prevIndex = -1;
        });
        _checkWin();
      } else {
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
    if (!_matched.every((e) => e)) return;
    if (_xpAwarded) return;
    _xpAwarded = true;

    // Award XP: 40 base, bonus for fewer tries
    final bonus = (_tries <= 10) ? 20 : (_tries <= 15 ? 10 : 0);
    final xpEarned = 40 + bonus;
    context.read<GamificationProvider>().addXP(xpEarned);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        title: const Text('Memory Master! 🧠', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Solved in $_tries tries!',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('+$xpEarned XP earned!',
                style: const TextStyle(
                    color: Color(0xFF00F0FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            if (bonus > 0)
              Text('(+$bonus bonus for ${_tries <= 10 ? "excellent" : "good"} performance!)',
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Tries: $_tries', style: const TextStyle(fontSize: 16)),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              ),
                          ],
                        ),
                        child: _flipped[index] || _matched[index]
                            ? Icon(_icons[index], size: 40, color: Colors.white)
                            : const Icon(Icons.question_mark,
                                size: 40, color: Colors.white24),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
