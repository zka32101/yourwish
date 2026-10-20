import 'streak.dart';

/// キャラの成長（簡易版: 経験値(XP)とステージのみ）。
/// 性格タイプ・属性は不変。成長は見た目と称号で表現する。
enum GrowthStage { egg, child, adult, special }

/// 各ステージに必要な累計XP（卵は0から）
const stageThresholds = <GrowthStage, int>{
  GrowthStage.egg: 0,
  GrowthStage.child: 50,
  GrowthStage.adult: 200,
  GrowthStage.special: 600,
};

const stageLabels = <GrowthStage, String>{
  GrowthStage.egg: 'たまご',
  GrowthStage.child: 'こども',
  GrowthStage.adult: 'おとな',
  GrowthStage.special: 'とくべつ',
};

/// 1日1回ずつ獲得できる行動
enum XpAction { action, mood, fortune, hitOrMiss }

const xpPerAction = <XpAction, int>{
  XpAction.action: 10,
  XpAction.mood: 3,
  XpAction.fortune: 2,
  XpAction.hitOrMiss: 2,
};

const weeklyBonusXp = 30;
const streak7BonusXp = 20;
const streak30BonusXp = 100;

String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class AwardResult {
  const AwardResult(this.state, this.gained, this.stageUp);
  final GrowthState state;
  final int gained;
  final bool stageUp;
}

class GrowthState {
  const GrowthState({this.totalXp = 0, this.claimed = const {}});

  final int totalXp;

  /// 獲得済みキー（同じ行動・ボーナスを二重に付与しないための記録）
  final Set<String> claimed;

  GrowthStage get stage {
    var s = GrowthStage.egg;
    for (final e in stageThresholds.entries) {
      if (totalXp >= e.value) s = e.key;
    }
    return s;
  }

  /// 次のステージまでの進み具合（最終ステージは 1.0）
  double get progress {
    final next = _nextStage;
    if (next == null) return 1.0;
    final from = stageThresholds[stage]!;
    final to = stageThresholds[next]!;
    return ((totalXp - from) / (to - from)).clamp(0.0, 1.0);
  }

  int? get xpToNext {
    final next = _nextStage;
    return next == null ? null : stageThresholds[next]! - totalXp;
  }

  GrowthStage? get _nextStage {
    final i = GrowthStage.values.indexOf(stage);
    return i + 1 < GrowthStage.values.length ? GrowthStage.values[i + 1] : null;
  }

  AwardResult _grant(String key, int xp) {
    if (xp <= 0 || claimed.contains(key)) return AwardResult(this, 0, false);
    final next = GrowthState(totalXp: totalXp + xp, claimed: {...claimed, key});
    return AwardResult(next, xp, next.stage != stage);
  }

  /// 1日1回の行動XP。同じ日に同じ行動は二重に付与しない。
  AwardResult award(XpAction action, DateTime day) =>
      _grant('${_day(day)}:${action.name}', xpPerAction[action]!);

  /// 週間達成・連続日数の節目ボーナス（既に付与済みなら何もしない）
  AwardResult awardBonuses(StreakState streak, DateTime day) {
    var cur = this;
    var gained = 0;
    var up = false;

    void apply(AwardResult r) {
      cur = r.state;
      gained += r.gained;
      up = up || r.stageUp;
    }

    final d = DateTime(day.year, day.month, day.day);
    if (streak.weeklyGoalAchieved(d)) {
      final monday = DateTime(d.year, d.month, d.day - (d.weekday - 1));
      apply(cur._grant('week:${_day(monday)}', weeklyBonusXp));
    }
    final n = streak.currentStreak(d);
    if (n == 7) apply(cur._grant('streak7:${_day(d)}', streak7BonusXp));
    if (n == 30) apply(cur._grant('streak30:${_day(d)}', streak30BonusXp));
    return AwardResult(cur, gained, up);
  }
}
