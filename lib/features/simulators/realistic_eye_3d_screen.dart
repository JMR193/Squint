import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';

enum EyeViewPerspective { anteriorAnatomy, muscleBiomechanical, posteriorFundus }

class RealisticEye3dScreen extends StatefulWidget {
  const RealisticEye3dScreen({super.key});

  @override
  State<RealisticEye3dScreen> createState() => _RealisticEye3dScreenState();
}

class _RealisticEye3dScreenState extends State<RealisticEye3dScreen> with SingleTickerProviderStateMixin {
  EyeViewPerspective _perspective = EyeViewPerspective.anteriorAnatomy;
  double _pitch = 0.0; // Up/Down rotation (-35° to +35°)
  double _yaw = 0.0;   // Left/Right rotation (-45° to +45°)
  double _pupilDiameterMm = 3.5; // 2.0mm to 8.0mm
  double _torchLightIntensity = 0.0; // 0.0 to 1.0 (triggers pupillary reflex)
  bool _showMuscles = true;
  bool _showVascularGrid = true;
  String _activeGazeLabel = 'Primary Gaze (Straight Ahead)';

  late AnimationController _idleGlintController;

  @override
  void initState() {
    super.initState();
    _idleGlintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleGlintController.dispose();
    super.dispose();
  }

  void _setGaze(String label, double p, double y) {
    setState(() {
      _activeGazeLabel = label;
      _pitch = p;
      _yaw = y;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic pupil constriction based on torchlight
    final effectivePupilMm = (_pupilDiameterMm - (_torchLightIntensity * 2.0)).clamp(1.8, 8.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Hyper-Realistic Orbital Anatomy'),
        actions: [
          PopupMenuButton<EyeViewPerspective>(
            icon: const Icon(Icons.layers, color: Colors.cyanAccent),
            tooltip: 'Anatomical View Layer',
            onSelected: (p) => setState(() => _perspective = p),
            itemBuilder: (context) => const [
              PopupMenuItem(value: EyeViewPerspective.anteriorAnatomy, child: Text('👁️ Anterior Segment & Iris Crypts')),
              PopupMenuItem(value: EyeViewPerspective.muscleBiomechanical, child: Text('💪 6-EOM Muscle Tension Vectors')),
              PopupMenuItem(value: EyeViewPerspective.posteriorFundus, child: Text('🔬 Posterior Pole & Retinal Fundus')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Interactive 3D Eyeball Canvas with Touch Drag (Distortion-Free 1:1 Viewport)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _yaw = (_yaw + details.delta.dx * 0.4).clamp(-45.0, 45.0);
                      _pitch = (_pitch - details.delta.dy * 0.4).clamp(-35.0, 35.0);
                      _activeGazeLabel = 'Custom Interactive Angle (${_yaw.toStringAsFixed(0)}°, ${_pitch.toStringAsFixed(0)}°)';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF1E293B), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedBuilder(
                      animation: _idleGlintController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _RealisticEye3dPainter(
                            perspective: _perspective,
                            pitch: _pitch,
                            yaw: _yaw,
                            pupilMm: effectivePupilMm,
                            torchIntensity: _torchLightIntensity,
                            showMuscles: _showMuscles,
                            showVessels: _showVascularGrid,
                            glintPhase: _idleGlintController.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Active Gaze Subtitle
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey.shade700),
              ),
              child: Text(
                _activeGazeLabel,
                style: const TextStyle(fontSize: 11, color: Colors.cyanAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. 9-Gaze Cardinal Preset Buttons
          SamsungOneUiGroupCard(
            title: '9-GAZE CARDINAL ORIENTATIONS',
            icon: Icons.grid_3x3,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGazeButton('Up-Left', 25, -30),
                    _buildGazeButton('Elevation', 30, 0),
                    _buildGazeButton('Up-Right', 25, 30),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGazeButton('Dextroversion', 0, -35),
                    _buildGazeButton('Primary (0,0)', 0, 0),
                    _buildGazeButton('Levoversion', 0, 35),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGazeButton('Down-Left', -25, -30),
                    _buildGazeButton('Depression', -30, 0),
                    _buildGazeButton('Down-Right', -25, 30),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Dynamic Iris Sphincter & Torchlight Reflex Controls
          SamsungOneUiGroupCard(
            title: 'PUPILLARY LIGHT REFLEX & IRIS DYNAMICS',
            icon: Icons.wb_incandescent,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pupil Diameter: ${effectivePupilMm.toStringAsFixed(1)} mm', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amberAccent)),
                    Text(effectivePupilMm > 5.5 ? 'Mydriasis' : (effectivePupilMm < 3.0 ? 'Miosis' : 'Physiological Normal'), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Slider(
                  value: _pupilDiameterMm,
                  min: 2.0,
                  max: 8.0,
                  divisions: 12,
                  label: '${_pupilDiameterMm.toStringAsFixed(1)} mm',
                  onChanged: (val) => setState(() => _pupilDiameterMm = val),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Direct Penlight Torch Reflex', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Shine focal beam into pupil to induce sphincter constriction.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      icon: Icon(_torchLightIntensity > 0 ? Icons.flashlight_on : Icons.flashlight_off),
                      style: IconButton.styleFrom(
                        backgroundColor: _torchLightIntensity > 0 ? Colors.amber : Colors.blueGrey.shade800,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _torchLightIntensity = (_torchLightIntensity > 0) ? 0.0 : 1.0;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Biomechanical Muscle Tension Indicators
          if (_perspective == EyeViewPerspective.muscleBiomechanical)
            SamsungOneUiGroupCard(
              title: '6-EOM RECTUS & OBLIQUE TENSION VECTORS',
              icon: Icons.fitness_center,
              child: Column(
                children: [
                  _buildMuscleRow('Lateral Rectus (LR - CN VI)', (_yaw > 0 ? (_yaw / 45.0) : 0.1).clamp(0.0, 1.0), Colors.cyanAccent),
                  _buildMuscleRow('Medial Rectus (MR - CN III)', (_yaw < 0 ? (-_yaw / 45.0) : 0.1).clamp(0.0, 1.0), Colors.blueAccent),
                  _buildMuscleRow('Superior Rectus (SR - CN III)', (_pitch > 0 ? (_pitch / 35.0) : 0.1).clamp(0.0, 1.0), Colors.greenAccent),
                  _buildMuscleRow('Inferior Rectus (IR - CN III)', (_pitch < 0 ? (-_pitch / 35.0) : 0.1).clamp(0.0, 1.0), Colors.orangeAccent),
                  _buildMuscleRow('Superior Oblique (SO - CN IV)', (_pitch < 0 && _yaw < 0 ? 0.85 : 0.2), Colors.purpleAccent),
                  _buildMuscleRow('Inferior Oblique (IO - CN III)', (_pitch > 0 && _yaw < 0 ? 0.85 : 0.2), Colors.pinkAccent),
                ],
              ),
            ),
          const SizedBox(height: 14),

          // 5. Visual Layer Overlays
          SamsungOneUiGroupCard(
            title: 'ANATOMICAL LAYERS & OVERLAYS',
            icon: Icons.layers,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show Extraocular Muscle Bands', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Render 4 rectus & 2 oblique tendon insertions', style: TextStyle(fontSize: 10)),
                  value: _showMuscles,
                  activeThumbColor: Colors.cyanAccent,
                  onChanged: (val) => setState(() => _showMuscles = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show Episcleral Vascular Mesh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Anterior ciliary arterial loops and capillary plexus', style: TextStyle(fontSize: 10)),
                  value: _showVascularGrid,
                  activeThumbColor: Colors.cyanAccent,
                  onChanged: (val) => setState(() => _showVascularGrid = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGazeButton(String label, double p, double y) {
    final isSelected = (_pitch == p && _yaw == y);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.cyanAccent : Colors.blueGrey.shade900,
        foregroundColor: isSelected ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _setGaze(label, p, y),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMuscleRow(String name, double tension, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              Text('${(tension * 100).toInt()}% Tension', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 3),
          LinearProgressIndicator(
            value: tension,
            backgroundColor: Colors.blueGrey.shade900,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

class _RealisticEye3dPainter extends CustomPainter {
  final EyeViewPerspective perspective;
  final double pitch;
  final double yaw;
  final double pupilMm;
  final double torchIntensity;
  final bool showMuscles;
  final bool showVessels;
  final double glintPhase;

  _RealisticEye3dPainter({
    required this.perspective,
    required this.pitch,
    required this.yaw,
    required this.pupilMm,
    required this.torchIntensity,
    required this.showMuscles,
    required this.showVessels,
    required this.glintPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final globeRadius = min(size.width, size.height) * 0.42;

    if (perspective == EyeViewPerspective.posteriorFundus) {
      _drawFundusView(canvas, center, globeRadius);
      return;
    }

    // 1. Draw 3D Globe Shadow & Sclera Base
    final Rect globeRect = Rect.fromCircle(center: center, radius: globeRadius);

    final Paint scleraGrad = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
        stops: const [0.65, 0.90, 1.0],
        center: Alignment(yaw / 90.0, -pitch / 70.0),
      ).createShader(globeRect);

    canvas.drawCircle(center, globeRadius, scleraGrad);

    // 2. Episcleral Microvascular Arborization Network
    if (showVessels) {
      _drawEpiscleralVessels(canvas, center, globeRadius);
    }

    // 3. Extraocular Muscle Insertions if enabled
    if (perspective == EyeViewPerspective.muscleBiomechanical && showMuscles) {
      _drawMuscleBands(canvas, center, globeRadius);
    }

    // 4. Cornea & Iris Projection based on 3D Pitch & Yaw
    final double corneaOffsetX = (yaw / 45.0) * (globeRadius * 0.45);
    final double corneaOffsetY = (-pitch / 35.0) * (globeRadius * 0.45);
    final Offset corneaCenter = Offset(center.dx + corneaOffsetX, center.dy + corneaOffsetY);
    final double corneaRadius = globeRadius * 0.52;

    // Limbus Gradient Ring
    final Paint limbusPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(corneaCenter, corneaRadius, limbusPaint);

    // 5. Realistic Iris Stroma (Radial Crypts of Fuchs & Collarette)
    _drawRealisticIris(canvas, corneaCenter, corneaRadius, pupilMm);

    // 6. Dynamic Pupil Aperture
    final double pupilRadius = (pupilMm / 8.0) * (corneaRadius * 0.65);
    final Paint pupilPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawCircle(corneaCenter, pupilRadius, pupilPaint);

    // 7. Specular Cornea Light Glint & Raytraced Reflection
    final glintOffset = Offset(
      corneaCenter.dx - corneaRadius * 0.35 + sin(glintPhase * 2 * pi) * 2,
      corneaCenter.dy - corneaRadius * 0.35,
    );
    final Paint glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(glintOffset, 5.5, glintPaint);
    canvas.drawCircle(glintOffset + const Offset(4, 5), 2.2, glintPaint);

    // Torchlight focal glow if active
    if (torchIntensity > 0) {
      final Paint torchGlow = Paint()
        ..color = Colors.amber.withValues(alpha: 0.35 * torchIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(corneaCenter, corneaRadius * 1.3, torchGlow);
    }
  }

  void _drawRealisticIris(Canvas canvas, Offset center, double radius, double pupilMm) {
    final Rect irisRect = Rect.fromCircle(center: center, radius: radius);

    // Cyan / Hazel Radiating Iris Fibers
    final Paint irisBase = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF0C4A6E), Color(0xFF082F49)],
        stops: const [0.2, 0.5, 0.8, 1.0],
      ).createShader(irisRect);
    canvas.drawCircle(center, radius, irisBase);

    // Radial Crypt Spoke Lines
    final Paint cryptPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 48; i++) {
      final theta = (i * (2 * pi / 48));
      final innerR = (pupilMm / 8.0) * (radius * 0.65);
      final p1 = Offset(center.dx + innerR * cos(theta), center.dy + innerR * sin(theta));
      final p2 = Offset(center.dx + radius * 0.95 * cos(theta), center.dy + radius * 0.95 * sin(theta));
      canvas.drawLine(p1, p2, cryptPaint);
    }

    // Iris Collarette Ring
    final Paint collarettePaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.55, collarettePaint);
  }

  void _drawEpiscleralVessels(Canvas canvas, Offset center, double radius) {
    final Paint vesselPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rand = Random(101);
    for (int i = 0; i < 8; i++) {
      final angle = i * (pi / 4);
      final Path path = Path()..moveTo(center.dx + (radius * 0.55) * cos(angle), center.dy + (radius * 0.55) * sin(angle));
      path.quadraticBezierTo(
        center.dx + (radius * 0.8) * cos(angle + 0.1),
        center.dy + (radius * 0.8) * sin(angle + 0.1),
        center.dx + radius * 0.96 * cos(angle + (rand.nextDouble() - 0.5) * 0.2),
        center.dy + radius * 0.96 * sin(angle + (rand.nextDouble() - 0.5) * 0.2),
      );
      canvas.drawPath(path, vesselPaint);
    }
  }

  void _drawMuscleBands(Canvas canvas, Offset center, double radius) {
    final Paint musclePaint = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.8)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    // Medial & Lateral Rectus insertion stumps
    canvas.drawLine(Offset(center.dx - radius * 0.95, center.dy), Offset(center.dx - radius * 0.70, center.dy), musclePaint);
    canvas.drawLine(Offset(center.dx + radius * 0.95, center.dy), Offset(center.dx + radius * 0.70, center.dy), musclePaint);

    // Superior & Inferior Rectus insertion stumps
    canvas.drawLine(Offset(center.dx, center.dy - radius * 0.95), Offset(center.dx, center.dy - radius * 0.70), musclePaint);
    canvas.drawLine(Offset(center.dx, center.dy + radius * 0.95), Offset(center.dx, center.dy + radius * 0.70), musclePaint);
  }

  void _drawFundusView(Canvas canvas, Offset center, double radius) {
    // Retinal Orange-Red Fundus
    final Rect fundusRect = Rect.fromCircle(center: center, radius: radius);
    final Paint fundusBase = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFEA580C), Color(0xFFC2410C), Color(0xFF7C2D12)],
        stops: const [0.4, 0.8, 1.0],
      ).createShader(fundusRect);
    canvas.drawCircle(center, radius, fundusBase);

    // Optic Nerve Head (OD)
    final opticDiscCenter = Offset(center.dx - radius * 0.35, center.dy);
    final Paint discPaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawOval(Rect.fromCenter(center: opticDiscCenter, width: 36, height: 42), discPaint);

    // Physiological Cup (CDR 0.3)
    final Paint cupPaint = Paint()..color = const Color(0xFFFFFBEB);
    canvas.drawOval(Rect.fromCenter(center: opticDiscCenter, width: 14, height: 16), cupPaint);

    // Macula Lutea & Fovea Centralis
    final maculaCenter = Offset(center.dx + radius * 0.25, center.dy);
    final Paint maculaPaint = Paint()..color = const Color(0xFF7C2D12).withValues(alpha: 0.6);
    canvas.drawCircle(maculaCenter, 18, maculaPaint);
    canvas.drawCircle(maculaCenter, 3.5, Paint()..color = const Color(0xFF451A03)); // Foveal pit

    // Retinal Vascular Arcades
    final Paint arteryPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final Paint veinPaint = Paint()
      ..color = const Color(0xFF991B1B)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    // Superior Arcade
    final Path supArc = Path()
      ..moveTo(opticDiscCenter.dx, opticDiscCenter.dy)
      ..quadraticBezierTo(opticDiscCenter.dx + 40, opticDiscCenter.dy - 60, center.dx + radius * 0.5, center.dy - radius * 0.6);
    canvas.drawPath(supArc, veinPaint);
    canvas.drawPath(supArc, arteryPaint);

    // Inferior Arcade
    final Path infArc = Path()
      ..moveTo(opticDiscCenter.dx, opticDiscCenter.dy)
      ..quadraticBezierTo(opticDiscCenter.dx + 40, opticDiscCenter.dy + 60, center.dx + radius * 0.5, center.dy + radius * 0.6);
    canvas.drawPath(infArc, veinPaint);
    canvas.drawPath(infArc, arteryPaint);
  }

  @override
  bool shouldRepaint(covariant _RealisticEye3dPainter oldDelegate) => true;
}
