class LyricLine {
  final Duration timestamp;
  final String text;

  const LyricLine({
    required this.timestamp,
    required this.text,
  });

  @override
  String toString() => '${timestamp.inMilliseconds}ms: $text';
}

class SyncedLyrics {
  final String trackName;
  final String artistName;
  final bool isSynced;
  final List<LyricLine> lines;
  final String? plainLyrics;

  const SyncedLyrics({
    required this.trackName,
    required this.artistName,
    required this.isSynced,
    required this.lines,
    this.plainLyrics,
  });

  factory SyncedLyrics.fromLrc(String lrcText, {required String track, required String artist}) {
    final lines = <LyricLine>[];
    final regExp = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final line in lrcText.split('\n')) {
      final match = regExp.firstMatch(line.trim());
      if (match != null) {
        final minutes = int.tryParse(match.group(1)!) ?? 0;
        final seconds = int.tryParse(match.group(2)!) ?? 0;
        final fractionStr = match.group(3)!;
        final milliseconds = fractionStr.length == 2
            ? (int.tryParse(fractionStr) ?? 0) * 10
            : int.tryParse(fractionStr) ?? 0;

        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        final text = match.group(4)?.trim() ?? '';
        if (text.isNotEmpty) {
          lines.add(LyricLine(timestamp: duration, text: text));
        }
      }
    }

    // Sort by timestamp
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return SyncedLyrics(
      trackName: track,
      artistName: artist,
      isSynced: lines.isNotEmpty,
      lines: lines,
      plainLyrics: lines.isEmpty ? lrcText : null,
    );
  }

  factory SyncedLyrics.plain(String text, {required String track, required String artist}) {
    return SyncedLyrics(
      trackName: track,
      artistName: artist,
      isSynced: false,
      lines: const [],
      plainLyrics: text,
    );
  }

  static const SyncedLyrics empty = SyncedLyrics(
    trackName: '',
    artistName: '',
    isSynced: false,
    lines: [],
  );

  int getActiveIndex(Duration currentPosition) {
    if (lines.isEmpty) return -1;
    for (int i = lines.length - 1; i >= 0; i--) {
      if (currentPosition >= lines[i].timestamp) {
        return i;
      }
    }
    return 0;
  }
}
