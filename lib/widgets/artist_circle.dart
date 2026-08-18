import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artist.dart';

class ArtistCircle extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;
  final double radius;

  const ArtistCircle({
    super.key,
    required this.artist,
    required this.onTap,
    this.radius = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey[900],
              backgroundImage: CachedNetworkImageProvider(artist.artworkUrl),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: radius * 2 + 10,
              child: Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            if (artist.subscriberCount != null) ...[
              const SizedBox(height: 2),
              Text(
                artist.subscriberCount!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
