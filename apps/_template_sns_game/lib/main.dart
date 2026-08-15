import 'package:flutter/material.dart';

/// SNS配信用ゲーム環境のテンプレート エントリーポイント。
///
/// 新しい配信用ゲームを追加する際は、このファイルごとコピーして
/// `apps/<新しいゲーム名>/` 配下に配置し、実際のゲームロジックに置き換えてください。
/// 詳細は docs/sns-live-game-environments.md を参照。
void main() {
  runApp(const SnsGameTemplateApp());
}

class SnsGameTemplateApp extends StatelessWidget {
  const SnsGameTemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNS配信ゲーム テンプレート',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const _TemplateHomeScreen(),
    );
  }
}

/// 配信画面を意識したプレースホルダー画面。
///
/// TikTok Liveなど縦向き配信を基準にする場合は、この画面を
/// 縦長レイアウトのまま実装していくことを想定しています。
class _TemplateHomeScreen extends StatelessWidget {
  const _TemplateHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNS配信ゲーム テンプレート')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'このテンプレートをコピーして新しい配信用ゲーム環境を作成してください。\n'
            '詳細: docs/sns-live-game-environments.md',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
