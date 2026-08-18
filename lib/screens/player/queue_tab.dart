import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/player_provider.dart';
import '../../providers/settings_provider.dart';

class QueueTab extends StatelessWidget {
  const QueueTab({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final settings = context.watch<SettingsProvider>();
    final queue = player.queue;
    final currentIndex = player.currentIndex;

    return Column(
      children: [
        // Auto-Radio Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.radio, color: Color(0xFF1DB954)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Infinite Auto-Radio',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Keep playing related music automatically',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.autoRadio,
                activeColor: const Color(0xFF1DB954),
                onChanged: (val) => settings.setAutoRadio(val),
              ),
            ],
          ),
        ),

        // Queue List
        Expanded(
          child: queue.isEmpty
              ? const Center(
                  child: Text('Queue is empty', style: TextStyle(color: Colors.grey)),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: queue.length,
                  onReorder: (oldIndex, newIndex) {
                    player.reorderQueue(oldIndex, newIndex);
                  },
                  itemBuilder: (context, i) {
                    final song = queue[i];
                    final isCurrent = i == currentIndex;

                    return Dismissible(
                      key: ValueKey('${song.id}_$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.withOpacity(0.8),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => player.removeFromQueue(i),
                      child: Container(
                        key: ValueKey('tile_${song.id}_$i'),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrent ? Colors.white.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: song.artworkUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                                if (isCurrent)
                                  Container(
                                    width: 44,
                                    height: 44,
                                    color: Colors.black.withOpacity(0.5),
                                    child: const Icon(Icons.equalizer, color: Color(0xFF1DB954), size: 20),
                                  ),
                              ],
                            ),
                          ),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent ? const Color(0xFF1DB954) : Colors.white,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          trailing: const ReorderableDragStartListener(
                            index: 0, // Handled automatically by ReorderableListView
                            child: Icon(Icons.drag_handle, color: Colors.white54),
                          ),
                          onTap: () => player.playQueueIndex(i),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
