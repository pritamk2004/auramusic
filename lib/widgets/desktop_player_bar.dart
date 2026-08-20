import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../services/audio_handler.dart';
import '../screens/player/now_playing_screen.dart';

class DesktopPlayerBar extends StatefulWidget {
  final VoidCallback? onToggleLyrics;
  final VoidCallback? onToggleQueue;
  final bool isLyricsActive;
  final bool isQueueActive;

  const DesktopPlayerBar({
    super.key,
    this.onToggleLyrics,
    this.onToggleQueue,
    this.isLyricsActive = false,
    this.isQueueActive = false,
  });

  @override
  State<DesktopPlayerBar> createState() => _DesktopPlayerBarState();
}

class _DesktopPlayerBarState extends State<DesktopPlayerBar> {
  double _volume = 1.0;
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;

    if (song == null) {
      return Container(
        height: 84,
        color: const Color(0xFF121212),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          children: [
            Icon(Icons.graphic_eq, color: Colors.grey, size: 24),
            SizedBox(width: 12),
            Text('Select a song to start listening', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    final library = context.watch<LibraryProvider>();
    final isLiked = library.isSongLiked(song.id);

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // LEFT SECTION: Track Info (30% width)
          SizedBox(
            width: 260,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: song.artworkUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[900],
                        child: const Icon(Icons.music_note, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? const Color(0xFF1DB954) : Colors.white60,
                    size: 20,
                  ),
                  onPressed: () => library.toggleLike(song),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // CENTER SECTION: Player Controls & Progress Bar
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: player.isShuffle ? const Color(0xFF1DB954) : Colors.white60,
                        size: 20,
                      ),
                      onPressed: () => player.toggleShuffle(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                      onPressed: () => player.skipToPrevious(),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => player.togglePlayPause(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: player.isBuffering
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : Icon(
                                  player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 26,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                      onPressed: () => player.skipToNext(),
                    ),
                    IconButton(
                      icon: Icon(
                        player.repeatMode == PlayerRepeatMode.one
                            ? Icons.repeat_one
                            : player.repeatMode == PlayerRepeatMode.all
                                ? Icons.repeat
                                : Icons.repeat,
                        color: player.repeatMode != PlayerRepeatMode.off
                            ? const Color(0xFF1DB954)
                            : Colors.white60,
                        size: 20,
                      ),
                      onPressed: () => player.toggleRepeatMode(),
                    ),
                  ],
                ),

                // Scrubber Progress Bar
                SizedBox(
                  width: 540,
                  child: ProgressBar(
                    progress: player.position,
                    buffered: player.bufferedPosition,
                    total: player.duration,
                    progressBarColor: const Color(0xFF1DB954),
                    baseBarColor: Colors.white.withOpacity(0.15),
                    bufferedBarColor: Colors.white.withOpacity(0.3),
                    thumbColor: Colors.white,
                    thumbRadius: 5.0,
                    thumbGlowRadius: 12.0,
                    timeLabelTextStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
                    onSeek: (pos) => player.seek(pos),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // RIGHT SECTION: Lyrics, Queue, Volume, Fullscreen (260px)
          SizedBox(
            width: 260,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Synced Lyrics Toggle
                IconButton(
                  tooltip: 'Real-time Lyrics',
                  icon: Icon(
                    Icons.lyrics_outlined,
                    color: widget.isLyricsActive ? const Color(0xFF1DB954) : Colors.white60,
                    size: 20,
                  ),
                  onPressed: widget.onToggleLyrics,
                ),

                // Queue Toggle
                IconButton(
                  tooltip: 'Queue',
                  icon: Icon(
                    Icons.queue_music,
                    color: widget.isQueueActive ? const Color(0xFF1DB954) : Colors.white60,
                    size: 20,
                  ),
                  onPressed: widget.onToggleQueue,
                ),

                // Mute / Unmute
                IconButton(
                  icon: Icon(
                    _isMuted || _volume == 0
                        ? Icons.volume_off
                        : _volume < 0.5
                            ? Icons.volume_down
                            : Icons.volume_up,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                      AudioPlayerService.instance.setVolume(_isMuted ? 0.0 : _volume);
                    });
                  },
                ),

                // Volume Slider
                SizedBox(
                  width: 80,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                      trackHeight: 3,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _isMuted ? 0.0 : _volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) {
                        setState(() {
                          _volume = val;
                          _isMuted = val == 0.0;
                          AudioPlayerService.instance.setVolume(val);
                        });
                      },
                    ),
                  ),
                ),

                // Fullscreen Button
                IconButton(
                  tooltip: 'Open Fullscreen Player',
                  icon: const Icon(Icons.fullscreen, color: Colors.white70, size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
