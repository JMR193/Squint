import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';

class CaseQuiz {
  final String id;
  final String title;
  final String patientAge;
  final String presentation;
  final String examinationFindings;
  final List<String> options;
  final int correctIndex;
  final String rationale;
  final String clinicalPearl;

  CaseQuiz({
    required this.id,
    required this.title,
    required this.patientAge,
    required this.presentation,
    required this.examinationFindings,
    required this.options,
    required this.correctIndex,
    required this.rationale,
    required this.clinicalPearl,
  });
}

class CaseQuizzesScreen extends StatefulWidget {
  const CaseQuizzesScreen({super.key});

  @override
  State<CaseQuizzesScreen> createState() => _CaseQuizzesScreenState();
}

class _CaseQuizzesScreenState extends State<CaseQuizzesScreen> {
  int _currentCaseIndex = 0;
  int? _selectedAnswer;
  bool _hasSubmitted = false;
  int _score = 0;
  final Set<int> _answeredIndices = {};

  final List<CaseQuiz> _cases = [
    CaseQuiz(
      id: 'CASE-01',
      title: 'Pediatric Inward Eye Turn & Head Tilt',
      patientAge: '6-month-old infant',
      presentation: 'Parents noticed inward turning of both eyes since 3 months of age. No prior medical history. Normal birth weight.',
      examinationFindings: 'Alternate Cover Test: 45Δ Constant Esotropia for distance and near. Cross-fixation present (uses right eye to view left field, left eye to view right field). Smooth pursuits normal with no abduction deficit on Doll\'s eye maneuver. Latent nystagmus and Inferior Oblique Overaction (IOOA) noted.',
      options: [
        'Accommodative Esotropia (needs full cycloplegic plus spectacles)',
        'Congenital / Infantile Esotropia (indicates Bilateral Medial Rectus Recession)',
        'Sixth Cranial Nerve (Abducens) Palsy',
        'Duane Retraction Syndrome Type 1',
      ],
      correctIndex: 1,
      rationale: 'Infantile Esotropia characteristically presents before 6 months of age with a large, stable angle (>30Δ), cross-fixation, normal neurological exam, and intact abduction on vestibulo-ocular reflex. Surgical alignment (BMR recession) before 2 years optimizes binocular potential.',
      clinicalPearl: 'Do not mistake cross-fixation for bilateral CN VI palsy! The Doll\'s eye maneuver demonstrates full bilateral abduction.',
    ),
    CaseQuiz(
      id: 'CASE-02',
      title: 'Vertical Diplopia Following Head Trauma',
      patientAge: '32-year-old cyclist',
      presentation: 'Presents with vertical and torsional diplopia following a minor bicycle fall without loss of consciousness. Diplopia is worse when looking down to read.',
      examinationFindings: 'Parks-Bielschowsky 3-Step Test:\n1) Primary gaze: Right Hypertropia (8Δ)\n2) Horizontal Gaze: Hypertropia increases to 18Δ on Left Gaze\n3) Head Tilt Test: Hypertropia increases to 24Δ on Right Head Tilt.\nDouble Maddox Rod: 9° excyclotorsion OD.',
      options: [
        'Left Superior Rectus Palsy',
        'Right Superior Oblique (CN IV) Palsy',
        'Right Inferior Oblique Palsy',
        'Left Inferior Rectus Palsy',
      ],
      correctIndex: 1,
      rationale: 'The Bielschowsky 3-Step Test isolates the right superior oblique muscle (Right Hypertropia + worse on left gaze + worse on right head tilt). The superior oblique is an intorter and depressor in adduction; tilting right forces the right eye to intort via the superior rectus, which elevates the eye unopposed.',
      clinicalPearl: 'The trochlear nerve has the longest intracranial course and is the most vulnerable cranial nerve to closed head trauma.',
    ),
    CaseQuiz(
      id: 'CASE-03',
      title: 'Diplopia with Headache & Papilledema',
      patientAge: '27-year-old female (BMI 33)',
      presentation: 'Constant horizontal diplopia at distance worse on right gaze, accompanied by daily pulsatile tinnitus and transient visual obscurations.',
      examinationFindings: 'Right eye fails to abduct past midline (-3 limitation). Bilateral swollen optic discs with peripapillary flame hemorrhages (Frisén Grade 3 papilledema). MRI brain normal, MRV shows bilateral transverse sinus stenosis. Opening pressure on LP is 38 cm H2O.',
      options: [
        'Right Oculomotor Nerve Palsy',
        'Idiopathic Intracranial Hypertension (IIH) with False Localizing Right CN VI Palsy',
        'Graves Thyroid Eye Disease with Lateral Rectus Restriction',
        'Myasthenia Gravis',
      ],
      correctIndex: 1,
      rationale: 'Elevated intracranial pressure compresses the abducens nerve against the petrous temporal bone ridge (Dorello\'s canal), producing a classic "false localizing" CN VI palsy.',
      clinicalPearl: 'Papilledema with normal neuroimaging and elevated opening pressure confirms IIH. Urgent weight management and acetazolamide are key.',
    ),
    CaseQuiz(
      id: 'CASE-04',
      title: 'Severe Ptosis with Dilated Fixed Pupil',
      patientAge: '58-year-old female',
      presentation: 'Sudden onset right eye drooping and "worst headache of life".',
      examinationFindings: 'Complete right upper eyelid ptosis. When the lid is manually lifted, the right eye is fixed in a "down and out" position (exotropia and hypotropia). Right pupil is 8mm and completely unreactive to direct light or 1% pilocarpine. Left pupil is 3.5mm and briskly reactive.',
      options: [
        'Microvascular (Diabetic) Pupil-Sparing CN III Palsy',
        'Posterior Communicating Artery (PCOM) Aneurysm compressing CN III',
        'Ocular Myasthenia Gravis',
        'Horner Syndrome',
      ],
      correctIndex: 1,
      rationale: 'Pupil-involving complete CN III palsy with down-and-out deviation and severe headache is a medical emergency representing pupillomotor parasympathetic fiber compression from a PCOM aneurysm. Requires emergent CTA / MRA brain.',
      clinicalPearl: 'Pupillomotor fibers travel on the outer superomedial periphery of CN III, making them exquisitely sensitive to external compression by aneurysms.',
    ),
    CaseQuiz(
      id: 'CASE-05',
      title: 'Left Eye Retraction & Narrowing on Adduction',
      patientAge: '7-year-old boy',
      presentation: 'Parents note left eye appears smaller when looking to the right. Left face turn noted when watching television.',
      examinationFindings: 'Left eye has complete absence of abduction past midline. On attempted adduction to the right, the left eye retracts into the orbit with significant narrowing of the palpebral fissure. Normal pupillary reflexes. Orthophoric with 15° left head turn.',
      options: [
        'Left Sixth Nerve Palsy',
        'Duane Retraction Syndrome Type 1',
        'Brown Syndrome',
        'Mobius Syndrome',
      ],
      correctIndex: 1,
      rationale: 'Duane Syndrome Type 1 is caused by congenital hypoplasia/absence of the sixth nerve nucleus with anomalous aberrant innervation of the lateral rectus by branches of the third cranial nerve, causing co-contraction on adduction (globe retraction).',
      clinicalPearl: 'Never resect the lateral rectus in Duane syndrome! It will worsen globe retraction and palpebral fissure narrowing.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final curCase = _cases[_currentCaseIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Case Vignette Lab'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Score: $_score / ${_cases.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Case Progress Bar
          LinearProgressIndicator(
            value: (_currentCaseIndex + 1) / _cases.length,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 12),

          // Case Header Card
          SamsungOneUiGroupCard(
            title: '${curCase.id} • ${curCase.patientAge}',
            icon: Icons.person_pin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(curCase.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.cyanAccent)),
                const SizedBox(height: 8),
                Text('Clinical History:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.secondary)),
                Text(curCase.presentation, style: const TextStyle(fontSize: 12)),
                const Divider(height: 16),
                Text('Physical & Motility Findings:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.secondary)),
                Text(curCase.examinationFindings, style: const TextStyle(fontSize: 12, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Multiple Choice Options
          SamsungOneUiGroupCard(
            title: 'DIFFERENTIAL DIAGNOSIS QUESTION',
            icon: Icons.help_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What is the most likely diagnosis and management plan?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                ...List.generate(curCase.options.length, (i) {
                  final isSelected = _selectedAnswer == i;
                  Color? tileColor;
                  Widget? trailingIcon;

                  if (_hasSubmitted) {
                    if (i == curCase.correctIndex) {
                      tileColor = Colors.green.withValues(alpha: 0.2);
                      trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
                    } else if (isSelected) {
                      tileColor = Colors.red.withValues(alpha: 0.2);
                      trailingIcon = const Icon(Icons.cancel, color: Colors.red);
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: tileColor ?? (isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : null),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey.shade700,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(curCase.options[i], style: const TextStyle(fontSize: 12)),
                      trailing: trailingIcon,
                      onTap: _hasSubmitted
                          ? null
                          : () {
                              setState(() => _selectedAnswer = i);
                            },
                    ),
                  );
                }),
                const SizedBox(height: 10),
                if (!_hasSubmitted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Clinical Assessment'),
                      onPressed: _selectedAnswer == null
                          ? null
                          : () {
                              setState(() {
                                _hasSubmitted = true;
                                if (_selectedAnswer == curCase.correctIndex) {
                                  if (!_answeredIndices.contains(_currentCaseIndex)) {
                                    _score++;
                                    _answeredIndices.add(_currentCaseIndex);
                                  }
                                }
                              });
                            },
                    ),
                  ),
              ],
            ),
          ),

          // Rationale & Remediation Pearl (Appears on submit)
          if (_hasSubmitted) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedAnswer == curCase.correctIndex
                    ? Colors.green.shade900.withValues(alpha: 0.3)
                    : Colors.red.shade900.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedAnswer == curCase.correctIndex ? Colors.green : Colors.red,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedAnswer == curCase.correctIndex ? Icons.check_circle : Icons.error,
                        color: _selectedAnswer == curCase.correctIndex ? Colors.greenAccent : Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedAnswer == curCase.correctIndex ? 'Correct Diagnosis!' : 'Incorrect Differential',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedAnswer == curCase.correctIndex ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Clinical Rationale:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(curCase.rationale, style: const TextStyle(fontSize: 12, height: 1.3)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb, size: 16, color: Colors.amberAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Remediation Pearl: ${curCase.clinicalPearl}',
                            style: const TextStyle(fontSize: 11, color: Colors.amberAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentCaseIndex > 0)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous Case'),
                    onPressed: () {
                      setState(() {
                        _currentCaseIndex--;
                        _selectedAnswer = null;
                        _hasSubmitted = false;
                      });
                    },
                  )
                else
                  const SizedBox.shrink(),
                if (_currentCaseIndex < _cases.length - 1)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next Clinical Case'),
                    onPressed: () {
                      setState(() {
                        _currentCaseIndex++;
                        _selectedAnswer = null;
                        _hasSubmitted = false;
                      });
                    },
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.replay),
                    label: const Text('Restart Case Bank'),
                    onPressed: () {
                      setState(() {
                        _currentCaseIndex = 0;
                        _selectedAnswer = null;
                        _hasSubmitted = false;
                        _score = 0;
                        _answeredIndices.clear();
                      });
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
