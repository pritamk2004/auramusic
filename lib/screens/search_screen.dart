import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/explore_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> genreBrowseCategories = [
    {'title': 'Pop', 'color': Color(0xFFE91E63), 'query': 'top pop music hits'},
    {'title': 'Hip-Hop / Rap', 'color': Color(0xFFE65100), 'query': 'hip hop top hits rap'},
    {'title': 'Bollywood & Desi', 'color': Color(0xFF9C27B0), 'query': 'top bollywood hits latest'},
    {'title': 'Lo-Fi Chill', 'color': Color(0xFF3F51B5), 'query': 'lofi hip hop chill beats'},
    {'title': 'Rock & Metal', 'color': Color(0xFFD32F2F), 'query': 'classic rock metal hits'},
    {'title': 'Electronic / EDM', 'color': Color(0xFF00ACC1), 'query': 'edm dance electronic music'},
    {'title': 'R&B / Soul', 'color': Color(0xFF43A047), 'query': 'r&b soul smooth music'},
    {'title': 'Anime & OST', 'color': Color(0xFFFFB300), 'query': 'popular anime ost songs'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<ExploreProvider>().search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final explore = context.watch<ExploreProvider>();
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (val) => _performSearch(val),
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists, albums...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              explore.clearSearch();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
            ),

            // Search Content
            Expanded(
              child: explore.isSearching
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF1DB954)),
                          SizedBox(height: 16),
                          Text('Searching ad-free audio catalog...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : explore.searchResults.isNotEmpty
                      ? _buildSearchResults(explore, player)
                      : _buildBrowseAndHistory(explore),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(ExploreProvider explore, PlayerProvider player) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: explore.searchResults.length,
      itemBuilder: (context, i) {
        final song = explore.searchResults[i];
        return SongTile(
          song: song,
          index: i + 1,
          onTap: () {
            player.playSong(song, queue: explore.searchResults, initialIndex: i);
          },
        );
      },
    );
  }

  Widget _buildBrowseAndHistory(ExploreProvider explore) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (explore.recentSearches.isNotEmpty) ...[
            const Text(
              'Recent Searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: explore.recentSearches.map((item) {
                return InputChip(
                  label: Text(item, style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFF222222),
                  onPressed: () {
                    _searchController.text = item;
                    _performSearch(item);
                  },
                  onDeleted: () => explore.removeRecentSearch(item),
                  deleteIconColor: Colors.grey[400],
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Browse All Genres Grid
          const Text(
            'Explore Genres & Moods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: genreBrowseCategories.length,
            itemBuilder: (context, i) {
              final cat = genreBrowseCategories[i];
              return GestureDetector(
                onTap: () {
                  _searchController.text = cat['title'] as String;
                  _performSearch(cat['query'] as String);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (cat['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      cat['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
