import '../../widgets/floating_chat_button.dart';
import '../chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bible_provider.dart';
import '../../services/bible_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/church_app_bar.dart';

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
                            context.read<BibleProvider>().setSelectedVersion(newVersion);
                          }
                        },
                        items: bibleProvider.availableVersions.map((version) {
                          return DropdownMenuItem<BibleVersion>(
                            value: version,
                            child: Text('${version.abbreviation} - ${version.fullName}'),
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
                  hintText: 'Search (e.g., John 3:16)',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.read<BibleProvider>().searchVerse(value, version: bibleProvider.selectedVersion);
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (searchController.text.isNotEmpty) {
                    await context
                        .read<BibleProvider>()
                        .searchVerse(searchController.text,
                            version: bibleProvider.selectedVersion);
                  }
                },
                child: const Text('Search Verse'),
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
              else if (bibleProvider.currentVerse != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bibleProvider.currentVerse!.reference,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bibleProvider.currentVerse!.version.abbreviation,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                bibleProvider.isFavorite(
                                  bibleProvider.currentVerse!,
                                )
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: AppTheme.errorColor,
                              ),
                              onPressed: () {
                                context
                                    .read<BibleProvider>()
                                    .toggleFavorite(bibleProvider.currentVerse!);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bibleProvider.currentVerse!.text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Popular Verses',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _PopularVersesList(),
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

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    final results = await BibleService().searchInternet(_searchController.text);
    
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
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Bible topics on the internet...',
              prefixIcon: const Icon(Icons.language),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _performSearch,
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_results.isEmpty && _searchController.text.isNotEmpty)
            const Expanded(
              child: Center(
                child: Text('No results found. Try a different search.'),
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
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for Bible topics, studies,\ncommentaries, and more',
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