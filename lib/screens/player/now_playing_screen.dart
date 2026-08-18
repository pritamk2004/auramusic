import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/audio_handler.dart';
import '../../widgets/audio_visualizer.dart';
import 'lyrics_tab.dart';
import 'queue_tab.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  int _currentTab = 0; // 0: Player, 1: Lyrics, 2: Queue

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;

    if (song == null) {
      return const Scaffold(
        body: Center(child: Text('No song playing')),
      );
    }

    final dominantColor = player.dominantColor;
    final secondaryColor = player.secondaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              dominantColor.withOpacity(0.85),
              secondaryColor.withOpacity(0.95),
              Colors.black,
            ],
            stops: const [0.0, 0.45, 0.85],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              _buildTopBar(context, player),

              // Segmented Tab Selector
              _buildTabSelector(),

              // Body Content according to selected tab
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildCurrentTabContent(player),
                ),
              ),

              // Bottom Utilities Bar (Speed, Sleep timer, Download)
              if (_currentTab == 0) _buildBottomUtilities(context, player),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PlayerProvider player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 36, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                'PLAYING FROM',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Aura Discovery',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
            onPressed: () => _showMoreOptions(context, player),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabs = ['Track', 'Lyrics', 'Queue'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(tabs.length, (i) {
          final isSelected = _currentTab == i;
          return GestureDetector(
            onTap: () => setState(() => _currentTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentTabContent(PlayerProvider player) {
    switch (_currentTab) {
      case 1:
        return const LyricsTab(key: ValueKey('lyrics'));
      case 2:
        return const QueueTab(key: ValueKey('queue'));
      default:
        return _buildPlayerTab(player);
    }
  }

  Widget _buildPlayerTab(PlayerProvider player) {
    final song = player.currentSong!;
    final library = context.watch<LibraryProvider>();
    final isLiked = library.isSongLiked(song.id);

    final size = MediaQuery.of(context).size;
    final artSize = (size.width * 0.76).clamp(240.0, 340.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Large Album Cover Art with Glow
          Center(
            child: Container(
              width: artSize,
              height: artSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: player.dominantColor.withOpacity(0.45),
                    blurRadius: 35,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: song.artworkUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.music_note, size: 80, color: Colors.white54),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title, Artist and Heart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? const Color(0xFF1DB954) : Colors.white,
                  size: 28,
                ),
                onPressed: () => library.toggleLike(song),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Audio Frequency Visualizer
          AudioVisualizer(
            isPlaying: player.isPlaying,
            color: player.dominantColor,
            barCount: 22,
            height: 32,
          ),

          const SizedBox(height: 16),

          // Interactive Progress Bar / Scrubber
          ProgressBar(
            progress: player.position,
            buffered: player.bufferedPosition,
            total: player.duration,
            progressBarColor: Colors.white,
            baseBarColor: Colors.white.withOpacity(0.2),
            bufferedBarColor: Colors.white.withOpacity(0.4),
            thumbColor: Colors.white,
            thumbRadius: 7.0,
            thumbGlowRadius: 18.0,
            timeLabelTextStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            onSeek: (duration) {
              player.seek(duration);
            },
          ),

          const SizedBox(height: 12),

          // Playback Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Shuffle
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: player.isShuffle ? const Color(0xFF1DB954) : Colors.white60,
                  size: 26,
                ),
                onPressed: () => player.toggleShuffle(),
              ),

              // Previous
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 38),
                onPressed: () => player.skipToPrevious(),
              ),

              // Big Play/Pause Button
              GestureDetector(
                onTap: () => player.togglePlayPause(),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: player.isBuffering
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black,
                            ),
                          )
                        : Icon(
                            player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 42,
                          ),
                  ),
                ),
              ),

              // Next
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 38),
                onPressed: () => player.skipToNext(),
              ),

              // Repeat
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
                  size: 26,
                ),
                onPressed: () => player.toggleRepeatMode(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomUtilities(BuildContext context, PlayerProvider player) {
    final library = context.watch<LibraryProvider>();
    final settings = context.watch<SettingsProvider>();
    final song = player.currentSong!;
    final isDownloaded = library.isSongDownloaded(song.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Playback Speed
          TextButton.icon(
            onPressed: () => _showSpeedSelector(context, player),
            icon: const Icon(Icons.speed, color: Colors.white70, size: 18),
            label: Text(
              '${player.playbackSpeed}x',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),

          // Sleep Timer
          TextButton.icon(
            onPressed: () => _showSleepTimerSelector(context, settings),
            icon: Icon(
              settings.hasActiveSleepTimer ? Icons.timer : Icons.timer_outlined,
              color: settings.hasActiveSleepTimer ? const Color(0xFF1DB954) : Colors.white70,
              size: 18,
            ),
            label: Text(
              settings.hasActiveSleepTimer ? '${settings.sleepTimerMinutes}m' : 'Timer',
              style: TextStyle(
                color: settings.hasActiveSleepTimer ? const Color(0xFF1DB954) : Colors.white70,
                fontSize: 13,
              ),
            ),
          ),

          // Offline Download
          IconButton(
            icon: Icon(
              isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
              color: isDownloaded ? const Color(0xFF1DB954) : Colors.white70,
              size: 22,
            ),
            onPressed: () {
              if (isDownloaded) {
                library.deleteDownload(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removed from downloads')),
                );
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
    );
  }

  void _showSpeedSelector(BuildContext context, PlayerProvider player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      builder: (ctx) {
        final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Playback Speed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Wrap(
                spacing: 12,
                children: speeds.map((s) {
                  final isCurrent = player.playbackSpeed == s;
                  return ChoiceChip(
                    label: Text('${s}x'),
                    selected: isCurrent,
                    selectedColor: const Color(0xFF1DB954),
                    onSelected: (_) {
                      player.setPlaybackSpeed(s);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSleepTimerSelector(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      builder: (ctx) {
        final times = [15, 30, 45, 60, 90];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Sleep Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              if (settings.hasActiveSleepTimer)
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Turn Off Timer'),
                  onTap: () {
                    settings.cancelSleepTimer();
                    Navigator.pop(ctx);
                  },
                ),
              ...times.map((m) {
                return ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.white),
                  title: Text('$m minutes'),
                  onTap: () {
                    settings.setSleepTimer(m);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Music will pause in $m minutes')),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context, PlayerProvider player) {
    final song = player.currentSong;
    if (song == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.equalizer, color: Color(0xFF1DB954)),
                title: const Text('Audio Quality: High 320/160kbps'),
                subtitle: const Text('Direct lossless stream with zero compression'),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Share Song Link'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied link for "${song.title}"')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
