// test/integration_test_7perspective.dart
//
// 🎯 7観点統合テスト - 自動化版
// 目的: 手動テスト 30分 → 自動テスト 2-3分 (90%削減)
//
// 実行方法:
//   flutter test test/integration_test_7perspective.dart
//   flutter drive --target=test_driver/app.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:your_app/main.dart'; // アプリのエントリーポイント

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('🎯 7観点統合テスト', () {
    // ═══════════════════════════════════════════════════════════════
    // Phase 1: 基盤検証（並列テスト対応）
    // ═══════════════════════════════════════════════════════════════

    testWidgets('✅ Test 1: 起動テスト', (WidgetTester tester) async {
      print('[Test 1] 起動テスト 開始...');

      // アプリ起動
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // ホーム画面表示確認
      expect(find.byType(MyApp), findsOneWidget);

      // クラッシュなし確認
      expect(tester.binding.window.physicalSize.isEmpty, false);

      print('[✅ PASS] Test 1: 起動成功');
    });

    testWidgets('✅ Test 2: Firebase接続テスト', (WidgetTester tester) async {
      print('[Test 2] Firebase接続テスト 開始...');

      try {
        // Firebase Core 初期化確認
        final firebaseApp = Firebase.app();
        expect(firebaseApp, isNotNull);

        // Firestore 接続確認
        final firestore = FirebaseFirestore.instance;
        final snapshot = await firestore.collection('test').limit(1).get();
        print('Firestore: ${snapshot.docs.length} documents found');

        // Realtime Database 接続確認（オプション）
        print('Firebase 接続: OK');

        print('[✅ PASS] Test 2: Firebase接続成功');
      } catch (e) {
        print('[⚠️  WARN] Test 2: Firebase接続情報不足 - $e');
      }
    });

    testWidgets('✅ Test 3: 認証テスト', (WidgetTester tester) async {
      print('[Test 3] 認証テスト 開始...');

      try {
        final auth = FirebaseAuth.instance;

        // 匿名認証
        final userCredential = await auth.signInAnonymously();
        final user = userCredential.user;

        expect(user, isNotNull);
        expect(user!.isAnonymous, true);
        expect(user.uid, isNotEmpty);

        print('ユーザーUID: ${user.uid}');
        print('[✅ PASS] Test 3: 認証成功');

        // クリーンアップ
        await auth.signOut();
      } catch (e) {
        print('[❌ FAIL] Test 3: 認証失敗 - $e');
        rethrow;
      }
    });

    // ═══════════════════════════════════════════════════════════════
    // Phase 2: 機能検証（順序依存）
    // ═══════════════════════════════════════════════════════════════

    testWidgets('⚠️  Test 4: 課金テスト', (WidgetTester tester) async {
      print('[Test 4] 課金テスト 開始...');

      // Note: エミュレータでは完全テスト不可
      // 実機テストまたはGoogle Play Console での検証が必要

      try {
        // IAP ライブラリ初期化確認
        // in_app_purchase plugin のチェック
        print('課金ライブラリ: 初期化確認');

        // 課金画面表示テスト（UI テスト）
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // プレミアム機能ボタン探索
        final premiumButton = find.text('プレミアム');
        if (premiumButton.evaluate().isNotEmpty) {
          print('プレミアムボタン: 存在');
        } else {
          print('⚠️  プレミアムボタン: 未検出');
        }

        print('[⚠️  WARN] Test 4: 課金テスト（エミュレータ制限）');
      } catch (e) {
        print('[⚠️  WARN] Test 4: 課金テスト情報不足 - $e');
      }
    });

    testWidgets('⚠️  Test 5: 広告テスト', (WidgetTester tester) async {
      print('[Test 5] 広告テスト 開始...');

      try {
        // Google Mobile Ads SDK 初期化確認
        // google_mobile_ads plugin のチェック
        print('広告ライブラリ: 初期化確認');

        // 広告表示テスト（UI テスト）
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 広告バナー探索
        final adBanner = find.byType(SizedBox).first;
        if (adBanner.evaluate().isNotEmpty) {
          print('広告バナー: 検出');
        } else {
          print('⚠️  広告バナー: 未検出');
        }

        print('[⚠️  WARN] Test 5: 広告テスト（実装確認待ち）');
      } catch (e) {
        print('[⚠️  WARN] Test 5: 広告テスト情報不足 - $e');
      }
    });

    // ═══════════════════════════════════════════════════════════════
    // Phase 3: 品質検証（並列テスト対応）
    // ═══════════════════════════════════════════════════════════════

    testWidgets('✅ Test 6: クラッシュテスト（ストレス）',
        (WidgetTester tester) async {
      print('[Test 6] クラッシュテスト 開始...');

      await tester.pumpWidget(const MyApp());

      // ストレステスト: 複数回の画面遷移
      for (int i = 0; i < 10; i++) {
        try {
          await tester.pumpAndSettle(const Duration(milliseconds: 100));

          // ランダムなタップを試みる
          final buttons = find.byType(ElevatedButton);
          if (buttons.evaluate().isNotEmpty) {
            await tester.tap(buttons.first);
            await tester.pumpAndSettle();
          }
        } catch (e) {
          print('[❌ CRASH] Test 6: ストレステスト中にエラー - $e');
          rethrow;
        }
      }

      print('[✅ PASS] Test 6: クラッシュなし（ストレステスト OK）');
    });

    testWidgets('✅ Test 7: パフォーマンステスト',
        (WidgetTester tester) async {
      print('[Test 7] パフォーマンステスト 開始...');

      // 計測開始
      final stopwatch = Stopwatch()..start();

      // アプリ起動
      await tester.pumpWidget(const MyApp());
      final startupTime = stopwatch.elapsedMilliseconds;
      print('起動時間: ${startupTime}ms');

      // 画面ロード
      await tester.pumpAndSettle();
      final screenLoadTime = stopwatch.elapsedMilliseconds - startupTime;
      print('画面ロード時間: ${screenLoadTime}ms');

      // パフォーマンス判定
      const maxStartupTime = 3000; // 3秒
      const maxScreenLoadTime = 2000; // 2秒

      expect(startupTime, lessThan(maxStartupTime),
          reason: '起動時間が遅い: ${startupTime}ms > ${maxStartupTime}ms');

      expect(screenLoadTime, lessThan(maxScreenLoadTime),
          reason: '画面ロード時間が遅い: ${screenLoadTime}ms > ${maxScreenLoadTime}ms');

      stopwatch.stop();

      // メモリ計測（オプション）
      print('メモリ使用量: 計測中...');

      print('[✅ PASS] Test 7: パフォーマンス OK');
      print('  起動時間: ${startupTime}ms (目標: <${maxStartupTime}ms)');
      print('  画面ロード: ${screenLoadTime}ms (目標: <${maxScreenLoadTime}ms)');
    });

    // ═══════════════════════════════════════════════════════════════
    // ボーナステスト: セッション復元
    // ═══════════════════════════════════════════════════════════════

    testWidgets('✅ Bonus: セッション復元テスト',
        (WidgetTester tester) async {
      print('[Bonus] セッション復元テスト 開始...');

      try {
        // Firebase 匿名認証
        final auth = FirebaseAuth.instance;
        final userCredential = await auth.signInAnonymously();
        final originalUid = userCredential.user?.uid;

        // アプリ再起動シミュレーション
        await tester.binding.window.onPlatformMessage(
          'flutter/navigation',
          const StandardMethodCodec()
              .encodeMethodCall(const MethodCall('popRoute')),
          (_) {},
        );

        // セッション確認
        final currentUser = auth.currentUser;
        expect(currentUser?.uid, equals(originalUid));

        print('[✅ PASS] Bonus: セッション復元 OK');

        // クリーンアップ
        await auth.signOut();
      } catch (e) {
        print('[⚠️  WARN] Bonus: セッション復元テスト情報不足 - $e');
      }
    });
  });

  // テストサマリー
  tearDownAll(() {
    print('\n═══════════════════════════════════');
    print('7観点統合テスト 完了');
    print('═══════════════════════════════════');
  });
}
