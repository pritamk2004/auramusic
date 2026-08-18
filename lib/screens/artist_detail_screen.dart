import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../providers/explore_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().openArtist(widget.artist);
    });
  }

  @override
  Widget build(BuildContext context) {
    final explore = context.watch<ExploreProvider>();
    final player = context.watch<PlayerProvider>();
    final artist = explore.selectedArtist ?? widget.artist;
    final topSongs = artist.topSongs;
    final isLoading = explore.isLoadingArtist;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Artist Header Image
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                artist.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: artist.artworkUrl,
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
                          Colors.black.withOpacity(0.6),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.65, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Artist Details & Action Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (artist.subscriberCount != null)
                    Text(
                      artist.subscriberCount!,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: topSongs.isEmpty
                            ? null
                            : () {
                                player.playSong(topSongs.first, queue: topSongs, initialIndex: 0);
                              },
                        icon: const Icon(Icons.play_arrow, size: 24),
                        label: const Text('Play Artist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: topSongs.isEmpty
                            ? null
                            : () {
                                final shuffled = List<Song>.from(topSongs)..shuffle();
                                player.playSong(shuffled.first, queue: shuffled, initialIndex: 0);
                              },
                        icon: const Icon(Icons.shuffle, size: 20),
                        label: const Text('Shuffle', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Popular Tracks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Top Songs List
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1DB954)),
              ),
            )
          else if (topSongs.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No songs found for this artist', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final song = topSongs[i];
                  return SongTile(
                    song: song,
                    index: i + 1,
                    onTap: () {
                      player.playSong(song, queue: topSongs, initialIndex: i);
                    },
                  );
                },
                childCount: topSongs.length,
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
