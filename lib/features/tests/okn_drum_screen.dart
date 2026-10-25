import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

enum OknDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }
enum OknPatternType { standardStripes, highContrastCheck, pediatricMascotStripes }
enum OknClinicalFinding { symmetricalNormal, rightAsymmetry, leftAsymmetry, absentCorticalDefect, malingeringConfirmed }

class OknDrumScreen extends StatefulWidget {
  const OknDrumScreen({super.key});

  @override
  State<OknDrumScreen> createState() => _OknDrumScreenState();
}

class _OknDrumScreenState extends State<OknDrumScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double _speedVelocity = 1.0; // 0.2x to 3.0x
  double _stripeWidth = 32.0;  // 12.0px to 64.0px
  OknDirection _direction = OknDirection.rightToLeft;
  OknPatternType _patternType = OknPatternType.standardStripes;
  OknClinicalFinding _finding = OknClinicalFinding.symmetricalNormal;
  bool _isPlaying = true;

  final TextEditingController _patientIdCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _patientIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animController.repeat();
      } else {
        _animController.stop();
      }
    });
  }

  void _saveToDatabase() async {
    final findingTitle = _getFindingTitle(_finding);
    final record = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientIdCtrl.text.trim().isEmpty ? 'Anonymous Patient' : _patientIdCtrl.text.trim(),
      age: 25,
      gender: 'Unspecified',
      primaryDiagnosis: 'OKN: $findingTitle',
      notes: 'Exam: OKN Drum (${_getDirectionName(_direction)}). Speed: ${_speedVelocity.toStringAsFixed(1)}x, Stripe: ${_stripeWidth.toInt()}px. Notes: ${_notesCtrl.text.trim()}',
      createdAt: DateTime.now(),
    );

    await ClinicalDatabaseService.saveRecord(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Expanded(child: Text('OKN Exam saved: $findingTitle')),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getDirectionName(OknDirection dir) {
    switch (dir) {
      case OknDirection.rightToLeft:
        return 'Right → Left (Triggers Left-Beating OKN)';
      case OknDirection.leftToRight:
        return 'Left → Right (Triggers Right-Beating OKN)';
      case OknDirection.topToBottom:
        return 'Top → Down (Triggers Up-Beating OKN)';
      case OknDirection.bottomToTop:
        return 'Bottom → Up (Triggers Down-Beating OKN)';
    }
  }

  String _getFindingTitle(OknClinicalFinding f) {
    switch (f) {
      case OknClinicalFinding.symmetricalNormal:
        return 'Symmetrical Normal OKN Response (Intact Visual Pathway)';
      case OknClinicalFinding.rightAsymmetry:
        return 'Right Asymmetric OKN Deficit (Right Parietal / Middle Temporal Lesion)';
      case OknClinicalFinding.leftAsymmetry:
        return 'Left Asymmetric OKN Deficit (Left Parietal / Middle Temporal Lesion)';
      case OknClinicalFinding.absentCorticalDefect:
        return 'Absent OKN Response (Cortical Blindness / Severe Amblyopia)';
      case OknClinicalFinding.malingeringConfirmed:
        return 'Positive OKN in Claimed Blindness (Malingering / Functional Vision Loss)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OKN Drum Simulator'),
        actions: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline),
            tooltip: _isPlaying ? 'Pause Drum' : 'Start Drum',
            onPressed: _togglePlayPause,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Clinical Principles',
            onPressed: _showInfoDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Record',
            onPressed: _saveToDatabase,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Moving Optokinetic Drum Canvas (Controlled Tablet Width)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _OknDrumPainter(
                            phase: _animController.value * _speedVelocity,
                            stripeWidth: _stripeWidth,
                            direction: _direction,
                            patternType: _patternType,
                          ),
                          child: Container(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Velocity & Spatial Frequency Controls
            SamsungOneUiGroupCard(
              title: 'DRUM SPEED & SPATIAL FREQUENCY',
              icon: Icons.speed,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fast_forward, size: 16, color: Colors.cyanAccent),
                      const SizedBox(width: 8),
                      const Text('Velocity:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: _speedVelocity,
                          min: 0.2,
                          max: 3.5,
                          divisions: 33,
                          activeColor: Colors.cyanAccent,
                          onChanged: (v) => setState(() => _speedVelocity = v),
                        ),
                      ),
                      Text('${_speedVelocity.toStringAsFixed(1)}x', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.view_column, size: 16, color: Colors.amberAccent),
                      const SizedBox(width: 8),
                      const Text('Stripe Width:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: _stripeWidth,
                          min: 12.0,
                          max: 64.0,
                          divisions: 26,
                          activeColor: Colors.amberAccent,
                          onChanged: (v) => setState(() => _stripeWidth = v),
                        ),
                      ),
                      Text('${_stripeWidth.toInt()} px', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Direction & Target Pattern Modes
            SamsungOneUiGroupCard(
              title: 'DIRECTION & PEDIATRIC FIXATION',
              icon: Icons.swap_horiz,
              child: Column(
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.arrow_back, size: 14),
                        label: const Text('Right → Left', style: TextStyle(fontSize: 11)),
                        selected: _direction == OknDirection.rightToLeft,
                        selectedColor: Colors.cyanAccent,
                        onSelected: (_) => setState(() => _direction = OknDirection.rightToLeft),
                      ),
                      ChoiceChip(
                        avatar: const Icon(Icons.arrow_forward, size: 14),
                        label: const Text('Left → Right', style: TextStyle(fontSize: 11)),
                        selected: _direction == OknDirection.leftToRight,
                        selectedColor: Colors.cyanAccent,
                        onSelected: (_) => setState(() => _direction = OknDirection.leftToRight),
                      ),
                      ChoiceChip(
                        avatar: const Icon(Icons.arrow_downward, size: 14),
                        label: const Text('Top → Down', style: TextStyle(fontSize: 11)),
                        selected: _direction == OknDirection.topToBottom,
                        selectedColor: Colors.cyanAccent,
                        onSelected: (_) => setState(() => _direction = OknDirection.topToBottom),
                      ),
                      ChoiceChip(
                        avatar: const Icon(Icons.arrow_upward, size: 14),
                        label: const Text('Bottom → Up', style: TextStyle(fontSize: 11)),
                        selected: _direction == OknDirection.bottomToTop,
                        selectedColor: Colors.cyanAccent,
                        onSelected: (_) => setState(() => _direction = OknDirection.bottomToTop),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Target Style:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      SegmentedButton<OknPatternType>(
                        segments: const [
                          ButtonSegment(value: OknPatternType.standardStripes, label: Text('Stripes', style: TextStyle(fontSize: 10))),
                          ButtonSegment(value: OknPatternType.highContrastCheck, label: Text('Check', style: TextStyle(fontSize: 10))),
                          ButtonSegment(value: OknPatternType.pediatricMascotStripes, label: Text('🦉 Mascot', style: TextStyle(fontSize: 10))),
                        ],
                        selected: {_patternType},
                        onSelectionChanged: (val) => setState(() => _patternType = val.first),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Clinical Finding Recorder
            SamsungOneUiGroupCard(
              title: 'CLINICAL NYSTAGMUS FINDINGS',
              icon: Icons.psychology,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...OknClinicalFinding.values.map((item) {
                    final isSel = _finding == item;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.cyan.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.1),
                          width: isSel ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSel ? Colors.cyanAccent : Colors.grey,
                          size: 18,
                        ),
                        title: Text(
                          _getFindingTitle(item),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel ? Colors.cyanAccent : Colors.white,
                          ),
                        ),
                        onTap: () => setState(() => _finding = item),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Patient Record & Export
            SamsungOneUiGroupCard(
              title: 'PATIENT RECORD ENTRY',
              icon: Icons.assignment_ind,
              child: Column(
                children: [
                  TextField(
                    controller: _patientIdCtrl,
                    decoration: InputDecoration(
                      labelText: 'Patient Identifier / MRN',
                      prefixIcon: const Icon(Icons.badge, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Clinical Notes / Pursuits vs Saccades',
                      prefixIcon: const Icon(Icons.note, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save OKN Result to Database', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _saveToDatabase,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.cyanAccent),
            SizedBox(width: 8),
            Text('OKN Nystagmus Principles'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Optokinetic Nystagmus (OKN):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
              ),
              SizedBox(height: 4),
              Text(
                '• Physiological jerk nystagmus elicited by smooth pursuit tracking of moving stripes followed by a rapid corrective saccade in the opposite direction.\n'
                '• Right-to-Left drum rotation induces Slow phase to Left and Fast phase to Right (Right-beating OKN).\n'
                '• Used for objective visual acuity threshold estimation in pre-verbal infants and uncooperative patients.\n'
                '• Asymmetric OKN: Localizes parieto-occipital deep cerebral lesions (Cogan sign) or infantile strabismus.\n'
                '• Malingering test: Presence of OKN definitively disproves claims of complete bilateral cortical or ocular blindness.',
                style: TextStyle(fontSize: 11, height: 1.4),
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

class _OknDrumPainter extends CustomPainter {
  final double phase;
  final double stripeWidth;
  final OknDirection direction;
  final OknPatternType patternType;

  _OknDrumPainter({
    required this.phase,
    required this.stripeWidth,
    required this.direction,
    required this.patternType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    final period = stripeWidth * 2;
    double offset = (phase * period) % period;

    if (direction == OknDirection.leftToRight || direction == OknDirection.topToBottom) {
      offset = period - offset;
    }

    if (direction == OknDirection.rightToLeft || direction == OknDirection.leftToRight) {
      // Horizontal motion (Vertical Stripes)
      for (double x = -period + offset; x < size.width + period; x += period) {
        canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), whitePaint);
        canvas.drawRect(Rect.fromLTWH(x + stripeWidth, 0, stripeWidth, size.height), blackPaint);

        if (patternType == OknPatternType.pediatricMascotStripes) {
          _drawMascotIcon(canvas, Offset(x + stripeWidth / 2, size.height / 2), stripeWidth * 0.7);
        }
      }
    } else {
      // Vertical motion (Horizontal Stripes)
      for (double y = -period + offset; y < size.height + period; y += period) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, stripeWidth), whitePaint);
        canvas.drawRect(Rect.fromLTWH(0, y + stripeWidth, size.width, stripeWidth), blackPaint);

        if (patternType == OknPatternType.pediatricMascotStripes) {
          _drawMascotIcon(canvas, Offset(size.width / 2, y + stripeWidth / 2), stripeWidth * 0.7);
        }
      }
    }
  }

  void _drawMascotIcon(Canvas canvas, Offset center, double size) {
    final eyePaint = Paint()..color = Colors.cyanAccent;
    final pupilPaint = Paint()..color = Colors.black;

    // Mini Dr. Iris fixation owl dot
    canvas.drawCircle(Offset(center.dx - size * 0.25, center.dy), size * 0.35, eyePaint);
    canvas.drawCircle(Offset(center.dx + size * 0.25, center.dy), size * 0.35, eyePaint);
    canvas.drawCircle(Offset(center.dx - size * 0.25, center.dy), size * 0.18, pupilPaint);
    canvas.drawCircle(Offset(center.dx + size * 0.25, center.dy), size * 0.18, pupilPaint);
  }

  @override
  bool shouldRepaint(covariant _OknDrumPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.direction != direction ||
        oldDelegate.patternType != patternType;
  }
}
