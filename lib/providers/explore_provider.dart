import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/artist.dart';
import '../services/music_service.dart';

class ExploreProvider extends ChangeNotifier {
  final MusicService _musicService = MusicService.instance;

  List<Song> _trendingSongs = [];
  List<Playlist> _moodPlaylists = [];
  List<Artist> _topArtists = [];
  bool _isLoadingHome = false;

  // Search state
  String _searchQuery = '';
  List<Song> _searchResults = [];
  bool _isSearching = false;
  final List<String> _recentSearches = ['The Weeknd', 'Taylor Swift', 'Ed Sheeran', 'Lo-Fi Chill', 'Arijit Singh'];

  // Active playlist/album viewing
  Playlist? _selectedPlaylist;
  List<Song> _playlistTracks = [];
  bool _isLoadingPlaylist = false;

  // Active artist viewing
  Artist? _selectedArtist;
  bool _isLoadingArtist = false;

  ExploreProvider() {
    initHome();
  }

  // Getters
  List<Song> get trendingSongs => _trendingSongs;
  List<Playlist> get moodPlaylists => _moodPlaylists;
  List<Artist> get topArtists => _topArtists;
  bool get isLoadingHome => _isLoadingHome;

  String get searchQuery => _searchQuery;
  List<Song> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  List<String> get recentSearches => _recentSearches;

  Playlist? get selectedPlaylist => _selectedPlaylist;
  List<Song> get playlistTracks => _playlistTracks;
  bool get isLoadingPlaylist => _isLoadingPlaylist;

  Artist? get selectedArtist => _selectedArtist;
  bool get isLoadingArtist => _isLoadingArtist;

  Future<void> initHome() async {
    _isLoadingHome = true;
    notifyListeners();

    try {
      _moodPlaylists = _musicService.getMoodPlaylists();
      _topArtists = _musicService.getTopArtists();
      _trendingSongs = await _musicService.getTrendingSongs();
    } catch (_) {}

    _isLoadingHome = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _searchQuery = query;
    _isSearching = true;
    notifyListeners();

    if (!_recentSearches.contains(query.trim())) {
      _recentSearches.insert(0, query.trim());
      if (_recentSearches.length > 8) {
        _recentSearches.removeLast();
      }
    }

    try {
      _searchResults = await _musicService.search(query);
    } catch (e) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  void removeRecentSearch(String item) {
    _recentSearches.remove(item);
    notifyListeners();
  }

  Future<void> openPlaylist(Playlist playlist) async {
    _selectedPlaylist = playlist;
    _playlistTracks = playlist.songs;
    _isLoadingPlaylist = true;
    notifyListeners();

    try {
      if (_playlistTracks.isEmpty) {
        _playlistTracks = await _musicService.getPlaylistTracks(playlist.id);
      }
    } catch (_) {}

    _isLoadingPlaylist = false;
    notifyListeners();
  }

  Future<void> openArtist(Artist artist) async {
    _selectedArtist = artist;
    _isLoadingArtist = true;
    notifyListeners();

    try {
      final fullArtist = await _musicService.getArtistDetails(artist.name);
      _selectedArtist = fullArtist;
    } catch (_) {}

    _isLoadingArtist = false;
    notifyListeners();
  }
}
