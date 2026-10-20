import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/app_repository.dart';
import 'package:jibunchara/growth.dart';
import 'package:jibunchara/notification_prefs.dart';
import 'package:jibunchara/storage.dart';
import 'package:jibunchara/streak.dart';

void main() {
  test('連続記録を保存して復元できる', () async {
    final repo = AppRepository(MemoryStore());
    final s = StreakState(
      completed: {DateTime(2026, 10, 7), DateTime(2026, 10, 8)},
      rested: {DateTime(2026, 10, 6)},
    );
    await repo.saveStreak(s);
    final back = await repo.loadStreak();
    expect(back.completed, s.completed);
    expect(back.rested, s.rested);
    expect(back.currentStreak(DateTime(2026, 10, 8)), 3);
  });

  test('通知設定を保存して復元できる', () async {
    final repo = AppRepository(MemoryStore());
    const p = NotifPrefs(
      slots: {NotifSlot.noon, NotifSlot.night},
      kinds: {NotifKind.mood, NotifKind.typeTrivia},
      tone: NotifTone.cool,
      frequency: NotifFrequency.weekdays,
      restDays: {DateTime.sunday},
    );
    await repo.savePrefs(p);
    final back = await repo.loadPrefs();
    expect(back.slots, p.slots);
    expect(back.kinds, p.kinds);
    expect(back.tone, NotifTone.cool);
    expect(back.frequency, NotifFrequency.weekdays);
    expect(back.restDays, {DateTime.sunday});
  });

  test('未保存なら初期値', () async {
    final repo = AppRepository(MemoryStore());
    expect((await repo.loadStreak()).completed, isEmpty);
    expect((await repo.loadPrefs()).tone, NotifTone.gentle);
  });

  test('壊れた保存データでも落ちずに初期値で起動する', () async {
    final store = MemoryStore();
    await store.write('streak_v1', '{not json');
    await store.write('notif_prefs_v1', '[1,2,3]');
    final repo = AppRepository(store);
    expect((await repo.loadStreak()).completed, isEmpty);
    expect((await repo.loadPrefs()).frequency, NotifFrequency.daily);
  });

  test('不正な値は無視される', () async {
    final store = MemoryStore();
    await store.write('streak_v1',
        '{"completed":["2026-10-08","bad",5],"rested":null}');
    await store.write('notif_prefs_v1',
        '{"tone":"???","restDays":[0,3,9,"x"],"slots":["noon"]}');
    final repo = AppRepository(store);
    final s = await repo.loadStreak();
    expect(s.completed, {DateTime(2026, 10, 8)});
    final p = await repo.loadPrefs();
    expect(p.tone, NotifTone.gentle);
    expect(p.restDays, {3});
    expect(p.slots, {NotifSlot.noon});
  });

  test('成長データを保存して復元できる', () async {
    final repo = AppRepository(MemoryStore());
    const g = GrowthState(totalXp: 120, claimed: {'2026-10-20:action'});
    await repo.saveGrowth(g);
    final back = await repo.loadGrowth();
    expect(back.totalXp, 120);
    expect(back.claimed, {'2026-10-20:action'});
    expect(back.stage, GrowthStage.child);
  });

  test('成長データが壊れていても初期値で起動する', () async {
    final store = MemoryStore();
    await store.write('growth_v1', 'oops');
    expect((await AppRepository(store).loadGrowth()).totalXp, 0);
    await store.write('growth_v1', '{"totalXp":-5,"claimed":[1,"a"]}');
    final g = await AppRepository(store).loadGrowth();
    expect(g.totalXp, 0);
    expect(g.claimed, {'a'});
  });
}
