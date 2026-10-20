import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/growth.dart';
import 'package:jibunchara/streak.dart';

void main() {
  final day = DateTime(2026, 10, 20); // 火曜
  DateTime ago(int n) => DateTime(2026, 10, 20 - n);

  test('初期はたまご・XP0', () {
    const s = GrowthState();
    expect(s.stage, GrowthStage.egg);
    expect(s.progress, 0);
  });

  test('行動XPが加算される', () {
    final r = const GrowthState().award(XpAction.action, day);
    expect(r.gained, 10);
    expect(r.state.totalXp, 10);
  });

  test('同じ日の同じ行動は二重に付与されない', () {
    final once = const GrowthState().award(XpAction.action, day);
    final twice = once.state.award(XpAction.action, day);
    expect(twice.gained, 0);
    expect(twice.state.totalXp, 10);
  });

  test('翌日なら再び付与される', () {
    final a = const GrowthState().award(XpAction.action, day).state;
    final b = a.award(XpAction.action, DateTime(2026, 10, 21));
    expect(b.gained, 10);
  });

  test('1日に稼げる行動XPの上限は17', () {
    var s = const GrowthState();
    for (final a in XpAction.values) {
      s = s.award(a, day).state;
    }
    expect(s.totalXp, 17);
  });

  test('50XPでこどもに進化し stageUp が立つ', () {
    var s = const GrowthState(totalXp: 45);
    final r = s.award(XpAction.action, day);
    expect(r.state.stage, GrowthStage.child);
    expect(r.stageUp, isTrue);
    s = r.state;
    expect(s.award(XpAction.mood, day).stageUp, isFalse);
  });

  test('進み具合は次のステージまでの割合', () {
    const s = GrowthState(totalXp: 125); // child(50)〜adult(200) の中間
    expect(s.stage, GrowthStage.child);
    expect(s.progress, closeTo(0.5, 0.001));
    expect(s.xpToNext, 75);
  });

  test('最終ステージは進み具合1.0・次なし', () {
    const s = GrowthState(totalXp: 9999);
    expect(s.stage, GrowthStage.special);
    expect(s.progress, 1.0);
    expect(s.xpToNext, isNull);
  });

  test('週5日達成で週ボーナス（週に1回だけ）', () {
    final streak = StreakState(completed: {
      DateTime(2026, 10, 19),
      DateTime(2026, 10, 20),
      DateTime(2026, 10, 21),
      DateTime(2026, 10, 22),
      DateTime(2026, 10, 23),
    });
    final first = const GrowthState().awardBonuses(streak, DateTime(2026, 10, 23));
    expect(first.gained, weeklyBonusXp);
    final again = first.state.awardBonuses(streak, DateTime(2026, 10, 24));
    expect(again.gained, 0);
  });

  test('連続7日で節目ボーナス', () {
    final streak = StreakState(completed: {for (var i = 0; i < 7; i++) ago(i)});
    final r = const GrowthState().awardBonuses(streak, day);
    expect(r.gained, streak7BonusXp);
  });

  test('達成していなければボーナスなし', () {
    final r = const GrowthState().awardBonuses(StreakState(), day);
    expect(r.gained, 0);
  });
}
