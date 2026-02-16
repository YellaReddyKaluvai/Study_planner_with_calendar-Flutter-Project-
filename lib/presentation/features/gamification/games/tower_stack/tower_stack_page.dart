import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class TowerStackPage extends StatefulWidget {
  const TowerStackPage({super.key});

  @override
  State<TowerStackPage> createState() => _TowerStackPageState();
}

class _TowerStackPageState extends State<TowerStackPage>
    with TickerProviderStateMixin {
  int _score = 0;
  bool _gameOver = false;
  bool _isPlaying = false;

  // Blocks
  final List<Block> _blocks = [];
  final double _blockHeight = 50.0;
  final double _initialWidth = 200.0;

  // Animation
  late AnimationController _controller;
  double _currentOffset = 0.0;
  double _direction = 1.0;
  double _speed = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_updateLoop);

    // Start with a base block
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _blocks.clear();
      _blocks.add(Block(
        width: _initialWidth,
        offset: 0,
        color: AppTheme.primary,
        level: 0,
      ));
      _score = 0;
      _gameOver = false;
      _isPlaying = false;
      _currentOffset = -200; // Start off screen
      _direction = 1.0;
      _speed = 3.0; // Reset speed
    });
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _gameOver = false;
    });
    _spawnNextBlock();
    _controller.repeat();
  }

  void _spawnNextBlock() {
    _currentOffset = -200; // Start from left
    _direction = 3.0; // Positive speed
  }

  void _updateLoop() {
    if (_gameOver || !_isPlaying) return;

    setState(() {
      _currentOffset += _direction * _speed;
      if (_currentOffset > 200) {
        _direction = -1.0;
      } else if (_currentOffset < -200) {
        _direction = 1.0;
      }
    });
  }

  void _placeBlock() {
    if (_gameOver || !_isPlaying) {
      if (!_isPlaying && !_gameOver) _startGame();
      return;
    }

    final topBlock = _blocks.last;
    final double diff = _currentOffset - topBlock.offset;
    final double absDiff = diff.abs();

    if (absDiff > topBlock.width) {
      // Missed completely
      _endGame();
    } else {
      // Landed
      final double newWidth = topBlock.width - absDiff;
      final double newOffset = topBlock.offset + diff / 2;

      setState(() {
        _blocks.add(Block(
          width: newWidth,
          offset: newOffset,
          color: _getNextColor(_blocks.length),
          level: _blocks.length,
        ));
        _score++;
        _speed += 0.2; // Increase speed
      });
      _spawnNextBlock();
    }
  }

  void _endGame() {
    _controller.stop();
    setState(() {
      _gameOver = true;
      _isPlaying = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("You stacked $_score blocks!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
              _startGame();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  Color _getNextColor(int level) {
    const colors = [
      AppTheme.primary,
      AppTheme.secondary,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.greenAccent,
      Colors.redAccent,
    ];
    return colors[level % colors.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Tower Stack"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
              padding: const EdgeInsets.all(16),
              child:
                  Text("Score: $_score", style: const TextStyle(fontSize: 18)))
        ],
      ),
      body: GestureDetector(
        onTap: _placeBlock,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E17), Color(0xFF161B28)],
            ),
          ),
          child: Stack(
            children: [
              // Instructions
              if (!_isPlaying && !_gameOver)
                const Center(
                    child: Text("Tap to Start & Stack",
                        style: TextStyle(color: Colors.white54, fontSize: 24))),

              // Game Area
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Stacked Blocks
                    ..._blocks.map((block) => Positioned(
                          bottom: block.level * _blockHeight,
                          left: (MediaQuery.of(context).size.width / 2) +
                              block.offset -
                              (block.width / 2),
                          child: Container(
                            width: block.width,
                            height: _blockHeight,
                            decoration: BoxDecoration(
                                color: block.color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                      color: block.color.withOpacity(0.5),
                                      blurRadius: 10)
                                ]),
                          ),
                        )),

                    // Current Moving Block
                    if (_isPlaying)
                      Positioned(
                        bottom: _blocks.length * _blockHeight,
                        left: (MediaQuery.of(context).size.width / 2) +
                            _currentOffset -
                            (_blocks.last.width / 2),
                        child: Container(
                          width: _blocks.last.width,
                          height: _blockHeight,
                          decoration: BoxDecoration(
                              color: _getNextColor(_blocks.length),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                    color: _getNextColor(_blocks.length)
                                        .withOpacity(0.5),
                                    blurRadius: 10)
                              ]),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Block {
  final double width;
  final double offset; // From center
  final Color color;
  final int level;

  Block({
    required this.width,
    required this.offset,
    required this.color,
    required this.level,
  });
}
