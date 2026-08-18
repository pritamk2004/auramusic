import 'song.dart';

class Playlist {
  final String id;
  final String title;
  final String? description;
  final String artworkUrl;
  final String author;
  final int songCount;
  final List<Song> songs;
  final bool isCustom;
  final DateTime? dateCreated;

  const Playlist({
    required this.id,
    required this.title,
    this.description,
    required this.artworkUrl,
    this.author = 'AuraMusic',
    this.songCount = 0,
    this.songs = const [],
    this.isCustom = false,
    this.dateCreated,
  });

  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    String? artworkUrl,
    String? author,
    int? songCount,
    List<Song>? songs,
    bool? isCustom,
    DateTime? dateCreated,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      author: author ?? this.author,
      songCount: songCount ?? this.songCount,
      songs: songs ?? this.songs,
      isCustom: isCustom ?? this.isCustom,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description ?? '',
      'artwork_url': artworkUrl,
      'author': author,
      'is_custom': isCustom ? 1 : 0,
      'date_created': (dateCreated ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map, {List<Song> songs = const []}) {
    return Playlist(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled Playlist',
      description: map['description'],
      artworkUrl: map['artwork_url'] ?? '',
      author: map['author'] ?? 'User',
      songCount: songs.isNotEmpty ? songs.length : (map['song_count'] ?? 0),
      songs: songs,
      isCustom: (map['is_custom'] ?? 0) == 1,
      dateCreated: map['date_created'] != null
          ? DateTime.tryParse(map['date_created'])
          : null,
    );
  }
}
