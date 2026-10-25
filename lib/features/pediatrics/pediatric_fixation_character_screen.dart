import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';

enum PediatricMascot { drIris, sparkyFox, barnabyBear }
enum FixationExerciseMode { freePlay, preferentialLooking, smoothPursuit, saccadicJumps }

class PediatricFixationCharacterScreen extends StatefulWidget {
  const PediatricFixationCharacterScreen({super.key});

  @override
  State<PediatricFixationCharacterScreen> createState() => _PediatricFixationCharacterScreenState();
}

class _PediatricFixationCharacterScreenState extends State<PediatricFixationCharacterScreen> with TickerProviderStateMixin {
  PediatricMascot _mascot = PediatricMascot.drIris;
  FixationExerciseMode _exerciseMode = FixationExerciseMode.freePlay;

  late AnimationController _idleAnimCtrl;
  late AnimationController _bounceAnimCtrl;
  late AnimationController _sparkleAnimCtrl;

  Offset _targetPosition = const Offset(0.5, 0.5); // Normalized 0.0 to 1.0
  final List<Offset> _sparkles = [];
  bool _preferentialTargetIsLeft = true;
  int _successTaps = 0;

  final List<String> _encouragements = [
    'Great job looking! 🌟',
    'Super star vision! 🦉',
    'Follow the target! 🎯',
    'You found Sparky! 🦊',
    'Awesome tracking! 🎈',
  ];
  String _currentSpeech = 'Hi there! Follow me with both eyes!';

  @override
  void initState() {
    super.initState();
    _idleAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _bounceAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _sparkleAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _idleAnimCtrl.dispose();
    _bounceAnimCtrl.dispose();
    _sparkleAnimCtrl.dispose();
    super.dispose();
  }

  void _onScreenTap(TapDownDetails details, Size screenSize) {
    final tappedPos = Offset(
      details.localPosition.dx / screenSize.width,
      details.localPosition.dy / screenSize.height,
    );

    setState(() {
      _targetPosition = tappedPos;
      _successTaps++;
      _currentSpeech = _encouragements[Random().nextInt(_encouragements.length)];

      if (_exerciseMode == FixationExerciseMode.preferentialLooking) {
        _preferentialTargetIsLeft = Random().nextBool();
      }

      _sparkles.add(details.localPosition);
      if (_sparkles.length > 8) _sparkles.removeAt(0);
    });

    _sparkleAnimCtrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pediatric Fixation & Character Lab'),
        actions: [
          PopupMenuButton<PediatricMascot>(
            icon: const Icon(Icons.face, color: Colors.amberAccent),
            tooltip: 'Select Animated Mascot',
            onSelected: (m) => setState(() => _mascot = m),
            itemBuilder: (context) => const [
              PopupMenuItem(value: PediatricMascot.drIris, child: Text('🦉 Dr. Iris the Wise Owl')),
              PopupMenuItem(value: PediatricMascot.sparkyFox, child: Text('🦊 Sparky the Cheerful Fox')),
              PopupMenuItem(value: PediatricMascot.barnabyBear, child: Text('🐻 Barnaby the Balloon Bear')),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return Column(
            children: [
              // 1. Interactive 3D/2D Animated Character Viewport
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTapDown: (details) => _onScreenTap(details, size),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getBackgroundGradient(),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Background Twinkling Stars
                        AnimatedBuilder(
                          animation: _idleAnimCtrl,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size.infinite,
                              painter: _StarfieldPainter(animValue: _idleAnimCtrl.value),
                            );
                          },
                        ),

                        // Preferential Looking High-Contrast Grating Panels
                        if (_exerciseMode == FixationExerciseMode.preferentialLooking)
                          Positioned.fill(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: _preferentialTargetIsLeft ? Colors.transparent : Colors.grey.shade900,
                                    child: _preferentialTargetIsLeft
                                        ? CustomPaint(painter: _SquareGratingPainter())
                                        : const Center(child: Text('Uniform Gray (Control)', style: TextStyle(color: Colors.grey, fontSize: 11))),
                                  ),
                                ),
                                Container(width: 3, color: Colors.amberAccent),
                                Expanded(
                                  child: Container(
                                    color: !_preferentialTargetIsLeft ? Colors.transparent : Colors.grey.shade900,
                                    child: !_preferentialTargetIsLeft
                                        ? CustomPaint(painter: _SquareGratingPainter())
                                        : const Center(child: Text('Uniform Gray (Control)', style: TextStyle(color: Colors.grey, fontSize: 11))),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Main Animated Character
                        AnimatedBuilder(
                          animation: Listenable.merge([_idleAnimCtrl, _bounceAnimCtrl]),
                          builder: (context, child) {
                            final posX = _targetPosition.dx * (constraints.maxWidth - 120);
                            final posY = _targetPosition.dy * (constraints.maxHeight * 0.5);

                            return Positioned(
                              left: posX.clamp(10.0, constraints.maxWidth - 140),
                              top: posY.clamp(10.0, (constraints.maxHeight * 0.5) - 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Speech Bubble
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                                    ),
                                    child: Text(
                                      _currentSpeech,
                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Character Vector Body
                                  Transform.translate(
                                    offset: Offset(0, sin(_bounceAnimCtrl.value * pi) * -12),
                                    child: CustomPaint(
                                      size: const Size(120, 120),
                                      painter: _MascotPainter(
                                        mascot: _mascot,
                                        idleValue: _idleAnimCtrl.value,
                                        bounceValue: _bounceAnimCtrl.value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Touch Sparkle Bursts
                        ..._sparkles.map((sp) {
                          return Positioned(
                            left: sp.dx - 20,
                            top: sp.dy - 20,
                            child: AnimatedBuilder(
                              animation: _sparkleAnimCtrl,
                              builder: (context, child) {
                                final s = _sparkleAnimCtrl.value;
                                return Opacity(
                                  opacity: (1.0 - s).clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: 1.0 + (s * 1.5),
                                    child: const Icon(Icons.star, color: Colors.amberAccent, size: 36),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Pediatric Clinical Control Dashboard
              Expanded(
                flex: 4,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Mascot Selector Bar
                    SamsungOneUiGroupCard(
                      title: 'PEDIATRIC FIXATION MASCOT',
                      icon: Icons.pets,
                      child: Row(
                        children: [
                          _buildMascotTab(PediatricMascot.drIris, 'Dr. Iris (Owl)', Icons.school),
                          const SizedBox(width: 8),
                          _buildMascotTab(PediatricMascot.sparkyFox, 'Sparky (Fox)', Icons.pets),
                          const SizedBox(width: 8),
                          _buildMascotTab(PediatricMascot.barnabyBear, 'Barnaby (Bear)', Icons.toys),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Exercise Mode Selector
                    SamsungOneUiGroupCard(
                      title: 'CLINICAL FIXATION PROTOCOL',
                      icon: Icons.track_changes,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildExerciseButton(FixationExerciseMode.freePlay, 'Free Fixation Target', Icons.touch_app),
                              const SizedBox(width: 8),
                              _buildExerciseButton(FixationExerciseMode.preferentialLooking, 'Preferential Looking (Teller)', Icons.grid_4x4),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildExerciseButton(FixationExerciseMode.smoothPursuit, 'Smooth Pursuit Glide', Icons.timeline),
                              const SizedBox(width: 8),
                              _buildExerciseButton(FixationExerciseMode.saccadicJumps, 'Saccadic Jumps Rock', Icons.speed),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Engagement Score: $_successTaps Fixations', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent)),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.replay, size: 14),
                                label: const Text('Reset', style: TextStyle(fontSize: 11)),
                                onPressed: () => setState(() {
                                  _successTaps = 0;
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMascotTab(PediatricMascot m, String label, IconData icon) {
    final isSelected = _mascot == m;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mascot = m),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.cyan.withValues(alpha: 0.2) : Colors.black12,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.blueGrey.shade700, width: isSelected ? 1.5 : 1.0),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.cyanAccent : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.cyanAccent : Colors.white), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseButton(FixationExerciseMode mode, String label, IconData icon) {
    final isSelected = _exerciseMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _exerciseMode = mode),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber.withValues(alpha: 0.2) : Colors.black12,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.amberAccent : Colors.blueGrey.shade700, width: isSelected ? 1.5 : 1.0),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.amberAccent : Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.amberAccent : Colors.white), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getBackgroundGradient() {
    switch (_mascot) {
      case PediatricMascot.drIris:
        return const [Color(0xFF0F172A), Color(0xFF1E1B4B)];
      case PediatricMascot.sparkyFox:
        return const [Color(0xFF451A03), Color(0xFF1E293B)];
      case PediatricMascot.barnabyBear:
        return const [Color(0xFF14532D), Color(0xFF0F172A)];
    }
  }
}

class _MascotPainter extends CustomPainter {
  final PediatricMascot mascot;
  final double idleValue;
  final double bounceValue;

  _MascotPainter({required this.mascot, required this.idleValue, required this.bounceValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (mascot) {
      case PediatricMascot.drIris:
        _drawOwl(canvas, center, size);
        break;
      case PediatricMascot.sparkyFox:
        _drawFox(canvas, center, size);
        break;
      case PediatricMascot.barnabyBear:
        _drawBear(canvas, center, size);
        break;
    }
  }

  void _drawOwl(Canvas canvas, Offset center, Size size) {
    // Owl Body
    final Paint bodyPaint = Paint()..color = const Color(0xFF3B82F6);
    canvas.drawOval(Rect.fromCenter(center: center, width: 75, height: 85), bodyPaint);

    // Owl Belly
    final Paint bellyPaint = Paint()..color = const Color(0xFF93C5FD);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + 12), width: 50, height: 50), bellyPaint);

    // Large Eyes (High contrast pediatric appeal)
    final eyeRadius = 16.0;
    final leftEyeCenter = Offset(center.dx - 18, center.dy - 14);
    final rightEyeCenter = Offset(center.dx + 18, center.dy - 14);

    final Paint whiteEye = Paint()..color = Colors.white;
    final Paint pupil = Paint()..color = Colors.black;
    final Paint specular = Paint()..color = Colors.white;

    canvas.drawCircle(leftEyeCenter, eyeRadius, whiteEye);
    canvas.drawCircle(rightEyeCenter, eyeRadius, whiteEye);

    // Animated blinking
    final double blinkScale = (sin(idleValue * 2 * pi) > 0.9) ? 0.1 : 1.0;
    final pupilOffset = Offset(sin(bounceValue * pi) * 2, 0);

    canvas.drawOval(Rect.fromCenter(center: leftEyeCenter + pupilOffset, width: 14, height: 14 * blinkScale), pupil);
    canvas.drawOval(Rect.fromCenter(center: rightEyeCenter + pupilOffset, width: 14, height: 14 * blinkScale), pupil);

    if (blinkScale > 0.5) {
      canvas.drawCircle(leftEyeCenter + pupilOffset - const Offset(2, 2), 3, specular);
      canvas.drawCircle(rightEyeCenter + pupilOffset - const Offset(2, 2), 3, specular);
    }

    // Beak
    final Paint beak = Paint()..color = Colors.orangeAccent;
    final Path beakPath = Path()
      ..moveTo(center.dx - 6, center.dy - 4)
      ..lineTo(center.dx + 6, center.dy - 4)
      ..lineTo(center.dx, center.dy + 8)
      ..close();
    canvas.drawPath(beakPath, beak);

    // Graduation / Doctor Hat
    final Paint hat = Paint()..color = const Color(0xFF1E293B);
    final Path hatPath = Path()
      ..moveTo(center.dx, center.dy - 48)
      ..lineTo(center.dx + 26, center.dy - 36)
      ..lineTo(center.dx, center.dy - 24)
      ..lineTo(center.dx - 26, center.dy - 36)
      ..close();
    canvas.drawPath(hatPath, hat);
  }

  void _drawFox(Canvas canvas, Offset center, Size size) {
    // Fox Head
    final Paint orange = Paint()..color = const Color(0xFFEA580C);
    final Path head = Path()
      ..moveTo(center.dx, center.dy + 25)
      ..lineTo(center.dx + 35, center.dy - 15)
      ..lineTo(center.dx + 25, center.dy - 42) // Right ear tip
      ..lineTo(center.dx + 8, center.dy - 20)
      ..lineTo(center.dx - 8, center.dy - 20)
      ..lineTo(center.dx - 25, center.dy - 42) // Left ear tip
      ..lineTo(center.dx - 35, center.dy - 15)
      ..close();
    canvas.drawPath(head, orange);

    // Cheeks
    final Paint white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 14, center.dy + 5), 10, white);
    canvas.drawCircle(Offset(center.dx + 14, center.dy + 5), 10, white);

    // Eyes
    final Paint black = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - 12, center.dy - 4), 5, black);
    canvas.drawCircle(Offset(center.dx + 12, center.dy - 4), 5, black);
    canvas.drawCircle(Offset(center.dx - 14, center.dy - 6), 2, white);
    canvas.drawCircle(Offset(center.dx + 10, center.dy - 6), 2, white);

    // Nose
    canvas.drawCircle(Offset(center.dx, center.dy + 18), 4, black);
  }

  void _drawBear(Canvas canvas, Offset center, Size size) {
    // Bear Head & Ears
    final Paint brown = Paint()..color = const Color(0xFF78350F);
    final Paint innerEar = Paint()..color = const Color(0xFFFDE68A);

    // Ears
    canvas.drawCircle(Offset(center.dx - 26, center.dy - 26), 14, brown);
    canvas.drawCircle(Offset(center.dx + 26, center.dy - 26), 14, brown);
    canvas.drawCircle(Offset(center.dx - 26, center.dy - 26), 8, innerEar);
    canvas.drawCircle(Offset(center.dx + 26, center.dy - 26), 8, innerEar);

    // Head
    canvas.drawCircle(center, 34, brown);

    // Muzzle
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + 8), width: 34, height: 26), innerEar);
    canvas.drawCircle(Offset(center.dx, center.dy + 4), 6, Paint()..color = Colors.black);

    // Eyes
    canvas.drawCircle(Offset(center.dx - 12, center.dy - 8), 5, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(center.dx + 12, center.dy - 8), 5, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(center.dx - 14, center.dy - 10), 2, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(center.dx + 10, center.dy - 10), 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) => true;
}

class _StarfieldPainter extends CustomPainter {
  final double animValue;
  _StarfieldPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);

    for (int i = 0; i < 35; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = (rand.nextDouble() * 2.5 + 1.0) * (0.6 + sin(animValue * 2 * pi + i) * 0.4);
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => true;
}

class _SquareGratingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripeWidth = 14.0;
    final Paint black = Paint()..color = Colors.black;
    final Paint white = Paint()..color = Colors.white;

    for (double x = 0; x < size.width; x += stripeWidth * 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), black);
      canvas.drawRect(Rect.fromLTWH(x + stripeWidth, 0, stripeWidth, size.height), white);
    }
  }

  @override
  bool shouldRepaint(covariant _SquareGratingPainter oldDelegate) => false;
}
