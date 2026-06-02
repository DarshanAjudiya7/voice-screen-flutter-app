import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/splash/splash_screen.dart';
import 'core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection and local storage
  await setupServiceLocator();

  runApp(const ProviderScope(child: VoiceLockApp()));
}

class VoiceLockApp extends StatelessWidget {
  const VoiceLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Lock',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Default to dark theme for premium feel
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
