/// 「視聴者コメント投票で多数決 → 結果判定」型のゲームで使う、
/// 1つの選択ポイントにおける選択肢。
class VoteChoice {
  const VoteChoice({
    required this.label,
    required this.voteKeyword,
    this.successRate = 0.5,
  });

  /// 画面に表示する選択肢のラベル（例: "山道を行く"）。
  final String label;

  /// 視聴者がライブコメントに入力する投票キーワード（例: "1"）。
  final String voteKeyword;

  /// この選択肢が選ばれた場合に「成功」側の結果になる確率（0.0〜1.0）。
  /// クイズのように結果が確定的なゲームでは 0.0 か 1.0 を指定すればよい。
  final double successRate;
}

/// 1つの状況・選択ポイント（ラウンド）。
class VoteScenario {
  const VoteScenario({required this.prompt, required this.choices});

  /// 視聴者に見せる状況説明文・問題文。
  final String prompt;

  /// 投票対象の選択肢一覧。
  final List<VoteChoice> choices;
}
