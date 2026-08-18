import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class LyricsTab extends StatefulWidget {
  const LyricsTab({super.key});

  @override
  State<LyricsTab> createState() => _LyricsTabState();
}

class _LyricsTabState extends State<LyricsTab> {
  final ScrollController _scrollController = ScrollController();
  int _lastActiveIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive(int index) {
    if (index != _lastActiveIndex && _scrollController.hasClients) {
      _lastActiveIndex = index;
      final targetOffset = (index * 60.0) - 180.0;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final lyrics = player.lyrics;

    if (player.isLoadingLyrics) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1DB954)),
            SizedBox(height: 16),
            Text('Fetching real-time lyrics...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (lyrics == null || (lyrics.lines.isEmpty && (lyrics.plainLyrics == null || lyrics.plainLyrics!.isEmpty))) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_off_outlined, color: Colors.grey[600], size: 48),
            const SizedBox(height: 12),
            Text(
              'No lyrics found for this song.',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // If plain text (not synced)
    if (!lyrics.isSynced) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Text(
          lyrics.plainLyrics ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            height: 1.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Synced Karaoke Lyrics
    final activeIndex = player.activeLyricIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeIndex >= 0) {
        _scrollToActive(activeIndex);
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      itemCount: lyrics.lines.length,
      itemBuilder: (context, i) {
        final line = lyrics.lines[i];
        final isActive = i == activeIndex;
        final isPast = i < activeIndex;

        return GestureDetector(
          onTap: () {
            player.seek(line.timestamp);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: isActive ? 24 : 18,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : isPast
                        ? Colors.white.withOpacity(0.65)
                        : Colors.white.withOpacity(0.3),
                height: 1.4,
              ),
              child: Text(
                line.text,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
