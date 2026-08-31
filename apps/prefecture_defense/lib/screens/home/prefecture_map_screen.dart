import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_puzzle_king/config/constants.dart';
import 'package:geography_puzzle_king/models/td_model.dart';
import 'package:geography_puzzle_king/providers/game_provider.dart';
import 'package:geography_puzzle_king/screens/game/game_screen.dart';
import 'package:geography_puzzle_king/services/td_engine.dart';
import 'package:geography_puzzle_king/utils/badge_data.dart';
import 'package:geography_puzzle_king/utils/history_stage_data.dart';
import 'package:geography_puzzle_king/utils/prefecture_data.dart';
import 'package:geography_puzzle_king/utils/region_data.dart';

class PrefectureMapScreen extends ConsumerStatefulWidget {
  const PrefectureMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PrefectureMapScreen> createState() =>
      _PrefectureMapScreenState();
}

class _PrefectureMapScreenState extends ConsumerState<PrefectureMapScreen> {
  String? _selectedPrefectureCode;
  String _selectedDifficulty = 'normal';
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('都道府県を選択'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: '都道府県'),
              Tab(text: '🏆 地方決戦'),
              Tab(text: '⚔️ 歴史決戦'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrefectureTab(),
            _buildRegionBattleTab(),
            _buildHistoryStageTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefectureTab() {
    final earnedIds = ref.watch(gameServiceProvider).getEarnedBadgeIds();
    return Column(
      children: [
        // 特別バッジセクション
        if (earnedIds.isNotEmpty)
          _buildSpecialBadgesSection(earnedIds),
        // 検索バー
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
          ),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: '県名・かなで検索',
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        // 地域フィルター
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _buildRegionChip(null, '全国'),
              ...regionNames.entries.map(
                (e) => _buildRegionChip(e.key, e.value),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // 凡例 + 件数
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Text('${_filteredPrefectures.length} 件',
                  style: AppTextStyles.bodySmall),
              const Spacer(),
              const Icon(Icons.check_circle, size: 14, color: AppColors.success),
              const SizedBox(width: 2),
              const Text('制圧済', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              const Text('⭐', style: TextStyle(fontSize: 11)),
              const Text('難易度', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // グリッド
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.82,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: _filteredPrefectures.length,
            itemBuilder: (context, index) {
              final pref = _filteredPrefectures[index];
              return _buildPrefectureCard(pref);
            },
          ),
        ),
      ],
    );
  }

  // ── 特別バッジ水平スクロール ───────────────────────────────────────────

  Widget _buildSpecialBadgesSection(Set<String> earnedIds) {
    final earned = allBadges.where((b) => earnedIds.contains(b.id)).toList();
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: earned.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final b = earned[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: b.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: b.color.withOpacity(0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(b.emoji, style: const TextStyle(fontSize: 18)),
                Text(b.name,
                    style: TextStyle(
                        color: b.color,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegionBattleTab() {
    final gameService = ref.watch(gameServiceProvider);
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: allRegions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Text('🗺️', style: TextStyle(fontSize: 20)),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '地方内の全都道府県をいずれかの難度でクリアすると解放されます',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final region = allRegions[index - 1];
        final allCleared = region.prefectureCodes
            .every((code) => gameService.isPrefectureClearedAny(code));
        final regionCleared = gameService.isRegionCleared(region.code);
        final clearedCount = region.prefectureCodes
            .where((code) => gameService.isPrefectureClearedAny(code))
            .length;
        return _buildRegionBattleCard(region, allCleared, regionCleared, clearedCount);
      },
    );
  }

  Widget _buildRegionBattleCard(RegionData region, bool unlocked, bool cleared, int clearedCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: BorderSide(
          color: unlocked
              ? region.color.withOpacity(0.6)
              : AppColors.divider,
          width: unlocked ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: unlocked ? () => _showRegionBattleSheet(region) : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 地方アイコン（ロック時グレーアウト）
              Opacity(
                opacity: unlocked ? 1.0 : 0.35,
                child: Text(region.emoji, style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          region.name,
                          style: TextStyle(
                            color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (cleared)
                          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${region.bossEmoji} ボス: ${region.bossName}',
                      style: TextStyle(
                        color: unlocked ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 進捗バー
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: region.prefectureCodes.isEmpty
                                  ? 1.0
                                  : clearedCount / region.prefectureCodes.length,
                              minHeight: 4,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                unlocked ? region.color : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$clearedCount/${region.prefectureCodes.length}県',
                          style: TextStyle(
                            color: unlocked ? region.color : AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (unlocked)
                Icon(Icons.chevron_right, color: region.color)
              else
                const Icon(Icons.lock, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegionBattleSheet(RegionData region) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      builder: (context) => _buildRegionBattleDetailSheet(region),
    );
  }

  Widget _buildRegionBattleDetailSheet(RegionData region) {
    final gameService = ref.read(gameServiceProvider);
    final regionCleared = gameService.isRegionCleared(region.code);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // ヘッダー
              Center(
                child: Column(
                  children: [
                    Text(region.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${region.name}地方 決戦', style: AppTextStyles.headline2),
                    Text('WAVE ${TdEngine.regionTotalWaves}  ／  地方統一への道',
                        style: AppTextStyles.subtitle2),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // クリア状況
              if (regionCleared)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.military_tech, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      Text('制圧済み！', style: AppTextStyles.subtitle2.copyWith(color: AppColors.success)),
                    ],
                  ),
                ),
              // ボス情報
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  children: [
                    Text(region.bossEmoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ボス: ${region.bossName}', style: AppTextStyles.subtitle1),
                          Text('スキル「${region.bossSkill}」', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // 対象都道府県
              Text('対象都道府県（${region.prefectureCodes.length}県）', style: AppTextStyles.subtitle2),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: region.prefectureCodes.map((code) {
                  final pref = getPrefectureByCode(code);
                  final cleared = gameService.isPrefectureClearedAny(code);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cleared ? AppColors.success.withOpacity(0.15) : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cleared ? AppColors.success.withOpacity(0.5) : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cleared) const Icon(Icons.check, size: 10, color: AppColors.success),
                        if (cleared) const SizedBox(width: 2),
                        Text(
                          pref?.name ?? code,
                          style: TextStyle(
                            color: cleared ? AppColors.success : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              // 難度選択
              const Text('難度を選択', style: AppTextStyles.subtitle1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _buildDifficultyButton(label: 'イージー', value: 'easy', color: Colors.green),
                  const SizedBox(width: AppSpacing.md),
                  _buildDifficultyButton(label: 'ノーマル', value: 'normal', color: Colors.blue),
                  const SizedBox(width: AppSpacing.md),
                  _buildDifficultyButton(label: 'ハード', value: 'hard', color: Colors.red),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // 出撃ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          prefectureCode: '',
                          difficulty: _selectedDifficulty,
                          regionCode: region.code,
                        ),
                      ),
                    );
                  },
                  icon: const Text('⚔️', style: TextStyle(fontSize: 18)),
                  label: const Text('地方決戦 開始', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: region.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 歴史決戦タブ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHistoryStageTab() {
    final gameService = ref.read(gameServiceProvider);
    final hardCount = gameService.hardClearedPrefCount();
    final allHardDone = hardCount >= 47;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // 解放条件バナー
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: allHardDone
                ? const Color(0xFF4527A0).withOpacity(0.2)
                : Colors.black38,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: allHardDone
                  ? const Color(0xFF7C4DFF).withOpacity(0.6)
                  : Colors.white12,
            ),
          ),
          child: Column(
            children: [
              Text(
                allHardDone ? '🏆 全国ハード制覇達成！歴史決戦解放！' : '⚔️ やりこみ要素',
                style: TextStyle(
                  color: allHardDone ? const Color(0xFFB39DDB) : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!allHardDone) ...[
                Text(
                  '全47都道府県をハード難度でクリアすると\n「神代の決戦」が解放されます',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: hardCount / 47,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7C4DFF)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$hardCount / 47 県 ハードクリア済み',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
        // 歴史ステージカード一覧
        for (final stage in allHistoryStages)
          _buildHistoryStageCard(stage),
      ],
    );
  }

  Widget _buildHistoryStageCard(HistoryStageData stage) {
    final gameService = ref.read(gameServiceProvider);
    final isUnlocked = gameService.isHistoryStageUnlocked(stage.code);
    final isCleared = gameService.isHistoryStageCleared(stage.code);
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: isCleared
            ? BorderSide(color: stage.color, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isUnlocked ? () => _showHistoryStageSheet(stage) : null,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Emoji / lock
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? stage.color.withOpacity(0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(stage.emoji,
                          style: const TextStyle(fontSize: 28))
                      : const Icon(Icons.lock, color: Colors.white38, size: 24),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isUnlocked ? stage.name : '???',
                            style: TextStyle(
                              color: isUnlocked ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isCleared)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('制覇',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    if (isUnlocked) ...[
                      Text(
                        stage.subTitle,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(stage.bossEmoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '${stage.bossName}  •  ${stage.totalWaves}波',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        stage.code == 'h01'
                            ? '全国ハードクリアで解放'
                            : '前の歴史ステージをクリアで解放',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (isUnlocked)
                const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryStageSheet(HistoryStageData stage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      builder: (context) => _buildHistoryStageDetailSheet(stage),
    );
  }

  Widget _buildHistoryStageDetailSheet(HistoryStageData stage) {
    final gameService = ref.read(gameServiceProvider);
    final isCleared = gameService.isHistoryStageCleared(stage.code);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Column(
                  children: [
                    Text(stage.emoji, style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(stage.name, style: AppTextStyles.headline2),
                    Text(stage.subTitle, style: AppTextStyles.subtitle2),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (isCleared)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.military_tech, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      Text('歴史決戦 制覇済み！',
                          style: AppTextStyles.subtitle2
                              .copyWith(color: AppColors.success)),
                    ],
                  ),
                ),
              // ストーリー
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: stage.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: stage.color.withOpacity(0.3)),
                ),
                child: Text(
                  stage.lore,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.6),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // ボス情報
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  children: [
                    Text(stage.bossEmoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ボス: ${stage.bossName}',
                              style: AppTextStyles.subtitle1),
                          Text('スキル「${stage.bossSkill}」',
                              style: AppTextStyles.bodySmall),
                          Text('${stage.totalWaves}波・超高難度',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('難度を選択', style: AppTextStyles.subtitle1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _buildDifficultyButton(
                      label: 'イージー', value: 'easy', color: Colors.green),
                  const SizedBox(width: AppSpacing.md),
                  _buildDifficultyButton(
                      label: 'ノーマル', value: 'normal', color: Colors.blue),
                  const SizedBox(width: AppSpacing.md),
                  _buildDifficultyButton(
                      label: 'ハード', value: 'hard', color: Colors.red),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          prefectureCode: '',
                          difficulty: _selectedDifficulty,
                          regionCode: stage.code,
                        ),
                      ),
                    );
                  },
                  icon: Text(stage.emoji, style: const TextStyle(fontSize: 18)),
                  label: const Text('歴史決戦 開始！', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stage.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrefectureCard(PrefectureData pref) {
    final gameService = ref.read(gameServiceProvider);
    final isCleared = gameService.isPrefectureClearedAny(pref.code);
    final isSelected = _selectedPrefectureCode == pref.code;
    final prefColor = Color(int.parse(pref.color.replaceFirst('#', '0xff')));
    final diffColor = AppColors.difficulty(pref.difficultyRating);
    final hasExclusive =
        TdEngine.exclusiveFacilityForPrefecture(pref.code) != null;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPrefectureCode = pref.code);
        _showPrefectureDetail(context, pref);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: isSelected ? AppColors.primary : prefColor.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 難易度アクセントバー（左端）
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: diffColor.withOpacity(0.8),
                ),
              ),
              // 限定施設バッジ（右上）
              if (hasExclusive)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('限定',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ),
                ),
              // クリアバッジ（左上）
              if (isCleared)
                const Positioned(
                  top: 4,
                  left: 8,
                  child: Icon(Icons.check_circle,
                      size: 16, color: AppColors.success),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(pref.geographyIcon,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 2),
                    Text(
                      pref.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // E/N/H クリアバッジ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _diffStar(pref.code, 'easy',   'E', const Color(0xFF43A047)),
                        const SizedBox(width: 2),
                        _diffStar(pref.code, 'normal', 'N', const Color(0xFF1E88E5)),
                        const SizedBox(width: 2),
                        _diffStar(pref.code, 'hard',   'H', const Color(0xFFE53935)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // 地形名（小さく）
                    Text(
                      pref.geographyName,
                      style: TextStyle(
                        color: diffColor.withOpacity(0.75),
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _diffStar(String prefCode, String difficulty, String label, Color activeColor) {
    final cleared = ref.read(gameServiceProvider).isPrefectureCleared(prefCode, difficulty);
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cleared ? activeColor : AppColors.divider.withOpacity(0.4),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.bold,
            color: cleared ? Colors.white : AppColors.textSecondary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionChip(String? region, String label) {
    final isSelected = _selectedRegion == region;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedRegion = region),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showPrefectureDetail(BuildContext context, PrefectureData pref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      builder: (context) => _buildPrefectureDetailSheet(pref),
    );
  }

  Widget _buildPrefectureDetailSheet(PrefectureData pref) {
    final gameService = ref.read(gameServiceProvider);
    final clearedDiffs = gameService.getClearedDifficulties(pref.code);
    final best = gameService.getBestScoreForPrefecture(pref.code);
    final diffColor = AppColors.difficulty(pref.difficultyRating);
    final exclusive = TdEngine.exclusiveFacilityForPrefecture(pref.code);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 県名 + 地理アイコン
              Center(
                child: Column(
                  children: [
                    Text(pref.geographyIcon, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(pref.name, style: AppTextStyles.headline2),
                    Text(pref.kana, style: AppTextStyles.subtitle2),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 難易度 + 地理タイプ バナー
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: diffColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: diffColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('難易度', style: AppTextStyles.bodySmall),
                          const SizedBox(height: 2),
                          Text(pref.difficultyStars,
                              style: const TextStyle(fontSize: 14)),
                          Text(
                            pref.difficultyLabel,
                            style: TextStyle(
                              color: diffColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: AppSpacing.md),
                            child: Text('地形', style: AppTextStyles.bodySmall),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.md),
                            child: Text(
                              _geographyName(pref.geography),
                              style: AppTextStyles.subtitle1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // クリア状況
              if (clearedDiffs.isNotEmpty || best != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.military_tech, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clearedDiffs.isEmpty
                                  ? '未制圧'
                                  : '制圧難度: ${clearedDiffs.map(_diffJa).join('・')}',
                              style: AppTextStyles.subtitle2.copyWith(
                                  color: AppColors.textPrimary),
                            ),
                            if (best != null)
                              Text('ベスト: ${_formatNumber(best)} pts',
                                  style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 限定施設の紹介
              if (exclusive != null) ...[
                _buildExclusiveCard(exclusive),
                const SizedBox(height: AppSpacing.md),
              ],

              // 産業ボーナス
              if (pref.primaryIndustry != null)
                _buildBonusCard(pref),

              const SizedBox(height: AppSpacing.md),

              // 基本情報
              Row(
                children: [
                  Expanded(child: _infoTile(Icons.location_city, '県庁', pref.capitalCity)),
                  Expanded(child: _infoTile(Icons.map, '面積', '${pref.area}km²')),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ボス
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('👹 ', style: TextStyle(fontSize: 16)),
                        Text('ボス: ${pref.boss.name}',
                            style: AppTextStyles.subtitle1),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'HP ${pref.boss.baseHp} / 攻撃 ${pref.boss.baseAttack} / スキル「${pref.boss.skill}」',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 難度選択
              const Text('難度を選択', style: AppTextStyles.subtitle1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _buildDifficultyButton(label: 'イージー', value: 'easy', color: Colors.green),
                  const SizedBox(width: AppSpacing.md),
                  _buildDifficultyButton(label: 'ノーマル', value: 'normal', color: Colors.blue),
                  const SizedBox(width: AppSpacing.md),
                  _buildDifficultyButton(label: 'ハード', value: 'hard', color: Colors.red),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 出撃ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          prefectureCode: pref.code,
                          difficulty: _selectedDifficulty,
                        ),
                      ),
                    );
                  },
                  icon: const Text('⚔️', style: TextStyle(fontSize: 18)),
                  label: const Text('防衛開始', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExclusiveCard(FacilityType type) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent.withOpacity(0.18), AppColors.accent.withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(type.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏠 限定施設', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(type.label, style: AppTextStyles.subtitle1),
                Text(_exclusiveDescription(type), style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusCard(PrefectureData pref) {
    final type = pref.primaryIndustry!;
    final pct = ((pref.industryBonus - 1.0) * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Text(type.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${type.label}施設 強化 +$pct%（コスト減・威力増）',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodySmall),
            Text(value, style: AppTextStyles.subtitle2.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyButton({
    required String label,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedDifficulty == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedDifficulty = value),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? color.withOpacity(0.2) : null,
          side: BorderSide(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _geographyName(String g) {
    switch (g) {
      case 'sea':
        return '海・沿岸';
      case 'mountain':
        return '山岳';
      case 'urban':
        return '都市';
      case 'agriculture':
        return '農業';
      case 'mixed':
        return '複合';
      default:
        return '—';
    }
  }

  String _diffJa(String d) {
    switch (d) {
      case 'easy':
        return 'イージー';
      case 'normal':
        return 'ノーマル';
      case 'hard':
        return 'ハード';
      default:
        return d;
    }
  }

  String _exclusiveDescription(FacilityType type) {
    switch (type) {
      case FacilityType.dairyFarm:
        return '敵の速度を-20%する酪農施設';
      case FacilityType.alpineWatch:
        return '長射程＋スロー付与の見張所';
      case FacilityType.toyotaFactory:
        return '高速攻撃＋コイン生成';
      case FacilityType.kiyomizuTemple:
        return '敵への被ダメージ+40%';
      case FacilityType.peaceShrine:
        return '敵にシールドを付与し弱体化';
      case FacilityType.heimeyuriTower:
        return '40%でスタン（1秒）';
      case FacilityType.umeSakeBrewery:
        return '50%でスロー付与';
      case FacilityType.udonShop:
        return '超低コスト・高速攻撃';
      default:
        return '都道府県限定の特殊施設';
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (Match m) => '${m[1]},',
        );
  }
}
