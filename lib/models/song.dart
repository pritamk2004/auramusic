class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final Duration duration;
  final String artworkUrl;
  final String? audioUrl; // Can be direct stream or empty if needs resolving
  final String source; // 'youtube', 'jiosaavn', 'local'
  final bool isDownloaded;
  final String? localFilePath;
  final DateTime? dateAdded;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.duration = Duration.zero,
    required this.artworkUrl,
    this.audioUrl,
    this.source = 'youtube',
    this.isDownloaded = false,
    this.localFilePath,
    this.dateAdded,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? artworkUrl,
    String? audioUrl,
    String? source,
    bool? isDownloaded,
    String? localFilePath,
    DateTime? dateAdded,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      source: source ?? this.source,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localFilePath: localFilePath ?? this.localFilePath,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album ?? '',
      'duration_seconds': duration.inSeconds,
      'artwork_url': artworkUrl,
      'audio_url': audioUrl ?? '',
      'source': source,
      'is_downloaded': isDownloaded ? 1 : 0,
      'local_file_path': localFilePath ?? '',
      'date_added': (dateAdded ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] != null && map['album'].toString().isNotEmpty
          ? map['album']
          : null,
      duration: Duration(seconds: map['duration_seconds'] ?? 0),
      artworkUrl: map['artwork_url'] ?? '',
      audioUrl: map['audio_url'] != null && map['audio_url'].toString().isNotEmpty
          ? map['audio_url']
          : null,
      source: map['source'] ?? 'youtube',
      isDownloaded: (map['is_downloaded'] ?? 0) == 1,
      localFilePath: map['local_file_path'] != null &&
              map['local_file_path'].toString().isNotEmpty
          ? map['local_file_path']
          : null,
      dateAdded: map['date_added'] != null
          ? DateTime.tryParse(map['date_added'])
          : null,
    );
  }

  String get durationString {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
