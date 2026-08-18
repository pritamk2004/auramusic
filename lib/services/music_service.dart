import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dart_des/dart_des.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Playlist;
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/artist.dart';

class MusicService {
  static final MusicService instance = MusicService._internal();
  MusicService._internal();

  final YoutubeExplode _yt = YoutubeExplode();
  final Map<String, String> _streamCache = {};

  // Curated Fallback Trending Tracks with high-res artwork
  static const List<Map<String, String>> defaultTrending = [
    {
      'id': 'kJQP7kiw5Fk',
      'title': 'Despacito',
      'artist': 'Luis Fonsi ft. Daddy Yankee',
      'artwork': 'https://i.ytimg.com/vi/kJQP7kiw5Fk/hqdefault.jpg',
      'duration': '228'
    },
    {
      'id': 'JGwWNGJdvx8',
      'title': 'Shape of You',
      'artist': 'Ed Sheeran',
      'artwork': 'https://i.ytimg.com/vi/JGwWNGJdvx8/hqdefault.jpg',
      'duration': '233'
    },
    {
      'id': '4NRXx6U8ABQ',
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'artwork': 'https://i.ytimg.com/vi/4NRXx6U8ABQ/hqdefault.jpg',
      'duration': '200'
    },
    {
      'id': '3y-O-4IL-PU',
      'title': 'Starboy',
      'artist': 'The Weeknd ft. Daft Punk',
      'artwork': 'https://i.ytimg.com/vi/3y-O-4IL-PU/hqdefault.jpg',
      'duration': '230'
    },
    {
      'id': '7wtfhZwyrcc',
      'title': 'Believer',
      'artist': 'Imagine Dragons',
      'artwork': 'https://i.ytimg.com/vi/7wtfhZwyrcc/hqdefault.jpg',
      'duration': '204'
    },
    {
      'id': 'YQHsXMglC9A',
      'title': 'Hello',
      'artist': 'Adele',
      'artwork': 'https://i.ytimg.com/vi/YQHsXMglC9A/hqdefault.jpg',
      'duration': '295'
    },
    {
      'id': 'OPf0YbXqDm0',
      'title': 'Uptown Funk',
      'artist': 'Mark Ronson ft. Bruno Mars',
      'artwork': 'https://i.ytimg.com/vi/OPf0YbXqDm0/hqdefault.jpg',
      'duration': '270'
    },
    {
      'id': 'fJ9rUzIMcZQ',
      'title': 'Bohemian Rhapsody',
      'artist': 'Queen',
      'artwork': 'https://i.ytimg.com/vi/fJ9rUzIMcZQ/hqdefault.jpg',
      'duration': '359'
    },
  ];

  static const List<Map<String, String>> defaultMoods = [
    {
      'id': 'mood_lofi',
      'title': 'Lo-Fi Chill & Study',
      'desc': 'Relaxing beats to focus and chill',
      'artwork': 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=500&auto=format&fit=crop&q=60',
      'query': 'lofi hip hop radio chill beats'
    },
    {
      'id': 'mood_workout',
      'title': 'Gym & High Energy',
      'desc': 'Electrifying tracks for peak motivation',
      'artwork': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=60',
      'query': 'workout music gym motivation electronic'
    },
    {
      'id': 'mood_party',
      'title': 'Club & Party Hits',
      'desc': 'Bangers to get the vibe going',
      'artwork': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500&auto=format&fit=crop&q=60',
      'query': 'party dance hits top 50'
    },
    {
      'id': 'mood_acoustic',
      'title': 'Acoustic & Soft',
      'desc': 'Unplugged guitar, piano and raw vocals',
      'artwork': 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=500&auto=format&fit=crop&q=60',
      'query': 'acoustic covers soft pop coffee morning'
    },
    {
      'id': 'mood_gaming',
      'title': 'Gaming & Synthwave',
      'desc': 'Retro synth & high tempo beats',
      'artwork': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500&auto=format&fit=crop&q=60',
      'query': 'synthwave cyberpunk gaming music'
    },
    {
      'id': 'mood_hindi',
      'title': 'Bollywood & Desi Hits',
      'desc': 'Soulful romantic & upbeat chartbusters',
      'artwork': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&auto=format&fit=crop&q=60',
      'query': 'top bollywood hits latest hindi romantic'
    },
  ];

  static const List<Map<String, String>> defaultArtists = [
    {
      'id': 'art_theweeknd',
      'name': 'The Weeknd',
      'artwork': 'https://i.ytimg.com/vi/4NRXx6U8ABQ/hqdefault.jpg',
      'subs': '34.2M Subscribers'
    },
    {
      'id': 'art_edsheeran',
      'name': 'Ed Sheeran',
      'artwork': 'https://i.ytimg.com/vi/JGwWNGJdvx8/hqdefault.jpg',
      'subs': '54.1M Subscribers'
    },
    {
      'id': 'art_taylorswift',
      'name': 'Taylor Swift',
      'artwork': 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=500&auto=format&fit=crop&q=60',
      'subs': '59.8M Subscribers'
    },
    {
      'id': 'art_drake',
      'name': 'Drake',
      'artwork': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=60',
      'subs': '29.3M Subscribers'
    },
    {
      'id': 'art_billieeilish',
      'name': 'Billie Eilish',
      'artwork': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60',
      'subs': '48.5M Subscribers'
    },
    {
      'id': 'art_arjit',
      'name': 'Arijit Singh',
      'artwork': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=60',
      'subs': '38.4M Subscribers'
    },
  ];

  /// Decrypt JioSaavn DES encrypted media URL
  String _decryptSaavnUrl(String encUrl, {String quality = 'High'}) {
    try {
      final key = utf8.encode('38346591');
      final des = DES(key: key, mode: DESMode.ECB, paddingType: DESPaddingType.PKCS7);
      final bytes = base64.decode(encUrl);
      final decrypted = des.decrypt(bytes);
      var url = utf8.decode(decrypted);

      if (quality.contains('Data Saver')) {
        url = url.replaceAll('_320.mp4', '_96.mp4').replaceAll('_160.mp4', '_96.mp4');
      } else if (quality.contains('Standard')) {
        url = url.replaceAll('_96.mp4', '_160.mp4').replaceAll('_320.mp4', '_160.mp4');
      } else {
        url = url.replaceAll('_96.mp4', '_320.mp4').replaceAll('_160.mp4', '_320.mp4');
      }
      return url;
    } catch (e) {
      debugPrint('Saavn decrypt error: $e');
      return '';
    }
  }

  /// Resolve direct playable audio stream with Web CORS and Android compatibility
  Future<String> getAudioStreamUrl(Song song, {String quality = 'High (160/320 kbps)'}) async {
    // 1. Direct URL already embedded in song
    if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
      return song.audioUrl!;
    }

    // 2. Memory cache check
    if (_streamCache.containsKey(song.id)) {
      return _streamCache[song.id]!;
    }

    // 3. Web backend stream query
    if (kIsWeb) {
      try {
        final query = '${song.title} ${song.artist}'.trim();
        final res = await http.get(Uri.parse('/api/search?q=${Uri.encodeComponent(query)}')).timeout(
          const Duration(seconds: 4),
        );
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final list = data['results'] as List<dynamic>? ?? [];
          if (list.isNotEmpty && list.first['audioUrl'] != null) {
            final url = list.first['audioUrl'].toString();
            if (url.isNotEmpty) {
              _streamCache[song.id] = url;
              return url;
            }
          }
        }
      } catch (_) {}
    }

    // 4. Native direct multi-query resolver
    final cleanTitle = song.title
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .split(RegExp(r'\s+(?:ft\.?|feat\.?)\s+', caseSensitive: false))[0]
        .trim();
    final cleanArtist = song.artist
        .split(RegExp(r'[,&]|\s+(?:ft\.?|feat\.?)\s+', caseSensitive: false))[0]
        .trim();

    final queriesToTry = [
      '${song.title} ${song.artist}'.trim(),
      '$cleanTitle $cleanArtist'.trim(),
      cleanTitle,
    ];

    for (final q in queriesToTry) {
      try {
        final saavnUrl = Uri.parse(
          'https://www.jiosaavn.com/api.php?__call=search.getResults&_format=json&_marker=0&cc=in&includeMetaTags=1&q=${Uri.encodeComponent(q)}&p=1&n=3',
        );
        final res = await http.get(saavnUrl, headers: {'User-Agent': 'Mozilla/5.0'}).timeout(
          const Duration(seconds: 4),
        );

        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final results = data['results'] as List<dynamic>? ?? [];
          if (results.isNotEmpty) {
            for (final item in results) {
              final enc = item['encrypted_media_url']?.toString();
              if (enc != null && enc.isNotEmpty) {
                final decrypted = _decryptSaavnUrl(enc, quality: quality);
                if (decrypted.isNotEmpty) {
                  _streamCache[song.id] = decrypted;
                  return decrypted;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Saavn search stream error ($q): $e');
      }
    }

    // 5. Native YouTube Explode stream extraction (for Android / Desktop)
    if (!kIsWeb) {
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(song.id);
        final audioStreams = manifest.audioOnly.toList();

        if (audioStreams.isNotEmpty) {
          AudioStreamInfo selectedStream;
          if (quality.contains('Data Saver')) {
            selectedStream = audioStreams.reduce(
              (a, b) => a.bitrate.kiloBitsPerSecond < b.bitrate.kiloBitsPerSecond ? a : b,
            );
          } else {
            selectedStream = audioStreams.reduce(
              (a, b) => a.bitrate.kiloBitsPerSecond > b.bitrate.kiloBitsPerSecond ? a : b,
            );
          }

          final streamUrl = selectedStream.url.toString();
          _streamCache[song.id] = streamUrl;
          return streamUrl;
        }
      } catch (e) {
        debugPrint('YouTube stream extraction error: $e');
      }
    }

    throw Exception('Unable to extract playable audio stream for ${song.title}');
  }

  /// Real-Time Search for songs, albums, and tracks
  Future<List<Song>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final cleanQuery = query.trim();
    final results = <Song>[];

    // 1. On Web: Use same-origin real-time API
    if (kIsWeb) {
      try {
        final res = await http.get(Uri.parse('/api/search?q=${Uri.encodeComponent(cleanQuery)}')).timeout(
          const Duration(seconds: 5),
        );
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final list = data['results'] as List<dynamic>? ?? [];
          for (final item in list) {
            results.add(Song(
              id: item['id'] ?? '',
              title: item['title'] ?? '',
              artist: item['artist'] ?? '',
              album: item['album'],
              duration: Duration(seconds: item['duration'] ?? 210),
              artworkUrl: item['artworkUrl'] ?? '',
              audioUrl: item['audioUrl'],
              source: 'jiosaavn',
            ));
          }
          if (results.isNotEmpty) return results;
        }
      } catch (e) {
        debugPrint('Web search API error: $e');
      }
    }

    // 2. Direct JioSaavn Search (Native & Fallback)
    try {
      final saavnResults = await searchSaavn(cleanQuery);
      if (saavnResults.isNotEmpty) {
        results.addAll(saavnResults);
      }
    } catch (_) {}

    // 3. YouTube Search (if more results needed)
    try {
      final ytResults = await _yt.search.search(cleanQuery);
      for (final video in ytResults) {
        if (video.duration == null || video.duration == Duration.zero) continue;
        if (!results.any((r) => r.title.toLowerCase() == video.title.toLowerCase())) {
          results.add(Song(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            duration: video.duration ?? Duration.zero,
            artworkUrl: video.thumbnails.highResUrl.isNotEmpty
                ? video.thumbnails.highResUrl
                : video.thumbnails.standardResUrl,
            source: 'youtube',
          ));
        }
      }
    } catch (_) {}

    return results;
  }

  /// Fast JioSaavn Search
  Future<List<Song>> searchSaavn(String query) async {
    final list = <Song>[];
    try {
      final url = Uri.parse(
        'https://www.jiosaavn.com/api.php?__call=search.getResults&_format=json&_marker=0&cc=in&includeMetaTags=1&q=${Uri.encodeComponent(query)}&p=1&n=15',
      );
      final res = await http.get(url, headers: {'User-Agent': 'Mozilla/5.0'}).timeout(
        const Duration(seconds: 5),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final songs = data['results'] as List<dynamic>? ?? [];
        for (final item in songs) {
          final id = item['id']?.toString() ?? '';
          final title = item['song']?.toString().replaceAll('&quot;', '"').replaceAll('&#039;', "'").replaceAll('&amp;', '&') ?? '';
          final artist = item['primary_artists']?.toString() ?? item['singers']?.toString() ?? 'Artist';
          var img = item['image']?.toString() ?? '';
          img = img.replaceAll('50x50', '500x500').replaceAll('150x150', '500x500');
          final enc = item['encrypted_media_url']?.toString();
          final durationSec = int.tryParse(item['duration']?.toString() ?? '210') ?? 210;

          if (id.isNotEmpty && title.isNotEmpty) {
            String? directUrl;
            if (enc != null && enc.isNotEmpty) {
              directUrl = _decryptSaavnUrl(enc);
            }

            list.add(Song(
              id: 'saavn_$id',
              title: title,
              artist: artist,
              album: item['album']?.toString(),
              duration: Duration(seconds: durationSec),
              artworkUrl: img,
              audioUrl: directUrl,
              source: 'jiosaavn',
            ));
          }
        }
      }
    } catch (_) {}
    return list;
  }

  /// Get Trending / Top Charts in Real Time
  Future<List<Song>> getTrendingSongs() async {
    // 1. On Web: Try live API first
    if (kIsWeb) {
      try {
        final res = await http.get(Uri.parse('/api/trending')).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final list = data['results'] as List<dynamic>? ?? [];
          final songs = <Song>[];
          for (final item in list) {
            songs.add(Song(
              id: item['id'] ?? '',
              title: item['title'] ?? '',
              artist: item['artist'] ?? '',
              album: item['album'],
              duration: Duration(seconds: item['duration'] ?? 210),
              artworkUrl: item['artworkUrl'] ?? '',
              audioUrl: item['audioUrl'],
              source: 'jiosaavn',
            ));
          }
          if (songs.isNotEmpty) return songs;
        }
      } catch (_) {}
    }

    // 2. Real-time Search for Top Charts
    try {
      final liveTrending = await searchSaavn('Top English Songs 2026');
      if (liveTrending.isNotEmpty) {
        return liveTrending;
      }
    } catch (_) {}

    // 3. Fallback Curated list
    final list = <Song>[];
    for (final item in defaultTrending) {
      list.add(Song(
        id: item['id']!,
        title: item['title']!,
        artist: item['artist']!,
        duration: Duration(seconds: int.parse(item['duration']!)),
        artworkUrl: item['artwork']!,
        source: 'youtube',
      ));
    }
    return list;
  }

  /// Get Curated Mood / Genre Playlists
  List<Playlist> getMoodPlaylists() {
    return defaultMoods.map((m) {
      return Playlist(
        id: m['id']!,
        title: m['title']!,
        description: m['desc'],
        artworkUrl: m['artwork']!,
        author: 'Aura Vibes',
      );
    }).toList();
  }

  /// Get Curated Top Artists
  List<Artist> getTopArtists() {
    return defaultArtists.map((a) {
      return Artist(
        id: a['id']!,
        name: a['name']!,
        artworkUrl: a['artwork']!,
        subscriberCount: a['subs'],
      );
    }).toList();
  }

  /// Load playlist tracks dynamically based on genre or query
  Future<List<Song>> getPlaylistTracks(String playlistId) async {
    final mood = defaultMoods.firstWhere(
      (m) => m['id'] == playlistId,
      orElse: () => {'query': 'trending songs 2026'},
    );
    final query = mood['query'] ?? 'trending music';
    return await search(query);
  }

  /// Load artist top songs dynamically
  Future<Artist> getArtistDetails(String artistName) async {
    final songs = await search('$artistName songs');
    return Artist(
      id: 'art_${artistName.toLowerCase().replaceAll(' ', '_')}',
      name: artistName,
      artworkUrl: songs.isNotEmpty
          ? songs.first.artworkUrl
          : 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=60',
      topSongs: songs,
    );
  }

  /// Fetch related songs for Infinite Radio Autoplay
  Future<List<Song>> getRelatedSongs(Song currentSong) async {
    final results = await search('${currentSong.artist} mix');
    return results;
  }

  void dispose() {
    _yt.close();
  }
}
