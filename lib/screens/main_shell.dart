import 'package:flutter/material.dart';
import '../widgets/mini_player.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/desktop_player_bar.dart';
import 'player/lyrics_tab.dart';
import 'player/queue_tab.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  bool _showDesktopLyrics = false;
  bool _showDesktopQueue = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 768;

    if (isWide) {
      // RESPONSIVE DESKTOP & WEB LAYOUT
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Left Navigation Sidebar
                  DesktopSidebar(
                    selectedIndex: _currentIndex,
                    onItemSelected: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),

                  // Divider
                  Container(width: 1, color: Colors.white.withOpacity(0.08)),

                  // Center Content Pane
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: _screens,
                    ),
                  ),

                  // Optional Right Side Panel for Lyrics / Queue
                  if (_showDesktopLyrics || _showDesktopQueue) ...[
                    Container(width: 1, color: Colors.white.withOpacity(0.08)),
                    SizedBox(
                      width: 340,
                      child: Container(
                        color: const Color(0xFF0D0D0D),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _showDesktopLyrics ? 'Synchronized Lyrics' : 'Up-Next Queue',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _showDesktopLyrics = false;
                                        _showDesktopQueue = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            Expanded(
                              child: _showDesktopLyrics
                                  ? const LyricsTab()
                                  : const QueueTab(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Persistent Full-Width Bottom Player Bar
            DesktopPlayerBar(
              isLyricsActive: _showDesktopLyrics,
              isQueueActive: _showDesktopQueue,
              onToggleLyrics: () {
                setState(() {
                  _showDesktopLyrics = !_showDesktopLyrics;
                  if (_showDesktopLyrics) _showDesktopQueue = false;
                });
              },
              onToggleQueue: () {
                setState(() {
                  _showDesktopQueue = !_showDesktopQueue;
                  if (_showDesktopQueue) _showDesktopLyrics = false;
                });
              },
            ),
          ],
        ),
      );
    }

    // MOBILE / ANDROID LAYOUT
    return Scaffold(
      body: Stack(
        children: [
          // Active Screen
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Floating Mini Player pinned above Bottom Navigation Bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: MiniPlayer(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0A0A0A),
          selectedItemColor: const Color(0xFF1DB954),
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              activeIcon: Icon(Icons.home_filled, color: Color(0xFF1DB954)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search, color: Color(0xFF1DB954)),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined),
              activeIcon: Icon(Icons.library_music, color: Color(0xFF1DB954)),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings, color: Color(0xFF1DB954)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
