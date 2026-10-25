import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class HartChartScreen extends StatefulWidget {
  const HartChartScreen({super.key});

  @override
  State<HartChartScreen> createState() => _HartChartScreenState();
}

class _HartChartScreenState extends State<HartChartScreen> {
  // Grid size: 10 columns x 10 rows (Classic Hart Chart Standard)
  static const int _rows = 10;
  static const int _cols = 10;
  late List<List<String>> _grid;
  final Random _random = Random();

  // Metronome & Pacing
  Timer? _metronomeTimer;
  bool _isMetronomeActive = false;
  int _bpm = 60; // 60 beats per minute = 1 tick/sec
  int _currentCol = 0;
  int _currentRow = 0;
  bool _highlightCurrentTarget = true;

  // Visual modes
  bool _highContrastInverted = false; // Black on white vs White on black
  bool _redCyanFilter = false; // For binocular rock with anaglyph
  _PacingPattern _pattern = _PacingPattern.columnsDown;

  // Characters used in standard Hart charts (letters & distinct numbers)
  static const String _charPool = 'ABCDEFHKLMNPRTUVWXYZ23456789';

  @override
  void initState() {
    super.initState();
    _generateChart();
  }

  @override
  void dispose() {
    _metronomeTimer?.cancel();
    super.dispose();
  }

  void _generateChart() {
    _grid = List.generate(
      _rows,
      (_) => List.generate(
        _cols,
        (_) => _charPool[_random.nextInt(_charPool.length)],
      ),
    );
  }

  void _toggleMetronome() {
    if (_isMetronomeActive) {
      _metronomeTimer?.cancel();
      setState(() {
        _isMetronomeActive = false;
      });
    } else {
      setState(() {
        _isMetronomeActive = true;
        _currentRow = 0;
        _currentCol = 0;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _metronomeTimer?.cancel();
    final intervalMs = (60000 / _bpm).round();
    _metronomeTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) return;
      setState(() {
        _advanceTarget();
      });
    });
  }

  void _advanceTarget() {
    switch (_pattern) {
      case _PacingPattern.rowsAcross:
        _currentCol++;
        if (_currentCol >= _cols) {
          _currentCol = 0;
          _currentRow = (_currentRow + 1) % _rows;
        }
        break;
      case _PacingPattern.columnsDown:
        _currentRow++;
        if (_currentRow >= _rows) {
          _currentRow = 0;
          _currentCol = (_currentCol + 1) % _cols;
        }
        break;
      case _PacingPattern.outerToInner:
        // Jump between column 0 and column 9 (saccadic rock), then 1 and 8
        if (_currentCol == 0) {
          _currentCol = 9;
        } else {
          _currentCol = 0;
          _currentRow = (_currentRow + 1) % _rows;
        }
        break;
    }
  }

  void _updateBpm(int newBpm) {
    setState(() {
      _bpm = newBpm;
    });
    if (_isMetronomeActive) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = _highContrastInverted ? Colors.white : Colors.black;
    final fgColor = _highContrastInverted ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hart Chart Accommodative Facility'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Randomize Chart',
            onPressed: () => setState(_generateChart),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Training Protocol',
            onPressed: _showInstructionsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clinical Information Banner
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.blueAccent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Saccadic Rock & Accommodative Facility: Call each target aloud in sync with metronome ticks. Use with ±2.00D flipper lenses for accommodative rock.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 10x10 Hart Chart Grid Display
              Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700, width: 2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Column(
                  children: List.generate(_rows, (r) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_cols, (c) {
                          final isTarget = _isMetronomeActive &&
                              _highlightCurrentTarget &&
                              _currentRow == r &&
                              _currentCol == c;

                          Color charColor = fgColor;
                          if (_redCyanFilter) {
                            charColor = (c % 2 == 0)
                                ? const Color(0xFFFF1744)
                                : const Color(0xFF00E5FF);
                          }

                          return Container(
                            width: 28,
                            height: 28,
                            decoration: isTarget
                                ? BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.amberAccent, blurRadius: 6),
                                    ],
                                  )
                                : null,
                            alignment: Alignment.center,
                            child: Text(
                              _grid[r][c],
                              style: TextStyle(
                                color: isTarget ? Colors.black : charColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Metronome & Pacing Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Metronome Pacer: $_bpm BPM (${(60 / _bpm).toStringAsFixed(1)}s)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Switch(
                            value: _isMetronomeActive,
                            onChanged: (_) => _toggleMetronome(),
                          ),
                        ],
                      ),
                      Slider(
                        value: _bpm.toDouble(),
                        min: 30,
                        max: 120,
                        divisions: 18,
                        label: '$_bpm BPM',
                        onChanged: (val) => _updateBpm(val.round()),
                      ),
                      const SizedBox(height: 8),
                      const Text('Scanning Pattern:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Columns Down'),
                            selected: _pattern == _PacingPattern.columnsDown,
                            onSelected: (val) {
                              if (val) setState(() => _pattern = _PacingPattern.columnsDown);
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Rows Across'),
                            selected: _pattern == _PacingPattern.rowsAcross,
                            onSelected: (val) {
                              if (val) setState(() => _pattern = _PacingPattern.rowsAcross);
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Outer-to-Inner Saccades'),
                            selected: _pattern == _PacingPattern.outerToInner,
                            onSelected: (val) {
                              if (val) setState(() => _pattern = _PacingPattern.outerToInner);
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Highlight Current Beat Target', style: TextStyle(fontSize: 13)),
                          Switch(
                            value: _highlightCurrentTarget,
                            onChanged: (val) => setState(() => _highlightCurrentTarget = val),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Invert Contrast (Black on White)', style: TextStyle(fontSize: 13)),
                          Switch(
                            value: _highContrastInverted,
                            onChanged: (val) => setState(() => _highContrastInverted = val),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Red-Cyan Anaglyph Columns', style: TextStyle(fontSize: 13)),
                          Switch(
                            value: _redCyanFilter,
                            onChanged: (val) => setState(() => _redCyanFilter = val),
                          ),
                        ],
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

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Hart Chart Protocols'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Distance-Near Accommodative Rock:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Mount a printed Hart chart at 3 meters (distance).\n• Hold this phone screen at 40 cm (near).\n• Read 1st letter at distance, shift gaze to 1st letter at near, verify clarity before reading.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 10),
              Text(
                '2. Metronome Paced Saccades:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Enable the Metronome at 60 BPM.\n• Call each character clearly without head movements (isolate extraocular muscles).\n• Progression: increase BPM to 90 and 120.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 10),
              Text(
                '3. Flipper Lens Accommodation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Wear ±1.50D or ±2.00D flipper lenses while reading rows across at near.\n• Flip lens on each completed column or row.',
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

enum _PacingPattern {
  rowsAcross,
  columnsDown,
  outerToInner,
}
