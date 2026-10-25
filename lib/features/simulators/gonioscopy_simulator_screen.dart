import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';

/// Interactive Gonioscopy & Anterior Chamber Angle Grading Laboratory.
/// Features 4-mirror Goldmann/Zeiss simulation, Corneal Optical Wedge visualization,
/// Spaeth/Shaffer/Van Herick grading systems, dynamic indentation gonioscopy,
/// and comprehensive anterior chamber angle pathologies.
class GonioscopySimulatorScreen extends StatefulWidget {
  const GonioscopySimulatorScreen({super.key});

  @override
  State<GonioscopySimulatorScreen> createState() => _GonioscopySimulatorScreenState();
}

class _GonioscopySimulatorScreenState extends State<GonioscopySimulatorScreen> with SingleTickerProviderStateMixin {
  int _shafferGrade = 4; // 4: Wide Open (45°), 3: Open (30°), 2: Narrow (20°), 1: Extremely Narrow (10°), 0: Closed (0°)
  bool _isIndentationActive = false;
  String _selectedQuadrant = 'inferior'; // inferior, superior, nasal, temporal
  String _selectedPathology = 'normal'; // normal, angle_closure, pigmentary, pseudoexfoliation, angle_recession, neovascularization, plateau_iris, ice_syndrome, schlemm_blood
  bool _showCornealWedge = true;
  bool _showCrossSection = false;
  late AnimationController _pulseController;

  final Map<String, Map<String, dynamic>> _pathologyData = {
    'normal': {
      'name': 'Normal Wide Open Angle (Shaffer Grade 4 / Spaeth D40r)',
      'description': 'All anterior chamber angle structures are clearly identifiable in proper anatomical sequence: Schwalbe Line, Non-pigmented TM, Pigmented TM, Scleral Spur, and Ciliary Body Band.',
      'structures': ['Schwalbe\'s Line (SL)', 'Non-Pigmented TM', 'Pigmented Trabecular Meshwork', 'Scleral Spur (SS)', 'Ciliary Body Band (CBB)'],
      'clinical': 'Low risk for angle closure. Normal aqueous outflow facility through Schlemm\'s canal and collector channels.',
      'spaeth': 'D40r (Insertion at CBB, 40° approach, regular flat iris)',
      'vanHerick': 'Grade 4 (Peripheral AC depth > 100% corneal thickness)',
    },
    'angle_closure': {
      'name': 'Primary Angle Closure (PAC / PACS / Acute PACG)',
      'description': 'Appositional or synechial contact between the peripheral iris and trabecular meshwork blocking trabecular outflow.',
      'structures': ['Cornea only (Appositional)', 'Schwalbe\'s Line unmasked on dynamic indentation', 'Peripheral Anterior Synechiae (PAS)'],
      'clinical': 'Shaffer Grade 0-1. High risk of pupillary block and severe IOP spike. Indication for Laser Peripheral Iridotomy (LPI) or lens extraction.',
      'spaeth': '(A)0s (Appositional contact anterior to SL, 0° steep iris)',
      'vanHerick': 'Grade 0-1 (Peripheral AC depth < 25% corneal thickness)',
    },
    'pigmentary': {
      'name': 'Pigment Dispersion Syndrome / Pigmentary Glaucoma',
      'description': 'Dense, homogenous 360° dark chocolate-brown trabecular meshwork pigmentation with pronounced Sampaolesi line.',
      'structures': ['Heavily Saturated Pigmented TM', 'Sampaolesi Line (Pigment on SL)', 'Iris Transillumination Defects', 'Concave Mid-Peripheral Iris'],
      'clinical': 'Reverse pupillary block causing mechanical friction between iris pigment epithelium and zonular bundles during accommodation.',
      'spaeth': 'D40q 4+ (CBB insertion, 40° angle, concave "queer" contour, 4+ pigment)',
      'vanHerick': 'Grade 4 (Deep anterior chamber)',
    },
    'pseudoexfoliation': {
      'name': 'Pseudoexfoliation Syndrome (PXF / PEX)',
      'description': 'Dandruff-like fibrillar white amyloid-like deposits on lens capsule, pupillary margin, and trabecular meshwork with patchy irregular pigmentation.',
      'structures': ['Patchy/Uneven TM Pigmentation', 'Sampaolesi Line with Flake Deposits', 'Fibrillar White Exfoliation Material', 'Weak Zonules'],
      'clinical': 'Asymmetric, marked IOP fluctuation, zonular instability (phacodonesis). High surgical risk for zonular dialysis during cataract extraction.',
      'spaeth': 'D30r 3+ (CBB insertion, 30° approach, patchy 3+ pigment)',
      'vanHerick': 'Grade 3-4',
    },
    'angle_recession': {
      'name': 'Traumatic Angle Recession (Contusion Deformity)',
      'description': 'Tear between circular and longitudinal ciliary muscle fibers following blunt ocular trauma, causing abnormal widening of CBB.',
      'structures': ['Pathologically Broadened Ciliary Body Band', 'Torn/Broken Iris Processes', 'Posteriorly Displaced Scleral Spur', 'Focal TM Fibrosis'],
      'clinical': 'Recession >180° carries a high lifetime cumulative risk of secondary glaucoma due to progressive trabecular endothelial scarring.',
      'spaeth': 'E45r (Deep ciliary body insertion deeper than CBB, wide 45° angle)',
      'vanHerick': 'Grade 4 (Asymmetrically deep AC compared to fellow eye)',
    },
    'neovascularization': {
      'name': 'Neovascular Glaucoma (NVG / Angle Rubeosis)',
      'description': 'Delicate arborizing neovascular vessels branching across the scleral spur to arborize over the trabecular meshwork with fibrovascular contraction.',
      'structures': ['Arborizing Neovascular Vessels', 'Zipper-like Peripheral Anterior Synechiae (PAS)', 'Distorted Angle Anatomy'],
      'clinical': 'Secondary to ischemic retinal vascular disease (CRVO, PDR, OIS). Intractable IOP elevation; requires urgent Anti-VEGF + Panretinal Photocoagulation (PRP).',
      'spaeth': 'A10s with high tented PAS (Anterior iris synechiae)',
      'vanHerick': 'Grade 1-2 with progressive angle zippering',
    },
    'plateau_iris': {
      'name': 'Plateau Iris Configuration / Syndrome',
      'description': 'Anteriorly displaced ciliary processes holding the peripheral iris root against the trabecular meshwork despite a patent LPI.',
      'structures': ['Double-Hump Sign on Dynamic Indentation', 'Flat Central Anterior Chamber', 'Steep Peripheral Iris Angle Drop-off'],
      'clinical': 'Persistent angle closure post-iridotomy. Indentation gonioscopy shows central deepening with peripheral iris humps (double hump). Treat with Argon Laser Peripheral Iridoplasty (ALPI).',
      'spaeth': 'B20s (Iris insertion at TM/SS, steep peripheral contour)',
      'vanHerick': 'Grade 1-2 peripherally, Grade 4 centrally',
    },
    'ice_syndrome': {
      'name': 'Iridocorneal Endothelial (ICE) Syndrome',
      'description': 'Abnormal proliferative corneal endothelial membrane extending across the angle, contracting to form broad-based high PAS reaching anterior to Schwalbe\'s line.',
      'structures': ['Broad-based High PAS extending onto Cornea', 'Iris Hole Formation (Essential Iris Atrophy)', 'Corectopia', 'Corneal Edema (Hammered Silver)'],
      'clinical': 'Unilateral progressive condition in young/middle-aged adults. Glaucoma is refractory to drops; often requires tube-shunt drainage surgery.',
      'spaeth': 'A0s with high broad corneal PAS',
      'vanHerick': 'Grade 0-1 focal closure',
    },
    'schlemm_blood': {
      'name': 'Blood in Schlemm\'s Canal (Elevated Episcleral Venous Pressure)',
      'description': 'Reflux of bright red blood into Schlemm\'s canal visible through the non-pigmented/pigmented trabecular meshwork.',
      'structures': ['Continuous Red Blood Column in Schlemm\'s Canal', 'Normal Open Angle Anatomy'],
      'clinical': 'Seen in Carotid-Cavernous Fistula (CCF), Sturge-Weber Syndrome, Thyroid Eye Disease, or iatrogenic goniolens compression of episcleral veins.',
      'spaeth': 'D40r with full Schlemm blood filling',
      'vanHerick': 'Grade 4 (Wide open)',
    },
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final curData = _pathologyData[_selectedPathology] ?? _pathologyData['normal']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gonioscopy & Angle Grading Lab'),
        actions: [
          IconButton(
            icon: Icon(_showCornealWedge ? Icons.visibility : Icons.visibility_off, color: Colors.cyanAccent),
            tooltip: 'Toggle Corneal Optical Wedge',
            onPressed: () => setState(() => _showCornealWedge = !_showCornealWedge),
          ),
          IconButton(
            icon: Icon(_showCrossSection ? Icons.view_sidebar : Icons.panorama_fish_eye),
            tooltip: 'Toggle Cross-Sectional Angle View',
            onPressed: () => setState(() => _showCrossSection = !_showCrossSection),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Interactive Gonioscopic Mirror Canvas (Distortion-Free 1:1 Slit-Lamp Ocular View)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF334155), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.15 * _pulseController.value),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CustomPaint(
                        painter: _GonioscopyPainter(
                          shafferGrade: _shafferGrade,
                          isIndented: _isIndentationActive,
                          quadrant: _selectedQuadrant,
                          pathology: _selectedPathology,
                          showCornealWedge: _showCornealWedge,
                          showCrossSection: _showCrossSection,
                          pulseValue: _pulseController.value,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey.shade700),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_showCrossSection ? Icons.view_sidebar : Icons.flip_camera_android, size: 12, color: Colors.cyanAccent),
                    const SizedBox(width: 6),
                    Text(
                      _showCrossSection ? 'Cross-Sectional Chamber Depth View' : '4-Mirror Goldmann / Zeiss Slit-Lamp Gonioscopy View',
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. 4-Quadrant Goldmann Mirror Navigation Selector
          SamsungOneUiGroupCard(
            title: '4-MIRROR QUADRANT INSPECTION',
            icon: Icons.explore,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select gonio mirror quadrant (Remember: Gonio mirrors view the opposite angle 180°):',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildQuadrantButton('inferior', 'Inferior (Top Mirror)', 'Widest, most pigmented'),
                    const SizedBox(width: 8),
                    _buildQuadrantButton('superior', 'Superior (Bottom)', 'Narrowest angle'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQuadrantButton('nasal', 'Nasal (Temporal)', 'Intermediate width'),
                    const SizedBox(width: 8),
                    _buildQuadrantButton('temporal', 'Temporal (Nasal)', 'Intermediate width'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Clinical Findings & Angle Anatomy Card
          SamsungOneUiGroupCard(
            title: 'ANGLE STRUCTURE & MULTI-SYSTEM CLASSIFICATION',
            icon: Icons.search,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curData['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.cyanAccent),
                ),
                const SizedBox(height: 6),
                Text(
                  curData['description'] as String,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const Divider(height: 18),
                const Text('Identified Structures (Posterior to Anterior):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (curData['structures'] as List<String>).map((str) {
                    return Chip(
                      label: Text(str, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      backgroundColor: Colors.blueGrey.shade800,
                      side: BorderSide(color: Colors.blueGrey.shade600),
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueGrey.shade800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, size: 14, color: Colors.amberAccent),
                          const SizedBox(width: 6),
                          Text('Spaeth Grading: ${curData['spaeth']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye, size: 14, color: Colors.lightGreenAccent),
                          const SizedBox(width: 6),
                          Text('Van Herick Depth: ${curData['vanHerick']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Clinical Management Pearl: ${curData['clinical']}',
                  style: const TextStyle(fontSize: 11, color: Colors.orangeAccent, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Shaffer Angle Grade Slider & Dynamic Indentation Controls
          SamsungOneUiGroupCard(
            title: 'SHAFFER GRADING & ZEISS DYNAMIC INDENTATION',
            icon: Icons.tune,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shaffer Grade: Grade $_shafferGrade', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent)),
                    Text(_getShafferAngleLabel(_shafferGrade), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Slider(
                  value: _shafferGrade.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: 'Grade $_shafferGrade (${_getShafferAngleLabel(_shafferGrade)})',
                  onChanged: (val) => setState(() => _shafferGrade = val.toInt()),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Dynamic Indentation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              if (_isIndentationActive)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('FORCE ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Compresses central cornea to displace aqueous backward, differentiating appositional closure from true synechial (PAS) closure.',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: Icon(_isIndentationActive ? Icons.compress : Icons.touch_app, size: 14),
                      label: Text(_isIndentationActive ? 'Release' : 'Indentation', style: const TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isIndentationActive ? Colors.orangeAccent : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () => setState(() => _isIndentationActive = !_isIndentationActive),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Clinical Pathologies Catalog
          SamsungOneUiGroupCard(
            title: 'GONIOSCOPIC PATHOLOGY CATALOG (OCULEARNING CURRICULUM)',
            icon: Icons.category,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedPathology,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: _pathologyData.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value['name'] as String, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPathology = val;
                    if (val == 'angle_closure') {
                      _shafferGrade = 0;
                    } else if (val == 'normal') {
                      _shafferGrade = 4;
                    } else if (val == 'plateau_iris') {
                      _shafferGrade = 1;
                    } else if (val == 'ice_syndrome') {
                      _shafferGrade = 1;
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrantButton(String key, String title, String subtitle) {
    final isSelected = _selectedQuadrant == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedQuadrant = key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.cyan.withValues(alpha: 0.2) : Colors.black12,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.cyanAccent : Colors.blueGrey.shade700,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.cyanAccent : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  String _getShafferAngleLabel(int grade) {
    switch (grade) {
      case 4:
        return '45° (Wide Open - CBB Visible)';
      case 3:
        return '30° (Open - Scleral Spur Visible)';
      case 2:
        return '20° (Narrow - Pigmented TM Visible)';
      case 1:
        return '10° (Extremely Narrow - Schwalbe Line Only)';
      case 0:
        return '0° (Closed - No Structures)';
      default:
        return '';
    }
  }
}

class _GonioscopyPainter extends CustomPainter {
  final int shafferGrade;
  final bool isIndented;
  final String quadrant;
  final String pathology;
  final bool showCornealWedge;
  final bool showCrossSection;
  final double pulseValue;

  _GonioscopyPainter({
    required this.shafferGrade,
    required this.isIndented,
    required this.quadrant,
    required this.pathology,
    required this.showCornealWedge,
    required this.showCrossSection,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Background
    final bgPaint = Paint()..color = const Color(0xFF090D16);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    if (showCrossSection) {
      _paintCrossSection(canvas, size);
      return;
    }

    // 1. Gonioscopy Mirror Aperture Ring (Goldmann Mirror)
    final mirrorRadius = min(w, h) * 0.44;
    final Paint mirrorBg = Paint()..color = const Color(0xFF131B2E);
    final Paint mirrorRim = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(center, mirrorRadius, mirrorBg);
    canvas.drawCircle(center, mirrorRadius, mirrorRim);

    // Effective angle structures visibility
    int effectiveGrade = shafferGrade;
    if (isIndented && shafferGrade == 0) {
      effectiveGrade = (pathology == 'plateau_iris') ? 3 : 2; // Indentation opens appositional closure
    }

    // 2. Draw Anterior Chamber Angle Layers (from peripheral Cornea to Iris root)
    final double layerWidth = mirrorRadius * 1.8;
    final double baseCenterY = center.dy;

    // A. Cornea & Optical Wedge (Top Layer)
    final Paint corneaPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.20);
    final Rect corneaRect = Rect.fromCenter(center: Offset(center.dx, baseCenterY - mirrorRadius * 0.70), width: layerWidth, height: 28);
    canvas.drawOval(corneaRect, corneaPaint);
    _drawLayerLabel(canvas, Offset(center.dx, baseCenterY - mirrorRadius * 0.70), 'Corneal Dome', Colors.cyanAccent.shade100);

    // Corneal Optical Wedge (Slit-lamp beam convergence)
    if (showCornealWedge) {
      final Paint wedgePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 2.0;

      // Outer corneal light line
      final Path wedgeOuter = Path()
        ..moveTo(center.dx - 45, baseCenterY - mirrorRadius * 0.75)
        ..quadraticBezierTo(center.dx - 15, baseCenterY - mirrorRadius * 0.60, center.dx, baseCenterY - mirrorRadius * 0.45);
      // Inner corneal light line
      final Path wedgeInner = Path()
        ..moveTo(center.dx + 45, baseCenterY - mirrorRadius * 0.75)
        ..quadraticBezierTo(center.dx + 15, baseCenterY - mirrorRadius * 0.60, center.dx, baseCenterY - mirrorRadius * 0.45);

      canvas.drawPath(wedgeOuter, wedgePaint);
      canvas.drawPath(wedgeInner, wedgePaint);

      // Apex highlight dot at Schwalbe's Line
      final Paint apexPaint = Paint()..color = Colors.yellowAccent;
      canvas.drawCircle(Offset(center.dx, baseCenterY - mirrorRadius * 0.45), 3.5, apexPaint);
      _drawLayerLabel(canvas, Offset(center.dx + 65, baseCenterY - mirrorRadius * 0.52), 'Optical Wedge Apex (SL)', Colors.yellowAccent);
    }

    // B. Schwalbe's Line
    if (effectiveGrade >= 1 || pathology == 'pigmentary' || pathology == 'pseudoexfoliation') {
      final Paint schwalbePaint = Paint()
        ..color = (pathology == 'pigmentary' || pathology == 'pseudoexfoliation') ? const Color(0xFF78350F) : Colors.white
        ..strokeWidth = 3.5;
      canvas.drawLine(
        Offset(center.dx - mirrorRadius * 0.8, baseCenterY - mirrorRadius * 0.45),
        Offset(center.dx + mirrorRadius * 0.8, baseCenterY - mirrorRadius * 0.45),
        schwalbePaint,
      );
      _drawLayerLabel(
        canvas,
        Offset(center.dx, baseCenterY - mirrorRadius * 0.45 - 9),
        (pathology == 'pigmentary' || pathology == 'pseudoexfoliation') ? 'Schwalbe\'s Line (Sampaolesi Pigment Line)' : 'Schwalbe\'s Line (SL)',
        (pathology == 'pigmentary' || pathology == 'pseudoexfoliation') ? Colors.amber : Colors.white,
      );
    }

    // C. Non-Pigmented & Pigmented Trabecular Meshwork (TM)
    if (effectiveGrade >= 2) {
      Color tmColor = const Color(0xFFD97706);
      if (pathology == 'pigmentary') tmColor = const Color(0xFF451A03);
      if (pathology == 'pseudoexfoliation') tmColor = const Color(0xFF92400E);

      final Paint tmPaint = Paint()..color = tmColor.withValues(alpha: 0.90);
      final Rect tmRect = Rect.fromCenter(center: Offset(center.dx, baseCenterY - mirrorRadius * 0.20), width: layerWidth * 0.9, height: 26);
      canvas.drawRect(tmRect, tmPaint);

      // Schlemm canal blood reflux if active
      if (pathology == 'schlemm_blood') {
        final Paint bloodPaint = Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 4.0;
        canvas.drawLine(
          Offset(center.dx - mirrorRadius * 0.75, baseCenterY - mirrorRadius * 0.20),
          Offset(center.dx + mirrorRadius * 0.75, baseCenterY - mirrorRadius * 0.20),
          bloodPaint,
        );
        _drawLayerLabel(canvas, Offset(center.dx, baseCenterY - mirrorRadius * 0.20), 'Blood in Schlemm\'s Canal', Colors.white);
      } else {
        _drawLayerLabel(canvas, Offset(center.dx, baseCenterY - mirrorRadius * 0.20), 'Trabecular Meshwork (TM)', Colors.amberAccent);
      }

      // Pseudoexfoliation dandruff flakes
      if (pathology == 'pseudoexfoliation') {
        final Paint flakePaint = Paint()..color = Colors.white;
        for (int i = -4; i <= 4; i++) {
          canvas.drawCircle(Offset(center.dx + i * 16 + (i % 2) * 4, baseCenterY - mirrorRadius * 0.20 + (i % 3) * 3), 2.0, flakePaint);
        }
      }
    }

    // D. Scleral Spur (SS)
    if (effectiveGrade >= 3) {
      final Paint ssPaint = Paint()
        ..color = const Color(0xFFF8FAFC)
        ..strokeWidth = 3.5;
      canvas.drawLine(
        Offset(center.dx - mirrorRadius * 0.8, baseCenterY + mirrorRadius * 0.05),
        Offset(center.dx + mirrorRadius * 0.8, baseCenterY + mirrorRadius * 0.05),
        ssPaint,
      );
      _drawLayerLabel(canvas, Offset(center.dx, baseCenterY + mirrorRadius * 0.05 - 8), 'Scleral Spur (SS - White Line)', const Color(0xFFE2E8F0));
    }

    // E. Ciliary Body Band (CBB)
    if (effectiveGrade >= 4 || pathology == 'angle_recession') {
      final double cbbHeight = pathology == 'angle_recession' ? 38.0 : 22.0;
      final Paint cbbPaint = Paint()..color = const Color(0xFF581C87).withValues(alpha: 0.95);
      final Rect cbbRect = Rect.fromCenter(center: Offset(center.dx, baseCenterY + mirrorRadius * 0.26), width: layerWidth * 0.85, height: cbbHeight);
      canvas.drawRect(cbbRect, cbbPaint);
      _drawLayerLabel(
        canvas,
        Offset(center.dx, baseCenterY + mirrorRadius * 0.26),
        pathology == 'angle_recession' ? 'Traumatic Angle Recession (Widened CBB)' : 'Ciliary Body Band (CBB)',
        pathology == 'angle_recession' ? Colors.redAccent : Colors.purpleAccent,
      );
    }

    // F. Peripheral Iris Root & Plateau Iris Humps
    double irisTopOffset = mirrorRadius * 0.42;
    if (effectiveGrade == 0) irisTopOffset = -mirrorRadius * 0.45; // Iris touches Schwalbe line
    if (effectiveGrade == 1) irisTopOffset = -mirrorRadius * 0.20;

    final Paint irisPaint = Paint()..color = const Color(0xFF1E3A8A);
    final Path irisPath = Path();

    if (pathology == 'plateau_iris' && isIndented) {
      // Double hump sign on dynamic indentation
      irisPath.moveTo(center.dx - mirrorRadius, baseCenterY + irisTopOffset);
      irisPath.quadraticBezierTo(center.dx - mirrorRadius * 0.5, baseCenterY + irisTopOffset - 25, center.dx - mirrorRadius * 0.25, baseCenterY + irisTopOffset);
      irisPath.quadraticBezierTo(center.dx, baseCenterY + irisTopOffset + 15, center.dx + mirrorRadius * 0.25, baseCenterY + irisTopOffset);
      irisPath.quadraticBezierTo(center.dx + mirrorRadius * 0.5, baseCenterY + irisTopOffset - 25, center.dx + mirrorRadius, baseCenterY + irisTopOffset);
      irisPath.lineTo(center.dx + mirrorRadius, center.dy + mirrorRadius);
      irisPath.lineTo(center.dx - mirrorRadius, center.dy + mirrorRadius);
      irisPath.close();
      canvas.drawPath(irisPath, irisPaint);
      _drawLayerLabel(canvas, Offset(center.dx, center.dy + mirrorRadius * 0.60), 'Plateau Iris Double-Hump Sign', Colors.yellowAccent);
    } else {
      irisPath.moveTo(center.dx - mirrorRadius, baseCenterY + irisTopOffset);
      irisPath.quadraticBezierTo(center.dx, baseCenterY + irisTopOffset - 16, center.dx + mirrorRadius, baseCenterY + irisTopOffset);
      irisPath.lineTo(center.dx + mirrorRadius, center.dy + mirrorRadius);
      irisPath.lineTo(center.dx - mirrorRadius, center.dy + mirrorRadius);
      irisPath.close();
      canvas.drawPath(irisPath, irisPaint);
      _drawLayerLabel(canvas, Offset(center.dx, center.dy + mirrorRadius * 0.65), 'Peripheral Iris Root', Colors.lightBlueAccent);
    }

    // G. Neovascularization / ICE Synechiae Overlays
    if (pathology == 'neovascularization') {
      final Paint neoPaint = Paint()
        ..color = Colors.redAccent
        ..strokeWidth = 1.8;
      for (int i = -3; i <= 3; i++) {
        final double startX = center.dx + i * 24;
        canvas.drawLine(
          Offset(startX, baseCenterY + mirrorRadius * 0.38),
          Offset(startX + (i.isEven ? 8 : -8), baseCenterY - mirrorRadius * 0.22),
          neoPaint,
        );
      }
      _drawLayerLabel(canvas, Offset(center.dx, baseCenterY + mirrorRadius * 0.08), 'Arborizing Rubeosis Vessels', Colors.redAccent);
    }

    if (pathology == 'ice_syndrome') {
      final Paint pasPaint = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      for (int i = -2; i <= 2; i++) {
        final Path pas = Path()
          ..moveTo(center.dx + i * 40 - 15, baseCenterY + mirrorRadius * 0.35)
          ..lineTo(center.dx + i * 40, baseCenterY - mirrorRadius * 0.48) // Extends onto Cornea!
          ..lineTo(center.dx + i * 40 + 15, baseCenterY + mirrorRadius * 0.35)
          ..close();
        canvas.drawPath(pas, pasPaint);
      }
      _drawLayerLabel(canvas, Offset(center.dx, baseCenterY - mirrorRadius * 0.35), 'High Broad-Based PAS across SL', Colors.white);
    }
  }

  void _paintCrossSection(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Cross-sectional diagram of anterior chamber angle
    final Paint corneaPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    // Cornea arc
    final Path corneaPath = Path()
      ..moveTo(40, center.dy + 70)
      ..quadraticBezierTo(w * 0.45, center.dy - 90, w - 40, center.dy + 70);
    canvas.drawPath(corneaPath, corneaPaint);

    // Iris profile based on Shaffer grade & indentation
    double irisArch = 0;
    if (shafferGrade == 0 && !isIndented) irisArch = -50;
    if (shafferGrade == 1) irisArch = -35;
    if (shafferGrade == 2) irisArch = -20;
    if (shafferGrade >= 3) irisArch = 10;
    if (isIndented) irisArch = 25; // Indentation forces deep AC

    final Paint irisPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;

    final Path irisPath = Path()
      ..moveTo(50, center.dy + 70)
      ..quadraticBezierTo(center.dx, center.dy + 70 + irisArch, w - 50, center.dy + 70)
      ..lineTo(w - 50, center.dy + 85)
      ..quadraticBezierTo(center.dx, center.dy + 85 + irisArch, 50, center.dy + 85)
      ..close();
    canvas.drawPath(irisPath, irisPaint);

    // Pupil aperture & Crystalline Lens
    final Paint lensPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final Rect lensRect = Rect.fromCenter(center: Offset(center.dx, center.dy + 95 + irisArch * 0.5), width: 140, height: 40);
    canvas.drawOval(lensRect, lensPaint);

    _drawLayerLabel(canvas, Offset(center.dx, center.dy - 60), 'Anterior Chamber Depth (Van Herick View)', Colors.cyanAccent);
    _drawLayerLabel(canvas, Offset(center.dx, center.dy + 120), 'Crystalline Lens & Pupillary Plane', Colors.amberAccent);
  }

  void _drawLayerLabel(Canvas canvas, Offset pos, String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _GonioscopyPainter oldDelegate) => true;
}
