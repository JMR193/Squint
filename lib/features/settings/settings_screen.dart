import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/language_provider.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/custom_ui_components.dart';
import 'about_screen.dart';
import 'apache_license_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isStudentMode = true;
  bool _hapticFeedback = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(langProvider.translate('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 0. Global Language Selector Card
          SamsungOneUiGroupCard(
            title: 'GLOBAL LOCALIZATION & LANGUAGES',
            icon: Icons.language,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active: ${langProvider.languageName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: AppLanguage.values.map((lang) {
                    final isSel = langProvider.currentLanguage == lang;
                    return ChoiceChip(
                      label: Text(_getLangChipLabel(lang), style: TextStyle(fontSize: 11, color: isSel ? Colors.black : Colors.white)),
                      selected: isSel,
                      selectedColor: Colors.cyanAccent,
                      onSelected: (_) => langProvider.setLanguage(lang),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // 1. Appearance & Theme Customization
          SamsungOneUiGroupCard(
            title: 'APPEARANCE & DISPLAY MODES',
            icon: Icons.palette,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme Mode:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildThemeModeChip(context, themeProvider, AppThemeMode.light, 'Clean Light', Icons.light_mode),
                    _buildThemeModeChip(context, themeProvider, AppThemeMode.dark, 'Cyber Dark', Icons.dark_mode),
                    _buildThemeModeChip(context, themeProvider, AppThemeMode.amoled, 'AMOLED Black', Icons.brightness_2),
                    _buildThemeModeChip(context, themeProvider, AppThemeMode.system, 'System Auto', Icons.auto_mode),
                  ],
                ),
                const Divider(height: 20),
                const Text('Accent Palette:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAccentColorButton(themeProvider, AccentColor.cyan, const Color(0xFF06B6D4), 'Cyan'),
                    _buildAccentColorButton(themeProvider, AccentColor.blue, const Color(0xFF3B82F6), 'Blue'),
                    _buildAccentColorButton(themeProvider, AccentColor.emerald, const Color(0xFF10B981), 'Emerald'),
                    _buildAccentColorButton(themeProvider, AccentColor.purple, const Color(0xFF8B5CF6), 'Purple'),
                    _buildAccentColorButton(themeProvider, AccentColor.orange, const Color(0xFFF97316), 'Orange'),
                  ],
                ),
                const Divider(height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('High-Contrast Accessibility (a11y)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Enhance borders and text contrast for maximum visibility.', style: TextStyle(fontSize: 11)),
                  value: themeProvider.isHighContrast,
                  onChanged: (val) => themeProvider.toggleHighContrast(val),
                  secondary: const Icon(Icons.accessibility_new, color: Colors.cyanAccent),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Text Scale Factor:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${(themeProvider.fontScale * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                  ],
                ),
                Slider(
                  value: themeProvider.fontScale,
                  min: 0.85,
                  max: 1.25,
                  divisions: 4,
                  label: '${(themeProvider.fontScale * 100).toInt()}%',
                  onChanged: (val) => themeProvider.setFontScale(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Ocular Simulation Customizations
          SamsungOneUiGroupCard(
            title: 'OCULAR MOTILITY ENGINE',
            icon: Icons.remove_red_eye,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer, color: Colors.cyanAccent),
                  title: const Text('Automatic Eye Blinking Loop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Natural periodic eyelid blink cycle (3.5s interval)', style: TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.cyan),
                    ),
                    child: const Text('ACTIVE', style: TextStyle(fontSize: 10, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Haptic Confirmation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Tactile response when changing gazes and prism angles.', style: TextStyle(fontSize: 11)),
                  value: _hapticFeedback,
                  onChanged: (val) => setState(() => _hapticFeedback = val),
                  secondary: const Icon(Icons.vibration, color: Colors.amberAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Clinical Education & AI Engine
          SamsungOneUiGroupCard(
            title: 'CLINICAL EDUCATION & DECISION SUPPORT',
            icon: Icons.school,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Student Learning Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Displays high-yield differential diagnostic pearls and exam hints.', style: TextStyle(fontSize: 11)),
                  value: _isStudentMode,
                  onChanged: (val) => setState(() => _isStudentMode = val),
                  secondary: const Icon(Icons.menu_book, color: Colors.amberAccent),
                ),
                const Divider(),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.security, color: Colors.tealAccent),
                  title: Text('100% Offline Diagnostic Autonomy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Full database, calculators, and simulators operate without internet connectivity.', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Patient Database Management
          SamsungOneUiGroupCard(
            title: 'PATIENT DATABASE & DATA SECURITY',
            icon: Icons.storage,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text('Purge Local Patient Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                  subtitle: const Text('Irreversibly delete all locally stored exam records.', style: TextStyle(fontSize: 11)),
                  onTap: _showClearDatabaseDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. App Store / Play Store Legal & About
          SamsungOneUiGroupCard(
            title: 'METADATA & LICENSING',
            icon: Icons.info,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Apache License 2.0 Legal Terms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Open-source permissions and terms of use.', style: TextStyle(fontSize: 11)),
                  leading: const Icon(Icons.gavel, color: Colors.cyanAccent),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApacheLicenseScreen())),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('About Squint Clinical Suite', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('v3.0.0 Pro Clinical Edition • Documentation & Credits', style: TextStyle(fontSize: 11)),
                  leading: const Icon(Icons.stars, color: Colors.amberAccent),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeChip(BuildContext context, ThemeProvider provider, AppThemeMode mode, String label, IconData icon) {
    final isSelected = provider.appThemeMode == mode;
    return ChoiceChip(
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.black : Colors.cyanAccent),
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white)),
      selected: isSelected,
      selectedColor: Colors.cyanAccent,
      onSelected: (_) => provider.setThemeMode(mode),
    );
  }

  Widget _buildAccentColorButton(ThemeProvider provider, AccentColor color, Color hexColor, String name) {
    final isSelected = provider.accentColor == color;
    return GestureDetector(
      onTap: () => provider.setAccentColor(color),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hexColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: hexColor.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 2)]
                  : null,
            ),
            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 9, color: isSelected ? Colors.white : Colors.grey)),
        ],
      ),
    );
  }

  void _showClearDatabaseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Purge Database?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all locally saved patient examination records? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              await ClinicalDatabaseService.clearAll();
              nav.pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('All patient examination records deleted.')),
              );
            },
            child: const Text('Confirm Purge'),
          ),
        ],
      ),
    );
  }

  String _getLangChipLabel(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return 'EN 🇺🇸';
      case AppLanguage.es:
        return 'ES 🇪🇸';
      case AppLanguage.fr:
        return 'FR 🇫🇷';
      case AppLanguage.de:
        return 'DE 🇩🇪';
      case AppLanguage.zh:
        return '中文 🇨🇳';
      case AppLanguage.hi:
        return 'हिन्दी 🇮🇳';
      case AppLanguage.ar:
        return 'العربية 🇸🇦';
      case AppLanguage.ja:
        return '日本語 🇯🇵';
    }
  }
}
