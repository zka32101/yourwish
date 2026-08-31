import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  final SharedPreferences prefs;

  static const _keyTutorialCompleted = 'tutorial_completed';
  static const _keyTutorialStep = 'tutorial_step';

  TutorialService(this.prefs);

  /// チュートリアル完了状態を取得
  bool isTutorialCompleted() =>
      prefs.getBool(_keyTutorialCompleted) ?? false;

  /// 現在のチュートリアルステップを取得（1-5）
  int getCurrentStep() => prefs.getInt(_keyTutorialStep) ?? 1;

  /// チュートリアルステップを進める
  Future<void> advanceStep() async {
    final currentStep = getCurrentStep();
    if (currentStep < 5) {
      await prefs.setInt(_keyTutorialStep, currentStep + 1);
    }
  }

  /// チュートリアル完了
  Future<void> completeTutorial() async {
    await prefs.setBool(_keyTutorialCompleted, true);
    await prefs.setInt(_keyTutorialStep, 5);
  }

  /// チュートリアルをスキップ
  Future<void> skipTutorial() async {
    await prefs.setBool(_keyTutorialCompleted, true);
  }

  /// チュートリアルをリセット（デバッグ用）
  Future<void> resetTutorial() async {
    await prefs.remove(_keyTutorialCompleted);
    await prefs.setInt(_keyTutorialStep, 1);
  }
}

/// チュートリアルステップ定義
class TutorialStep {
  final int step;
  final String title;
  final String description;
  final String? imagePath;
  final TutorialAction action;

  const TutorialStep({
    required this.step,
    required this.title,
    required this.description,
    this.imagePath,
    required this.action,
  });

  static const steps = [
    // Step 1: ようこそ
    TutorialStep(
      step: 1,
      title: 'ようこそ！',
      description: '地理パズル王へようこそ！\n47都道府県を舞台にしたタワーディフェンスゲームです。',
      action: TutorialAction.welcome,
    ),
    // Step 2: 県選択
    TutorialStep(
      step: 2,
      title: '県を選んでゲーム開始',
      description: '「ゲーム開始」から好きな県を選択します。\n県ごとに異なるボスキャラが待っています！',
      action: TutorialAction.selectPrefecture,
    ),
    // Step 3: 難易度選択
    TutorialStep(
      step: 3,
      title: '難易度を選択',
      description: 'Easy（簡単）、Normal（普通）、Hard（難しい）\nから好きな難易度を選びます。',
      action: TutorialAction.selectDifficulty,
    ),
    // Step 4: ゲームプレイ
    TutorialStep(
      step: 4,
      title: 'ゲームをプレイ',
      description: '敵が来る前に施設を配置して、敵を倒します。\nすべての波をクリアするとゲーム勝利です！',
      action: TutorialAction.playGame,
    ),
    // Step 5: ランキング
    TutorialStep(
      step: 5,
      title: 'ランキングで競おう',
      description: '「ランキング」でプレイヤー同士のスコアを比較。\nあなたの実力を試してください！',
      action: TutorialAction.checkRanking,
    ),
  ];

  static TutorialStep? getStep(int step) {
    try {
      return steps.firstWhere((s) => s.step == step);
    } catch (_) {
      return null;
    }
  }
}

enum TutorialAction {
  welcome,
  selectPrefecture,
  selectDifficulty,
  playGame,
  checkRanking,
}
