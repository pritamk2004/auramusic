import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lyrics.dart';
import '../models/song.dart';

class LyricsService {
  static final LyricsService instance = LyricsService._internal();
  LyricsService._internal();

  final Map<String, SyncedLyrics> _cache = {};

  /// Fetch lyrics for a song (synchronized with timestamps or plain text)
  Future<SyncedLyrics> getLyrics(Song song) async {
    // Check in-memory cache
    if (_cache.containsKey(song.id)) {
      return _cache[song.id]!;
    }

    // Clean track title (strip out "(Official Video)", "feat.", "[4K]", etc.)
    final cleanTitle = _cleanSongTitle(song.title);
    final cleanArtist = _cleanArtistName(song.artist);

    try {
      // 1. Query LRCLIB direct get endpoint
      final directUri = Uri.parse(
        'https://lrclib.net/api/get?artist_name=${Uri.encodeComponent(cleanArtist)}&track_name=${Uri.encodeComponent(cleanTitle)}',
      );
      final res = await http.get(directUri, headers: {'User-Agent': 'AuraMusic/1.0'}).timeout(
        const Duration(seconds: 4),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['syncedLyrics'] != null && data['syncedLyrics'].toString().isNotEmpty) {
          final lyrics = SyncedLyrics.fromLrc(
            data['syncedLyrics'],
            track: song.title,
            artist: song.artist,
          );
          _cache[song.id] = lyrics;
          return lyrics;
        } else if (data['plainLyrics'] != null && data['plainLyrics'].toString().isNotEmpty) {
          final lyrics = SyncedLyrics.plain(
            data['plainLyrics'],
            track: song.title,
            artist: song.artist,
          );
          _cache[song.id] = lyrics;
          return lyrics;
        }
      }
    } catch (_) {}

    // 2. Query LRCLIB search endpoint as fallback
    try {
      final searchUri = Uri.parse(
        'https://lrclib.net/api/search?q=${Uri.encodeComponent('$cleanTitle $cleanArtist')}',
      );
      final res = await http.get(searchUri, headers: {'User-Agent': 'AuraMusic/1.0'}).timeout(
        const Duration(seconds: 4),
      );

      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        if (list.isNotEmpty) {
          final first = list.first;
          if (first['syncedLyrics'] != null && first['syncedLyrics'].toString().isNotEmpty) {
            final lyrics = SyncedLyrics.fromLrc(
              first['syncedLyrics'],
              track: song.title,
              artist: song.artist,
            );
            _cache[song.id] = lyrics;
            return lyrics;
          } else if (first['plainLyrics'] != null && first['plainLyrics'].toString().isNotEmpty) {
            final lyrics = SyncedLyrics.plain(
              first['plainLyrics'],
              track: song.title,
              artist: song.artist,
            );
            _cache[song.id] = lyrics;
            return lyrics;
          }
        }
      }
    } catch (_) {}

    final empty = SyncedLyrics.plain(
      'Lyrics not found for this track.\nEnjoy the music!',
      track: song.title,
      artist: song.artist,
    );
    _cache[song.id] = empty;
    return empty;
  }

  String _cleanSongTitle(String title) {
    var clean = title;
    // Remove (Official Video), [Official Audio], etc.
    clean = clean.replaceAll(RegExp(r'\((.*?)\)'), '');
    clean = clean.replaceAll(RegExp(r'\[(.*?)\]'), '');
    clean = clean.replaceAll(RegExp(r'ft\..*|feat\..*', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r'\|.*'), '');
    return clean.trim();
  }

  String _cleanArtistName(String artist) {
    var clean = artist;
    clean = clean.replaceAll(RegExp(r' - Topic$'), '');
    clean = clean.replaceAll(RegExp(r'VEVO$'), '');
    return clean.trim();
  }
}
