import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../providers/explore_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().openPlaylist(widget.playlist);
    });
  }

  @override
  Widget build(BuildContext context) {
    final explore = context.watch<ExploreProvider>();
    final player = context.watch<PlayerProvider>();
    final tracks = explore.playlistTracks;
    final isLoading = explore.isLoadingPlaylist;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Header with Album Art
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.playlist.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.playlist.artworkUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                          const Color(0xFF000000),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playlist Info & Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.playlist.description != null) ...[
                    Text(
                      widget.playlist.description!,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Created by ${widget.playlist.author} • ${tracks.length} songs',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // Play All & Shuffle Buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: tracks.isEmpty
                            ? null
                            : () {
                                player.playSong(tracks.first, queue: tracks, initialIndex: 0);
                              },
                        icon: const Icon(Icons.play_arrow, size: 24),
                        label: const Text('Play All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: tracks.isEmpty
                            ? null
                            : () {
                                final shuffled = List<Song>.from(tracks)..shuffle();
                                player.playSong(shuffled.first, queue: shuffled, initialIndex: 0);
                              },
                        icon: const Icon(Icons.shuffle, size: 20),
                        label: const Text('Shuffle', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                ],
              ),
            ),
          ),

          // Tracks List
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1DB954)),
              ),
            )
          else if (tracks.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No tracks found', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final song = tracks[i];
                  return SongTile(
                    song: song,
                    index: i + 1,
                    onTap: () {
                      player.playSong(song, queue: tracks, initialIndex: i);
                    },
                  );
                },
                childCount: tracks.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
