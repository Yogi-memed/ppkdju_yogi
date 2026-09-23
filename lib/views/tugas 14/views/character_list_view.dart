import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/views/tugas%2014/views/reusable/app_theme.dart';

import '../models/character_model.dart';
import '../services/rick_morty_client.dart';
import '../services/rick_morty_service.dart';
import '../reusable/app_theme.dart';
import 'character_detail_view.dart';

class CharacterListView extends StatefulWidget {
  const CharacterListView({super.key});

  @override
  State<CharacterListView> createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  late final RickMortyService service;

  late Future<List<CharacterModel>> charactersFuture;

  final TextEditingController searchController = TextEditingController();

  final Set<int> favoriteIds = {};

  String searchKeyword = '';

  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();

    final dio = createRickMortyClient();

    service = RickMortyService(dio);

    charactersFuture = service.fetchData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleFavorite(CharacterModel character) {
    final id = character.id;

    if (id == null) return;

    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });
  }

  bool isFavorite(CharacterModel character) {
    final id = character.id;

    if (id == null) return false;

    return favoriteIds.contains(id);
  }

  void searchCharacters() {
    final keyword = searchController.text.trim();

    setState(() {
      searchKeyword = keyword;

      charactersFuture = service.fetchData(
        name: keyword.isEmpty ? null : keyword,
      );
    });
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      searchKeyword = '';
      charactersFuture = service.fetchData();
    });
  }

  void toggleFavoritesFilter() {
    setState(() {
      showFavoritesOnly = !showFavoritesOnly;
    });
  }

  Future<void> refreshCharacters() async {
    setState(() {
      charactersFuture = service.fetchData(
        name: searchKeyword.isEmpty ? null : searchKeyword,
      );
    });

    await charactersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Column(
          children: [
            Text(
              'Rick & Morty',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            Text(
              'Explore the characters',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: toggleFavoritesFilter,
            tooltip: 'Favorite',
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: showFavoritesOnly ? Colors.redAccent : Colors.white,
            ),
          ),
          IconButton(
            onPressed: refreshCharacters,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildSummarySection(),
          const SizedBox(height: 8),
          Expanded(child: _buildCharacterList()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => searchCharacters(),
            onChanged: (_) {
              setState(() {});
            },
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari nama karakter...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: clearSearch,
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: searchCharacters,
              icon: const Icon(Icons.search),
              label: const Text(
                'Cari Karakter',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            showFavoritesOnly ? 'Karakter Favorite' : 'Daftar Karakter',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 16, color: AppTheme.primary),
                const SizedBox(width: 5),
                Text(
                  '${favoriteIds.length}',
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterList() {
    return FutureBuilder<List<CharacterModel>>(
      future: charactersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final apiCharacters = snapshot.data ?? [];

        final characters = showFavoritesOnly
            ? apiCharacters.where((character) => isFavorite(character)).toList()
            : apiCharacters;

        if (characters.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: refreshCharacters,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];

              return _buildCharacterCard(character);
            },
          ),
        );
      },
    );
  }

  Widget _buildCharacterCard(CharacterModel character) {
    final favorite = isFavorite(character);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterDetailView(
                character: character,
                isFavorite: favorite,
                onFavoriteChanged: () {
                  toggleFavorite(character);
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCharacterImage(character),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            character.name ?? 'Unknown',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          onPressed: () {
                            toggleFavorite(character);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            color: favorite
                                ? Colors.red
                                : AppTheme.textSecondary,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(character.status),
                    const SizedBox(height: 8),
                    Text(
                      character.species ?? 'Unknown',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          'Lihat detail',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 11,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterImage(CharacterModel character) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        character.image ?? '',
        width: 112,
        height: 128,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 112,
            height: 128,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported,
              size: 35,
              color: AppTheme.textSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final currentStatus = status ?? 'Unknown';

    Color color;

    if (currentStatus.toLowerCase() == 'alive') {
      color = AppTheme.alive;
    } else if (currentStatus.toLowerCase() == 'dead') {
      color = AppTheme.dead;
    } else {
      color = AppTheme.unknown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            currentStatus,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 60,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal mengambil data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: refreshCharacters,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 60,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              showFavoritesOnly
                  ? 'Belum ada karakter favorite'
                  : 'Karakter tidak ditemukan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            if (showFavoritesOnly)
              ElevatedButton(
                onPressed: toggleFavoritesFilter,
                child: const Text('Tampilkan Semua'),
              ),
          ],
        ),
      ),
    );
  }
}
