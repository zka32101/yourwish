import 'package:flutter/material.dart';

import '../models/vote_scenario.dart';

/// 投票の選択肢一覧を「ラベル + 得票数 + 得票率バー」の形で表示する
/// 共通ウィジェット。投票中／結果確定後どちらの表示にも使える。
class VoteBarList extends StatelessWidget {
  const VoteBarList({
    super.key,
    required this.choices,
    required this.voteCounts,
    this.barColor = Colors.deepPurpleAccent,
  });

  final List<VoteChoice> choices;

  /// 選択肢の `voteKeyword` をキーにした得票数マップ。
  final Map<String, int> voteCounts;

  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final totalVotes = voteCounts.values.fold<int>(0, (a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: choices.map((choice) {
        final votes = voteCounts[choice.voteKeyword] ?? 0;
        final ratio = totalVotes == 0 ? 0.0 : votes / totalVotes;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(choice.label, style: const TextStyle(color: Colors.white)),
                  Text('$votes票', style: const TextStyle(color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
