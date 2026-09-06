import 'package:flutter/material.dart';
import 'package:prefecture_defense/config/constants.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ダミーランキングデータ
  final List<RankingEntry> globalRanking = [
    RankingEntry(
      rank: 1,
      nickname: '太郎くん',
      score: 12450,
      clearedPrefectures: 42,
    ),
    RankingEntry(
      rank: 2,
      nickname: '花子さん',
      score: 11980,
      clearedPrefectures: 40,
    ),
    RankingEntry(
      rank: 3,
      nickname: '次郎くん',
      score: 11450,
      clearedPrefectures: 38,
    ),
    RankingEntry(
      rank: 4,
      nickname: '美咲さん',
      score: 10980,
      clearedPrefectures: 36,
    ),
    RankingEntry(
      rank: 5,
      nickname: 'ケンくん',
      score: 10450,
      clearedPrefectures: 35,
    ),
  ];

  final List<PrefectureRanking> prefectureRanking = [
    PrefectureRanking(
      rank: 1,
      prefectureName: '北海道',
      score: 450000,
      playerCount: 125,
    ),
    PrefectureRanking(
      rank: 2,
      prefectureName: '東京都',
      score: 380000,
      playerCount: 456,
    ),
    PrefectureRanking(
      rank: 3,
      prefectureName: '大阪府',
      score: 320000,
      playerCount: 289,
    ),
    PrefectureRanking(
      rank: 4,
      prefectureName: '神奈川県',
      score: 310000,
      playerCount: 234,
    ),
    PrefectureRanking(
      rank: 5,
      prefectureName: '福岡県',
      score: 280000,
      playerCount: 198,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('ランキング'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'グローバル'),
            Tab(text: '都道府県対抗'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalRankingTab(),
          _buildPrefectureRankingTab(),
        ],
      ),
    );
  }

  Widget _buildGlobalRankingTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: globalRanking.length,
      itemBuilder: (context, index) {
        final entry = globalRanking[index];
        final isMedal = entry.rank <= 3;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              gradient: isMedal
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getMedalColor(entry.rank).withOpacity(0.1),
                        _getMedalColor(entry.rank).withOpacity(0.05),
                      ],
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isMedal
                        ? _getMedalColor(entry.rank)
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                  ),
                  child: Center(
                    child: Text(
                      isMedal ? _getMedalEmoji(entry.rank) : '${entry.rank}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Player Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.nickname,
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'クリア県: ${entry.clearedPrefectures} / 47',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.score}',
                      style: AppTextStyles.subtitle1.copyWith(
                        color: isMedal ? _getMedalColor(entry.rank) : null,
                      ),
                    ),
                    const Text(
                      'pts',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrefectureRankingTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: prefectureRanking.length,
      itemBuilder: (context, index) {
        final entry = prefectureRanking[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: entry.rank <= 3 ? AppColors.accent : AppColors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                  ),
                  child: Center(
                    child: Text(
                      entry.rank <= 3
                          ? _getMedalEmoji(entry.rank)
                          : '${entry.rank}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Prefecture Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.prefectureName,
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'プレイヤー: ${entry.playerCount} 人',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.score}',
                      style: AppTextStyles.subtitle1,
                    ),
                    const Text(
                      'pts',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}

class RankingEntry {
  final int rank;
  final String nickname;
  final int score;
  final int clearedPrefectures;

  RankingEntry({
    required this.rank,
    required this.nickname,
    required this.score,
    required this.clearedPrefectures,
  });
}

class PrefectureRanking {
  final int rank;
  final String prefectureName;
  final int score;
  final int playerCount;

  PrefectureRanking({
    required this.rank,
    required this.prefectureName,
    required this.score,
    required this.playerCount,
  });
}
