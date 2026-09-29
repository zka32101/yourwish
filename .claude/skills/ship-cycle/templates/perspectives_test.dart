// ship-cycle bootstrap で自動生成（10観点テストの端末上パート）。編集してよい。
// 実行: flutter drive --driver=test_driver/integration_test.dart \
//         --target=integration_test/perspectives_test.dart
// 方針: shared_core docs/DEVICE_TEST_POLICY.md
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:__PKG__/main.dart' as app;

import 'screen_catalog.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('10観点: 起動・全画面ツアー', (tester) async {
    final fatal = <String>[]; // 観点3で失敗にするもの（表示崩れ・起動時例外）
    final routeWarnings = <String>[]; // 引数が必要な画面など（初回は警告扱い）
    String current = 'launch';
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = '${details.exceptionAsString().split('\n').first} @ $current';
      final isLayout = msg.contains('overflowed') || msg.contains('RenderBox was not laid out');
      (isLayout || current == 'launch' ? fatal : routeWarnings).add(msg);
    };

    // 観点1: 起動
    app.main();
    await _settle(tester, const Duration(seconds: 15));
    expect(find.byType(WidgetsApp), findsWidgets, reason: '観点1: アプリが起動しない');
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await _shot(binding, tester, '00_launch');

    // 観点3: 全画面ツアー（MaterialApp.routes を自動検出 + screen_catalog.dart の追加分）
    final navFinder = find.byType(Navigator);
    final routes = <String>{};
    final materialApps = find.byType(MaterialApp);
    if (materialApps.evaluate().isNotEmpty) {
      routes.addAll(tester.widget<MaterialApp>(materialApps.first).routes?.keys ?? const []);
    }
    routes
      ..addAll(extraRoutes)
      ..removeAll({'/', ...skipRoutes});

    var i = 1;
    for (final route in routes) {
      if (navFinder.evaluate().isEmpty) break;
      current = route;
      final nav = tester.state<NavigatorState>(navFinder.first);
      try {
        nav.pushNamed(route);
        await _settle(tester, const Duration(seconds: 8));
        await _shot(binding, tester, '${(i++).toString().padLeft(2, '0')}_${route.replaceAll(RegExp(r'[^\w]'), '_')}');
      } catch (e) {
        routeWarnings.add('$e @ $route');
      }
      if (nav.canPop()) nav.pop();
      await _settle(tester, const Duration(seconds: 4));
    }
    current = 'done';
    FlutterError.onError = original;

    // ignore: avoid_print
    for (final w in routeWarnings) print('SHIP_CYCLE_WARN $w');
    // ignore: avoid_print
    print('SHIP_CYCLE_ROUTES ${routes.length}');
    expect(fatal, isEmpty, reason: '観点3: 表示崩れ・起動時例外 ${fatal.take(5).join(' | ')}');
  });
}

/// 無限アニメーションがあっても止まらないよう上限付きで待つ
Future<void> _settle(WidgetTester tester, Duration timeout) async {
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, timeout);
  } catch (_) {
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _shot(IntegrationTestWidgetsFlutterBinding binding, WidgetTester tester, String name) async {
  try {
    await tester.pump();
    await binding.takeScreenshot(name);
  } catch (_) {
    // スクリーンショット非対応の実行方法（flutter test）でもテスト自体は続ける
  }
}
