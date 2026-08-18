import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';

class LibraryProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final DownloadService _downloader = DownloadService.instance;

  List<Song> _likedSongs = [];
  List<Playlist> _customPlaylists = [];
  List<Song> _downloadedSongs = [];
  List<Song> _history = [];
  bool _isLoading = false;

  final Set<String> _likedIds = {};

  LibraryProvider() {
    loadAll();
  }

  List<Song> get likedSongs => _likedSongs;
  List<Playlist> get customPlaylists => _customPlaylists;
  List<Song> get downloadedSongs => _downloadedSongs;
  List<Song> get history => _history;
  bool get isLoading => _isLoading;

  bool isSongLiked(String id) => _likedIds.contains(id);
  bool isSongDownloaded(String id) => _downloadedSongs.any((s) => s.id == id);
  bool isDownloading(String id) => _downloader.isDownloading(id);
  double getDownloadProgress(String id) => _downloader.getProgress(id);

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _likedSongs = await _storage.getLikedSongs();
      _likedIds.clear();
      _likedIds.addAll(_likedSongs.map((s) => s.id));

      _customPlaylists = await _storage.getCustomPlaylists();
      _downloadedSongs = await _storage.getDownloadedSongs();
      _history = await _storage.getHistory();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(Song song) async {
    await _storage.toggleLikedSong(song);
    if (_likedIds.contains(song.id)) {
      _likedIds.remove(song.id);
      _likedSongs.removeWhere((s) => s.id == song.id);
    } else {
      _likedIds.add(song.id);
      _likedSongs.insert(0, song);
    }
    notifyListeners();
  }

  Future<Playlist> createPlaylist(String title, {String? desc}) async {
    final pl = await _storage.createPlaylist(title, description: desc);
    _customPlaylists.insert(0, pl);
    notifyListeners();
    return pl;
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _storage.deletePlaylist(playlistId);
    _customPlaylists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    await _storage.addSongToPlaylist(playlistId, song);
    final idx = _customPlaylists.indexWhere((p) => p.id == playlistId);
    if (idx != -1) {
      final p = _customPlaylists[idx];
      final updatedSongs = List<Song>.from(p.songs)..add(song);
      _customPlaylists[idx] = p.copyWith(
        songs: updatedSongs,
        songCount: updatedSongs.length,
      );
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _storage.removeSongFromPlaylist(playlistId, songId);
    final idx = _customPlaylists.indexWhere((p) => p.id == playlistId);
    if (idx != -1) {
      final p = _customPlaylists[idx];
      final updatedSongs = p.songs.where((s) => s.id != songId).toList();
      _customPlaylists[idx] = p.copyWith(
        songs: updatedSongs,
        songCount: updatedSongs.length,
      );
      notifyListeners();
    }
  }

  Future<void> downloadSong(Song song) async {
    notifyListeners();
    final success = await _downloader.downloadSong(
      song,
      onProgress: (p) => notifyListeners(),
    );
    if (success) {
      _downloadedSongs = await _storage.getDownloadedSongs();
    }
    notifyListeners();
  }

  Future<void> deleteDownload(Song song) async {
    await _downloader.deleteDownload(song);
    _downloadedSongs.removeWhere((s) => s.id == song.id);
    notifyListeners();
  }

  Future<void> refreshHistory() async {
    _history = await _storage.getHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    _history.clear();
    notifyListeners();
  }
}
