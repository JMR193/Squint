import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../simulators/simulators_screen.dart';
import '../simulators/gonioscopy_simulator_screen.dart';
import '../calculators/calculators_screen.dart';
import '../therapy/therapy_hub_screen.dart';
import '../education/education_screen.dart';
import '../education/case_quizzes_screen.dart';
import '../research/research_screen.dart';
import '../records/patient_records_screen.dart';
import '../screening/hirschberg_test_screen.dart';
import '../tests/visual_acuity_chart_screen.dart';
import '../tests/hess_screen_simulator.dart';
import '../tests/color_vision_simulator_screen.dart';
import '../simulators/realistic_eye_3d_screen.dart';
import '../simulators/cover_test_3d_studio_screen.dart';
import '../pediatrics/pediatric_fixation_character_screen.dart';
import '../tests/smart_optometry_hub_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/about_screen.dart';
import '../settings/apache_license_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SimulatorsScreen(),
    CalculatorsScreen(),
    TherapyHubScreen(),
    EducationScreen(),
    ResearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.white, size: 32),
                      SizedBox(width: 10),
                      Text('Squint', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text('Strabismus & BSV Suite 2.5.0 Clinical', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.cyanAccent : Colors.orangeAccent,
              ),
              title: Text(themeProvider.isDarkMode ? 'Dark Mode (Active)' : 'Light Mode (Active)'),
              subtitle: const Text('Tap to switch theme mode'),
              onTap: () {
                themeProvider.toggleTheme(!themeProvider.isDarkMode);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.biotech, color: Colors.cyanAccent),
              title: const Text('Smart Optometry Clinical Suite', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Worth 4-Dot, Schober, OKN Drum, Amsler, Cobalt Blue & Aniseikonia'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartOptometryHubScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_ind, color: Colors.cyanAccent),
              title: const Text('Patient Clinical Records'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientRecordsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: Colors.tealAccent),
              title: const Text('Clinical Case Quiz Bank'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseQuizzesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lens, color: Colors.amberAccent),
              title: const Text('Gonioscopy & Angle Lab'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GonioscopySimulatorScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purpleAccent),
              title: const Text('Digital Hirschberg Camera'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HirschbergTestScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.font_download, color: Colors.blueAccent),
              title: const Text('Visual Acuity & LogMAR Chart'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualAcuityChartScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_on, color: Colors.greenAccent),
              title: const Text('Hess / Lees Motility Screen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HessScreenSimulator()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_vintage, color: Colors.redAccent),
              title: const Text('Color Vision & Ishihara Lab'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorVisionSimulatorScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.blur_circular, color: Colors.cyanAccent),
              title: const Text('3D Orbital Eye Anatomy Lab'),
              subtitle: const Text('Raytraced cornea, iris crypts & 6-EOM tension'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RealisticEye3dScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.deepPurpleAccent),
              title: const Text('3D Cover Test & Prism Studio'),
              subtitle: const Text('Occluder paddle & refixation saccades'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CoverTest3dStudioScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets, color: Colors.pinkAccent),
              title: const Text('Pediatric Mascot Fixation Lab'),
              subtitle: const Text('Dr. Iris, Sparky, Barnaby & Teller gratings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PediatricFixationCharacterScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.cyanAccent),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.gavel, color: Colors.cyanAccent),
              title: const Text('Apache License 2.0'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ApacheLicenseScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.cyanAccent),
              title: const Text('About & Disclaimers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
          );
        },
        tooltip: 'Clinical AI Assistant',
        icon: const Icon(Icons.smart_toy),
        label: const Text('AI Assistant'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.remove_red_eye_outlined),
            selectedIcon: Icon(Icons.remove_red_eye),
            label: 'Simulators',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculators',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Therapy',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Education',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Research',
          ),
        ],
      ),
    );
  }
}
