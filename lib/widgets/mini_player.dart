import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../screens/player/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;

    if (song == null) return const SizedBox.shrink();

    final library = context.watch<LibraryProvider>();
    final isLiked = library.isSongLiked(song.id);
    final progress = (player.duration.inMilliseconds > 0)
        ? (player.position.inMilliseconds / player.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Dismissible(
      key: ValueKey(song.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          player.skipToNext();
        } else {
          player.skipToPrevious();
        }
        return false; // Don't actually dismiss the widget
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, anim, secAnim) => const NowPlayingScreen(),
              transitionsBuilder: (context, anim, secAnim, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(position: anim.drive(tween), child: child);
              },
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: player.dominantColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Frosted background tint
                Container(
                  color: const Color(0xFF161616).withOpacity(0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: song.artworkUrl,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 46,
                            height: 46,
                            color: Colors.grey[900],
                            child: const Icon(Icons.music_note, color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title & Artist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Favorite button
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? const Color(0xFF1DB954) : Colors.white70,
                          size: 22,
                        ),
                        onPressed: () => library.toggleLike(song),
                      ),
                      // Play / Pause Button
                      if (player.isBuffering)
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF1DB954),
                            ),
                          ),
                        )
                      else
                        IconButton(
                          icon: Icon(
                            player.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: Colors.white,
                            size: 34,
                          ),
                          onPressed: () => player.togglePlayPause(),
                        ),
                      // Next Button
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white70, size: 26),
                        onPressed: () => player.skipToNext(),
                      ),
                    ],
                  ),
                ),
                // Tiny progress bar on top
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(player.dominantColor),
                    minHeight: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
