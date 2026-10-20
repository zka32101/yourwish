import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/action_check_page.dart';
import 'package:jibunchara/app_repository.dart';
import 'package:jibunchara/storage.dart';

void main() {
  final today = DateTime(2026, 10, 20);

  Future<AppRepository> pumpPage(WidgetTester tester) async {
    final repo = AppRepository(MemoryStore());
    await tester.pumpWidget(MaterialApp(
      home: ActionCheckPage(
        repository: repo,
        now: () => DateTime(2026, 10, 20, 9),
      ),
    ));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('初期表示: 未達成・連続0日・たまご', (tester) async {
    await pumpPage(tester);
    expect(find.text('できた！'), findsOneWidget);
    expect(find.text('🔥 0 日れんぞく'), findsOneWidget);
    expect(find.text('たまご  0 XP'), findsOneWidget);
  });

  testWidgets('「できた！」で達成・XP加算・保存される', (tester) async {
    final repo = await pumpPage(tester);
    await tester.tap(find.text('できた！'));
    await tester.pumpAndSettle();

    expect(find.text('きょうは完了！'), findsOneWidget);
    expect(find.text('🔥 1 日れんぞく'), findsOneWidget);
    expect(find.text('たまご  10 XP'), findsOneWidget);

    expect((await repo.loadStreak()).completed, contains(today));
    expect((await repo.loadGrowth()).totalXp, 10);
  });

  testWidgets('おやすみカードでは連続は続くがXPは増えない', (tester) async {
    final repo = await pumpPage(tester);
    await tester.tap(find.textContaining('おやすみカードを使う'));
    await tester.pumpAndSettle();

    expect(find.text('きょうはおやすみ中'), findsOneWidget);
    expect(find.text('🔥 1 日れんぞく'), findsOneWidget);
    expect(find.text('たまご  0 XP'), findsOneWidget);
    expect((await repo.loadStreak()).rested, contains(today));
  });
}
