import 'package:flutter_test/flutter_test.dart';
import 'package:auramusic/models/song.dart';
import 'package:auramusic/models/lyrics.dart';

void main() {
  group('AuraMusic Unit Tests', () {
    test('Song model serialization and formatting', () {
      final song = Song(
        id: 'test_1',
        title: 'Starboy',
        artist: 'The Weeknd',
        duration: const Duration(minutes: 3, seconds: 50),
        artworkUrl: 'https://example.com/art.jpg',
      );

      expect(song.title, 'Starboy');
      expect(song.durationString, '3:50');

      final map = song.toMap();
      expect(map['id'], 'test_1');
      expect(map['duration_seconds'], 230);

      final fromMap = Song.fromMap(map);
      expect(fromMap.id, song.id);
      expect(fromMap.title, song.title);
      expect(fromMap.duration.inSeconds, 230);
    });

    test('SyncedLyrics LRC timestamp parser test', () {
      const sampleLrc = '''
[00:05.12] First line of song
[00:12.45] Second line of song
[00:25.80] Chorus line
''';

      final lyrics = SyncedLyrics.fromLrc(
        sampleLrc,
        track: 'Sample Track',
        artist: 'Sample Artist',
      );

      expect(lyrics.isSynced, true);
      expect(lyrics.lines.length, 3);
      expect(lyrics.lines[0].text, 'First line of song');
      expect(lyrics.lines[0].timestamp.inSeconds, 5);
      expect(lyrics.lines[1].text, 'Second line of song');
      expect(lyrics.lines[1].timestamp.inSeconds, 12);
      expect(lyrics.lines[2].text, 'Chorus line');
      expect(lyrics.lines[2].timestamp.inSeconds, 25);

      // Test active line index lookup at 15 seconds
      final activeIdx = lyrics.getActiveIndex(const Duration(seconds: 15));
      expect(activeIdx, 1); // Second line
    });
  });
}
