import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_puzzle_king/config/constants.dart';
import 'package:geography_puzzle_king/models/achievement_model.dart';
import 'package:geography_puzzle_king/providers/auth_provider.dart';
import 'package:geography_puzzle_king/providers/game_provider.dart';
import 'package:geography_puzzle_king/services/audio_service.dart';
import 'package:geography_puzzle_king/services/daily_bonus_service.dart';
import 'package:geography_puzzle_king/services/tutorial_service.dart';
import 'package:geography_puzzle_king/utils/prefecture_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AudioService().stopBgm();
    // デイリーボーナスとチュートリアルをチェック
    Future.microtask(() => _checkDailyBonusAndTutorial());
  }

  Future<void> _checkDailyBonusAndTutorial() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);

    // デイリーボーナスチェック
    final dailyBonusService = DailyBonusService(prefs);
    final bonusResult = await dailyBonusService.checkAndClaimDailyBonus();

    if (bonusResult.claimed && mounted) {
      _showDailyBonusDialog(bonusResult);
    }

    // チュートリアルチェック
    final tutorialService = TutorialService(prefs);
    if (!tutorialService.isTutorialCompleted() && mounted) {
      _showTutorialStep(tutorialService);
    }
  }

  void _showDailyBonusDialog(DailyBonusResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎁 デイリーボーナス'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ログインボーナス！\n\n💰 ${result.gold} gold\n⭐ ${result.exp} EXP'),
            const SizedBox(height: 8),
            if (result.streak > 1)
              Text('連続ログイン: ${result.streak}日 🔥', style: const TextStyle(color: Colors.orange)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTutorialStep(TutorialService tutorialService) {
    final step = tutorialService.getCurrentStep();
    final tutorialStep = TutorialStep.getStep(step);

    if (tutorialStep == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('📖 ${tutorialStep.title}'),
        content: Text(tutorialStep.description),
        actions: [
          if (step < 5)
            TextButton(
              onPressed: () async {
                await tutorialService.advanceStep();
                Navigator.pop(ctx);
                if (mounted) Future.delayed(const Duration(milliseconds: 300),
                  () => _showTutorialStep(tutorialService));
              },
              child: const Text('次へ'),
            )
          else
            ElevatedButton(
              onPressed: () async {
                await tutorialService.completeTutorial();
                Navigator.pop(ctx);
              },
              child: const Text('完了'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SharedPreferences からのデータ初期化（初回ビルドで実行）
    ref.watch(gameDataInitProvider);

    final user = ref.watch(currentUserProvider);
    if (user == null) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroHeader(user.nickname),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeployButton(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildStatsRow(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildContinueSection(),
                      const SizedBox(height: AppSpacing.lg),
                      const Text('メニュー', style: AppTextStyles.headline3),
                      const SizedBox(height: AppSpacing.md),
                      _buildMenuGrid(),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ヒーローヘッダー（タイトル + 全国制圧進捗） ─────────────────────────
  Widget _buildHeroHeader(String nickname) {
    final cleared = _clearedCount();
    const total = 47;
    final progress = cleared / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroTop, AppColors.heroBottom],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🗾', style: TextStyle(fontSize: 30)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '日本領土ディフェンス',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '指揮官 $nickname',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 全国制圧ゲージ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '全国制圧',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$cleared / $total 県',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% 制圧完了',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── 出撃ボタン（メインCTA） ──────────────────────────────────────────
  Widget _buildDeployButton() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(AppRadius.large),
      shadowColor: AppColors.primary.withOpacity(0.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: () => Navigator.of(context).pushNamed('/prefecture_selection'),
        child: Container(
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.large),
            gradient: const LinearGradient(
              colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('⚔️', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '出撃する',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '都道府県を選んで防衛開始',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── 統計サマリー（クリア県・総スコア・実績） ─────────────────────────
  Widget _buildStatsRow() {
    final stats = ref.watch(gameStatsProvider);
    final achievements = ref.watch(achievementsProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return Row(
      children: [
        _statCard('🏯', '制圧県', '${_clearedCount()}', AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        _statCard('⭐', '総スコア', _compact(stats.totalScore), AppColors.accent),
        const SizedBox(width: AppSpacing.sm),
        _statCard('🏅', '実績', '$unlocked/${achievements.length}', AppColors.secondary),
      ],
    );
  }

  Widget _statCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  // ── おすすめ（次に挑む県） ───────────────────────────────────────────
  Widget _buildContinueSection() {
    final pref = _recommendedPrefecture();
    final diffColor = AppColors.difficulty(pref.difficultyRating);
    final prefColor = Color(int.parse(pref.color.replaceFirst('#', '0xff')));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('つぎの作戦', style: AppTextStyles.headline3),
        const SizedBox(height: AppSpacing.md),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.large),
            onTap: () => Navigator.of(context).pushNamed('/prefecture_selection'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: prefColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Center(
                      child: Text(pref.geographyIcon,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pref.name,
                          style: AppTextStyles.subtitle1
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(pref.difficultyStars,
                                style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: diffColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                pref.difficultyLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: diffColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: const Text(
                      '挑む',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── メニューグリッド（実装済みルートのみ） ───────────────────────────
  Widget _buildMenuGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.0,
      children: [
        _menuTile('🗺️', '地図', Colors.green, '/territory'),
        _menuTile('📖', '図鑑', AppColors.secondary, '/pokedex'),
        _menuTile('🏆', 'ランキング', AppColors.accent, '/ranking'),
        _menuTile('🏛️', '本部強化', Colors.deepOrangeAccent, '/hq'),
        _menuTile('⚙️', '設定', AppColors.textSecondary, '/settings'),
      ],
    );
  }

  Widget _menuTile(String emoji, String label, Color color, String route) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.large),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ヘルパー ─────────────────────────────────────────────────────────
  int _clearedCount() {
    final gameService = ref.read(gameServiceProvider);
    return allPrefectures
        .where((p) => gameService.isPrefectureClearedAny(p.code))
        .length;
  }

  /// 未クリアの中で最も難易度が低い県を推奨（全クリアなら北海道）
  PrefectureData _recommendedPrefecture() {
    final gameService = ref.read(gameServiceProvider);
    final uncleared = allPrefectures
        .where((p) => !gameService.isPrefectureClearedAny(p.code))
        .toList();
    if (uncleared.isEmpty) return allPrefectures.first;
    uncleared.sort((a, b) => a.difficultyRating.compareTo(b.difficultyRating));
    return uncleared.first;
  }

  String _compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }
}
