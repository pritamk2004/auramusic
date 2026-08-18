import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/song.dart';
import 'music_service.dart';
import 'storage_service.dart';

class DownloadService {
  static final DownloadService instance = DownloadService._internal();
  DownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, double> _downloadProgress = {};
  final Map<String, CancelToken> _cancelTokens = {};

  double getProgress(String songId) => _downloadProgress[songId] ?? 0.0;
  bool isDownloading(String songId) => _downloadProgress.containsKey(songId);

  /// Download a song for offline playback
  Future<bool> downloadSong(
    Song song, {
    Function(double progress)? onProgress,
  }) async {
    if (isDownloading(song.id)) return false;

    try {
      _downloadProgress[song.id] = 0.01;
      final cancelToken = CancelToken();
      _cancelTokens[song.id] = cancelToken;

      // 1. Get audio stream URL
      final streamUrl = await MusicService.instance.getAudioStreamUrl(song);

      // 2. Prepare local destination directory
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(p.join(appDir.path, 'downloads'));
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Safe filename
      final safeTitle = song.title.replaceAll(RegExp(r'[^\w\s\.-]'), '_');
      final filePath = p.join(downloadsDir.path, '${song.id}_$safeTitle.m4a');

      // 3. Start download
      await _dio.download(
        streamUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            _downloadProgress[song.id] = progress;
            onProgress?.call(progress);
          }
        },
      );

      final file = File(filePath);
      final fileSize = await file.length();

      // 4. Save metadata to DB
      await StorageService.instance.saveDownloadedSong(song, filePath, fileSize);

      _downloadProgress.remove(song.id);
      _cancelTokens.remove(song.id);
      return true;
    } catch (e) {
      _downloadProgress.remove(song.id);
      _cancelTokens.remove(song.id);
      return false;
    }
  }

  /// Delete a downloaded song from storage
  Future<void> deleteDownload(Song song) async {
    try {
      if (song.localFilePath != null) {
        final file = File(song.localFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await StorageService.instance.removeDownloadedSong(song.id);
    } catch (_) {}
  }

  /// Cancel ongoing download
  void cancelDownload(String songId) {
    if (_cancelTokens.containsKey(songId)) {
      _cancelTokens[songId]?.cancel();
      _cancelTokens.remove(songId);
      _downloadProgress.remove(songId);
    }
  }
}
