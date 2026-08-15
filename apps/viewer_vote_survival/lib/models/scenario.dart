/// 1つの選択ポイントにおける選択肢。
class ScenarioChoice {
  const ScenarioChoice({
    required this.label,
    required this.voteKeyword,
    required this.safetyRate,
  });

  /// 画面に表示する選択肢のラベル（例: "山道を行く"）。
  final String label;

  /// 視聴者がライブコメントに入力する投票キーワード（例: "1"）。
  final String voteKeyword;

  /// この選択肢が選ばれた場合に「安全」な結果になる確率（0.0〜1.0）。
  final double safetyRate;
}

/// 1つの状況・選択ポイント（ラウンド）。
class Scenario {
  const Scenario({required this.prompt, required this.choices});

  /// 視聴者に見せる状況説明文。
  final String prompt;

  /// 投票対象の選択肢一覧。
  final List<ScenarioChoice> choices;
}
