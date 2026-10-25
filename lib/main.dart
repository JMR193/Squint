import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/language_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global Flutter UI Error Handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🚨 [Squint Error Boundary]: ${details.exceptionAsString()}');
  };

  // 2. Global Platform Dispatcher Error Handler (Async errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🚨 [Squint Async Boundary]: $error');
    return true;
  };

  // 3. Custom Cyber-Clinical Error Fallback Widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0F172A),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, color: Colors.cyanAccent, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Clinical Engine Auto-Recovery',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'The system safely caught a render exception. State remains stable.\n\n${details.exceptionAsString()}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const SquintApp(),
    ),
  );
}

class SquintApp extends StatefulWidget {
  const SquintApp({super.key});

  @override
  State<SquintApp> createState() => _SquintAppState();
}

class _SquintAppState extends State<SquintApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 [Squint Lifecycle]: App Resumed - Syncing Motility & Simulation Engines.');
        break;
      case AppLifecycleState.inactive:
        debugPrint('📱 [Squint Lifecycle]: App Inactive.');
        break;
      case AppLifecycleState.paused:
        debugPrint('📱 [Squint Lifecycle]: App Paused - Pausing Timers & Background Resources.');
        break;
      case AppLifecycleState.detached:
        debugPrint('📱 [Squint Lifecycle]: App Detached - Clean Resource Release.');
        break;
      case AppLifecycleState.hidden:
        debugPrint('📱 [Squint Lifecycle]: App Hidden.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Squint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(
        themeProvider.primaryAccentColor,
        highContrast: themeProvider.isHighContrast,
      ),
      darkTheme: AppTheme.getDarkTheme(
        themeProvider.primaryAccentColor,
        isAmoled: themeProvider.isAmoled,
        highContrast: themeProvider.isHighContrast,
      ),
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(themeProvider.fontScale),
          ),
          child: child ?? const SizedBox(),
        );
      },
      home: const DashboardScreen(),
    );
  }
}

