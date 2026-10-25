import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

enum WorthDotResponse {
  fourDotsNormal,
  twoRedRightEye,
  threeGreenLeftEye,
  fiveDotsUncrossedEsophoria,
  fiveDotsCrossedExophoria,
  alternatingSuppression,
}

class WorthFourDotScreen extends StatefulWidget {
  const WorthFourDotScreen({super.key});

  @override
  State<WorthFourDotScreen> createState() => _WorthFourDotScreenState();
}

class _WorthFourDotScreenState extends State<WorthFourDotScreen> {
  bool _isNearMode = true; // Near 33cm (wider separation) vs Distance 6m (subtends 1.25 deg)
  double _brightness = 1.0;
  WorthDotResponse _selectedResponse = WorthDotResponse.fourDotsNormal;
  bool _whiteDotTintRed = true; // In normal fusion, white dot may alternate red/green or show lustrous mix

  final TextEditingController _patientIdCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveToDatabase() async {
    final diagnosis = _getDiagnosisText(_selectedResponse);
    final record = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientIdCtrl.text.trim().isEmpty ? 'Anonymous Patient' : _patientIdCtrl.text.trim(),
      age: 25,
      gender: 'Unspecified',
      primaryDiagnosis: 'Worth 4-Dot: $diagnosis',
      bsvGrade: _selectedResponse == WorthDotResponse.fourDotsNormal ? 'Grade II Fusion (Harmonious)' : 'Suppression / Diplopia',
      notes: 'Exam: Worth 4-Dot (${_isNearMode ? "Near 33cm" : "Distance 6m"}). Response: ${_getResponseTitle(_selectedResponse)}. Notes: ${_notesCtrl.text.trim()}',
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
              Expanded(child: Text('Worth 4-Dot Result saved: $diagnosis')),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getResponseTitle(WorthDotResponse resp) {
    switch (resp) {
      case WorthDotResponse.fourDotsNormal:
        return '4 Dots (Normal BSV Fusion)';
      case WorthDotResponse.twoRedRightEye:
        return '2 Red Dots (Left Eye Suppression)';
      case WorthDotResponse.threeGreenLeftEye:
        return '3 Green Dots (Right Eye Suppression)';
      case WorthDotResponse.fiveDotsUncrossedEsophoria:
        return '5 Dots: Uncrossed Diplopia (Esotropia / Esophoria)';
      case WorthDotResponse.fiveDotsCrossedExophoria:
        return '5 Dots: Crossed Diplopia (Exotropia / Exophoria)';
      case WorthDotResponse.alternatingSuppression:
        return 'Alternating 2 Red / 3 Green (Alternating Suppression)';
    }
  }

  String _getDiagnosisText(WorthDotResponse resp) {
    switch (resp) {
      case WorthDotResponse.fourDotsNormal:
        return 'Normal Binocular Single Vision (Harmonious Fusion)';
      case WorthDotResponse.twoRedRightEye:
        return 'Left Eye Suppression (OS Suppressed, OD Fixating)';
      case WorthDotResponse.threeGreenLeftEye:
        return 'Right Eye Suppression (OD Suppressed, OS Fixating)';
      case WorthDotResponse.fiveDotsUncrossedEsophoria:
        return 'Uncrossed Diplopia (Esotropia / Uncompensated Esophoria)';
      case WorthDotResponse.fiveDotsCrossedExophoria:
        return 'Crossed Diplopia (Exotropia / Uncompensated Exophoria)';
      case WorthDotResponse.alternatingSuppression:
        return 'Alternating Suppression (Absence of Binocular Fusion)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotSize = _isNearMode ? 44.0 : 26.0;
    final dotSpacing = _isNearMode ? 70.0 : 42.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worth 4-Dot Test'),
        actions: [
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
            // Instructions Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility, color: Colors.redAccent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Wear Red-Green Glasses (Red filter over Right Eye, Green over Left Eye).',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Worth 4-Dot Display Stage
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade800, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Opacity(
                  opacity: _brightness,
                  child: SizedBox(
                    width: dotSpacing * 2 + dotSize,
                    height: dotSpacing * 2 + dotSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Top Dot: Red (Visible to OD)
                        Positioned(
                          top: 0,
                          child: _buildLuminousDot(Colors.redAccent, dotSize, 'Red (OD)'),
                        ),
                        // Left Dot: Green (Visible to OS)
                        Positioned(
                          left: 0,
                          child: _buildLuminousDot(const Color(0xFF00E676), dotSize, 'Green (OS)'),
                        ),
                        // Right Dot: Green (Visible to OS)
                        Positioned(
                          right: 0,
                          child: _buildLuminousDot(const Color(0xFF00E676), dotSize, 'Green (OS)'),
                        ),
                        // Bottom Dot: White (Visible to Both Eyes)
                        Positioned(
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _whiteDotTintRed = !_whiteDotTintRed),
                            child: _buildLuminousDot(
                              _whiteDotTintRed ? const Color(0xFFFFE0E0) : const Color(0xFFE0FFF0),
                              dotSize,
                              'White (OU)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Test Configuration & Distance Mode
            SamsungOneUiGroupCard(
              title: 'TEST CONTROLS & DISTANCE',
              icon: Icons.tune,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.near_me, size: 14),
                          label: const Text('Near Test (33 cm / 6°)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: _isNearMode,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (val) => setState(() => _isNearMode = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.straighten, size: 14),
                          label: const Text('Distance Test (6 m / 1.25°)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: !_isNearMode,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (val) => setState(() => _isNearMode = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.brightness_6, size: 16, color: Colors.cyanAccent),
                      const SizedBox(width: 8),
                      const Text('Luminance:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: _brightness,
                          min: 0.3,
                          max: 1.0,
                          activeColor: Colors.cyanAccent,
                          onChanged: (v) => setState(() => _brightness = v),
                        ),
                      ),
                      Text('${(_brightness * 100).toInt()}%', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Clinical Response & Interpretation Selector
            SamsungOneUiGroupCard(
              title: 'PATIENT PERCEPTION & INTERPRETATION',
              icon: Icons.psychology,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select what the patient reports seeing:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ...WorthDotResponse.values.map((resp) {
                    final isSel = _selectedResponse == resp;
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
                          _getResponseTitle(resp),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel ? Colors.cyanAccent : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          _getDiagnosisText(resp),
                          style: TextStyle(fontSize: 10, color: isSel ? Colors.white70 : Colors.grey),
                        ),
                        onTap: () => setState(() => _selectedResponse = resp),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Clinical Documentation & Save
            SamsungOneUiGroupCard(
              title: 'CLINICAL DOCUMENTATION',
              icon: Icons.edit_note,
              child: Column(
                children: [
                  TextField(
                    controller: _patientIdCtrl,
                    decoration: InputDecoration(
                      labelText: 'Patient Name / MRN',
                      prefixIcon: const Icon(Icons.badge, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Clinical Notes / Peripheral Fusion',
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
                      label: const Text('Save Examination to Patient Database', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildLuminousDot(Color color, double size, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.8),
              blurRadius: 16,
              spreadRadius: 3,
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
            Icon(Icons.menu_book, color: Colors.cyanAccent),
            SizedBox(width: 8),
            Text('Worth 4-Dot Test Principles'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Optics & Dissociation:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
              ),
              SizedBox(height: 4),
              Text(
                '• Red Filter (OD) passes only Red light (sees 1 Red top dot + 1 White bottom dot as red).\n'
                '• Green Filter (OS) passes only Green light (sees 2 Green side dots + 1 White bottom dot as green).\n'
                '• Distance Test (6m): Subtends 1.25° assessing central foveal suppression.\n'
                '• Near Test (33cm): Subtends 6° assessing peripheral fusion.\n'
                '• If 4 dots seen: Harmonious fusion or ARC.\n'
                '• If 5 dots uncrossed (Red on right): Esodeviation.\n'
                '• If 5 dots crossed (Red on left): Exodeviation.',
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
