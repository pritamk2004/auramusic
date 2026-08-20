import 'dart:async';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import 'music_service.dart';
import 'storage_service.dart';

enum PlayerRepeatMode { off, all, one }

class AudioPlayerService {
  static final AudioPlayerService instance = AudioPlayerService._internal();
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  final List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffleEnabled = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.off;
  Timer? _sleepTimer;
  Duration? _sleepDurationLeft;
  double _volume = 1.0;

  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;

  // Streams & Controllers
  final _songChangeController = StreamController<Song?>.broadcast();
  Stream<Song?> get currentSongStream => _songChangeController.stream;

  final _queueChangeController = StreamController<List<Song>>.broadcast();
  Stream<List<Song>> get queueStream => _queueChangeController.stream;

  final _playbackStateController = StreamController<bool>.broadcast();
  Stream<bool> get isPlayingStream => _playbackStateController.stream;

  final _bufferingController = StreamController<bool>.broadcast();
  Stream<bool> get isBufferingStream => _bufferingController.stream;

  final _positionController = StreamController<Duration>.broadcast();
  Stream<Duration> get positionStream => _positionController.stream;

  final _durationController = StreamController<Duration>.broadcast();
  Stream<Duration> get durationStream => _durationController.stream;

  AudioPlayer get player => _player;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _queue.length) ? _queue[_currentIndex] : null;
  bool get isShuffleEnabled => _isShuffleEnabled;
  PlayerRepeatMode get repeatMode => _repeatMode;
  bool get hasSleepTimer => _sleepTimer != null && _sleepTimer!.isActive;
  Duration? get sleepDurationLeft => _sleepDurationLeft;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get bufferedPosition => _bufferedPosition;

  Future<void> init() async {
    // Listen to player state stream
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;
      _playbackStateController.add(_isPlaying);
      _bufferingController.add(_isBuffering);

      if (state.processingState == ProcessingState.completed) {
        if (_position > const Duration(seconds: 2) &&
            _duration > const Duration(seconds: 2) &&
            _position >= _duration - const Duration(seconds: 3)) {
          _handleSongCompletion();
        }
      }
    });

    // Position Stream
    _player.positionStream.listen((pos) {
      _position = pos;
      _positionController.add(pos);
    });

    // Duration Stream
    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        _durationController.add(dur);
      }
    });

    // Buffered Position Stream
    _player.bufferedPositionStream.listen((buf) {
      _bufferedPosition = buf;
    });

    // Volume Stream
    _player.volumeStream.listen((vol) {
      _volume = vol;
    });
  }

  /// Play a song with a new queue
  Future<void> playSong(Song song, {List<Song>? queue, int initialIndex = 0}) async {
    if (queue != null && queue.isNotEmpty) {
      _queue.clear();
      _queue.addAll(queue);
      _currentIndex = initialIndex.clamp(0, _queue.length - 1);
    } else {
      _queue.clear();
      _queue.add(song);
      _currentIndex = 0;
    }
    _queueChangeController.add(_queue);

    await _loadAndPlayCurrent();
  }

  /// Load and start playback for current song in queue
  Future<void> _loadAndPlayCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;

    final song = _queue[_currentIndex];
    _songChangeController.add(song);
    _isBuffering = true;
    _bufferingController.add(true);

    // Save to listening history
    StorageService.instance.addToHistory(song);

    try {
      if (!kIsWeb && song.isDownloaded && song.localFilePath != null && File(song.localFilePath!).existsSync()) {
        await _player.setFilePath(song.localFilePath!);
      } else {
        String streamUrl = '';
        if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
          streamUrl = song.audioUrl!;
        } else {
          streamUrl = await MusicService.instance.getAudioStreamUrl(
            song,
            quality: StorageService.instance.streamingQuality,
          );
        }

        if (streamUrl.isEmpty) {
          throw Exception('Unable to obtain audio stream URL');
        }

        debugPrint('Playing stream URL: $streamUrl');

        await _player.setUrl(
          streamUrl,
          headers: const {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
            'Accept': '*/*',
          },
        );
      }

      await _player.play();
      _isBuffering = false;
      _bufferingController.add(false);
    } catch (e) {
      debugPrint('Error playing audio stream: $e');
      _isBuffering = false;
      _bufferingController.add(false);
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;

    if (_repeatMode == PlayerRepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _loadAndPlayCurrent();
    } else if (_repeatMode == PlayerRepeatMode.all) {
      _currentIndex = 0;
      await _loadAndPlayCurrent();
    } else if (StorageService.instance.autoRadioEnabled && currentSong != null) {
      await _fetchRadioAndContinue();
    }
  }

  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 4) {
      await _player.seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
      await _loadAndPlayCurrent();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> playQueueIndex(int index) async {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      await _loadAndPlayCurrent();
    }
  }

  void addToQueue(Song song) {
    _queue.add(song);
    _queueChangeController.add(_queue);
  }

  void playNextInQueue(Song song) {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      _queue.insert(_currentIndex + 1, song);
    } else {
      _queue.add(song);
    }
    _queueChangeController.add(_queue);
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex && _queue.isNotEmpty) {
      _currentIndex = _currentIndex.clamp(0, _queue.length - 1);
      _loadAndPlayCurrent();
    }
    _queueChangeController.add(_queue);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }

    _queueChangeController.add(_queue);
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    if (_isShuffleEnabled && _queue.isNotEmpty && _currentIndex >= 0) {
      final current = _queue[_currentIndex];
      final others = _queue.where((s) => s.id != current.id).toList()..shuffle();
      _queue.clear();
      _queue.add(current);
      _queue.addAll(others);
      _currentIndex = 0;
      _queueChangeController.add(_queue);
    }
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case PlayerRepeatMode.off:
        _repeatMode = PlayerRepeatMode.all;
        _player.setLoopMode(LoopMode.all);
        break;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
        _player.setLoopMode(LoopMode.one);
        break;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.off;
        _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  void setSleepTimer(Duration duration, {VoidCallback? onTimerEnd}) {
    cancelSleepTimer();
    _sleepDurationLeft = duration;
    _sleepTimer = Timer(duration, () async {
      await pause();
      _sleepDurationLeft = null;
      _sleepTimer = null;
      onTimerEnd?.call();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepDurationLeft = null;
  }

  Future<void> _handleSongCompletion() async {
    if (_repeatMode == PlayerRepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    if (_currentIndex < _queue.length - 1) {
      skipToNext();
    } else if (_repeatMode == PlayerRepeatMode.all) {
      _currentIndex = 0;
      _loadAndPlayCurrent();
    } else if (StorageService.instance.autoRadioEnabled && currentSong != null) {
      await _fetchRadioAndContinue();
    }
  }

  Future<void> _fetchRadioAndContinue() async {
    if (currentSong == null) return;
    try {
      final related = await MusicService.instance.getRelatedSongs(currentSong!);
      if (related.isNotEmpty) {
        final existingIds = _queue.map((s) => s.id).toSet();
        final newSongs = related.where((s) => !existingIds.contains(s.id)).toList();
        if (newSongs.isNotEmpty) {
          _queue.addAll(newSongs);
          _queueChangeController.add(_queue);
          _currentIndex++;
          await _loadAndPlayCurrent();
        }
      }
    } catch (_) {}
  }

  void dispose() {
    _sleepTimer?.cancel();
    _songChangeController.close();
    _queueChangeController.close();
    _playbackStateController.close();
    _bufferingController.close();
    _positionController.close();
    _durationController.close();
    _player.dispose();
  }
}
