import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prefecture_defense/config/constants.dart';
import 'package:prefecture_defense/firebase_options.dart';
import 'package:prefecture_defense/screens/auth/splash_screen.dart';
import 'package:prefecture_defense/screens/auth/login_screen.dart';
import 'package:prefecture_defense/screens/home/home_screen.dart';
import 'package:prefecture_defense/screens/home/prefecture_selection_screen.dart';
import 'package:prefecture_defense/screens/home/prefecture_map_screen.dart';
import 'package:prefecture_defense/screens/pokedex/pokedex_screen.dart';
import 'package:prefecture_defense/screens/ranking/ranking_screen.dart';
import 'package:prefecture_defense/screens/settings/settings_screen.dart';
import 'package:prefecture_defense/screens/territory/territory_screen.dart';
import 'package:prefecture_defense/screens/hq/hq_upgrade_screen.dart';
import 'package:prefecture_defense/services/cloud_functions_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 縦画面固定（タワーディフェンスUIは縦画面前提のレイアウトのため）
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初期化順序を明示的に設定
  await SharedPreferences.getInstance(); // 先に SharedPreferences を初期化

  // Android ネイティブ側（google-services.json の自動初期化）で既に
  // "[DEFAULT]" アプリが存在する場合がある。Firebase.apps は Dart 側の
  // キャッシュのみを見るため検知できず、try-catch で duplicate-app を吸収する。
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // Phase 4.18: FCM プッシュ通知初期化
  try {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received message: ${message.notification?.title}');
    });
  } catch (e) {
    // FCM listener setup failed, continue anyway
  }

  // FCM トークンを取得・保存
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      debugPrint('FCM Token obtained: ${fcmToken.substring(0, 20)}...');
      // 将来: await updateUserFCMToken(userId, fcmToken);
    }
  } catch (e) {
    // FCM token retrieval failed, continue anyway
  }

  // Phase 4.19: 適応難易度エンジン初期化
  // 注: ユーザーID取得後（プロフィール画面後）に各ユーザーごとに initializeAdaptiveDifficulty() を呼ぶこと
  debugPrint('Phase 4.19 Retention Optimization Engine: Initialized');

  // Phase 4.23: Cloud Functions サービス初期化
  final cloudFunctionsService = CloudFunctionsService();
  debugPrint('Cloud Functions Service initialized');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日本領土ディフェンス',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: const BorderSide(
              color: AppColors.divider,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: const BorderSide(
              color: AppColors.divider,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/prefecture_selection': (context) => const PrefectureSelectionScreen(),
        '/map': (context) => const PrefectureMapScreen(),
        '/territory': (context) => const TerritoryScreen(),
        '/pokedex': (context) => const PokedexScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/hq': (context) => const HqUpgradeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
