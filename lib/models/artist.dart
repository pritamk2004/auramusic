import 'song.dart';
import 'playlist.dart';

class Artist {
  final String id;
  final String name;
  final String artworkUrl;
  final String? subscriberCount;
  final List<Song> topSongs;
  final List<Playlist> albums;

  const Artist({
    required this.id,
    required this.name,
    required this.artworkUrl,
    this.subscriberCount,
    this.topSongs = const [],
    this.albums = const [],
  });

  Artist copyWith({
    String? id,
    String? name,
    String? artworkUrl,
    String? subscriberCount,
    List<Song>? topSongs,
    List<Playlist>? albums,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      topSongs: topSongs ?? this.topSongs,
      albums: albums ?? this.albums,
    );
  }
}
