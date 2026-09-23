import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/views/tugas%2014/views/reusable/app_theme.dart';

import '../models/character_model.dart';
import '../reusable/app_theme.dart';

class CharacterDetailView extends StatefulWidget {
  final CharacterModel character;

  final bool isFavorite;

  final VoidCallback onFavoriteChanged;

  const CharacterDetailView({
    super.key,
    required this.character,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<CharacterDetailView> createState() => _CharacterDetailViewState();
}

class _CharacterDetailViewState extends State<CharacterDetailView> {
  late bool favorite;

  @override
  void initState() {
    super.initState();

    favorite = widget.isFavorite;
  }

  void toggleFavorite() {
    widget.onFavoriteChanged();

    setState(() {
      favorite = !favorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Character Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: favorite ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderImage(character),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    character.name ?? 'Unknown',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(character.status),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: toggleFavorite,
                      icon: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      label: Text(
                        favorite ? 'Hapus dari Favorite' : 'Tambah ke Favorite',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: favorite
                            ? Colors.red
                            : AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Informasi Karakter'),
                  const SizedBox(height: 12),
                  _buildInfo(
                    icon: Icons.tag,
                    title: 'ID',
                    value: '${character.id ?? 'Unknown'}',
                  ),
                  _buildInfo(
                    icon: Icons.category,
                    title: 'Species',
                    value: character.species ?? 'Unknown',
                  ),
                  _buildInfo(
                    icon: Icons.person,
                    title: 'Gender',
                    value: character.gender ?? 'Unknown',
                  ),
                  _buildInfo(
                    icon: Icons.public,
                    title: 'Origin',
                    value: character.origin?.name ?? 'Unknown',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(CharacterModel character) {
    return SizedBox(
      width: double.infinity,
      height: 340,
      child: Image.network(
        character.image ?? '',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported,
              size: 65,
              color: AppTheme.textSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            currentStatus,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
