import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DichopticGameScreen extends StatefulWidget {
  const DichopticGameScreen({super.key});

  @override
  State<DichopticGameScreen> createState() => _DichopticGameScreenState();
}

class _DichopticGameScreenState extends State<DichopticGameScreen> {
  double _playerX = 0;
  double _playerY = 0;
  double _targetX = 0;
  double _targetY = 0;
  int _score = 0;
  Timer? _timer;
  final Random _random = Random();
  bool _isPlaying = false;

  void _startGame() {
    setState(() {
      _score = 0;
      _isPlaying = true;
      _moveTarget();
    });
    
    // Timer to gradually move the target if the user doesn't catch it
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isPlaying) _moveTarget();
    });
  }

  void _stopGame() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  void _moveTarget() {
    setState(() {
      // Keep within bounds of a typical screen for simplicity (-1 to 1 space roughly)
      _targetX = (_random.nextDouble() * 2) - 1;
      _targetY = (_random.nextDouble() * 2) - 1;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isPlaying) return;
    
    // Translate screen pixels to roughly -1 to 1 coordinate space
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    setState(() {
      _playerX += (details.delta.dx / (size.width / 2));
      _playerY += (details.delta.dy / (size.height / 2));
      
      // Clamp to screen
      _playerX = _playerX.clamp(-1.0, 1.0);
      _playerY = _playerY.clamp(-1.0, 1.0);
      
      _checkCollision();
    });
  }
  
  void _checkCollision() {
    final distance = sqrt(pow(_playerX - _targetX, 2) + pow(_playerY - _targetY, 2));
    if (distance < 0.2) {
      setState(() {
        _score++;
        _moveTarget();
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
      backgroundColor: Colors.black, // Crucial for red/green cancellation
      appBar: AppBar(
        title: const Text('Dichoptic Training'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_isPlaying)
            IconButton(
              icon: const Icon(Icons.pause),
              tooltip: 'End Session',
              onPressed: _stopGame,
            ),
        ],
      ),
      body: !_isPlaying
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility, color: Colors.cyanAccent, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Put on your Red/Green glasses!',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Target (Red) is visible to the Green eye.\nPlayer (Green) is visible to the Red eye.\n\nYou must use BOTH eyes simultaneously to solve the puzzle and break macular suppression.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                    ),
                    if (_score > 0) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Last Session Score: $_score targets caught',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Therapy Session', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    )
                  ],
                ),
              ),
            )
          : GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: Stack(
                children: [
                  // Target (Red) - Only visible to eye looking through Green filter
                  Align(
                    alignment: Alignment(_targetX, _targetY),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.red, // Pure red
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // Player (Green) - Only visible to eye looking through Red filter
                  Align(
                    alignment: Alignment(_playerX, _playerY),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green, // Pure green
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.touch_app, color: Colors.white),
                    ),
                  ),
                  
                  // Score
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Score: $_score',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      onPressed: _stopGame,
                      icon: const Icon(Icons.stop, size: 16),
                      label: const Text('Finish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
