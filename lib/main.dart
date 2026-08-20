import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/audio_handler.dart';
import 'providers/player_provider.dart';
import 'providers/explore_provider.dart';
import 'providers/library_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Database & Storage
  try {
    await StorageService.instance.init();
  } catch (e) {
    debugPrint('StorageService init warning: $e');
  }

  // Initialize Audio Player Engine
  await AudioPlayerService.instance.init();

  if (!kIsWeb) {
    // Dark navigation bar and status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0A0A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ],
      child: const AuraMusicApp(),
    ),
  );
}

class AuraMusicApp extends StatelessWidget {
  const AuraMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'AuraMusic',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: settings.themeMode == 'Spotify Midnight'
          ? AppTheme.midnightTheme
          : AppTheme.amoledBlackTheme,
      home: const MainShellScreen(),
    );
  }
}
