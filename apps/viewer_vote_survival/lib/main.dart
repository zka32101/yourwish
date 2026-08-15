import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/live_game_screen.dart';

/// 視聴者投票サバイバル（TikTok Live等の視聴者参加型SNS配信ゲーム）。
///
/// 視聴者はライブコメントで選択肢に投票し、多数決で選ばれた選択肢の
/// 結果によってキャラクターの生死が決まっていくサバイバルゲーム。
/// 詳細は README.md / docs/sns-live-game-environments.md を参照。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TikTok Liveなどの縦向き配信を前提にしているため、縦画面に固定する。
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ViewerVoteSurvivalApp());
}

class ViewerVoteSurvivalApp extends StatelessWidget {
  const ViewerVoteSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '視聴者投票サバイバル',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const LiveGameScreen(),
    );
  }
}
