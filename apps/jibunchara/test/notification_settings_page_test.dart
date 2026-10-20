import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/app_repository.dart';
import 'package:jibunchara/notification_prefs.dart';
import 'package:jibunchara/notification_scheduler.dart';
import 'package:jibunchara/notification_settings_page.dart';
import 'package:jibunchara/storage.dart';

class _CountingScheduler implements NotificationScheduler {
  int cancelCount = 0;
  int scheduled = 0;

  @override
  Future<void> cancelAll() async => cancelCount++;

  @override
  Future<void> schedule(PlannedNotification n) async => scheduled++;
}

void main() {
  late AppRepository repo;
  late _CountingScheduler scheduler;

  Future<void> pumpPage(WidgetTester tester) async {
    repo = AppRepository(MemoryStore());
    scheduler = _CountingScheduler();
    await tester.pumpWidget(MaterialApp(
      home: NotificationSettingsPage(
        repository: repo,
        scheduler: scheduler,
        now: () => DateTime(2026, 10, 20, 7),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('話し方を選ぶと保存され、予定が作り直される', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('元気'));
    await tester.pumpAndSettle();

    expect((await repo.loadPrefs()).tone, NotifTone.energetic);
    expect(scheduler.cancelCount, 1);
    expect(scheduler.scheduled, greaterThan(0));
  });

  testWidgets('時間帯は最低1つ残る', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('朝'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('夜'));
    await tester.pumpAndSettle();

    expect((await repo.loadPrefs()).slots, {NotifSlot.night});
  });

  testWidgets('頻度を平日のみにして保存できる', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('平日のみ'));
    await tester.pumpAndSettle();

    expect((await repo.loadPrefs()).frequency, NotifFrequency.weekdays);
  });
}
