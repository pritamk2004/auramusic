import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/audio_handler.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final AudioPlayerService _audio = AudioPlayerService.instance;

  String _themeMode = 'AMOLED Black';
  String _streamingQuality = 'High (160/320 kbps)';
  String _downloadQuality = 'High (320 kbps)';
  bool _autoRadio = true;

  int? _sleepTimerMinutes;

  SettingsProvider() {
    _loadSettings();
  }

  String get themeMode => _themeMode;
  String get streamingQuality => _streamingQuality;
  String get downloadQuality => _downloadQuality;
  bool get autoRadio => _autoRadio;
  int? get sleepTimerMinutes => _sleepTimerMinutes;
  bool get hasActiveSleepTimer => _audio.hasSleepTimer;

  void _loadSettings() {
    _themeMode = _storage.themeMode;
    _streamingQuality = _storage.streamingQuality;
    _downloadQuality = _storage.downloadQuality;
    _autoRadio = _storage.autoRadioEnabled;
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _storage.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setStreamingQuality(String quality) async {
    _streamingQuality = quality;
    await _storage.setStreamingQuality(quality);
    notifyListeners();
  }

  Future<void> setDownloadQuality(String quality) async {
    _downloadQuality = quality;
    await _storage.setDownloadQuality(quality);
    notifyListeners();
  }

  Future<void> setAutoRadio(bool enabled) async {
    _autoRadio = enabled;
    await _storage.setAutoRadioEnabled(enabled);
    notifyListeners();
  }

  void setSleepTimer(int minutes) {
    _sleepTimerMinutes = minutes;
    _audio.setSleepTimer(Duration(minutes: minutes), onTimerEnd: () {
      _sleepTimerMinutes = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimerMinutes = null;
    _audio.cancelSleepTimer();
    notifyListeners();
  }
}
