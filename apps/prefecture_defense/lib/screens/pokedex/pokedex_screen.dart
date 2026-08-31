import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_puzzle_king/config/constants.dart';
import 'package:geography_puzzle_king/models/achievement_model.dart';
import 'package:geography_puzzle_king/providers/game_provider.dart';
import 'package:geography_puzzle_king/utils/prefecture_data.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('図鑑'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'クリア県'),
            Tab(text: '統計'),
            Tab(text: '実績'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClearedPrefecturesTab(),
          _buildStatisticsTab(),
          _buildAchievementsTab(),
        ],
      ),
    );
  }

  Widget _buildClearedPrefecturesTab() {
    final gameService = ref.read(gameServiceProvider);
    final cleared = allPrefectures
        .where((p) => gameService.isPrefectureClearedAny(p.code))
        .toList();
    final total = allPrefectures.length;
    final progress = cleared.length / total;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'クリア進捗',
                      style: AppTextStyles.subtitle1,
                    ),
                    Text(
                      '${cleared.length} / $total',
                      style: AppTextStyles.headline3,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% 完成',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          // Cleared Prefectures Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
              ),
              itemCount: cleared.length,
              itemBuilder: (context, index) {
                final prefecture = cleared[index];
                return GestureDetector(
                  onTap: () {
                    _showPrefectureDetail(prefecture, gameService);
                  },
                  child: _buildClearedPrefCard(prefecture, gameService),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final stats = ref.watch(gameStatsProvider);
    final hours = stats.totalPlayTime ~/ 60;
    final minutes = stats.totalPlayTime % 60;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('学習統計', style: AppTextStyles.headline3),
          const SizedBox(height: AppSpacing.lg),
          _buildStatCard(
            icon: Icons.location_on,
            title: 'クリア県数',
            value: '${stats.totalClearedPrefectures} / ${allPrefectures.length}',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatCard(
            icon: Icons.timer,
            title: '総プレイ時間',
            value: '$hours 時間 $minutes 分',
            color: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatCard(
            icon: Icons.grade,
            title: '総スコア',
            value: _formatNumber(stats.totalScore),
            color: AppColors.accent,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatCard(
            icon: Icons.games,
            title: '総プレイ回数',
            value: '${stats.totalGamesPlayed} 回',
            color: Colors.purple,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('難度別クリア数', style: AppTextStyles.subtitle1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildDiffBadge('Easy', stats.difficultyClearedCount['easy'] ?? 0, Colors.green),
              const SizedBox(width: AppSpacing.md),
              _buildDiffBadge('Normal', stats.difficultyClearedCount['normal'] ?? 0, Colors.blue),
              const SizedBox(width: AppSpacing.md),
              _buildDiffBadge('Hard', stats.difficultyClearedCount['hard'] ?? 0, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiffBadge(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.large),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: AppTextStyles.headline3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final achievements = ref.watch(achievementsProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('実績', style: AppTextStyles.headline3),
              Text(
                '$unlocked / ${achievements.length}',
                style: AppTextStyles.subtitle1,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final a = achievements[index];
              return Card(
                elevation: a.isUnlocked ? 3 : 1,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: Text(
                    a.isUnlocked ? a.emoji : '🔒',
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    a.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: a.isUnlocked ? null : AppColors.textSecondary,
                    ),
                  ),
                  subtitle: Text(a.description, style: AppTextStyles.bodySmall),
                  trailing: a.isUnlocked && a.unlockedAt != null
                      ? Text(
                          '${a.unlockedAt!.month}/${a.unlockedAt!.day}',
                          style: AppTextStyles.bodySmall,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClearedPrefCard(PrefectureData prefecture, GameService gameService) {
    final prefColor = Color(int.parse(prefecture.color.replaceFirst('#', '0xff')));
    final diffs = gameService.getClearedDifficulties(prefecture.code);
    final best  = gameService.getBestScoreForPrefecture(prefecture.code);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [prefColor.withOpacity(0.2), prefColor.withOpacity(0.05)],
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: prefColor, size: 26),
            const SizedBox(height: 3),
            Text(
              prefecture.name,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (best != null) ...[
              const SizedBox(height: 2),
              Text(
                _formatNumber(best),
                style: const TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _miniDiffBadge('E', diffs.contains('easy'),   Colors.green),
                const SizedBox(width: 2),
                _miniDiffBadge('N', diffs.contains('normal'), Colors.blue),
                const SizedBox(width: 2),
                _miniDiffBadge('H', diffs.contains('hard'),   Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniDiffBadge(String label, bool active, Color color) {
    return Container(
      width: 16, height: 16,
      decoration: BoxDecoration(
        color: active ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : color.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  void _showPrefectureDetail(PrefectureData prefecture, GameService gameService) {
    final diffs = gameService.getClearedDifficulties(prefecture.code);
    final best  = gameService.getBestScoreForPrefecture(prefecture.code);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prefecture.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('かな: ${prefecture.kana}'),
            const SizedBox(height: AppSpacing.sm),
            Text('県庁: ${prefecture.capitalCity}'),
            Text('人口: 約 ${(prefecture.population / 10000).round()} 万人'),
            Text('面積: ${prefecture.area} km²'),
            const Divider(height: 20),
            if (best != null) Text('ベストスコア: ${_formatNumber(best)} pts',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              const Text('クリア難度: '),
              ...['easy', 'normal', 'hard'].map((d) {
                final labels = {'easy': 'E', 'normal': 'N', 'hard': 'H'};
                final colors = {'easy': Colors.green, 'normal': Colors.blue, 'hard': Colors.red};
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _miniDiffBadge(labels[d]!, diffs.contains(d), colors[d]!),
                );
              }),
            ]),
            const SizedBox(height: 8),
            Text('特産品: ${prefecture.specialties.take(3).join('・')}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
