import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

enum FluorogramFinding {
  intactEpitheliumNormal,
  cornealAbrasionDefect,
  punctateEpithelialErosions,
  dendriticUlcerHerpes,
  positiveSeidelLeak,
  rgpApicalClearanceSteep,
  rgpApicalBearingFlat,
  rgpIdealAlignment,
  shortTbutDryEye,
}

class CobaltBlueLightScreen extends StatefulWidget {
  const CobaltBlueLightScreen({super.key});

  @override
  State<CobaltBlueLightScreen> createState() => _CobaltBlueLightScreenState();
}

class _CobaltBlueLightScreenState extends State<CobaltBlueLightScreen> {
  bool _isWrattenYellowFilterOn = false;
  double _screenIntensity = 1.0;
  bool _isFullscreenLightActive = false;
  FluorogramFinding _selectedFinding = FluorogramFinding.intactEpitheliumNormal;

  final TextEditingController _patientIdCtrl = TextEditingController();
  final TextEditingController _tbutSecondsCtrl = TextEditingController(text: '12');
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _tbutSecondsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveToDatabase() async {
    final findingText = _getFindingTitle(_selectedFinding);
    final tbut = _tbutSecondsCtrl.text.trim();
    final record = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientIdCtrl.text.trim().isEmpty ? 'Anonymous Patient' : _patientIdCtrl.text.trim(),
      age: 30,
      gender: 'Unspecified',
      primaryDiagnosis: 'Fluorescein Exam: $findingText (TBUT: ${tbut}s)',
      notes: 'Finding: $findingText. TBUT: ${tbut}s. Filter: ${_isWrattenYellowFilterOn ? "Wratten #12 Yellow Barrier Active" : "Cobalt Blue Direct"}. Notes: ${_notesCtrl.text.trim()}',
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
              Expanded(child: Text('Fluorescein Exam saved: $findingText')),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getFindingTitle(FluorogramFinding f) {
    switch (f) {
      case FluorogramFinding.intactEpitheliumNormal:
        return 'Intact Corneal Epithelium (No Staining / Normal TBUT)';
      case FluorogramFinding.cornealAbrasionDefect:
        return 'Corneal Abrasion / Epithelial Defect (Intense Green Pool)';
      case FluorogramFinding.punctateEpithelialErosions:
        return 'Punctate Epithelial Erosions - PEE (Keratitis / Dry Eye)';
      case FluorogramFinding.dendriticUlcerHerpes:
        return 'Dendritic Ulcer with Terminal Bulbs (Herpes Simplex Keratitis)';
      case FluorogramFinding.positiveSeidelLeak:
        return 'Positive Seidel Sign (Aqueous Stream Wound Leak / Perforation)';
      case FluorogramFinding.rgpApicalClearanceSteep:
        return 'RGP Steep Fit (Heavy Central Apical Pooling)';
      case FluorogramFinding.rgpApicalBearingFlat:
        return 'RGP Flat Fit (Central Apical Touch / Bearing)';
      case FluorogramFinding.rgpIdealAlignment:
        return 'RGP Ideal Alignment (Three-Point Feathered Touch)';
      case FluorogramFinding.shortTbutDryEye:
        return 'Short TBUT <10s (Evaporative Dry Eye / MGD)';
    }
  }

  Color _getIlluminationColor() {
    if (_isWrattenYellowFilterOn) {
      // Wratten #12 Yellow enhances green fluorescence
      return const Color(0xFFFFD600).withValues(alpha: _screenIntensity);
    }
    // Pure 450nm Cobalt Blue light
    return const Color(0xFF0038FF).withValues(alpha: _screenIntensity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fullscreen Illuminator Mode
    if (_isFullscreenLightActive) {
      return Scaffold(
        backgroundColor: _getIlluminationColor(),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isWrattenYellowFilterOn ? Icons.filter_vintage : Icons.light_mode,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isWrattenYellowFilterOn ? 'Wratten #12 Yellow Barrier Filter Active' : 'Cobalt Blue Excitation Light (450nm)',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text('Tap anywhere to exit fullscreen illuminator', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _isFullscreenLightActive = false),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobalt Blue & Fluorescein Lab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Fullscreen Illuminator',
            onPressed: () => setState(() => _isFullscreenLightActive = true),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Fluorescein Principles',
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
            // 1. Interactive Illuminator Preview Box
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: _getIlluminationColor(),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: (_isWrattenYellowFilterOn ? Colors.amber : const Color(0xFF0038FF)).withValues(alpha: 0.5),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isWrattenYellowFilterOn ? Icons.filter_vintage : Icons.blur_on,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isWrattenYellowFilterOn ? 'Wratten #12 Yellow Filter (530nm Barrier)' : 'Cobalt Blue Excitation Beam (450nm)',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.fullscreen, size: 16),
                      label: const Text('Launch Fullscreen Light Source'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(() => _isFullscreenLightActive = true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Light Controls & Filter Toggles
            SamsungOneUiGroupCard(
              title: 'ILLUMINATION & BARRIER FILTER CONTROLS',
              icon: Icons.tune,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Wratten #12 Yellow Barrier Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Blocks blue backscatter and enhances green fluorescence contrast', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    value: _isWrattenYellowFilterOn,
                    activeThumbColor: Colors.amberAccent,
                    onChanged: (val) => setState(() => _isWrattenYellowFilterOn = val),
                  ),
                  const Divider(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.brightness_6, size: 16, color: Colors.cyanAccent),
                      const SizedBox(width: 8),
                      const Text('Intensity:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: _screenIntensity,
                          min: 0.4,
                          max: 1.0,
                          activeColor: Colors.cyanAccent,
                          onChanged: (v) => setState(() => _screenIntensity = v),
                        ),
                      ),
                      Text('${(_screenIntensity * 100).toInt()}%', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Clinical Fluorogram Finding Selector
            SamsungOneUiGroupCard(
              title: 'FLUORESCEIN PATTERN & CORNEAL FINDING',
              icon: Icons.biotech,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...FluorogramFinding.values.map((item) {
                    final isSel = _selectedFinding == item;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
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
                        onTap: () => setState(() => _selectedFinding = item),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Tear Break-Up Time & Patient Database Export
            SamsungOneUiGroupCard(
              title: 'TBUT & PATIENT EXAM ENTRY',
              icon: Icons.assignment_ind,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _patientIdCtrl,
                          decoration: InputDecoration(
                            labelText: 'Patient Name / MRN',
                            prefixIcon: const Icon(Icons.badge, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _tbutSecondsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'TBUT (sec)',
                            prefixIcon: const Icon(Icons.timer, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Clinical Notes / RGP Tear Lens Clearance',
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
                      label: const Text('Save Fluorescein Exam to Database', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Fluorescein & Filter Optics'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Photophysical Excitation & Emission:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
              ),
              SizedBox(height: 4),
              Text(
                '• Excitation: Fluorescein sodium absorbs light maximally in the blue spectrum at 490 nm.\n'
                '• Emission: It emits green fluorescence light at 530 nm (Stokes shift).\n'
                '• Wratten #12 Yellow Filter: A 530 nm long-pass barrier filter placed in the observation system that absorbs reflected excitation blue light, transmitting pure high-contrast green fluorescence.\n'
                '• Seidel Test: Demonstrates full-thickness corneal laceration or surgical wound leak (clear aqueous displaces concentrated orange fluorescein into a flowing green stream under blue light).\n'
                '• Normal Tear Break-Up Time (TBUT): > 10 seconds. Values < 10s indicate tear film instability.',
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
