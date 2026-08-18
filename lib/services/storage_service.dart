import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  Database? _db;
  SharedPreferences? _prefs;

  // In-memory web fallback stores
  final List<Song> _webLikedSongs = [];
  final List<Playlist> _webPlaylists = [];
  final List<Song> _webHistory = [];
  final List<Song> _webDownloads = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      _loadWebData();
      return;
    }

    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'auramusic.db');

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Liked songs table
          await db.execute('''
            CREATE TABLE liked_songs (
              id TEXT PRIMARY KEY,
              title TEXT,
              artist TEXT,
              album TEXT,
              duration_seconds INTEGER,
              artwork_url TEXT,
              audio_url TEXT,
              source TEXT,
              is_downloaded INTEGER,
              local_file_path TEXT,
              date_added TEXT
            )
          ''');

          // Playlists table
          await db.execute('''
            CREATE TABLE custom_playlists (
              id TEXT PRIMARY KEY,
              title TEXT,
              description TEXT,
              artwork_url TEXT,
              author TEXT,
              is_custom INTEGER,
              date_created TEXT
            )
          ''');

          // Playlist songs mapping table
          await db.execute('''
            CREATE TABLE playlist_songs (
              playlist_id TEXT,
              song_id TEXT,
              title TEXT,
              artist TEXT,
              album TEXT,
              duration_seconds INTEGER,
              artwork_url TEXT,
              audio_url TEXT,
              source TEXT,
              date_added TEXT,
              PRIMARY KEY (playlist_id, song_id)
            )
          ''');

          // History table
          await db.execute('''
            CREATE TABLE history (
              id TEXT PRIMARY KEY,
              title TEXT,
              artist TEXT,
              album TEXT,
              duration_seconds INTEGER,
              artwork_url TEXT,
              audio_url TEXT,
              source TEXT,
              played_at TEXT
            )
          ''');

          // Downloaded songs table
          await db.execute('''
            CREATE TABLE downloads (
              id TEXT PRIMARY KEY,
              title TEXT,
              artist TEXT,
              album TEXT,
              duration_seconds INTEGER,
              artwork_url TEXT,
              local_file_path TEXT,
              file_size_bytes INTEGER,
              downloaded_at TEXT
            )
          ''');
        },
      );
    } catch (e) {
      debugPrint('SQLite initialization error, falling back to prefs: $e');
      _loadWebData();
    }
  }

  void _loadWebData() {
    try {
      final likedStr = _prefs?.getString('web_liked_songs');
      if (likedStr != null) {
        final List list = json.decode(likedStr);
        _webLikedSongs.clear();
        _webLikedSongs.addAll(list.map((m) => Song.fromMap(m)));
      }

      final historyStr = _prefs?.getString('web_history');
      if (historyStr != null) {
        final List list = json.decode(historyStr);
        _webHistory.clear();
        _webHistory.addAll(list.map((m) => Song.fromMap(m)));
      }
    } catch (_) {}
  }

  void _saveWebLiked() {
    _prefs?.setString('web_liked_songs', json.encode(_webLikedSongs.map((s) => s.toMap()).toList()));
  }

  void _saveWebHistory() {
    _prefs?.setString('web_history', json.encode(_webHistory.map((s) => s.toMap()).toList()));
  }

  Database get db {
    if (_db == null) {
      throw Exception('Database not initialized. Call init() first.');
    }
    return _db!;
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // --- LIKED SONGS ---
  Future<List<Song>> getLikedSongs() async {
    if (kIsWeb || _db == null) {
      return List.from(_webLikedSongs);
    }
    final results = await db.query('liked_songs', orderBy: 'date_added DESC');
    return results.map((row) => Song.fromMap(row)).toList();
  }

  Future<bool> isSongLiked(String id) async {
    if (kIsWeb || _db == null) {
      return _webLikedSongs.any((s) => s.id == id);
    }
    final results = await db.query('liked_songs', where: 'id = ?', whereArgs: [id], limit: 1);
    return results.isNotEmpty;
  }

  Future<void> toggleLikedSong(Song song) async {
    if (kIsWeb || _db == null) {
      final exists = _webLikedSongs.any((s) => s.id == song.id);
      if (exists) {
        _webLikedSongs.removeWhere((s) => s.id == song.id);
      } else {
        _webLikedSongs.insert(0, song);
      }
      _saveWebLiked();
      return;
    }

    final isLiked = await isSongLiked(song.id);
    if (isLiked) {
      await db.delete('liked_songs', where: 'id = ?', whereArgs: [song.id]);
    } else {
      await db.insert(
        'liked_songs',
        song.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // --- PLAYLISTS ---
  Future<List<Playlist>> getCustomPlaylists() async {
    if (kIsWeb || _db == null) {
      return List.from(_webPlaylists);
    }
    final rows = await db.query('custom_playlists', orderBy: 'date_created DESC');
    final playlists = <Playlist>[];
    for (final row in rows) {
      final pId = row['id'] as String;
      final songRows = await db.query('playlist_songs',
          where: 'playlist_id = ?', whereArgs: [pId], orderBy: 'date_added ASC');
      final songs = songRows.map((sRow) => Song.fromMap(sRow)).toList();
      playlists.add(Playlist.fromMap(row, songs: songs));
    }
    return playlists;
  }

  Future<Playlist> createPlaylist(String title, {String? description, String? artworkUrl}) async {
    final id = 'pl_${DateTime.now().millisecondsSinceEpoch}';
    final playlist = Playlist(
      id: id,
      title: title,
      description: description ?? 'Created by You',
      artworkUrl: artworkUrl ?? '',
      isCustom: true,
      dateCreated: DateTime.now(),
    );

    if (kIsWeb || _db == null) {
      _webPlaylists.insert(0, playlist);
      return playlist;
    }

    await db.insert('custom_playlists', playlist.toMap());
    return playlist;
  }

  Future<void> deletePlaylist(String playlistId) async {
    if (kIsWeb || _db == null) {
      _webPlaylists.removeWhere((p) => p.id == playlistId);
      return;
    }
    await db.delete('playlist_songs', where: 'playlist_id = ?', whereArgs: [playlistId]);
    await db.delete('custom_playlists', where: 'id = ?', whereArgs: [playlistId]);
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    if (kIsWeb || _db == null) {
      final idx = _webPlaylists.indexWhere((p) => p.id == playlistId);
      if (idx != -1) {
        final p = _webPlaylists[idx];
        final updatedSongs = List<Song>.from(p.songs)..add(song);
        _webPlaylists[idx] = p.copyWith(songs: updatedSongs, songCount: updatedSongs.length);
      }
      return;
    }

    final map = song.toMap();
    map['playlist_id'] = playlistId;
    map['song_id'] = song.id;
    await db.insert('playlist_songs', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    if (kIsWeb || _db == null) {
      final idx = _webPlaylists.indexWhere((p) => p.id == playlistId);
      if (idx != -1) {
        final p = _webPlaylists[idx];
        final updatedSongs = p.songs.where((s) => s.id != songId).toList();
        _webPlaylists[idx] = p.copyWith(songs: updatedSongs, songCount: updatedSongs.length);
      }
      return;
    }

    await db.delete('playlist_songs',
        where: 'playlist_id = ? AND song_id = ?', whereArgs: [playlistId, songId]);
  }

  // --- HISTORY ---
  Future<List<Song>> getHistory({int limit = 50}) async {
    if (kIsWeb || _db == null) {
      return List.from(_webHistory);
    }
    final results = await db.query('history', orderBy: 'played_at DESC', limit: limit);
    return results.map((row) => Song.fromMap(row)).toList();
  }

  Future<void> addToHistory(Song song) async {
    if (kIsWeb || _db == null) {
      _webHistory.removeWhere((s) => s.id == song.id);
      _webHistory.insert(0, song);
      _saveWebHistory();
      return;
    }

    final map = song.toMap();
    map['played_at'] = DateTime.now().toIso8601String();
    await db.insert('history', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearHistory() async {
    if (kIsWeb || _db == null) {
      _webHistory.clear();
      _saveWebHistory();
      return;
    }
    await db.delete('history');
  }

  // --- DOWNLOADS ---
  Future<List<Song>> getDownloadedSongs() async {
    if (kIsWeb || _db == null) {
      return List.from(_webDownloads);
    }
    final rows = await db.query('downloads', orderBy: 'downloaded_at DESC');
    return rows.map((row) {
      return Song(
        id: row['id'] as String,
        title: row['title'] as String,
        artist: row['artist'] as String,
        album: row['album'] as String?,
        duration: Duration(seconds: row['duration_seconds'] as int? ?? 0),
        artworkUrl: row['artwork_url'] as String? ?? '',
        localFilePath: row['local_file_path'] as String?,
        isDownloaded: true,
      );
    }).toList();
  }

  Future<void> saveDownloadedSong(Song song, String localFilePath, int fileSizeBytes) async {
    if (kIsWeb || _db == null) {
      _webDownloads.add(song);
      return;
    }
    await db.insert('downloads', {
      'id': song.id,
      'title': song.title,
      'artist': song.artist,
      'album': song.album ?? '',
      'duration_seconds': song.duration.inSeconds,
      'artwork_url': song.artworkUrl,
      'local_file_path': localFilePath,
      'file_size_bytes': fileSizeBytes,
      'downloaded_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeDownloadedSong(String id) async {
    if (kIsWeb || _db == null) {
      _webDownloads.removeWhere((s) => s.id == id);
      return;
    }
    await db.delete('downloads', where: 'id = ?', whereArgs: [id]);
  }

  // --- USER PREFERENCES ---
  String get streamingQuality => prefs.getString('streaming_quality') ?? 'High (160/320 kbps)';
  Future<void> setStreamingQuality(String quality) => prefs.setString('streaming_quality', quality);

  String get downloadQuality => prefs.getString('download_quality') ?? 'High (320 kbps)';
  Future<void> setDownloadQuality(String quality) => prefs.setString('download_quality', quality);

  bool get autoRadioEnabled => prefs.getBool('auto_radio_enabled') ?? true;
  Future<void> setAutoRadioEnabled(bool value) => prefs.setBool('auto_radio_enabled', value);

  String get themeMode => prefs.getString('app_theme_mode') ?? 'AMOLED Black';
  Future<void> setThemeMode(String theme) => prefs.setString('app_theme_mode', theme);
}
