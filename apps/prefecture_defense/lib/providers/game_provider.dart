import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geography_puzzle_king/config/difficulty_config.dart';
import 'package:geography_puzzle_king/models/achievement_model.dart';
import 'package:geography_puzzle_king/models/game_model.dart';
import 'package:geography_puzzle_king/models/player_level_model.dart';
import 'package:geography_puzzle_king/services/achievement_service.dart';
import 'package:geography_puzzle_king/services/local_storage_service.dart';
import 'package:geography_puzzle_king/services/ranking_service.dart';
import 'package:geography_puzzle_king/services/player_level_service.dart';
import 'package:geography_puzzle_king/services/daily_bonus_service.dart';
import 'package:geography_puzzle_king/models/hq_upgrade_model.dart';
import 'package:geography_puzzle_king/services/hq_upgrade_service.dart';

// ─── SharedPreferences 初期化 (FutureProvider) ──────────────────────────────

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

// ─── ローカルストレージサービス ──────────────────────────────────────────────

final localStorageServiceProvider = Provider<LocalStorageService?>((ref) {
  return ref.watch(sharedPreferencesProvider).whenData(LocalStorageService.new).value;
});

// ─── 実績サービス ────────────────────────────────────────────────────────────

final achievementServiceProvider = Provider<AchievementService?>((ref) {
  return ref.watch(sharedPreferencesProvider).whenData(AchievementService.new).value;
});

// ─── ランキングサービス ──────────────────────────────────────────────────────

final rankingServiceProvider = Provider<RankingService?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return prefs != null ? RankingService(prefs) : null;
});

// ─── プレイヤーレベルサービス ────────────────────────────────────────────────

final playerLevelServiceProvider = Provider<PlayerLevelService?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return prefs != null ? PlayerLevelService(prefs) : null;
});

final playerLevelProvider = StateProvider<PlayerLevel>((ref) {
  final svc = ref.watch(playerLevelServiceProvider);
  return svc?.loadPlayerLevel() ?? PlayerLevel.initial();
});

// ─── デイリーボーナスサービス ──────────────────────────────────────────────────

final dailyBonusServiceProvider = Provider<DailyBonusService?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return prefs != null ? DailyBonusService(prefs) : null;
});

// ─── 実績プロバイダー ─────────────────────────────────────────────────────────

final achievementsProvider = StateProvider<List<Achievement>>((ref) => List.from(allAchievements));

// ─── 本部強化（恒久アップグレード）サービス ──────────────────────────────────

final hqUpgradeServiceProvider = Provider<HqUpgradeService?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return prefs != null ? HqUpgradeService(prefs) : null;
});

final hqUpgradeProvider = StateProvider<HqUpgradeState>((ref) {
  final svc = ref.watch(hqUpgradeServiceProvider);
  return svc?.load() ?? HqUpgradeState.initial();
});

// ─── データ初期化プロバイダー ────────────────────────────────────────────────
// アプリ起動時に SharedPreferences から読み込み、各 StateProvider を更新する。
// HomeScreen で ref.watch(gameDataInitProvider) して確実に初期化させる。

final gameDataInitProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final storage = LocalStorageService(prefs);
  final achievementService = AchievementService(prefs);
  final playerLevelSvc = PlayerLevelService(prefs);

  ref.read(gameStatsProvider.notifier).state   = storage.loadStats();
  ref.read(gameHistoryProvider.notifier).state = storage.loadHistory();
  ref.read(achievementsProvider.notifier).state = achievementService.loadAchievements();
  ref.read(playerLevelProvider.notifier).state = playerLevelSvc.loadPlayerLevel();
});

// ─── ゲーム状態プロバイダー ─────────────────────────────────────────────────

final gameInProgressProvider = StateProvider<GameInProgress?>((ref) => null);

final gameStatsProvider = StateProvider<GameStats>((ref) {
  return const GameStats(
    totalGamesPlayed:        0,
    totalClearedPrefectures: 0,
    totalScore:              0,
    totalPlayTime:           0,
    totalMistakes:           0,
    difficultyClearedCount:  {},
  );
});

final gameHistoryProvider = StateProvider<List<GameSession>>((ref) => []);

final gameServiceProvider = Provider((ref) => GameService(ref));

// ─── ゲームサービス ─────────────────────────────────────────────────────────

class GameService {
  final Ref ref;
  GameService(this.ref);

  LocalStorageService? get _storage => ref.read(localStorageServiceProvider);

  void startGame(String prefectureCode, String difficulty) {
    final gameId = 'game_${DateTime.now().millisecondsSinceEpoch}';
    ref.read(gameInProgressProvider.notifier).state = GameInProgress(
      gameId:           gameId,
      prefectureCode:   prefectureCode,
      difficulty:       difficulty,
      currentScore:     0,
      currentTime:      0,
      currentMistakes:  0,
      isActive:         true,
    );
  }

  void updateGameScore(int score) {
    final g = ref.read(gameInProgressProvider);
    if (g != null) {
      ref.read(gameInProgressProvider.notifier).state = g.copyWith(currentScore: score);
    }
  }

  void updateGameTime(int seconds) {
    final g = ref.read(gameInProgressProvider);
    if (g != null) {
      ref.read(gameInProgressProvider.notifier).state = g.copyWith(currentTime: seconds);
    }
  }

  Future<void> endGame({
    required int finalScore,
    required int finalTime,
    required int finalMistakes,
    required bool isCleared,
    Set<String> facilitiesUsed = const {},
    int bossKills = 0,
    bool usedUltimate = false,
    int maxSynergyDirections = 0,
    int criticalCount = 0,
  }) async {
    final g = ref.read(gameInProgressProvider);
    if (g == null) return;

    // 難度別スコア乗数を適用
    final modifier = difficultyModifiers[g.difficulty] ?? difficultyModifiers['normal']!;
    final adjustedScore = (finalScore * modifier.scoreMultiplier).toInt();

    final earnedExp = isCleared ? (50 + adjustedScore ~/ 100) : 0;
    final session = GameSession(
      gameId:         g.gameId,
      prefectureCode: g.prefectureCode,
      difficulty:     g.difficulty,
      score:          adjustedScore,
      clearTime:      finalTime,
      mistakes:       finalMistakes,
      isCleared:      isCleared,
      earnedExp:      earnedExp,
      timestamp:      DateTime.now(),
    );

    // 履歴追加
    final history = [...ref.read(gameHistoryProvider), session];
    ref.read(gameHistoryProvider.notifier).state = history;

    // 統計更新
    final stats = ref.read(gameStatsProvider);
    final newDiff = Map<String, int>.from(stats.difficultyClearedCount);
    if (isCleared) {
      newDiff[g.difficulty] = (newDiff[g.difficulty] ?? 0) + 1;
    }
    final newStats = stats.copyWith(
      totalGamesPlayed:        stats.totalGamesPlayed + 1,
      totalClearedPrefectures: isCleared ? stats.totalClearedPrefectures + 1 : stats.totalClearedPrefectures,
      totalScore:              stats.totalScore + finalScore,
      totalPlayTime:           stats.totalPlayTime + (finalTime ~/ 60),
      totalMistakes:           stats.totalMistakes + finalMistakes,
      difficultyClearedCount:  newDiff,
    );
    ref.read(gameStatsProvider.notifier).state = newStats;

    // SharedPreferences に保存
    final storage = _storage;
    if (storage != null) {
      await Future.wait([
        storage.saveStats(newStats),
        storage.saveHistory(history),
        if (isCleared) ...[
          storage.setCleared(g.prefectureCode, g.difficulty),
          storage.updateBestScore(g.prefectureCode, g.difficulty, finalScore),
        ],
      ]);
    }

    // 本部強化: 研究ポイント付与（クリア時のみ。難度が高いほど多く獲得）
    if (isCleared) {
      final hqSvc = ref.read(hqUpgradeServiceProvider);
      if (hqSvc != null) {
        final diffBonus = switch (g.difficulty) {
          'hard' => 15,
          'easy' => 5,
          _ => 10,
        };
        final currentHq = ref.read(hqUpgradeProvider);
        final updatedHq = await hqSvc.addResearchPoints(currentHq, diffBonus);
        ref.read(hqUpgradeProvider.notifier).state = updatedHq;
      }
    }

    // 実績チェック
    final achievementSvc = ref.read(achievementServiceProvider);
    if (achievementSvc != null) {
      // ボスキル数を追加
      if (bossKills > 0) {
        await achievementSvc.addBossKills(bossKills);
      }
      final totalBossKills = achievementSvc.getBossKills();
      final hardCount = newDiff['hard'] ?? 0;
      final currentAchievements = ref.read(achievementsProvider);
      final newAchievements = await achievementSvc.checkAndUnlock(
        current: currentAchievements,
        session: session,
        totalCleared: newStats.totalClearedPrefectures,
        hardCleared: hardCount,
        totalBossKills: totalBossKills,
        facilitiesUsed: facilitiesUsed,
        usedUltimate: usedUltimate,
        maxSynergyDirections: maxSynergyDirections,
        criticalCount: criticalCount,
      );
      ref.read(achievementsProvider.notifier).state = newAchievements;
    }

    // ランキング更新
    if (isCleared) {
      final rankingSvc = ref.read(rankingServiceProvider);
      if (rankingSvc != null) {
        await rankingSvc.recordPrefectureScore(
          userId: 'player_1',
          prefCode: g.prefectureCode,
          difficulty: g.difficulty,
          score: finalScore,
          clearTime: finalTime,
        );
      }
    }

    // プレイヤーレベル更新（EXP追加）
    final playerLevelSvc = ref.read(playerLevelServiceProvider);
    if (playerLevelSvc != null) {
      final result = await playerLevelSvc.addExperience(earnedExp);
      ref.read(playerLevelProvider.notifier).state = PlayerLevel(
        currentLevel: result.newLevel,
        totalExp: (await playerLevelSvc.loadPlayerLevel()).totalExp,
        lastUpdated: DateTime.now(),
      );
    }

    ref.read(gameInProgressProvider.notifier).state = null;
  }

  void cancelGame() {
    ref.read(gameInProgressProvider.notifier).state = null;
  }

  // ── 地方決戦 ─────────────────────────────────────────────────────────────

  bool isRegionCleared(String regionCode) {
    return _storage?.isRegionCleared(regionCode) ?? false;
  }

  Future<void> endRegionBattle({
    required String regionCode,
    required int finalScore,
    required int finalTime,
    required bool isCleared,
  }) async {
    final storage = _storage;
    if (storage != null && isCleared) {
      await storage.setRegionCleared(regionCode);
    }
    final stats = ref.read(gameStatsProvider);
    final newStats = stats.copyWith(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalScore: stats.totalScore + finalScore,
      totalPlayTime: stats.totalPlayTime + (finalTime ~/ 60),
    );
    ref.read(gameStatsProvider.notifier).state = newStats;
    if (storage != null) {
      await storage.saveStats(newStats);
    }
    ref.read(gameInProgressProvider.notifier).state = null;
  }

  // ── 歴史ステージ ──────────────────────────────────────────────────────────

  bool allPrefsHardCleared() {
    for (var i = 1; i <= 47; i++) {
      final code = i.toString().padLeft(2, '0');
      if (!isPrefectureCleared(code, 'hard')) return false;
    }
    return true;
  }

  bool isHistoryStageUnlocked(String histCode) {
    switch (histCode) {
      case 'h01': return allPrefsHardCleared();
      case 'h02': return _storage?.isHistoryStageCleared('h01') ?? false;
      case 'h03': return _storage?.isHistoryStageCleared('h02') ?? false;
      case 'h04': return _storage?.isHistoryStageCleared('h03') ?? false;
      default:    return false;
    }
  }

  bool isHistoryStageCleared(String histCode) {
    return _storage?.isHistoryStageCleared(histCode) ?? false;
  }

  Future<void> endHistoryBattle({
    required String histCode,
    required int finalScore,
    required int finalTime,
    required bool isCleared,
  }) async {
    final storage = _storage;
    if (storage != null && isCleared) {
      await storage.setHistoryStageCleared(histCode);
    }
    final stats = ref.read(gameStatsProvider);
    final newStats = stats.copyWith(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalScore: stats.totalScore + finalScore,
      totalPlayTime: stats.totalPlayTime + (finalTime ~/ 60),
    );
    ref.read(gameStatsProvider.notifier).state = newStats;
    if (storage != null) {
      await storage.saveStats(newStats);
    }
    ref.read(gameInProgressProvider.notifier).state = null;
  }

  int hardClearedPrefCount() {
    int count = 0;
    for (var i = 1; i <= 47; i++) {
      final code = i.toString().padLeft(2, '0');
      if (isPrefectureCleared(code, 'hard')) count++;
    }
    return count;
  }

  int allClearedPrefCount() {
    int count = 0;
    for (var i = 1; i <= 47; i++) {
      final code = i.toString().padLeft(2, '0');
      if (isPrefectureClearedAny(code)) count++;
    }
    return count;
  }

  // ── バッジ ───────────────────────────────────────────────────────────────

  Set<String> getEarnedBadgeIds() {
    final earned = <String>{};
    const regionCodes = ['r01','r02','r03','r04','r05','r06','r07','r08'];
    const historyCodes = ['h01','h02','h03','h04'];
    for (final c in regionCodes) {
      if (isRegionCleared(c)) earned.add('region_$c');
    }
    for (final c in historyCodes) {
      if (isHistoryStageCleared(c)) earned.add('hist_$c');
    }
    var allPrefs = true;
    for (var i = 1; i <= 47; i++) {
      if (!isPrefectureClearedAny(i.toString().padLeft(2, '0'))) {
        allPrefs = false; break;
      }
    }
    if (allPrefs) earned.add('national');
    if (allPrefsHardCleared()) earned.add('national_hard');
    final allRegions = regionCodes.every(isRegionCleared);
    if (allRegions) earned.add('all_regions');
    final allHistory = historyCodes.every(isHistoryStageCleared);
    if (allHistory) earned.add('all_history');
    if (allPrefs && allRegions && allHistory) earned.add('legend');
    return earned;
  }

  // ── クエリ ───────────────────────────────────────────────────────────────

  List<String> getClearedPrefectures() {
    final fromHistory = ref.read(gameHistoryProvider)
        .where((s) => s.isCleared)
        .map((s) => s.prefectureCode)
        .toSet();
    return fromHistory.toList();
  }

  /// 県×難度のクリア済みフラグ（永続化済みも含む）
  bool isPrefectureCleared(String prefCode, String difficulty) {
    return _storage?.isCleared(prefCode, difficulty) ?? false;
  }

  /// 県のいずれかの難度でクリア済みか
  bool isPrefectureClearedAny(String prefCode) {
    for (final d in ['easy', 'normal', 'hard']) {
      if (isPrefectureCleared(prefCode, d)) return true;
    }
    return false;
  }

  /// クリア済み難度リスト（図鑑バッジ用）
  List<String> getClearedDifficulties(String prefCode) {
    return ['easy', 'normal', 'hard']
        .where((d) => isPrefectureCleared(prefCode, d))
        .toList();
  }

  /// 県×難度のベストスコア
  int? getBestScoreForPrefecture(String prefCode, [String? difficulty]) {
    final storage = _storage;
    if (difficulty != null) {
      return storage?.getBestScore(prefCode, difficulty);
    }
    // 全難度の最大値
    int? best;
    for (final d in ['easy', 'normal', 'hard']) {
      final s = storage?.getBestScore(prefCode, d);
      if (s != null && (best == null || s > best)) best = s;
    }
    return best;
  }
}
