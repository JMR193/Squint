import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ContrastDichopticGameScreen extends StatefulWidget {
  const ContrastDichopticGameScreen({super.key});

  @override
  State<ContrastDichopticGameScreen> createState() => _ContrastDichopticGameScreenState();
}

class _ContrastDichopticGameScreenState extends State<ContrastDichopticGameScreen> {
  // Dichoptic Therapy Settings
  // Amblyopic Eye (AE) is always presented at 100% contrast to maximize neuroplastic drive.
  // Sound / Fellow Eye (FE) contrast is attenuated (Dynamic Contrast Penalization - DCP)
  // to break interocular cortical suppression.
  bool _soundEyeIsRight = false; // default: Left is Sound, Right is Amblyopic
  double _soundEyeContrast = 0.35; // 35% starting contrast
  bool _anaglyphMode = true; // true = Red/Cyan glasses mode, false = split / brightness mode

  // Game state
  int _score = 0;
  int _targetsRemaining = 8;
  int _sessionSeconds = 180; // 3-minute round
  Timer? _sessionTimer;
  bool _isPlaying = false;
  bool _roundCompleted = false;

  // Grid / visual items
  // Board elements: Target symbols (AE) vs Distractor background noise (FE)
  late List<_DichopticItem> _items;
  final Random _random = Random();
  String _targetSymbol = '★';
  final List<String> _distractorSymbols = ['●', '▲', '■', '◆', '✚'];

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _resetBoard() {
    _items = [];
    _targetsRemaining = 6 + _random.nextInt(3); // 6-8 targets
    
    // Choose a random target symbol
    final allSymbols = ['★', '⚡', '♥', '✿', '✦'];
    _targetSymbol = allSymbols[_random.nextInt(allSymbols.length)];

    // Create 30 items for a 6x5 grid
    int targetsPlaced = 0;
    List<bool> isTargetList = List.generate(30, (index) => false);
    while (targetsPlaced < _targetsRemaining) {
      int idx = _random.nextInt(30);
      if (!isTargetList[idx]) {
        isTargetList[idx] = true;
        targetsPlaced++;
      }
    }

    for (int i = 0; i < 30; i++) {
      if (isTargetList[i]) {
        _items.add(_DichopticItem(
          id: i,
          symbol: _targetSymbol,
          isTarget: true,
          // Targets belong to the Amblyopic Eye (AE)
          isAmblyopicTarget: true,
        ));
      } else {
        _items.add(_DichopticItem(
          id: i,
          symbol: _distractorSymbols[_random.nextInt(_distractorSymbols.length)],
          isTarget: false,
          // Distractors/surround belong to the Sound Fellow Eye (FE)
          isAmblyopicTarget: false,
        ));
      }
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _sessionSeconds = 180;
      _isPlaying = true;
      _roundCompleted = false;
      _resetBoard();
    });

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_sessionSeconds > 0) {
        setState(() {
          _sessionSeconds--;
        });
      } else {
        _stopGame();
      }
    });
  }

  void _stopGame() {
    _sessionTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _roundCompleted = true;
    });
  }

  void _handleItemTap(_DichopticItem item) {
    if (!_isPlaying || item.isCollected) return;

    if (item.isTarget) {
      setState(() {
        item.isCollected = true;
        _score += 10;
        _targetsRemaining--;
      });

      if (_targetsRemaining <= 0) {
        // Successfully found all targets!
        // Slightly increase fellow eye contrast as suppression breaks down (staircase protocol)
        setState(() {
          _score += 50; // Round bonus
          _soundEyeContrast = min(1.0, _soundEyeContrast + 0.05);
          _resetBoard();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Level Complete! Fellow eye contrast increased to ${(_soundEyeContrast * 100).toInt()}%.'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } else {
      // False alarm (tapped sound-eye distractor)
      setState(() {
        _score = max(0, _score - 5);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedTime =
        '${(_sessionSeconds ~/ 60).toString().padLeft(2, '0')}:${(_sessionSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Contrast Dichoptic DTx'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Clinical Rationale',
            onPressed: _showClinicalProtocolDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clinical protocol badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.health_and_safety, color: Colors.cyanAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Balanced Contrast Binocular Protocol (DCP)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            _anaglyphMode
                                ? 'Wear Red-Cyan glasses: Target is RED (100% Contrast) - Distractors are CYAN (${(_soundEyeContrast * 100).toInt()}%).'
                                : 'Amblyopic eye sees 100% contrast. Sound eye attenuated to ${(_soundEyeContrast * 100).toInt()}%.',
                            style: TextStyle(color: Colors.grey.shade300, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Game Status & Heads-up Display
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Score', '$_score', Icons.star, Colors.amber),
                      _buildStatColumn('Time', formattedTime, Icons.timer, Colors.blue),
                      _buildStatColumn('Find', _targetSymbol, Icons.center_focus_strong, Colors.redAccent, isSymbol: true),
                      _buildStatColumn('Remaining', '$_targetsRemaining', Icons.flag, Colors.teal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dichoptic Game Board (6 cols x 5 rows)
              Container(
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _buildDichopticItemWidget(item);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Start / Stop Controls
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isPlaying ? _stopGame : _startGame,
                      icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      label: Text(_isPlaying ? 'PAUSE SESSION' : (_roundCompleted ? 'RESTART THERAPY' : 'START THERAPY')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPlaying ? Colors.amber.shade800 : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Therapy Parameter Customization
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Therapeutic Contrast Adjustments',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Sound Eye (Fellow Eye): ', style: TextStyle(fontSize: 13)),
                          ChoiceChip(
                            label: const Text('Left Eye (OS)'),
                            selected: !_soundEyeIsRight,
                            onSelected: (val) {
                              if (val) setState(() => _soundEyeIsRight = false);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Right Eye (OD)'),
                            selected: _soundEyeIsRight,
                            onSelected: (val) {
                              if (val) setState(() => _soundEyeIsRight = true);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fellow Eye Contrast Penalty:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('${(_soundEyeContrast * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                      Slider(
                        value: _soundEyeContrast,
                        min: 0.10,
                        max: 1.0,
                        divisions: 18,
                        label: '${(_soundEyeContrast * 100).toInt()}%',
                        onChanged: (val) {
                          setState(() {
                            _soundEyeContrast = val;
                          });
                        },
                      ),
                      const Text(
                        'Tip: Start with high contrast penalization (20-30%) until binocular fusion is maintained, then gradually increase toward 100%.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const Divider(height: 24),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Red / Cyan Anaglyph Filter Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Filters targets to Red lens (AE) and distractors to Cyan lens (FE)', style: TextStyle(fontSize: 11)),
                        value: _anaglyphMode,
                        onChanged: (val) => setState(() => _anaglyphMode = val),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color, {bool isSymbol = false}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        isSymbol
            ? Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))
            : Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDichopticItemWidget(_DichopticItem item) {
    if (item.isCollected) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.check, color: Colors.greenAccent, size: 18),
        ),
      );
    }

    // Determine color and opacity based on anaglyph mode and contrast penalty
    Color symbolColor;
    double opacity;

    if (item.isAmblyopicTarget) {
      // Amblyopic target: 100% contrast, Red (for Red-Cyan) or Pure White
      opacity = 1.0;
      symbolColor = _anaglyphMode ? const Color(0xFFFF0033) : Colors.white;
    } else {
      // Sound eye distractor: Attenuated contrast, Cyan (for Red-Cyan) or Dim Grey
      opacity = _soundEyeContrast;
      symbolColor = _anaglyphMode ? const Color(0xFF00E5FF) : Colors.white;
    }

    return GestureDetector(
      onTap: () => _handleItemTap(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: Text(
              item.symbol,
              style: TextStyle(
                color: symbolColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClinicalProtocolDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.science, color: Colors.teal),
            SizedBox(width: 8),
            Text('Balanced Dichoptic Therapy'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mechanism of Action:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Traditional occlusion therapy (patching) treats amblyopia monocularly. Dichoptic Digital Therapeutics (e.g., Luminopia, CureSight, Hess et al.) treat amblyopia as a binocular disorder resulting from active cortical suppression of the amblyopic eye by the sound eye.\n',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Dynamic Contrast Penalization (DCP):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'By presenting high-contrast essential game targets exclusively to the amblyopic eye and reducing the contrast of the fellow eye, interocular suppression is abolished at the visual cortex, enabling simultaneous binocular perception and stereopsis restoration.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DichopticItem {
  final int id;
  final String symbol;
  final bool isTarget;
  final bool isAmblyopicTarget;
  bool isCollected = false;

  _DichopticItem({
    required this.id,
    required this.symbol,
    required this.isTarget,
    required this.isAmblyopicTarget,
  });
}
