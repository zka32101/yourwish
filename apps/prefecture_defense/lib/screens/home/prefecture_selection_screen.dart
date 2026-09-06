import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefecture_defense/config/constants.dart';
import 'package:prefecture_defense/config/difficulty_config.dart';
import 'package:prefecture_defense/models/td_model.dart';
import 'package:prefecture_defense/providers/game_provider.dart';
import 'package:prefecture_defense/screens/game/game_screen.dart';
import 'package:prefecture_defense/utils/prefecture_data.dart';

class PrefectureSelectionScreen extends ConsumerStatefulWidget {
  const PrefectureSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PrefectureSelectionScreen> createState() =>
      _PrefectureSelectionScreenState();
}

class _PrefectureSelectionScreenState
    extends ConsumerState<PrefectureSelectionScreen> {
  String _searchQuery = '';
  String? _selectedRegion;

  List<PrefectureData> get _filteredPrefectures {
    var list = searchPrefectures(_searchQuery);
    if (_selectedRegion != null) {
      list = list.where((p) => p.region == _selectedRegion).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('都道府県を選択'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildRegionFilter(),
          Expanded(child: _buildPrefectureGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surface,
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: '県名で検索',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionFilter() {
    const regions = [
      ('', '全国'),
      ('hokkaido', '北海道'),
      ('tohoku', '東北'),
      ('kanto', '関東'),
      ('chubu', '中部'),
      ('kansai', '近畿'),
      ('chugoku', '中国'),
      ('shikoku', '四国'),
      ('kyushu', '九州'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      child: Row(
        children: regions.map((region) {
          final isSelected = _selectedRegion == region.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(region.$2),
              selected: isSelected,
              onSelected: (_) =>
                  setState(() => _selectedRegion = region.$1.isEmpty ? null : region.$1),
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrefectureGrid() {
    final prefs = _filteredPrefectures;
    final gameService = ref.read(gameServiceProvider);

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: prefs.length,
      itemBuilder: (context, idx) {
        final pref = prefs[idx];
        final isCleared = gameService.isPrefectureClearedAny(pref.code);
        final clearedDiffs = gameService.getClearedDifficulties(pref.code);

        return GestureDetector(
          onTap: () => _showDifficultyDialog(context, pref),
          child: Card(
            color: AppColors.surface,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pref.geographyIcon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  pref.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _diffStar('E', clearedDiffs.contains('easy')),
                    const SizedBox(width: 2),
                    _diffStar('N', clearedDiffs.contains('normal')),
                    const SizedBox(width: 2),
                    _diffStar('H', clearedDiffs.contains('hard')),
                  ],
                ),
                if (isCleared)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.check_circle, size: 14, color: Colors.green),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _diffStar(String label, bool cleared) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cleared ? Colors.amber : Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: cleared ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, PrefectureData pref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildDifficultySheet(context, pref),
    );
  }

  Widget _buildDifficultySheet(BuildContext context, PrefectureData pref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ボス情報
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                Text(
                  pref.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // ボスキャラ画像
                _buildBossImage(pref),
                const SizedBox(height: 12),
                Text(
                  'ボス: ${pref.boss.name}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 難度選択ボタン
          const Text(
            '難易度を選択',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),

          ..._buildDifficultyButtons(context, pref),
        ],
      ),
    );
  }

  List<Widget> _buildDifficultyButtons(BuildContext context, PrefectureData pref) {
    // 県ごとの選択可能難易度（暫定：全て可能）
    // TODO: 各県の難易度制限を設定可能にする
    final availableDifficulties = ['easy', 'normal', 'hard'];

    return availableDifficulties.map((difficulty) {
      final modifier = difficultyModifiers[difficulty]!;
      final isAvailable = availableDifficulties.contains(difficulty);

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable ? modifier.color : Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              disabledBackgroundColor: Colors.grey.shade600,
            ),
            onPressed: isAvailable ? () => _startGame(context, pref, difficulty) : null,
            child: Column(
              children: [
                Text(
                  getDifficultyLabel(difficulty),
                  style: TextStyle(
                    color: isAvailable ? Colors.white : Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  modifier.description,
                  style: TextStyle(
                    color: isAvailable ? Colors.white : Colors.white54,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _startGame(BuildContext context, PrefectureData pref, String difficulty) {
    final gameService = ref.read(gameServiceProvider);
    gameService.startGame(pref.code, difficulty);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          prefectureCode: pref.code,
          difficulty: difficulty,
        ),
      ),
    );
  }

  Widget _buildBossImage(PrefectureData pref) {
    final imagePath = prefectureBossImages[pref.code];
    if (imagePath == null) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('👹')),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: SizedBox(
        height: 150,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              color: Colors.grey.shade300,
              child: const Center(child: Text('👹')),
            );
          },
        ),
      ),
    );
  }
}

// ─── 検索ユーティリティ ────────────────────────────────────────

List<PrefectureData> searchPrefectures(String query) {
  if (query.isEmpty) return allPrefectures;

  final q = query.toLowerCase();
  return allPrefectures
      .where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.capitalCity.toLowerCase().contains(q) ||
          p.geographyName.toLowerCase().contains(q))
      .toList();
}
