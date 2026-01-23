import '../../widgets/floating_chat_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bible_provider.dart';
import '../../services/bible_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';

import 'package:go_router/go_router.dart';

// Quick Link Button Widget (must be visible to all widgets)
class _QuickLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/bible'),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: Column(
          children: [
            const ChurchAppBar(
              title: 'Bible',
              showBackButton: true,
            ),
            Material(
              color: AppTheme.primaryColor,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Search'),
                  Tab(text: 'Favorites'),
                  Tab(text: 'Internet'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SearchTab(searchController: _searchController),
          _FavoritesTab(),
          _InternetSearchTab(),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      floatingActionButton: FloatingChatButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ChatScreen(role: 'Me'),
          );
        },
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  final TextEditingController searchController;

  const _SearchTab({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bibleProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ...removed quick search links grid...
              // Version Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bible Version',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<BibleVersion>(
                        isExpanded: true,
                        value: bibleProvider.selectedVersion,
                        onChanged: (BibleVersion? newVersion) {
                          if (newVersion != null) {
                            context
                                .read<BibleProvider>()
                                .setSelectedVersion(newVersion);
                          }
                        },
                        items: bibleProvider.availableVersions.map((version) {
                          return DropdownMenuItem<BibleVersion>(
                            value: version,
                            child: Text(
                                '${version.abbreviation} - ${version.fullName}'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText:
                      'Search the whole Bible (e.g., faith, love, John 3:16)',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.read<BibleProvider>().searchBible(
                          value,
                          version: bibleProvider.selectedVersion,
                        );
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (searchController.text.isNotEmpty) {
                    await context.read<BibleProvider>().searchBible(
                          searchController.text,
                          version: bibleProvider.selectedVersion,
                        );
                  }
                },
                child: const Text('Search Bible'),
              ),
              const SizedBox(height: 24),
              if (bibleProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (bibleProvider.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    bibleProvider.error!,
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                )
              else if (bibleProvider.searchResults.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bibleProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final verse = bibleProvider.searchResults[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          verse.referenceWithVersion,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          verse.text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            bibleProvider.isFavorite(verse)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppTheme.errorColor,
                          ),
                          onPressed: () {
                            context.read<BibleProvider>().toggleFavorite(verse);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Popular Verses',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _PopularVersesList(),
              const SizedBox(height: 24),
              // Quick Links Row (6 links, as on home page)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickLinkButton(
                    icon: Icons.favorite,
                    label: 'Devotion',
                    color: AppTheme.primaryColor,
                    onTap: () => context.pushNamed('devotion'),
                  ),
                  _QuickLinkButton(
                    icon: Icons.live_tv,
                    label: 'TV',
                    color: Color(0xFFE91E63),
                    onTap: () => context.pushNamed('watch'),
                  ),
                  _QuickLinkButton(
                    icon: Icons.calendar_today,
                    label: 'Events',
                    color: Color(0xFF9C27B0),
                    onTap: () => context.pushNamed('events'),
                  ),
                  _QuickLinkButton(
                    icon: Icons.volunteer_activism,
                    label: 'Give',
                    color: AppTheme.secondaryColor,
                    onTap: () => context.pushNamed('give'),
                  ),
                  _QuickLinkButton(
                    icon: Icons.groups,
                    label: 'About',
                    color: Color(0xFF00BCD4),
                    onTap: () => context.pushNamed('about'),
                  ),
                  _QuickLinkButton(
                    icon: Icons.menu_book,
                    label: 'Bible',
                    color: Color(0xFF4CAF50),
                    onTap: () => context.pushNamed('bible'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bibleProvider, _) {
        final favorites = bibleProvider.favoriteVerses;

        if (favorites.isEmpty) {
          return const Center(
            child: Text('No favorite verses yet. Add some!'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final verse = favorites[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(verse.reference),
                subtitle: Text(
                  verse.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: AppTheme.errorColor),
                  onPressed: () {
                    context.read<BibleProvider>().toggleFavorite(verse);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PopularVersesList extends StatelessWidget {
  final List<String> popularVerses = [
    'John 3:16',
    'Psalm 23:1',
    'Proverbs 3:5',
    'Romans 8:28',
    '1 John 4:7',
    'Jeremiah 29:11',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bibleProvider, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularVerses.map((verse) {
            return ActionChip(
              label: Text(verse),
              onPressed: () async {
                await context
                    .read<BibleProvider>()
                    .searchVerse(verse, version: bibleProvider.selectedVersion);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _InternetSearchTab extends StatefulWidget {
  const _InternetSearchTab();

  @override
  State<_InternetSearchTab> createState() => _InternetSearchTabState();
}

class _InternetSearchTabState extends State<_InternetSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, String>>> searchNlccBackend(String query) async {
    final url = Uri.parse('http://localhost:8000/search?query=${Uri.encodeComponent(query)}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, String>>.from(data['results']);
      }
    } catch (e) {
      // Optionally handle error
    }
    return [];
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final results = await searchNlccBackend(_searchController.text);

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'NLCC Search',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search the internet (e.g., faith, prayer, church history)...',
                    prefixIcon: const Icon(Icons.language),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_results.isEmpty && _searchController.text.isNotEmpty)
            const Expanded(
              child: Center(
                child: Text('No results found. Try a different search or broader keywords.'),
              ),
            )
          else if (_results.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.language,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Use NLCC Search to find Bible topics, Christian resources, commentaries, and more.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        result['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(result['snippet'] ?? ''),
                          if (result['url']?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 4),
                            Text(
                              result['url']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        if (result['url'] != null) {
                          // Open the result in a new tab or browser
                          // (You may want to use url_launcher for mobile)
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
