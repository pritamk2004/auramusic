import 'dart:async';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../models/lyrics.dart';
import '../services/audio_handler.dart';
import '../services/lyrics_service.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService.instance;
  final LyricsService _lyricsService = LyricsService.instance;

  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = -1;

  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;

  Color _dominantColor = const Color(0xFF1DB954);
  Color _secondaryColor = const Color(0xFF121212);

  SyncedLyrics? _lyrics;
  int _activeLyricIndex = -1;
  bool _isLoadingLyrics = false;

  double _playbackSpeed = 1.0;

  // Subscriptions
  StreamSubscription? _playingSub;
  StreamSubscription? _bufferingSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _songSub;
  StreamSubscription? _queueSub;

  PlayerProvider() {
    _initListeners();
  }

  // Getters
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get bufferedPosition => _bufferedPosition;
  Color get dominantColor => _dominantColor;
  Color get secondaryColor => _secondaryColor;
  SyncedLyrics? get lyrics => _lyrics;
  int get activeLyricIndex => _activeLyricIndex;
  bool get isLoadingLyrics => _isLoadingLyrics;
  bool get isShuffle => _audioService.isShuffleEnabled;
  PlayerRepeatMode get repeatMode => _audioService.repeatMode;
  double get playbackSpeed => _playbackSpeed;

  void _initListeners() {
    _playingSub = _audioService.isPlayingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _bufferingSub = _audioService.isBufferingStream.listen((buffering) {
      _isBuffering = buffering;
      notifyListeners();
    });

    _positionSub = _audioService.positionStream.listen((pos) {
      _position = pos;
      _updateActiveLyric(pos);
      notifyListeners();
    });

    _durationSub = _audioService.durationStream.listen((dur) {
      _duration = dur;
      _bufferedPosition = dur;
      notifyListeners();
    });

    _songSub = _audioService.currentSongStream.listen((song) {
      if (song != null && (_currentSong == null || _currentSong!.id != song.id)) {
        _currentSong = song;
        _currentIndex = _audioService.currentIndex;
        _extractColorPalette(song.artworkUrl);
        _loadLyrics(song);
        notifyListeners();
      }
    });

    _queueSub = _audioService.queueStream.listen((q) {
      _queue = List.from(q);
      _currentIndex = _audioService.currentIndex;
      notifyListeners();
    });
  }

  Future<void> playSong(Song song, {List<Song>? queue, int initialIndex = 0}) async {
    _currentSong = song;
    _position = Duration.zero;
    _duration = song.duration;
    _extractColorPalette(song.artworkUrl);
    _loadLyrics(song);
    notifyListeners();

    await _audioService.playSong(song, queue: queue, initialIndex: initialIndex);
    _queue = List.from(_audioService.queue);
    _currentIndex = _audioService.currentIndex;
    notifyListeners();
  }

  Future<void> togglePlayPause() => _audioService.togglePlayPause();
  Future<void> seek(Duration pos) => _audioService.seek(pos);
  Future<void> skipToNext() => _audioService.skipToNext();
  Future<void> skipToPrevious() => _audioService.skipToPrevious();
  Future<void> playQueueIndex(int index) => _audioService.playQueueIndex(index);

  void addToQueue(Song song) {
    _audioService.addToQueue(song);
    _queue = List.from(_audioService.queue);
    notifyListeners();
  }

  void playNextInQueue(Song song) {
    _audioService.playNextInQueue(song);
    _queue = List.from(_audioService.queue);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    _audioService.removeFromQueue(index);
    _queue = List.from(_audioService.queue);
    _currentIndex = _audioService.currentIndex;
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _audioService.reorderQueue(oldIndex, newIndex);
    _queue = List.from(_audioService.queue);
    _currentIndex = _audioService.currentIndex;
    notifyListeners();
  }

  void toggleShuffle() {
    _audioService.toggleShuffle();
    _queue = List.from(_audioService.queue);
    _currentIndex = _audioService.currentIndex;
    notifyListeners();
  }

  void toggleRepeatMode() {
    _audioService.toggleRepeatMode();
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _audioService.setSpeed(speed);
    notifyListeners();
  }

  Future<void> _extractColorPalette(String artworkUrl) async {
    if (artworkUrl.isEmpty) {
      _dominantColor = const Color(0xFF1DB954);
      _secondaryColor = const Color(0xFF121212);
      notifyListeners();
      return;
    }

    try {
      final imageProvider = CachedNetworkImageProvider(artworkUrl);
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(200, 200),
        maximumColorCount: 8,
      );

      _dominantColor = palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          const Color(0xFF1DB954);
      _secondaryColor = palette.darkVibrantColor?.color ??
          palette.darkMutedColor?.color ??
          const Color(0xFF121212);

      notifyListeners();
    } catch (_) {
      _dominantColor = const Color(0xFF1DB954);
      _secondaryColor = const Color(0xFF121212);
      notifyListeners();
    }
  }

  Future<void> _loadLyrics(Song song) async {
    _isLoadingLyrics = true;
    _lyrics = null;
    _activeLyricIndex = -1;
    notifyListeners();

    try {
      final l = await _lyricsService.getLyrics(song);
      _lyrics = l;
    } catch (_) {
      _lyrics = SyncedLyrics.plain('Lyrics not available for this track.', track: song.title, artist: song.artist);
    } finally {
      _isLoadingLyrics = false;
      notifyListeners();
    }
  }

  void _updateActiveLyric(Duration currentPosition) {
    if (_lyrics == null || !_lyrics!.isSynced || _lyrics!.lines.isEmpty) return;

    final index = _lyrics!.getActiveIndex(currentPosition);
    if (index != _activeLyricIndex) {
      _activeLyricIndex = index;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _songSub?.cancel();
    _queueSub?.cancel();
    super.dispose();
  }
}
