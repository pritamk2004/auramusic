import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import 'aura_logo.dart';
import 'create_playlist_dialog.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return Container(
      width: 240,
      color: const Color(0xFF000000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 18.0),
            child: Row(
              children: [
                const Expanded(
                  child: AuraLogo(size: 28, showText: true),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.4)),
                  ),
                  child: const Text(
                    'FREE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1DB954)),
                  ),
                ),
              ],
            ),
          ),

          // Primary Navigation Menu
          _buildNavItem(0, Icons.home_filled, 'Home'),
          _buildNavItem(1, Icons.search, 'Search'),
          _buildNavItem(2, Icons.library_music_outlined, 'Library'),
          _buildNavItem(3, Icons.settings_outlined, 'Settings'),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12, indent: 16, endIndent: 16),
          const SizedBox(height: 8),

          // Shortcuts & Playlists Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PLAYLISTS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.grey, size: 18),
                  tooltip: 'Create Playlist',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CreatePlaylistDialog(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Liked Songs Shortcut
          ListTile(
            dense: true,
            leading: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF450af5), Color(0xFF8e8ee5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 16),
            ),
            title: const Text('Liked Songs', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: () {
              onItemSelected(2); // Jump to Library
            },
          ),

          // Custom Playlists Scroll List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: library.customPlaylists.length,
              itemBuilder: (context, i) {
                final p = library.customPlaylists[i];
                return ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  title: Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  onTap: () {
                    onItemSelected(2); // Go to library
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF1DB954) : Colors.grey[400],
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}
