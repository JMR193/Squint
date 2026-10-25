import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/eye_motility_painter.dart';

class NeuroOphthoSimulatorScreen extends StatefulWidget {
  const NeuroOphthoSimulatorScreen({super.key});

  @override
  State<NeuroOphthoSimulatorScreen> createState() => _NeuroOphthoSimulatorScreenState();
}

class _NeuroOphthoSimulatorScreenState extends State<NeuroOphthoSimulatorScreen> with TickerProviderStateMixin {
  late AnimationController _nystagmusAnim;
  late AnimationController _blinkAnim;
  Timer? _autoBlinkTimer;

  // Motility Coordinates (-1.0 to +1.0)
  double _gazeX = 0.0;
  double _gazeY = 0.0;

  // Selected Pathology
  String _selectedCategory = 'cranial_nerves';
  String _pathologyKey = 'normal';

  // Examination Tools State
  Offset _torchPosition = const Offset(175, 95);
  bool _isTorchActive = true;
  double _lightRight = 0.0;
  double _lightLeft = 0.0;
  bool _isSwingingFlashlight = false;
  Timer? _swingTimer;

  // Cover & Near State
  String _coverState = 'uncovered';
  String _strabismusType = 'orthophoria';
  bool _isNearTargetActive = false;

  // Prism Bar State
  int _prismPower = 0;
  String _prismBase = 'none';
  String _prismEye = 'none';

  // Head Tilt & Fatigue State
  double _headTiltAngle = 0.0;
  double _fatigueLevel = 0.0;

  // Categories & 42 Detailed Pathologies
  final Map<String, List<Map<String, String>>> _pathologyTaxonomy = {
    'cranial_nerves': [
      {'key': 'normal', 'name': 'Normal Motility & Direct/Consensual Reflexes', 'pearl': 'Symmetric motility in all 9 cardinal positions; brisk, equal pupillary light reflexes.'},
      {'key': 'cn3_right', 'name': 'Right Complete CN III Palsy (Blown 8mm Pupil + Ptosis)', 'pearl': 'Right eye down-and-out with severe ptosis and unreactive dilated pupil. High risk for PCOM aneurysm.'},
      {'key': 'cn3_left', 'name': 'Left Complete CN III Palsy (Blown 8mm Pupil + Ptosis)', 'pearl': 'Left eye down-and-out with severe ptosis and unreactive dilated pupil.'},
      {'key': 'cn3_pupil_sparing', 'name': 'Right CN III Pupil-Sparing (Microvascular / Diabetic)', 'pearl': 'Down-and-out with complete ptosis, but normal pupillary light reflex. Classic microvascular ischemia.'},
      {'key': 'cn3_pupil_sparing_left', 'name': 'Left CN III Pupil-Sparing (Microvascular / Diabetic)', 'pearl': 'Down-and-out with intact pupillary constriction.'},
      {'key': 'cn3_superior_division_right', 'name': 'Right Superior Division CN III Palsy', 'pearl': 'Isolated weakness of Superior Rectus (limited elevation) and Levator (ptosis); intact adduction/pupil.'},
      {'key': 'cn4_right', 'name': 'Right CN IV Palsy (Superior Oblique Paresis)', 'pearl': 'Right hypertropia worsening on left gaze and right head tilt (Bielschowsky 3-step positive).'},
      {'key': 'cn4_left', 'name': 'Left CN IV Palsy (Superior Oblique Paresis)', 'pearl': 'Left hypertropia worsening on right gaze and left head tilt.'},
      {'key': 'cn4_bilateral', 'name': 'Bilateral CN IV Palsy (V-Pattern & Alternating HT)', 'pearl': 'V-pattern esotropia in downgaze, alternating hypertropia on lateral tilts, >10° excyclotorsion.'},
      {'key': 'cn6_right', 'name': 'Right CN VI Palsy (Lateral Rectus Deficit)', 'pearl': 'Failure of right abduction past midline with uncrossed horizontal diplopia at distance.'},
      {'key': 'cn6_left', 'name': 'Left CN VI Palsy (Lateral Rectus Deficit)', 'pearl': 'Failure of left abduction past midline.'},
      {'key': 'cn6_bilateral', 'name': 'Bilateral CN VI Palsy (Bilateral Abduction Failure)', 'pearl': 'Marked esotropia with bilateral abduction failure. Hallmark sign of elevated intracranial pressure (papilledema).'},
    ],
    'internuclear_gaze': [
      {'key': 'ino_right', 'name': 'Right INO (Right MLF Lesion)', 'pearl': 'Right eye fails to adduct in left gaze; dissociated horizontal jerk nystagmus in abducting left eye; intact convergence.'},
      {'key': 'ino_left', 'name': 'Left INO (Left MLF Lesion)', 'pearl': 'Left eye fails to adduct in right gaze; abducting right eye jerk nystagmus.'},
      {'key': 'ino_bilateral', 'name': 'Bilateral INO (Bilateral MLF Lesions)', 'pearl': 'Bilateral adduction deficits in horizontal gaze with bilateral abducting nystagmus. Pathognomonic for Multiple Sclerosis.'},
      {'key': 'webino', 'name': 'WEBINO (Wall-Eyed Bilateral INO)', 'pearl': 'Exotropia in primary position combined with bilateral adduction failure.'},
      {'key': 'one_and_a_half', 'name': 'Right One-and-a-Half Syndrome (PPRF + MLF)', 'pearl': 'Conjugate gaze palsy to the right PLUS right eye adduction deficit to the left; only abducting left eye moves.'},
      {'key': 'one_and_a_half_left', 'name': 'Left One-and-a-Half Syndrome (PPRF + MLF)', 'pearl': 'Conjugate gaze palsy to the left PLUS left eye adduction deficit to the right.'},
      {'key': 'parinaud', 'name': 'Parinaud Syndrome (Dorsal Midbrain)', 'pearl': 'Upgaze paralysis, light-near dissociation, convergence-retraction nystagmus, and Collier\'s lid retraction.'},
      {'key': 'skew_deviation', 'name': 'Skew Deviation (Vestibular Otolithic Disruption)', 'pearl': 'Vertical misalignment not conforming to any single cyclovertical muscle; positive ocular tilt reaction.'},
      {'key': 'psp', 'name': 'Progressive Supranuclear Palsy (PSP)', 'pearl': 'Prominent limitation of voluntary downgaze saccades with preservation of vestibulo-ocular reflex (doll\'s head).'},
    ],
    'pupillary': [
      {'key': 'rapd_right', 'name': 'Right RAPD (Marcus Gunn Pupil)', 'pearl': 'Paradoxical bilateral pupillary dilation when flashlight swings from normal left eye to affected right eye.'},
      {'key': 'rapd_left', 'name': 'Left RAPD (Marcus Gunn Pupil)', 'pearl': 'Paradoxical dilation on swinging flashlight to left eye. Classic sign of unilateral optic neuropathy.'},
      {'key': 'horner_right', 'name': 'Right Horner Syndrome (Mild Ptosis & Miosis)', 'pearl': 'Oculosympathetic disruption: right mild partial ptosis (Müller\'s) and 2.5mm miosis, anisocoria greater in the dark.'},
      {'key': 'horner_left', 'name': 'Left Horner Syndrome (Mild Ptosis & Miosis)', 'pearl': 'Left mild ptosis and miosis.'},
      {'key': 'adie_right', 'name': 'Right Adie Tonic Pupil', 'pearl': 'Unilaterally enlarged pupil, poor light reaction, robust tonic near response, and supersensitivity to dilute 0.125% pilocarpine.'},
      {'key': 'adie_left', 'name': 'Left Adie Tonic Pupil', 'pearl': 'Left dilated tonic pupil.'},
      {'key': 'argyll_robertson', 'name': 'Argyll Robertson Pupils (Bilateral Miosis)', 'pearl': 'Small bilateral 2mm irregular pupils; fail to react to light, but constrict briskly to near target (Neurosyphilis).'},
      {'key': 'pharmacologic_right', 'name': 'Right Pharmacologic Mydriasis (Atropine)', 'pearl': 'Fixed, fully dilated 8-9mm pupil unresponsive to bright light, near target, or 1% pilocarpine.'},
    ],
    'nystagmus': [
      {'key': 'gaze_nystagmus', 'name': 'Gaze-Evoked Jerk Nystagmus', 'pearl': 'High-frequency horizontal jerk nystagmus in eccentric gaze toward direction of gaze; neural integrator failure.'},
      {'key': 'downbeat_nystagmus', 'name': 'Downbeat Nystagmus (Chiari / Cerebellar)', 'pearl': 'Fast phase beating downward; worse in lateral gaze and downgaze. Strong indicator of craniocervical junction lesion.'},
      {'key': 'upbeat_nystagmus', 'name': 'Upbeat Nystagmus (Medullary / Pontine)', 'pearl': 'Fast phase beating upward in primary position or upgaze; anterior vermis or lower brainstem lesion.'},
      {'key': 'infantile_nystagmus', 'name': 'Infantile Nystagmus Syndrome', 'pearl': 'Conjugate horizontal oscillation dampening with convergence; distinct null point with abnormal head posture.'},
      {'key': 'convergence_retraction', 'name': 'Convergence-Retraction Nystagmus', 'pearl': 'Co-contraction of recti retracting the globes into the orbit on attempted upgaze; hallmark of dorsal midbrain mass.'},
    ],
    'strabismus': [
      {'key': 'orthophoria', 'name': 'Orthophoria', 'pearl': 'Perfect bifoveal binocular motor alignment maintained on cover and uncover.'},
      {'key': 'esophoria', 'name': 'Esophoria (Latent Inward Shift)', 'pearl': 'Eye drifts inward only under cover; makes rapid temporal recovery saccade upon uncover.'},
      {'key': 'exophoria', 'name': 'Exophoria (Latent Outward Shift)', 'pearl': 'Eye drifts outward under cover; recovers inward toward midline on uncover.'},
      {'key': 'esotropia', 'name': 'Constant Esotropia', 'pearl': 'Manifest inward deviation present without cover; temporal shift of corneal light reflex (Hirschberg).'},
      {'key': 'exotropia', 'name': 'Constant Exotropia', 'pearl': 'Manifest outward deviation present without cover; nasal shift of corneal light reflex.'},
      {'key': 'hypertropia_right', 'name': 'Right Hypertropia (Manifest Elevation OD)', 'pearl': 'Right eye elevated relative to left; downward recovery movement on cover-uncover.'},
      {'key': 'hypertropia_left', 'name': 'Left Hypertropia (Manifest Elevation OS)', 'pearl': 'Left eye elevated relative to right; downward recovery on cover-uncover.'},
      {'key': 'duane_type1', 'name': 'Duane Retraction Syndrome Type 1', 'pearl': 'Marked limitation of abduction with narrowing of palpebral fissure and globe retraction on adduction.'},
      {'key': 'myasthenia_gravis', 'name': 'Myasthenia Gravis (Fatigable Ptosis)', 'pearl': 'Variable, fatigable ptosis and diplopia worsening with sustained upgaze. Cogan lid twitch & Ice test positive.'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _nystagmusAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _blinkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    _autoBlinkTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (mounted) _triggerBlink();
    });
  }

  void _triggerBlink() {
    _blinkAnim.forward(from: 0.0).then((_) {
      if (mounted) _blinkAnim.reverse();
    });
  }

  @override
  void dispose() {
    _autoBlinkTimer?.cancel();
    _swingTimer?.cancel();
    _nystagmusAnim.dispose();
    _blinkAnim.dispose();
    super.dispose();
  }

  void _toggleSwingingFlashlight() {
    if (_isSwingingFlashlight) {
      _swingTimer?.cancel();
      setState(() {
        _isSwingingFlashlight = false;
        _lightRight = 0.0;
        _lightLeft = 0.0;
      });
    } else {
      setState(() {
        _isSwingingFlashlight = true;
        _isTorchActive = true;
        _torchPosition = const Offset(105, 95);
      });

      bool onRight = true;
      _swingTimer?.cancel();
      _swingTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
        if (!mounted) return;
        setState(() {
          onRight = !onRight;
          _torchPosition = onRight ? const Offset(105, 95) : const Offset(275, 95);
          _lightRight = onRight ? 1.0 : 0.0;
          _lightLeft = onRight ? 0.0 : 1.0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeList = _pathologyTaxonomy[_selectedCategory] ?? [];
    final currentCondition = activeList.firstWhere(
      (c) => c['key'] == _pathologyKey,
      orElse: () => activeList.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuro-Ophthalmic Examination Lab'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Interactive 2D Ocular Canvas
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_nystagmusAnim, _blinkAnim]),
                builder: (context, child) {
                  final state = EyeMotilityState(
                    gazeX: _gazeX,
                    gazeY: _gazeY,
                    pathologyKey: _pathologyKey,
                    lightIntensityRight: _lightRight,
                    lightIntensityLeft: _lightLeft,
                    torchPosition: _torchPosition,
                    isTorchActive: _isTorchActive,
                    coverState: _coverState,
                    strabismusType: _strabismusType,
                    nystagmusPhase: _nystagmusAnim.value,
                    prismPower: _prismPower,
                    prismBase: _prismBase,
                    prismEye: _prismEye,
                    isNearTargetActive: _isNearTargetActive,
                    headTiltAngle: _headTiltAngle,
                    fatigueLevel: _fatigueLevel,
                    blinkPhase: _blinkAnim.value,
                  );

                  return Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _torchPosition = details.localPosition;
                          _isTorchActive = true;
                          _isSwingingFlashlight = false;
                          _swingTimer?.cancel();
                          _lightRight = 0.0;
                          _lightLeft = 0.0;
                        });
                      },
                      child: CustomPaint(painter: EyeMotilityPainter(state: state)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Drag penlight across the patient\'s face to test direct/consensual reflexes & corneal reflection.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Clinical Pearl Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology, color: Colors.cyanAccent, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentCondition['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentCondition['pearl'] ?? '',
                          style: TextStyle(color: Colors.grey.shade300, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Category Selector & Pathology Dropdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pathology Domain:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('Cranial Nerves (12)', 'cranial_nerves'),
                          _buildCategoryChip('Internuclear & Gaze (9)', 'internuclear_gaze'),
                          _buildCategoryChip('Pupillary & Sympathetic (8)', 'pupillary'),
                          _buildCategoryChip('Nystagmus (5)', 'nystagmus'),
                          _buildCategoryChip('Strabismus & Tropias (8)', 'strabismus'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('$_selectedCategory-$_pathologyKey'),
                      isExpanded: true,
                      initialValue: _pathologyKey,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: activeList.map((item) {
                        return DropdownMenuItem(
                          value: item['key'],
                          child: Text(item['name']!, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _pathologyKey = val;
                            if (val.contains('tropia') || val.contains('phoria')) {
                              _strabismusType = val;
                            } else {
                              _strabismusType = 'orthophoria';
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Examination Instruments Dock: Penlight, Near Target & Marcus Gunn Swing
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Penlight & Pupillary Examination Dock',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.wb_incandescent, size: 14, color: Colors.amber),
                          label: const Text('Direct OD', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setState(() {
                              _torchPosition = const Offset(105, 95);
                              _isTorchActive = true;
                              _isSwingingFlashlight = false;
                              _swingTimer?.cancel();
                            });
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.wb_incandescent, size: 14, color: Colors.amber),
                          label: const Text('Direct OS', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setState(() {
                              _torchPosition = const Offset(275, 95);
                              _isTorchActive = true;
                              _isSwingingFlashlight = false;
                              _swingTimer?.cancel();
                            });
                          },
                        ),
                        ElevatedButton.icon(
                          icon: Icon(_isSwingingFlashlight ? Icons.stop : Icons.sync, size: 14),
                          label: Text(_isSwingingFlashlight ? 'Stop Swing' : 'Marcus Gunn Auto-Swing',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSwingingFlashlight ? Colors.redAccent : theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _toggleSwingingFlashlight,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.my_location, size: 14),
                          label: Text(_isNearTargetActive ? 'Remove Near Target' : 'Present Near Target',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isNearTargetActive ? Colors.teal : Colors.grey.shade800,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNearTargetActive = !_isNearTargetActive;
                              if (_isNearTargetActive) {
                                _isTorchActive = false;
                                _isSwingingFlashlight = false;
                                _swingTimer?.cancel();
                              }
                            });
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.cyanAccent),
                          label: const Text('Blink Eyes', style: TextStyle(fontSize: 11)),
                          onPressed: _triggerBlink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 5. Ophthalmic Occluder & Prism Neutralization Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cover Test & Prism Neutralization (PACT)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          avatar: const Icon(Icons.visibility, size: 14),
                          label: const Text('Uncovered', style: TextStyle(fontSize: 11)),
                          selected: _coverState == 'uncovered',
                          onSelected: (s) {
                            if (s) setState(() => _coverState = 'uncovered');
                          },
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.block, size: 14),
                          label: const Text('Cover OD (Right)', style: TextStyle(fontSize: 11)),
                          selected: _coverState == 'cover_right',
                          onSelected: (s) {
                            if (s) setState(() => _coverState = 'cover_right');
                          },
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.block, size: 14),
                          label: const Text('Cover OS (Left)', style: TextStyle(fontSize: 11)),
                          selected: _coverState == 'cover_left',
                          onSelected: (s) {
                            if (s) setState(() => _coverState = 'cover_left');
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _prismEye,
                            decoration: const InputDecoration(
                              labelText: 'Prism Over',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'none', child: Text('None', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'right', child: Text('OD (Right)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'left', child: Text('OS (Left)', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) => setState(() => _prismEye = val ?? 'none'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _prismBase,
                            decoration: const InputDecoration(
                              labelText: 'Base Direction',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'none', child: Text('None', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'BI', child: Text('Base In (BI)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'BO', child: Text('Base Out (BO)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'BU', child: Text('Base Up (BU)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'BD', child: Text('Base Down (BD)', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) => setState(() => _prismBase = val ?? 'none'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('$_prismPower Δ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan)),
                        Expanded(
                          child: Slider(
                            value: _prismPower.toDouble(),
                            min: 0,
                            max: 50,
                            divisions: 25,
                            onChanged: (val) => setState(() => _prismPower = val.toInt()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 5b. Head Tilt (Bielschowsky 3-Step Test) & Fatigue Test Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bielschowsky Head Tilt Test (CN IV Trochlear SO Palsy)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          avatar: const Icon(Icons.rotate_left, size: 14),
                          label: const Text('Left Tilt (-15°)', style: TextStyle(fontSize: 11)),
                          selected: _headTiltAngle == -15.0,
                          onSelected: (s) => setState(() => _headTiltAngle = s ? -15.0 : 0.0),
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.accessibility, size: 14),
                          label: const Text('Upright (0°)', style: TextStyle(fontSize: 11)),
                          selected: _headTiltAngle == 0.0,
                          onSelected: (s) => setState(() => _headTiltAngle = 0.0),
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.rotate_right, size: 14),
                          label: const Text('Right Tilt (+15°)', style: TextStyle(fontSize: 11)),
                          selected: _headTiltAngle == 15.0,
                          onSelected: (s) => setState(() => _headTiltAngle = s ? 15.0 : 0.0),
                        ),
                        if (_pathologyKey == 'myasthenia_gravis')
                          ElevatedButton.icon(
                            icon: const Icon(Icons.timer, size: 14),
                            label: Text(_fatigueLevel > 0.5 ? 'Reset Fatigue' : 'Sustained Upgaze (Fatigue Test)',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _fatigueLevel > 0.5 ? Colors.orangeAccent : Colors.purpleAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if (_fatigueLevel > 0.5) {
                                setState(() => _fatigueLevel = 0.0);
                              } else {
                                setState(() {
                                  _gazeY = 0.85; // Look up
                                  _fatigueLevel = 0.90; // Trigger ptosis fatigue
                                });
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 6. 9 Cardinal Diagnostic Gazes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('9 Cardinal Diagnostic Gazes',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        TextButton.icon(
                          icon: const Icon(Icons.center_focus_strong, size: 14),
                          label: const Text('Primary', style: TextStyle(fontSize: 11)),
                          onPressed: () => setState(() { _gazeX = 0; _gazeY = 0; }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 2.2,
                      children: [
                        _buildGazeBtn('Up-Right', -0.85, 0.85),
                        _buildGazeBtn('Up', 0.0, 0.85),
                        _buildGazeBtn('Up-Left', 0.85, 0.85),
                        _buildGazeBtn('Right', -0.85, 0.0),
                        _buildGazeBtn('Primary', 0.0, 0.0),
                        _buildGazeBtn('Left', 0.85, 0.0),
                        _buildGazeBtn('Down-Right', -0.85, -0.85),
                        _buildGazeBtn('Down', 0.0, -0.85),
                        _buildGazeBtn('Down-Left', 0.85, -0.85),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String key) {
    final isSel = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSel,
        onSelected: (s) {
          if (s) {
            setState(() {
              _selectedCategory = key;
              final list = _pathologyTaxonomy[key] ?? [];
              _pathologyKey = list.first['key']!;
              if (_pathologyKey.contains('tropia') || _pathologyKey.contains('phoria')) {
                _strabismusType = _pathologyKey;
              } else {
                _strabismusType = 'orthophoria';
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildGazeBtn(String label, double x, double y) {
    final isSelected = (_gazeX - x).abs() < 0.1 && (_gazeY - y).abs() < 0.1;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: isSelected ? const Color(0xFF0284C7).withValues(alpha: 0.25) : null,
        side: BorderSide(color: isSelected ? const Color(0xFF0284C7) : Colors.grey.shade700),
      ),
      onPressed: () => setState(() { _gazeX = x; _gazeY = y; }),
      child: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.cyanAccent : Colors.white)),
    );
  }
}
