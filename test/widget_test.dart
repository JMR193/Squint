import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squint/main.dart';
import 'package:squint/features/simulators/brock_string_simulator_screen.dart';
import 'package:squint/features/simulators/synoptophore_simulator_screen.dart';
import 'package:squint/features/simulators/surgical_biomechanics_screen.dart';
import 'package:squint/features/simulators/lancaster_screen_simulator.dart';
import 'package:squint/features/simulators/neuro_ophtho_simulator_screen.dart';
import 'package:squint/features/simulators/visual_pathways_simulator_screen.dart';
import 'package:squint/features/therapy/contrast_dichoptic_game_screen.dart';
import 'package:squint/features/therapy/hart_chart_screen.dart';
import 'package:squint/features/calculators/kestenbaum_calculator_screen.dart';
import 'package:squint/features/calculators/torsion_head_tilt_calculator_screen.dart';
import 'package:squint/features/calculators/prism_adaptation_screen.dart';

void main() {
  testWidgets('SquintApp smoke test and navigation verify', (WidgetTester tester) async {
    await tester.pumpWidget(const SquintApp());
    await tester.pumpAndSettle();

    expect(find.text('Therapy'), findsWidgets);
    expect(find.text('Tools'), findsWidgets);
    expect(find.text('Learn'), findsWidgets);
    expect(find.text('Research'), findsWidgets);
  });

  testWidgets('Neuro-Ophtho Simulator screen renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NeuroOphthoSimulatorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Neuro-Ophthalmic Examination Lab'), findsOneWidget);
    expect(find.text('OD (Right Eye)'), findsOneWidget);
    expect(find.text('OS (Left Eye)'), findsOneWidget);
  });

  testWidgets('Visual Pathways Simulator screen renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: VisualPathwaysSimulatorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Visual Pathways & Perimetry Lab'), findsOneWidget);
    expect(find.text('Left Eye Field (OS)'), findsOneWidget);
    expect(find.text('Right Eye Field (OD)'), findsOneWidget);
  });

  testWidgets('Brock String simulator renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BrockStringSimulatorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Brock String Vergence Trainer'), findsOneWidget);
    expect(find.text('Near (Green)'), findsOneWidget);
  });

  testWidgets('Synoptophore simulator renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SynoptophoreSimulatorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Virtual Synoptophore (Amblyoscope)'), findsOneWidget);
    expect(find.text('Lion & Cage (Grade 1 SMP)'), findsOneWidget);
  });

  testWidgets('Surgical Biomechanics screen renders and calculates', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SurgicalBiomechanicsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Biomechanical Surgical Simulator'), findsOneWidget);
  });

  testWidgets('Lancaster Screen Simulator renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LancasterScreenSimulator()));
    await tester.pumpAndSettle();

    expect(find.text('Computerized Lancaster Screen'), findsOneWidget);
  });

  testWidgets('Contrast-balanced Dichoptic Game renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ContrastDichopticGameScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Dynamic Contrast Dichoptic DTx'), findsOneWidget);
    expect(find.text('START THERAPY'), findsOneWidget);
  });

  testWidgets('Hart Chart Screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HartChartScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Hart Chart Accommodative Facility'), findsOneWidget);
  });

  testWidgets('Kestenbaum calculator renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: KestenbaumCalculatorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Kestenbaum-Anderson Dosing'), findsOneWidget);
  });

  testWidgets('Torsion & Head Tilt calculator renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TorsionHeadTiltCalculatorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Torsion & Bielschowsky Tilt'), findsOneWidget);
  });

  testWidgets('Prism Adaptation Screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrismAdaptationScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Prism Adaptation Test (PAT)'), findsOneWidget);
  });
}
