import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auramusic/services/storage_service.dart';
import 'package:auramusic/services/audio_handler.dart';
import 'package:auramusic/providers/player_provider.dart';
import 'package:auramusic/providers/explore_provider.dart';
import 'package:auramusic/providers/library_provider.dart';
import 'package:auramusic/providers/settings_provider.dart';
import 'package:auramusic/screens/main_shell.dart';
import 'package:auramusic/screens/home_screen.dart';
import 'package:auramusic/screens/search_screen.dart';
import 'package:auramusic/screens/library_screen.dart';
import 'package:auramusic/screens/settings_screen.dart';
import 'package:auramusic/widgets/desktop_sidebar.dart';
import 'package:auramusic/widgets/desktop_player_bar.dart';

Widget createTestApp(Widget child, {Size size = const Size(1200, 800)}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ChangeNotifierProvider(create: (_) => ExploreProvider()),
      ChangeNotifierProvider(create: (_) => LibraryProvider()),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'streaming_quality': 'High (160/320 kbps)',
      'download_quality': 'High (320 kbps)',
      'app_theme_mode': 'AMOLED Black',
      'auto_radio_enabled': true,
    });
    await StorageService.instance.init();
    await AudioPlayerService.instance.init();
  });

  group('Automated UI & Responsive Layout Tests', () {
    testWidgets('MainShellScreen renders Desktop layout on wide screen (1200x800)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const MainShellScreen(), size: const Size(1200, 800)));
      await tester.pumpAndSettle();

      // Verify Desktop Sidebar is present
      expect(find.byType(DesktopSidebar), findsOneWidget);
      expect(find.text('AuraMusic'), findsWidgets);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Search'), findsWidgets);
      expect(find.text('Library'), findsWidgets);
      expect(find.text('Settings'), findsWidgets);

      // Verify Desktop Player Bar is present
      expect(find.byType(DesktopPlayerBar), findsOneWidget);
    });

    testWidgets('MainShellScreen renders Mobile layout on narrow screen (400x800)', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const MainShellScreen(), size: const Size(400, 800)));
      await tester.pumpAndSettle();

      // Verify Mobile Bottom Navigation Bar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(DesktopSidebar), findsNothing);
    });

    testWidgets('HomeScreen renders sections and Moods', (tester) async {
      await tester.pumpWidget(createTestApp(const HomeScreen()));
      await tester.pump();

      expect(find.text('Moods & Genres'), findsOneWidget);
      expect(find.text('Featured Artists'), findsOneWidget);
      expect(find.text('Trending Now'), findsOneWidget);
    });

    testWidgets('SearchScreen renders search field and browse categories', (tester) async {
      await tester.pumpWidget(createTestApp(const SearchScreen()));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search songs, artists, albums...'), findsOneWidget);
      expect(find.text('Explore Genres & Moods'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Hip-Hop / Rap'), findsOneWidget);
    });

    testWidgets('LibraryScreen renders Liked, Playlists, Downloads, and History tabs', (tester) async {
      await tester.pumpWidget(createTestApp(const LibraryScreen()));
      await tester.pump();

      expect(find.text('Your Library'), findsOneWidget);
      expect(find.textContaining('Liked'), findsOneWidget);
      expect(find.textContaining('Playlists'), findsOneWidget);
      expect(find.textContaining('Downloads'), findsOneWidget);
      expect(find.textContaining('History'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders Audio Quality, Theme, and Sleep Timer options', (tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Streaming Audio Quality'), findsOneWidget);
      expect(find.text('Download Quality'), findsOneWidget);
      expect(find.text('App Theme'), findsOneWidget);
      expect(find.text('Sleep Timer'), findsOneWidget);
      expect(find.text('100% Free & Ad-Free Guarantee'), findsOneWidget);
    });
  });
}
