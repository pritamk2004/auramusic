import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import 'create_playlist_dialog.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final bool showArtwork;
  final bool showTrailing;
  final int? index;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.showArtwork = true,
    this.showTrailing = true,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final library = context.watch<LibraryProvider>();
    final isCurrent = player.currentSong?.id == song.id;
    final isPlaying = isCurrent && player.isPlaying;
    final isLiked = library.isSongLiked(song.id);
    final isDownloaded = library.isSongDownloaded(song.id);
    final isDownloading = library.isDownloading(song.id);

    return InkWell(
      onTap: onTap ?? () => player.playSong(song),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrent ? Colors.white.withOpacity(0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            if (index != null) ...[
              SizedBox(
                width: 28,
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: isCurrent ? const Color(0xFF1DB954) : Colors.grey[400],
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            if (showArtwork) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: song.artworkUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[900],
                        child: const Icon(Icons.music_note, color: Colors.white54),
                      ),
                    ),
                    if (isPlaying)
                      Container(
                        width: 50,
                        height: 50,
                        color: Colors.black.withOpacity(0.5),
                        child: const Icon(
                          Icons.equalizer,
                          color: Color(0xFF1DB954),
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent ? const Color(0xFF1DB954) : Colors.white,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isDownloading) ...[
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1DB954)),
                        ),
                        const SizedBox(width: 4),
                      ] else if (isDownloaded) ...[
                        const Icon(Icons.download_done, color: Color(0xFF1DB954), size: 14),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (song.duration != Duration.zero) ...[
                        const SizedBox(width: 6),
                        Text(
                          song.durationString,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (showTrailing) ...[
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? const Color(0xFF1DB954) : Colors.grey[500],
                  size: 20,
                ),
                onPressed: () => library.toggleLike(song),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                onPressed: () => _showSongOptionsMenu(context, song),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSongOptionsMenu(BuildContext context, Song song) {
    final player = context.read<PlayerProvider>();
    final library = context.read<LibraryProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: song.artworkUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.playlist_play, color: Colors.white),
                  title: const Text('Play Next'),
                  onTap: () {
                    player.playNextInQueue(song);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Playing "${song.title}" next')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.queue_music, color: Colors.white),
                  title: const Text('Add to Queue'),
                  onTap: () {
                    player.addToQueue(song);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to Queue')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add, color: Colors.white),
                  title: const Text('Add to Playlist'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddToPlaylistDialog(context, song);
                  },
                ),
                ListTile(
                  leading: Icon(
                    library.isSongDownloaded(song.id) ? Icons.delete_outline : Icons.download,
                    color: Colors.white,
                  ),
                  title: Text(
                    library.isSongDownloaded(song.id) ? 'Remove Download' : 'Download for Offline',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (library.isSongDownloaded(song.id)) {
                      library.deleteDownload(song);
                    } else {
                      library.downloadSong(song);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading "${song.title}"...')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    final library = context.read<LibraryProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: library.customPlaylists.isEmpty
                ? const Text('No custom playlists yet.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: library.customPlaylists.length,
                    itemBuilder: (_, i) {
                      final p = library.customPlaylists[i];
                      return ListTile(
                        leading: const Icon(Icons.queue_music, color: Color(0xFF1DB954)),
                        title: Text(p.title),
                        subtitle: Text('${p.songCount} songs'),
                        onTap: () {
                          library.addSongToPlaylist(p.id, song);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added to ${p.title}')),
                          );
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (_) => const CreatePlaylistDialog(),
                );
              },
              child: const Text('+ New Playlist', style: TextStyle(color: Color(0xFF1DB954))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
