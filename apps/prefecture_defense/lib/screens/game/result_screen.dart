import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefecture_defense/config/constants.dart';
import 'package:prefecture_defense/providers/game_provider.dart';
import 'package:prefecture_defense/providers/prefecture_records_provider.dart';
import 'package:prefecture_defense/utils/badge_data.dart';
import 'package:prefecture_defense/utils/history_stage_data.dart';
import 'package:prefecture_defense/utils/prefecture_data.dart';
import 'package:prefecture_defense/utils/region_data.dart';

class ResultScreen extends ConsumerWidget {
  final String prefectureCode;
  final String regionCode;
  final String difficulty;
  final int score;
  final int clearTime;
  final int mistakes;
  final bool isCleared;

  const ResultScreen({
    Key? key,
    required this.prefectureCode,
    this.regionCode = '',
    required this.difficulty,
    required this.score,
    required this.clearTime,
    required this.mistakes,
    required this.isCleared,
  }) : super(key: key);

  PrefectureData? get _prefecture => getPrefectureByCode(prefectureCode);
  RegionData? get _region => (!regionCode.startsWith('h') && regionCode.isNotEmpty)
      ? getRegionByCode(regionCode)
      : null;
  HistoryStageData? get _historyStage =>
      regionCode.startsWith('h') ? getHistoryStageByCode(regionCode) : null;

  String get _timeString {
    final m = clearTime ~/ 60;
    final s = clearTime % 60;
    return m > 0 ? '$m分${s}秒' : '$s秒';
  }

  String get _diffLabel => switch (difficulty) {
    'easy' => 'イージー',
    'hard' => 'ハード',
    _ => 'ノーマル',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref = _prefecture;
    final earnedBadges = ref.read(gameServiceProvider).getEarnedBadgeIds();

    // クリア時に県記録を保存
    if (isCleared && pref != null && regionCode.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final baseExp = 10 + (clearTime ~/ 60) * 2 +
            (difficulty == 'hard' ? 20 : (difficulty == 'easy' ? -5 : 0));
        ref
            .read(prefectureRecordsProvider.notifier)
            .recordClear(prefectureCode, score, difficulty, baseExp)
            .then((_) {
          // 成功したら何もしない（状態更新は provider が処理）
        }).catchError((e) {
          print('Error recording clear: $e');
        });
      });
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCleared
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [const Color(0xFF7F0000), const Color(0xFFB71C1C)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
              const SizedBox(height: AppSpacing.xl),
              // 結果バナー
              _buildResultBanner(),
              const SizedBox(height: AppSpacing.lg),
              // 地域名 or 県名
              if (_historyStage != null) ...[
                Text(
                  '${_historyStage!.emoji} ${_historyStage!.name}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _historyStage!.subTitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ] else if (_region != null) ...[
                Text(
                  '${_region!.emoji} ${_region!.name}地方 決戦',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _diffLabel,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ] else if (pref != null) ...[
                Text(
                  pref.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _diffLabel,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              // 成績カード
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildScoreCard(),
              ),
              const SizedBox(height: AppSpacing.lg),
              // 歴史決戦クリア情報
              if (isCleared && _historyStage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _buildHistoryClearCard(_historyStage!),
                ),
              // 地方決戦クリア情報
              if (isCleared && _region != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _buildRegionClearCard(_region!),
                ),
              // 県ファクト（クリア時のみ・通常戦）
              if (isCleared && pref != null && regionCode.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _buildKolegaLearningCard(pref),
                ),
              // 特別バッジ獲得表示
              if (isCleared && earnedBadges.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _buildEarnedBadgesSection(earnedBadges),
                ),
              const SizedBox(height: AppSpacing.lg),
              // ボタン群
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildButtons(context),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildResultBanner() {
    return Column(
      children: [
        Text(
          isCleared ? '🎉' : '💀',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isCleared ? 'クリア！' : 'ゲームオーバー',
          style: TextStyle(
            color: isCleared ? Colors.amber : Colors.redAccent.shade100,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Card(
      color: Colors.white12,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // スコア（大きく）
            Text(
              '$score',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'pts',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('⏱ 時間', _timeString),
                _buildStat('💥 ミス', '$mistakes 回'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── 小学コレ！スタイル学習カード ──────────────────────────────────────────

  Widget _buildKolegaLearningCard(PrefectureData pref) {
    return Card(
      color: Colors.white.withOpacity(0.07),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.25),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.large)),
            ),
            child: Row(
              children: [
                Text(pref.geographyIcon,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  '📚 ${pref.name} を学ぼう！',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // 地理情報セクション
                _buildLearningSection(
                  icon: '🗾',
                  title: '地理',
                  color: Colors.teal,
                  rows: [
                    ('🏛️ 県庁所在地', pref.capitalCity),
                    ('📐 面積', '${pref.area} km²'),
                    ('${pref.geographyIcon} 地形', pref.geographyName),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // 産業・人口セクション
                _buildLearningSection(
                  icon: '👥',
                  title: '産業・人口',
                  color: Colors.deepOrange,
                  rows: [
                    ('👥 人口', '約 ${(pref.population / 10000).round()} 万人'),
                    ('🍽 特産品', pref.specialties.take(3).join('・')),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // 豆知識セクション
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pref.trivia,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // 相棒獲得
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('🐾', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${pref.companion.name} が仲間になった！',
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                            Text(
                              pref.companion.description,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningSection({
    required String icon,
    required String title,
    required Color color,
    required List<(String, String)> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 6),
            child: Column(
              children: rows
                  .map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(r.$1,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 11)),
                            ),
                            Expanded(
                              child: Text(r.$2,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnedBadgesSection(Set<String> earnedIds) {
    final newBadges = allBadges.where((b) => earnedIds.contains(b.id)).toList();
    if (newBadges.isEmpty) return const SizedBox.shrink();
    return Card(
      color: Colors.white.withOpacity(0.07),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏅 獲得バッジ',
                style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: newBadges.map((b) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: b.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: b.color.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(b.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(b.name,
                        style: TextStyle(
                            color: b.color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefectureFactCard(PrefectureData pref) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📚 ${pref.name} のひみつ',
              style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildFactRow('🏛 県庁', pref.capitalCity),
            _buildFactRow('👥 人口',
                '約 ${(pref.population / 10000).round()} 万人'),
            _buildFactRow('📐 面積', '${pref.area} km²'),
            _buildFactRow('${pref.geographyIcon} 地形', pref.geographyName),
            _buildFactRow(
                '🍽 特産品', pref.specialties.take(3).join('・')),
            const SizedBox(height: AppSpacing.sm),
            // 豆知識
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pref.trivia,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // 相棒獲得
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pref.companion.name} が仲間になった！',
                          style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        Text(
                          pref.companion.description,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionClearCard(RegionData region) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(region.bossEmoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${region.bossName} を撃破！',
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text('${region.name}地方を制圧しました',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryClearCard(HistoryStageData stage) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: stage.color.withOpacity(0.5), width: 1.5),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(stage.bossEmoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stage.bossName} を撃破！',
                        style: TextStyle(
                            color: stage.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Text(
                        '${stage.name} クリア！',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Text(
                '🏆 やりこみ達成！歴史の守護者に認定！',
                style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.replay),
            label: const Text('もう一度',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context)
                  .popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacementNamed('/map');
            },
            icon: const Icon(Icons.map),
            label: const Text('マップへ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
          ),
        ),
      ],
    );
  }
}
