import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

enum AmslerChartType {
  standardWhiteOnBlack,
  standardBlackOnWhite,
  redOnBlackOpticNerve,
  diagonalFixationAids,
  fineCentralFoveal,
}

enum AmslerEyeTested { rightEyeOD, leftEyeOS, bothEyesOU }

class AmslerGridScreen extends StatefulWidget {
  const AmslerGridScreen({super.key});

  @override
  State<AmslerGridScreen> createState() => _AmslerGridScreenState();
}

class _AmslerGridScreenState extends State<AmslerGridScreen> {
  AmslerChartType _chartType = AmslerChartType.standardWhiteOnBlack;
  AmslerEyeTested _eyeTested = AmslerEyeTested.rightEyeOD;
  bool _hasMetamorphopsia = false;
  bool _hasCentralScotoma = false;
  bool _hasParacentralScotoma = false;

  final List<List<Offset>> _drawnPaths = [];
  List<Offset>? _currentPath;

  final TextEditingController _patientIdCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _clearDrawings() {
    setState(() {
      _drawnPaths.clear();
      _currentPath = null;
    });
  }

  String _getEyeName(AmslerEyeTested eye) {
    switch (eye) {
      case AmslerEyeTested.rightEyeOD:
        return 'Right Eye (OD)';
      case AmslerEyeTested.leftEyeOS:
        return 'Left Eye (OS)';
      case AmslerEyeTested.bothEyesOU:
        return 'Both Eyes (OU)';
    }
  }

  void _saveToDatabase() async {
    String diagnosis = 'Normal Central 20° Visual Field (No Metamorphopsia/Scotoma)';
    if (_hasMetamorphopsia || _hasCentralScotoma || _hasParacentralScotoma || _drawnPaths.isNotEmpty) {
      final issues = <String>[];
      if (_hasMetamorphopsia) issues.add('Metamorphopsia (Distorted Wavy Lines)');
      if (_hasCentralScotoma) issues.add('Central Scotoma');
      if (_hasParacentralScotoma) issues.add('Paracentral Scotoma');
      if (_drawnPaths.isNotEmpty && issues.isEmpty) issues.add('Localized Defect Marked on Grid');
      diagnosis = 'Maculopathy / Field Defect: ${issues.join(", ")}';
    }

    final record = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientIdCtrl.text.trim().isEmpty ? 'Anonymous Patient' : _patientIdCtrl.text.trim(),
      age: 65,
      gender: 'Unspecified',
      primaryDiagnosis: diagnosis,
      notes: 'Exam: Amsler Grid (${_getEyeName(_eyeTested)} - ${_getChartTypeName(_chartType)}). Marked Defects: ${_drawnPaths.length} drawn paths. Notes: ${_notesCtrl.text.trim()}',
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
              Expanded(child: Text('Amsler Result saved: $diagnosis')),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getChartTypeName(AmslerChartType type) {
    switch (type) {
      case AmslerChartType.standardWhiteOnBlack:
        return 'Chart 1: Standard White on Black';
      case AmslerChartType.standardBlackOnWhite:
        return 'Chart 1b: Black on White';
      case AmslerChartType.redOnBlackOpticNerve:
        return 'Chart 3: Red on Black (Optic Nerve / Toxicity)';
      case AmslerChartType.diagonalFixationAids:
        return 'Chart 2: Diagonal Fixation Lines';
      case AmslerChartType.fineCentralFoveal:
        return 'Chart 7: Fine Central Foveal Grid';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amsler Grid & Maculopathy Lab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Clear Markings',
            onPressed: _clearDrawings,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Clinical Guidelines',
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
            // Instructions Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.remove_red_eye, color: Colors.amber, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hold at 33 cm with reading correction. Cover one eye and fixate on central white dot. Draw directly to outline any wavy, distorted, or missing lines.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Amsler Grid Canvas with Markup Layer (Distortion-Free 1:1 Aspect Ratio)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340, maxHeight: 340),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _chartType == AmslerChartType.standardBlackOnWhite ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade700, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: GestureDetector(
                        onPanStart: (details) {
                          setState(() {
                            _currentPath = [details.localPosition];
                            _drawnPaths.add(_currentPath!);
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            _currentPath?.add(details.localPosition);
                          });
                        },
                        onPanEnd: (_) {
                          setState(() {
                            _currentPath = null;
                          });
                        },
                        child: CustomPaint(
                          painter: _AmslerGridPainter(
                            chartType: _chartType,
                            drawnPaths: _drawnPaths,
                          ),
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Eye Selection & Chart Type
            SamsungOneUiGroupCard(
              title: 'EXAMINATION CONFIGURATION',
              icon: Icons.tune,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.remove_red_eye, size: 14),
                          label: const Text('Right OD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: _eyeTested == AmslerEyeTested.rightEyeOD,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _eyeTested = AmslerEyeTested.rightEyeOD),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.remove_red_eye, size: 14),
                          label: const Text('Left OS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: _eyeTested == AmslerEyeTested.leftEyeOS,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _eyeTested = AmslerEyeTested.leftEyeOS),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.visibility, size: 14),
                          label: const Text('Both OU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: _eyeTested == AmslerEyeTested.bothEyesOU,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _eyeTested = AmslerEyeTested.bothEyesOU),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  DropdownButtonFormField<AmslerChartType>(
                    initialValue: _chartType,
                    decoration: InputDecoration(
                      labelText: 'Amsler Chart Standard',
                      prefixIcon: const Icon(Icons.grid_on, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: AmslerChartType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getChartTypeName(type), style: const TextStyle(fontSize: 11)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _chartType = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Clinical Defect Checkboxes
            SamsungOneUiGroupCard(
              title: 'PATIENT REPORTED ABERRATIONS',
              icon: Icons.checklist,
              child: Column(
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Metamorphopsia (Wavy / Distorted Lines)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Indicates macular edema, AMD, epiretinal membrane, or CSR', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    value: _hasMetamorphopsia,
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) => setState(() => _hasMetamorphopsia = val ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Central Scotoma (Missing Center Dot / Hole)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Indicates geographic atrophy, macular hole, or optic neuropathy', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    value: _hasCentralScotoma,
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) => setState(() => _hasCentralScotoma = val ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Paracentral Scotoma (Missing Quadrant Grid)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Indicates branch retinal vein occlusion, toxoplasmosis scar, or glaucoma', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    value: _hasParacentralScotoma,
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) => setState(() => _hasParacentralScotoma = val ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Patient Database Export
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
                      labelText: 'Clinical Notes / Distortion Quadrants',
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
                      label: const Text('Save Amsler Grid Exam to Database', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Amsler Grid Standards'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Optics & Geometric Visual Angle:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
              ),
              SizedBox(height: 4),
              Text(
                '• Chart dimensions: 10 cm × 10 cm divided into a 20 × 20 grid of 5 mm squares.\n'
                '• At 33 cm reading distance, the full grid subtends 20° of central visual field (10° in each direction from fovea).\n'
                '• Each individual 5 mm square subtends exactly 1° of visual angle.\n'
                '• Chart 1: Standard White on Black.\n'
                '• Chart 2: Diagonal lines assisting fixation in patients with central scotoma.\n'
                '• Chart 3: Red on black for subtle optic nerve lesions and toxic maculopathy (hydroxychloroquine/Plaquenil screening).\n'
                '• Chart 7: Central 0.5° fine grid for detecting early foveal metamorphopsia.',
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

class _AmslerGridPainter extends CustomPainter {
  final AmslerChartType chartType;
  final List<List<Offset>> drawnPaths;

  _AmslerGridPainter({
    required this.chartType,
    required this.drawnPaths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    Color gridColor = Colors.white;
    Color dotColor = Colors.white;
    if (chartType == AmslerChartType.standardBlackOnWhite) {
      gridColor = Colors.black;
      dotColor = Colors.black;
    } else if (chartType == AmslerChartType.redOnBlackOpticNerve) {
      gridColor = Colors.redAccent;
      dotColor = Colors.redAccent;
    }

    final linePaint = Paint()
      ..color = gridColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.2;

    final borderPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // 1. Draw outer boundary
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // 2. Draw Grid Lines (20 x 20 squares)
    final step = size.width / 20.0;
    for (int i = 1; i < 20; i++) {
      final pos = i * step;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), linePaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), linePaint);
    }

    // 3. Diagonal Fixation Lines (Chart 2)
    if (chartType == AmslerChartType.diagonalFixationAids) {
      final diagPaint = Paint()
        ..color = gridColor.withValues(alpha: 0.7)
        ..strokeWidth = 1.8;
      canvas.drawLine(Offset.zero, Offset(size.width, size.height), diagPaint);
      canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), diagPaint);
    }

    // 4. Fine Central Grid (Chart 7)
    if (chartType == AmslerChartType.fineCentralFoveal) {
      final finePaint = Paint()
        ..color = gridColor.withValues(alpha: 0.9)
        ..strokeWidth = 0.8;
      final centralRect = Rect.fromCenter(center: center, width: step * 4, height: step * 4);
      final halfStep = step / 2.0;
      for (double x = centralRect.left; x <= centralRect.right; x += halfStep) {
        canvas.drawLine(Offset(x, centralRect.top), Offset(x, centralRect.bottom), finePaint);
      }
      for (double y = centralRect.top; y <= centralRect.bottom; y += halfStep) {
        canvas.drawLine(Offset(centralRect.left, y), Offset(centralRect.right, y), finePaint);
      }
    }

    // 5. Central Fixation Dot
    final dotPaint = Paint()..color = dotColor;
    canvas.drawCircle(center, 4.0, dotPaint);

    // 6. Draw User Markup / Scotoma Paths
    final markupPaint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final path in drawnPaths) {
      if (path.length > 1) {
        final p = Path()..moveTo(path[0].dx, path[0].dy);
        for (int i = 1; i < path.length; i++) {
          p.lineTo(path[i].dx, path[i].dy);
        }
        canvas.drawPath(p, markupPaint);
      } else if (path.length == 1) {
        canvas.drawCircle(path[0], 2.5, markupPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AmslerGridPainter oldDelegate) {
    return oldDelegate.chartType != chartType || oldDelegate.drawnPaths != drawnPaths;
  }
}
