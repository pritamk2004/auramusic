import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/explore_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/playlist_card.dart';
import '../widgets/artist_circle.dart';
import '../widgets/aura_logo.dart';
import 'playlist_detail_screen.dart';
import 'artist_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final explore = context.watch<ExploreProvider>();
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      body: RefreshIndicator(
        color: const Color(0xFF1DB954),
        onRefresh: () => explore.initHome(),
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: const Color(0xFF000000).withOpacity(0.85),
              title: Row(
                children: [
                  const AuraLogo(size: 26, showText: true),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: Color(0xFF1DB954), size: 14),
                        SizedBox(width: 2),
                        Text(
                          'AD-FREE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Listen to unlimited songs in high fidelity without ads',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 24),

                    // Quick Picks Grid (6 items)
                    if (explore.trendingSongs.isNotEmpty) ...[
                      const Text(
                        'Quick Picks',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      _buildQuickPicksGrid(context, explore, player),
                      const SizedBox(height: 28),
                    ],

                    // Moods & Genres
                    const Text(
                      'Moods & Genres',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: explore.moodPlaylists.length,
                        itemBuilder: (context, i) {
                          final p = explore.moodPlaylists[i];
                          return PlaylistCard(
                            playlist: p,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaylistDetailScreen(playlist: p),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Top Artists Carousel
                    const Text(
                      'Featured Artists',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 155,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: explore.topArtists.length,
                        itemBuilder: (context, i) {
                          final a = explore.topArtists[i];
                          return ArtistCircle(
                            artist: a,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArtistDetailScreen(artist: a),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Trending Top 50 Global
                    const Text(
                      'Trending Now',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Trending Songs List
            if (explore.isLoadingHome)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF1DB954)),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final song = explore.trendingSongs[i];
                    return SongTile(
                      song: song,
                      index: i + 1,
                      onTap: () {
                        player.playSong(song, queue: explore.trendingSongs, initialIndex: i);
                      },
                    );
                  },
                  childCount: explore.trendingSongs.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPicksGrid(BuildContext context, ExploreProvider explore, PlayerProvider player) {
    final picks = explore.trendingSongs.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: picks.length,
      itemBuilder: (context, i) {
        final song = picks[i];
        final isPlaying = player.currentSong?.id == song.id && player.isPlaying;

        return GestureDetector(
          onTap: () => player.playSong(song, queue: explore.trendingSongs, initialIndex: i),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPlaying ? const Color(0xFF1DB954) : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  child: Image.network(
                    song.artworkUrl,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 54, color: Colors.grey[800]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPlaying ? const Color(0xFF1DB954) : Colors.white,
                        ),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                if (isPlaying)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.volume_up, color: Color(0xFF1DB954), size: 16),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
