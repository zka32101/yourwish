import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';

/// SNS配信用ゲーム環境のテンプレート エントリーポイント。
///
/// 新しい配信用ゲームを追加する際は、このディレクトリごとコピーして
/// `apps/<新しいゲーム名>/` に配置し、実際のゲームロジックに置き換えてください。
/// `scripts/new_sns_game.sh` を使うとコピー〜リネームまで自動化できます。
/// 詳細は docs/sns-live-game-environments.md を参照。
///
/// `package:game_kit` にライブコメント投票の受け口や、
/// HP表示・投票バー・コメントティッカーなどの共通ウィジェットが
/// 用意されているので、まずはそれを使って組み立てることを検討してください。
void main() {
  runApp(const SnsGameTemplateApp());
}

class SnsGameTemplateApp extends StatelessWidget {
  const SnsGameTemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNS配信ゲーム テンプレート',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const _TemplateHomeScreen(),
    );
  }
}

/// 配信画面を意識したプレースホルダー画面。
///
/// TikTok Liveなど縦向き配信を基準にする場合は、この画面を
/// 縦長レイアウトのまま実装していくことを想定しています。
/// `sns_live_game_kit` の `LivesRow` / `CommentTicker` を
/// 実際に使った例を最小限で示している。
class _TemplateHomeScreen extends StatelessWidget {
  const _TemplateHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNS配信ゲーム テンプレート')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'このディレクトリをコピーして新しい配信用ゲーム環境を作成してください。\n'
              '詳細: docs/sns-live-game-environments.md',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const LivesRow(current: 3, max: 3),
            const Spacer(),
            const CommentTicker(recentComments: ['1', '2', '1']),
          ],
        ),
      ),
    );
  }
}
