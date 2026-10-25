import 'package:flutter/material.dart';
import 'widgets/visual_pathway_painter.dart';

class VisualPathwaysSimulatorScreen extends StatefulWidget {
  const VisualPathwaysSimulatorScreen({super.key});

  @override
  State<VisualPathwaysSimulatorScreen> createState() => _VisualPathwaysSimulatorScreenState();
}

class _VisualPathwaysSimulatorScreenState extends State<VisualPathwaysSimulatorScreen> {
  String _lesionLocation = 'optic_chiasm';
  Offset? _testPoint;
  bool _isLeftEyeTested = true;
  bool _showNumericDecibels = false;
  String _testFeedback = 'Tap on OS or OD perimetry field to test visual sensitivity (Goldmann III stimulus).';

  final List<Map<String, String>> _lesionOptions = [
    {
      'key': 'normal',
      'title': 'Normal Visual Field (No Lesion)',
      'anatomy': 'Intact retinogeniculo-striate visual pathways bilaterally.',
      'clinical': 'Normal 30-2 visual field sensitivity with physiological blind spot (optic disc).'
    },
    {
      'key': 'left_optic_nerve',
      'title': 'Left Optic Nerve Lesion (Anterior to Chiasm)',
      'anatomy': 'Total transection of left afferent optic nerve fibers.',
      'clinical': 'Complete monocular blindness (amaurosis) of the left eye with left RAPD (Marcus Gunn pupil). Right eye field is completely normal.'
    },
    {
      'key': 'right_optic_nerve',
      'title': 'Right Optic Nerve Lesion (Anterior to Chiasm)',
      'anatomy': 'Total transection of right afferent optic nerve fibers.',
      'clinical': 'Complete monocular blindness of the right eye with right RAPD.'
    },
    {
      'key': 'junctional_scotoma',
      'title': 'Junctional Scotoma of Traquair (Anterior Chiasm)',
      'anatomy': 'Lesion at the junction of the left optic nerve and optic chiasm compressing decussating inferior nasal fibers from contralateral right eye (Wilbrand knee).',
      'clinical': 'Ipsilateral central scotoma/blindness in left eye + Contralateral superior temporal quadrantanopsia in right eye.'
    },
    {
      'key': 'optic_chiasm',
      'title': 'Optic Chiasm Compression (Pituitary Adenoma)',
      'anatomy': 'Compression of crossing nasal hemiretinal fibers in the body of the chiasm.',
      'clinical': 'Bitemporal hemianopsia (loss of both temporal visual fields). Hallmarks: Pituitary macroadenoma, craniopharyngioma, or Rathke cleft cyst.'
    },
    {
      'key': 'left_optic_tract',
      'title': 'Left Optic Tract Lesion',
      'anatomy': 'Left optic tract carrying ipsilateral temporal fibers (left eye) and contralateral nasal fibers (right eye).',
      'clinical': 'Incongruous Right Homonymous Hemianopsia with Wernicke pupillary hemianopic reflex.'
    },
    {
      'key': 'right_optic_tract',
      'title': 'Right Optic Tract Lesion',
      'anatomy': 'Right optic tract prior to Lateral Geniculate Nucleus (LGN).',
      'clinical': 'Incongruous Left Homonymous Hemianopsia.'
    },
    {
      'key': 'left_meyers_loop',
      'title': 'Left Meyer\'s Loop (Temporal Optic Radiation)',
      'anatomy': 'Inferior retinal fibers sweeping anteriorly into the left temporal lobe around the temporal horn of the lateral ventricle.',
      'clinical': 'Right Superior Homonymous Quadrantanopsia ("Pie-in-the-Sky"). Common in temporal lobectomy or MCA inferior division stroke.'
    },
    {
      'key': 'right_meyers_loop',
      'title': 'Right Meyer\'s Loop (Temporal Optic Radiation)',
      'anatomy': 'Inferior fibers in the right temporal lobe.',
      'clinical': 'Left Superior Homonymous Quadrantanopsia ("Pie-in-the-Sky").'
    },
    {
      'key': 'left_baums_loop',
      'title': 'Left Baum\'s Loop (Parietal Optic Radiation)',
      'anatomy': 'Superior retinal fibers passing directly posteriorly through the left parietal lobe to the upper bank of the calcarine fissure.',
      'clinical': 'Right Inferior Homonymous Quadrantanopsia ("Pie-on-the-Floor"). Often accompanied by Gerstmann syndrome or right-sided hemineglect.'
    },
    {
      'key': 'right_baums_loop',
      'title': 'Right Baum\'s Loop (Parietal Optic Radiation)',
      'anatomy': 'Superior retinal fibers in the right parietal lobe.',
      'clinical': 'Left Inferior Homonymous Quadrantanopsia ("Pie-on-the-Floor").'
    },
    {
      'key': 'left_occipital_sparing',
      'title': 'Left Occipital Cortex with Macular Sparing',
      'anatomy': 'Left primary visual cortex (V1 / striate area) infarction due to Posterior Cerebral Artery (PCA) occlusion.',
      'clinical': 'Congruous Right Homonymous Hemianopsia with 5°-10° Macular Sparing. Sparing is due to dual blood supply of the occipital pole (PCA + MCA collateral flow).'
    },
    {
      'key': 'right_occipital_sparing',
      'title': 'Right Occipital Cortex with Macular Sparing',
      'anatomy': 'Right primary visual cortex (V1) infarction.',
      'clinical': 'Congruous Left Homonymous Hemianopsia with Macular Sparing.'
    },
    {
      'key': 'occipital_pole',
      'title': 'Occipital Pole Lesion (Isolated Macular Scotoma)',
      'anatomy': 'Trauma, embolus, or localized mass at the extreme posterior tip of the occipital pole.',
      'clinical': 'Bilateral central homonymous maculopathy with preserved peripheral field.'
    },
  ];

  void _handleCanvasTap(TapDownDetails details, Size size) {
    final pos = details.localPosition;
    final w = size.width;
    final h = size.height;

    // Perimetry Field Taps (Upper Portion)
    if (pos.dy < h * 0.45) {
      final isLeft = pos.dx < w * 0.5;
      final fieldCenter = isLeft ? Offset(w * 0.25, h * 0.18) : Offset(w * 0.75, h * 0.18);
      final dist = (pos - fieldCenter).distance;

      if (dist <= 45.0) {
        setState(() {
          _testPoint = pos;
          _isLeftEyeTested = isLeft;
          _testFeedback = _evaluateStimulusSensitivity(pos, fieldCenter, isLeft, _lesionLocation);
        });
      }
    } else {
      // Anatomical Diagram Taps (Lower Portion)
      final normY = pos.dy / h;
      final normX = pos.dx / w;

      String? newLesion;
      if (normY >= 0.45 && normY <= 0.60) {
        if ((normX - 0.5).abs() < 0.15) {
          newLesion = 'optic_chiasm';
        } else if (normX < 0.38) {
          newLesion = 'left_optic_nerve';
        } else {
          newLesion = 'right_optic_nerve';
        }
      } else if (normY > 0.60 && normY <= 0.76) {
        if (normX < 0.5) {
          newLesion = 'left_optic_tract';
        } else {
          newLesion = 'right_optic_tract';
        }
      } else if (normY > 0.76 && normY <= 0.86) {
        if (normX < 0.5) {
          newLesion = 'left_meyers_loop';
        } else {
          newLesion = 'right_meyers_loop';
        }
      } else if (normY > 0.86) {
        if (normX < 0.5) {
          newLesion = 'left_occipital_sparing';
        } else {
          newLesion = 'right_occipital_sparing';
        }
      }

      if (newLesion != null) {
        setState(() {
          _lesionLocation = newLesion!;
          _testPoint = null;
          _testFeedback = 'Lesion shifted to: ${newLesion.replaceAll('_', ' ').toUpperCase()}';
        });
      }
    }
  }

  String _evaluateStimulusSensitivity(Offset tapPos, Offset center, bool isLeft, String lesion) {
    final dx = tapPos.dx - center.dx;
    final dy = tapPos.dy - center.dy;

    bool isBlind = false;
    switch (lesion) {
      case 'left_optic_nerve':
        if (isLeft) {
          isBlind = true;
        }
        break;
      case 'right_optic_nerve':
        if (!isLeft) {
          isBlind = true;
        }
        break;
      case 'optic_chiasm':
        isBlind = isLeft ? (dx < 0) : (dx > 0);
        break;
      case 'junctional_scotoma':
        if (isLeft) {
          isBlind = true;
        } else if (dx > 0 && dy < 0) {
          isBlind = true;
        }
        break;
      case 'left_optic_tract':
      case 'left_lgn':
        isBlind = (dx > 0);
        break;
      case 'right_optic_tract':
      case 'right_lgn':
        isBlind = (dx < 0);
        break;
      case 'left_meyers_loop':
        isBlind = (dx > 0 && dy < 0);
        break;
      case 'right_meyers_loop':
        isBlind = (dx < 0 && dy < 0);
        break;
      case 'left_baums_loop':
        isBlind = (dx > 0 && dy > 0);
        break;
      case 'right_baums_loop':
        isBlind = (dx < 0 && dy > 0);
        break;
      case 'left_occipital_sparing':
        if (dx > 0) {
          final centerDist = (tapPos - center).distance;
          isBlind = (centerDist > 11.0); // Macular Sparing 5°-10°
        }
        break;
      case 'right_occipital_sparing':
        if (dx < 0) {
          final centerDist = (tapPos - center).distance;
          isBlind = (centerDist > 11.0);
        }
        break;
    }

    if (isBlind) {
      return '🚨 0 dB - ABSOLUTE SCOTOMA / UNSEEN (Defect at tested location)';
    } else {
      return '✅ 30 dB - NORMAL SENSITIVITY (Stimulus Seen)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLesion = _lesionOptions.firstWhere(
      (item) => item['key'] == _lesionLocation,
      orElse: () => _lesionOptions.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visual Pathways & Perimetry Lab'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Clinical summary header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline, color: Colors.cyanAccent, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activeLesion['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anatomy:\n${activeLesion['anatomy']!}',
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Clinical Pearl:\n${activeLesion['clinical']!}',
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Perimetry Test Result Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
              ),
              child: Text(
                _testFeedback,
                style: const TextStyle(fontSize: 12, color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Dropdown Selector for Lesion Sites
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Lesion Site along Afferent Pathway:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _lesionLocation,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _lesionOptions.map((item) {
                        return DropdownMenuItem(
                          value: item['key'],
                          child: Text(item['title']!, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _lesionLocation = val;
                            _testPoint = null;
                            _testFeedback = 'Selected: ${itemTitle(val)}';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Perimetry Display Mode Toggle (Grayscale vs Decibel dB Map)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Humphrey 30-2 Display Mode:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: false, label: Text('Grayscale', style: TextStyle(fontSize: 11))),
                    ButtonSegment<bool>(value: true, label: Text('Numeric dB', style: TextStyle(fontSize: 11))),
                  ],
                  selected: {_showNumericDecibels},
                  onSelectionChanged: (Set<bool> sel) {
                    setState(() => _showNumericDecibels = sel.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Visual Pathways & Perimetry Interactive Canvas
            Center(
              child: Container(
                width: double.infinity,
                height: 440,
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onTapDown: (details) => _handleCanvasTap(details, size),
                      child: CustomPaint(
                        painter: VisualPathwayPainter(
                          state: VisualPathwayState(
                            lesionLocation: _lesionLocation,
                            perimetryTestPoint: _testPoint,
                            isLeftEyeTested: _isLeftEyeTested,
                            showNumericDecibels: _showNumericDecibels,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '💡 Tip: Tap directly on OS/OD Perimetry fields to test visual sensitivity, or tap anatomical nodes to shift lesion location.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String itemTitle(String key) {
    final opt = _lesionOptions.firstWhere((element) => element['key'] == key, orElse: () => _lesionOptions.first);
    return opt['title'] ?? key;
  }
}

