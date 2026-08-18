import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/create_playlist_dialog.dart';
import 'playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
            tooltip: 'Create Playlist',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CreatePlaylistDialog(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF1DB954),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Liked (${library.likedSongs.length})'),
            Tab(text: 'Playlists (${library.customPlaylists.length})'),
            Tab(text: 'Downloads (${library.downloadedSongs.length})'),
            Tab(text: 'History (${library.history.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Liked Songs
          _buildLikedSongsTab(library, player),

          // 2. Playlists
          _buildPlaylistsTab(library),

          // 3. Downloads (Offline)
          _buildDownloadsTab(library, player),

          // 4. History
          _buildHistoryTab(library, player),
        ],
      ),
    );
  }

  Widget _buildLikedSongsTab(LibraryProvider library, PlayerProvider player) {
    final songs = library.likedSongs;

    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 54, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'No liked songs yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any song to add it here',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: songs.length,
      itemBuilder: (context, i) {
        final song = songs[i];
        return SongTile(
          song: song,
          index: i + 1,
          onTap: () {
            player.playSong(song, queue: songs, initialIndex: i);
          },
        );
      },
    );
  }

  Widget _buildPlaylistsTab(LibraryProvider library) {
    final playlists = library.customPlaylists;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      children: [
        // Create Playlist Tile
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Color(0xFF1DB954), size: 28),
          ),
          title: const Text('New Playlist', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: const Text('Build your custom track collection', style: TextStyle(color: Colors.grey)),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const CreatePlaylistDialog(),
            );
          },
        ),
        const Divider(color: Colors.white12),

        ...playlists.map((pl) {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 50,
                height: 50,
                color: const Color(0xFF1DB954).withOpacity(0.2),
                child: const Icon(Icons.queue_music, color: Color(0xFF1DB954), size: 26),
              ),
            ),
            title: Text(pl.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text('${pl.songs.length} songs • ${pl.description ?? 'Custom Playlist'}',
                style: TextStyle(color: Colors.grey[400])),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => library.deletePlaylist(pl.id),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistDetailScreen(playlist: pl),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildDownloadsTab(LibraryProvider library, PlayerProvider player) {
    final downloads = library.downloadedSongs;

    if (downloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_for_offline_outlined, size: 54, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'No downloaded songs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Downloaded songs will appear here for 100% offline listening',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: downloads.length,
      itemBuilder: (context, i) {
        final song = downloads[i];
        return SongTile(
          song: song,
          index: i + 1,
          onTap: () {
            player.playSong(song, queue: downloads, initialIndex: i);
          },
        );
      },
    );
  }

  Widget _buildHistoryTab(LibraryProvider library, PlayerProvider player) {
    final history = library.history;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 54, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'No listening history',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${history.length} recently played tracks', style: TextStyle(color: Colors.grey[400])),
              TextButton(
                onPressed: () => library.clearHistory(),
                child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
        ...history.asMap().entries.map((entry) {
          final i = entry.key;
          final song = entry.value;
          return SongTile(
            song: song,
            index: i + 1,
            onTap: () {
              player.playSong(song, queue: history, initialIndex: i);
            },
          );
        }),
      ],
    );
  }
}
