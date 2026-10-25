import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

enum AccommodativeTestType {
  pushUpDonders,
  minusLensMethod,
  accommodativeFacilityFlipper,
  relativeAccommodationNraPra,
}

class AccommodationFacilityScreen extends StatefulWidget {
  const AccommodationFacilityScreen({super.key});

  @override
  State<AccommodationFacilityScreen> createState() => _AccommodationFacilityScreenState();
}

class _AccommodationFacilityScreenState extends State<AccommodationFacilityScreen> {
  AccommodativeTestType _testType = AccommodativeTestType.accommodativeFacilityFlipper;

  // 1. Patient Age & Hofstetter Norms
  int _patientAge = 22;
  double get _minHofstetter => 15.0 - (0.25 * _patientAge);
  double get _avgHofstetter => 18.5 - (0.30 * _patientAge);
  double get _maxHofstetter => 25.0 - (0.40 * _patientAge);

  // 2. Push-up / Push-down values
  double _nearPointDistanceCm = 8.0; // cm to blur
  double get _measuredPushUpDiopters => _nearPointDistanceCm > 0 ? (100.0 / _nearPointDistanceCm) : 0.0;

  // 3. Flipper Test Timer & Cycle Counter
  int _flipperCycles = 0; // Each flip is 0.5 cycle (Plus + Minus = 1 cycle)
  int _flipperTimerSeconds = 60;
  bool _isTimerRunning = false;
  Timer? _timer;
  bool _flipperIsBinocular = true; // BAF vs MAF
  bool _strugglesWithPlus = false;
  bool _strugglesWithMinus = false;

  // 4. NRA / PRA values
  double _nraDiopters = 2.00; // Expected +2.00 to +2.50
  double _praDiopters = -2.50; // Expected -2.00 to -3.50

  final TextEditingController _patientIdCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _patientIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _startStopTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() {
        _isTimerRunning = true;
        _flipperTimerSeconds = 60;
        _flipperCycles = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_flipperTimerSeconds > 1) {
          setState(() => _flipperTimerSeconds--);
        } else {
          timer.cancel();
          setState(() {
            _flipperTimerSeconds = 0;
            _isTimerRunning = false;
          });
        }
      });
    }
  }

  void _registerFlip() {
    if (_isTimerRunning) {
      setState(() {
        _flipperCycles++;
      });
    }
  }

  double get _calculatedCpm {
    final elapsedSec = 60 - _flipperTimerSeconds;
    if (elapsedSec <= 0) return 0.0;
    final totalCycles = _flipperCycles / 2.0; // 2 flips = 1 full cycle
    return (totalCycles / elapsedSec) * 60.0;
  }

  String _getDiagnosis() {
    if (_testType == AccommodativeTestType.accommodativeFacilityFlipper) {
      final cpm = _calculatedCpm;
      final normalCutoff = _flipperIsBinocular ? 8.0 : 11.0;
      if (cpm < normalCutoff) {
        if (_strugglesWithPlus && !_strugglesWithMinus) {
          return 'Accommodative Excess / Spasm of Near Reflex (Fails Plus)';
        } else if (_strugglesWithMinus && !_strugglesWithPlus) {
          return 'Accommodative Insufficiency (Fails Minus)';
        }
        return 'Accommodative Infacility (<${normalCutoff.toInt()} cpm with ±2.00D Flipper)';
      }
      return 'Normal Accommodative Facility (${cpm.toStringAsFixed(1)} cpm)';
    } else if (_testType == AccommodativeTestType.pushUpDonders) {
      if (_measuredPushUpDiopters < _minHofstetter) {
        return 'Accommodative Insufficiency (Amplitude ${_measuredPushUpDiopters.toStringAsFixed(1)}D < Hofstetter Min ${_minHofstetter.toStringAsFixed(1)}D)';
      }
      return 'Normal Amplitude of Accommodation (${_measuredPushUpDiopters.toStringAsFixed(1)} D)';
    } else {
      return 'NRA: +${_nraDiopters.toStringAsFixed(2)} D / PRA: ${_praDiopters.toStringAsFixed(2)} D';
    }
  }

  void _saveToDatabase() async {
    final diagnosis = _getDiagnosis();
    final record = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientIdCtrl.text.trim().isEmpty ? 'Anonymous Patient' : _patientIdCtrl.text.trim(),
      age: _patientAge,
      gender: 'Unspecified',
      primaryDiagnosis: diagnosis,
      notes: 'Exam: ${_getTestTypeName(_testType)}. Hofstetter Min/Avg/Max: ${_minHofstetter.toStringAsFixed(1)}/${_avgHofstetter.toStringAsFixed(1)}/${_maxHofstetter.toStringAsFixed(1)} D. CPM: ${_calculatedCpm.toStringAsFixed(1)}. Notes: ${_notesCtrl.text.trim()}',
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
              Expanded(child: Text('Accommodative Exam saved: $diagnosis')),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getTestTypeName(AccommodativeTestType t) {
    switch (t) {
      case AccommodativeTestType.accommodativeFacilityFlipper:
        return '±2.00 D Flipper Facility (BAF / MAF)';
      case AccommodativeTestType.pushUpDonders:
        return 'Push-Up Amplitude (RAF Rule / Donders)';
      case AccommodativeTestType.minusLensMethod:
        return 'Minus-Lens-to-Blur Method (Sheard)';
      case AccommodativeTestType.relativeAccommodationNraPra:
        return 'Relative Accommodation (NRA / PRA)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation & Flipper Lab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Hofstetter Formulas',
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
            // 1. Patient Age & Hofstetter Comparison Card
            SamsungOneUiGroupCard(
              title: 'PATIENT AGE & HOFSTETTER EXPECTED NORMS',
              icon: Icons.person_outline,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Patient Age: $_patientAge years', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 140,
                        child: Slider(
                          value: _patientAge.toDouble(),
                          min: 6,
                          max: 65,
                          divisions: 59,
                          activeColor: Colors.cyanAccent,
                          onChanged: (v) => setState(() => _patientAge = v.toInt()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNormColumn('Minimum (15 - 0.25A)', '${_minHofstetter.toStringAsFixed(1)} D', Colors.redAccent),
                        _buildNormColumn('Average (18.5 - 0.3A)', '${_avgHofstetter.toStringAsFixed(1)} D', Colors.cyanAccent),
                        _buildNormColumn('Maximum (25 - 0.4A)', '${_maxHofstetter.toStringAsFixed(1)} D', Colors.greenAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Select Test Protocol
            SegmentedButton<AccommodativeTestType>(
              segments: const [
                ButtonSegment(value: AccommodativeTestType.accommodativeFacilityFlipper, label: Text('±2.00D Flipper', style: TextStyle(fontSize: 10))),
                ButtonSegment(value: AccommodativeTestType.pushUpDonders, label: Text('Push-Up AA', style: TextStyle(fontSize: 10))),
                ButtonSegment(value: AccommodativeTestType.relativeAccommodationNraPra, label: Text('NRA / PRA', style: TextStyle(fontSize: 10))),
              ],
              selected: {_testType},
              onSelectionChanged: (val) => setState(() => _testType = val.first),
            ),
            const SizedBox(height: 14),

            // 3. Test Specific Interface
            if (_testType == AccommodativeTestType.accommodativeFacilityFlipper) ...[
              SamsungOneUiGroupCard(
                title: '±2.00 D FLIPPER 60-SECOND FACILITY TIMER',
                icon: Icons.timer,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          avatar: const Icon(Icons.visibility, size: 14),
                          label: const Text('BAF (Binocular)', style: TextStyle(fontSize: 11)),
                          selected: _flipperIsBinocular,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _flipperIsBinocular = true),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: const Icon(Icons.remove_red_eye, size: 14),
                          label: const Text('MAF (Monocular)', style: TextStyle(fontSize: 11)),
                          selected: !_flipperIsBinocular,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _flipperIsBinocular = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Timer Display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _isTimerRunning ? Colors.cyanAccent : Colors.grey, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '00:${_flipperTimerSeconds.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _isTimerRunning ? Colors.cyanAccent : Colors.grey,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cycles: ${(_flipperCycles / 2.0).toStringAsFixed(1)} | CPM: ${_calculatedCpm.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                            label: Text(_isTimerRunning ? 'Stop Timer' : 'Start 60s Test'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isTimerRunning ? Colors.redAccent : Colors.cyanAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _startStopTimer,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.flip_to_back),
                            label: const Text('Tap to Flip (+ / -)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isTimerRunning ? _registerFlip : null,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilterChip(
                            label: const Text('Fails +2.00D (Excess)', style: TextStyle(fontSize: 10)),
                            selected: _strugglesWithPlus,
                            selectedColor: Colors.amberAccent,
                            onSelected: (v) => setState(() => _strugglesWithPlus = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilterChip(
                            label: const Text('Fails -2.00D (Insufficiency)', style: TextStyle(fontSize: 10)),
                            selected: _strugglesWithMinus,
                            selectedColor: Colors.redAccent,
                            onSelected: (v) => setState(() => _strugglesWithMinus = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (_testType == AccommodativeTestType.pushUpDonders) ...[
              SamsungOneUiGroupCard(
                title: 'PUSH-UP RAF RULE AMPLITUDE OF ACCOMMODATION',
                icon: Icons.straighten,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.social_distance, size: 16, color: Colors.cyanAccent),
                        const SizedBox(width: 8),
                        const Text('Near Point of Accommodation (NPA):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _nearPointDistanceCm,
                            min: 4.0,
                            max: 50.0,
                            divisions: 46,
                            activeColor: Colors.cyanAccent,
                            onChanged: (v) => setState(() => _nearPointDistanceCm = v),
                          ),
                        ),
                        Text('${_nearPointDistanceCm.toStringAsFixed(1)} cm', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Measured Amplitude (100 / NPA cm):', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            '${_measuredPushUpDiopters.toStringAsFixed(2)} D',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SamsungOneUiGroupCard(
                title: 'NEGATIVE & POSITIVE RELATIVE ACCOMMODATION',
                icon: Icons.exposure,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('NRA (Relaxation with Plus):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('+${_nraDiopters.toStringAsFixed(2)} D', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                      ],
                    ),
                    Slider(
                      value: _nraDiopters,
                      min: 0.50,
                      max: 4.00,
                      divisions: 14,
                      activeColor: Colors.greenAccent,
                      onChanged: (v) => setState(() => _nraDiopters = v),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('PRA (Stimulation with Minus):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('${_praDiopters.toStringAsFixed(2)} D', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                    Slider(
                      value: _praDiopters,
                      min: -6.00,
                      max: -0.50,
                      divisions: 22,
                      activeColor: Colors.redAccent,
                      onChanged: (v) => setState(() => _praDiopters = v),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),

            // 4. Clinical Diagnosis & Patient Entry
            SamsungOneUiGroupCard(
              title: 'DIAGNOSTIC SUMMARY & SAVE',
              icon: Icons.assignment_turned_in,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Clinical Diagnostic Interpretation:', style: TextStyle(fontSize: 11, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_getDiagnosis(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      labelText: 'Clinical Notes / Vision Therapy Prescription',
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
                      label: const Text('Save Accommodative Exam to Database', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildNormColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
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
            Text('Hofstetter & Facility Norms'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hofstetter\'s Equations for Amplitude (AA):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
              ),
              SizedBox(height: 4),
              Text(
                '• Minimum AA = 15 - (0.25 × Age)\n'
                '• Average AA = 18.5 - (0.30 × Age)\n'
                '• Maximum AA = 25 - (0.40 × Age)\n\n'
                '±2.00 D Flipper Facility Norms:\n'
                '• Binocular (BAF): Normal is ≥ 8 to 10 cycles/min (cpm).\n'
                '• Monocular (MAF): Normal is ≥ 11 to 12 cycles/min (cpm).\n'
                '• Failing +2.00 D: Accommodative Excess / Spasm.\n'
                '• Failing -2.00 D: Accommodative Insufficiency.\n\n'
                'NRA / PRA Expected Norms:\n'
                '• NRA: +2.00 D (limits ciliary relaxation; values >+2.50 D indicate uncorrected hyperopia or over-minusing).\n'
                '• PRA: -2.37 ± 1.00 D (limits maximum positive accommodation).',
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
