import 'package:flutter_test/flutter_test.dart';
import 'package:auramusic/services/music_service.dart';
import 'package:auramusic/services/lyrics_service.dart';
import 'package:auramusic/models/song.dart';

import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  group('Live Network Streaming & Extraction Tests', () {
    final musicService = MusicService.instance;
    final lyricsService = LyricsService.instance;

    test('Search returns valid songs with metadata', () async {
      final results = await musicService.search('Shape of You');
      expect(results.isNotEmpty, true);
      final first = results.first;
      expect(first.title.toLowerCase().contains('shape of you'), true);
      expect(first.artworkUrl.isNotEmpty, true);
      print('Search verified: ${first.title} by ${first.artist}');
    });

    test('Resolve playable audio stream URL for top tracks', () async {
      final testSongs = [
        const Song(
          id: 'test_starboy',
          title: 'Starboy',
          artist: 'The Weeknd',
          artworkUrl: 'https://c.saavncdn.com/372/Starboy-English-2016-150x150.jpg',
        ),
        const Song(
          id: 'test_believer',
          title: 'Believer',
          artist: 'Imagine Dragons',
          artworkUrl: 'https://c.saavncdn.com/286/bRY5MNOyYuGisL3gNsd33UnRi5O90cNU7Hm3hlK_96_p.mp4',
        ),
        const Song(
          id: 'kJQP7kiw5Fk',
          title: 'Despacito',
          artist: 'Luis Fonsi',
          artworkUrl: 'https://i.ytimg.com/vi/kJQP7kiw5Fk/hqdefault.jpg',
        ),
      ];

      for (final song in testSongs) {
        final url = await musicService.getAudioStreamUrl(song);
        expect(url.isNotEmpty, true);
        expect(url.startsWith('http'), true);
        print('Resolved stream for "${song.title}": $url');
      }
    });

    test('Live Synced Lyrics fetching via LRCLIB', () async {
      final song = const Song(
        id: 'test_ed',
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        artworkUrl: '',
      );

      final lyrics = await lyricsService.getLyrics(song);
      expect(lyrics.trackName.isNotEmpty, true);
      expect(lyrics.lines.isNotEmpty || (lyrics.plainLyrics != null && lyrics.plainLyrics!.isNotEmpty), true);
      if (lyrics.isSynced) {
        expect(lyrics.lines.length > 5, true);
        print('Lyrics verified: ${lyrics.lines.length} timestamped lines');
      }
    });
  });
}
