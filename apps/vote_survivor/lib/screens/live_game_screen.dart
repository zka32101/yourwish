import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';

import '../data/scenarios.dart';

enum _GamePhase { voting, result, gameOver, cleared }

const int _startingHp = 3;
const int _votingSeconds = 8;

/// 視聴者投票サバイバルのメイン画面。
///
/// 縦向き配信（TikTok Liveなど）を前提にしたレイアウト。
/// 一定時間ごとに選択肢を提示し、視聴者コメントの投票を集計、
/// 多数決で選ばれた選択肢の結果をランダム判定でHPに反映していく。
///
/// 投票受信・HP表示・投票バー・コメントティッカーは
/// `package:game_kit` の共通部品を利用しており、
/// このファイルにはこのゲーム固有の進行ロジックだけを書いている。
class LiveGameScreen extends StatefulWidget {
  const LiveGameScreen({super.key});

  @override
  State<LiveGameScreen> createState() => _LiveGameScreenState();
}

class _LiveGameScreenState extends State<LiveGameScreen> {
  final LiveCommentService _commentService = MockLiveCommentService();
  final _random = Random();
  final List<String> _recentComments = [];

  StreamSubscription<String>? _voteSub;
  Timer? _countdownTimer;

  int _round = 0;
  int _hp = _startingHp;
  int _secondsLeft = _votingSeconds;
  _GamePhase _phase = _GamePhase.voting;
  String? _resultText;
  final Map<String, int> _voteCounts = {};

  VoteScenario get _currentScenario => survivalScenarios[_round];

  @override
  void initState() {
    super.initState();
    _commentService.start();
    _voteSub = _commentService.voteStream.listen(_onVoteReceived);
    _startRound();
  }

  @override
  void dispose() {
    _voteSub?.cancel();
    _countdownTimer?.cancel();
    _commentService.stop();
    _commentService.dispose();
    super.dispose();
  }

  void _startRound() {
    _voteCounts
      ..clear()
      ..addEntries(_currentScenario.choices.map((c) => MapEntry(c.voteKeyword, 0)));
    _commentService.updateActiveKeywords(
      _currentScenario.choices.map((c) => c.voteKeyword).toList(),
    );
    _secondsLeft = _votingSeconds;
    _phase = _GamePhase.voting;
    _resultText = null;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _resolveRound();
      }
    });
  }

  void _onVoteReceived(String keyword) {
    if (_phase != _GamePhase.voting) return;
    if (!_voteCounts.containsKey(keyword)) return;
    setState(() {
      _voteCounts[keyword] = (_voteCounts[keyword] ?? 0) + 1;
      _recentComments.insert(0, keyword);
      if (_recentComments.length > 6) _recentComments.removeLast();
    });
  }

  void _resolveRound() {
    final choices = _currentScenario.choices;
    // 得票数が最大の選択肢を採用。同数の場合はランダムに決める。
    final maxVotes = _voteCounts.values.isEmpty
        ? 0
        : _voteCounts.values.reduce((a, b) => a > b ? a : b);
    final topKeywords = _voteCounts.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();
    final winningKeyword = maxVotes == 0
        ? choices[_random.nextInt(choices.length)].voteKeyword
        : topKeywords[_random.nextInt(topKeywords.length)];
    final winningChoice = choices.firstWhere((c) => c.voteKeyword == winningKeyword);

    final isSafe = _random.nextDouble() < winningChoice.successRate;

    setState(() {
      _phase = _GamePhase.result;
      if (isSafe) {
        _resultText = '「${winningChoice.label}」を選択 → 無事だった！';
      } else {
        _hp -= 1;
        _resultText = '「${winningChoice.label}」を選択 → ピンチ！ HPが1減った…';
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_hp <= 0) {
        setState(() => _phase = _GamePhase.gameOver);
        return;
      }
      if (_round + 1 >= survivalScenarios.length) {
        setState(() => _phase = _GamePhase.cleared);
        return;
      }
      setState(() {
        _round += 1;
        _startRound();
      });
    });
  }

  void _restart() {
    setState(() {
      _round = 0;
      _hp = _startingHp;
      _recentComments.clear();
      _startRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101018),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: switch (_phase) {
            _GamePhase.gameOver => _EndScreen(
                title: '生存失敗…',
                message: '第${_round + 1}のイベントで力尽きた。',
                emoji: '💀',
                onRestart: _restart,
              ),
            _GamePhase.cleared => _EndScreen(
                title: '生還成功！',
                message: '視聴者の投票で無人島を生き延びた！',
                emoji: '🏝️',
                onRestart: _restart,
              ),
            _ => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderBar(round: _round, total: survivalScenarios.length, hp: _hp),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _ScenarioCard(
                      scenario: _currentScenario,
                      voteCounts: _voteCounts,
                      phase: _phase,
                      resultText: _resultText,
                      secondsLeft: _secondsLeft,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommentTicker(recentComments: _recentComments),
                ],
              ),
          },
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.round, required this.total, required this.hp});

  final int round;
  final int total;
  final int hp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '視聴者投票サバイバル',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
        ),
        Row(
          children: [
            Text('${round + 1} / $total', style: const TextStyle(color: Colors.white54)),
            const SizedBox(width: 12),
            LivesRow(current: hp, max: _startingHp),
          ],
        ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.voteCounts,
    required this.phase,
    required this.resultText,
    required this.secondsLeft,
  });

  final VoteScenario scenario;
  final Map<String, int> voteCounts;
  final _GamePhase phase;
  final String? resultText;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            scenario.prompt,
            style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.4),
          ),
          const SizedBox(height: 20),
          if (phase == _GamePhase.voting) ...[
            Text(
              'コメントで投票！ 残り $secondsLeft 秒',
              style: const TextStyle(color: Colors.amberAccent),
            ),
            const SizedBox(height: 12),
          ],
          VoteBarList(choices: scenario.choices, voteCounts: voteCounts),
          if (phase == _GamePhase.result && resultText != null) ...[
            const SizedBox(height: 8),
            Text(
              resultText!,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _EndScreen extends StatelessWidget {
  const _EndScreen({
    required this.title,
    required this.message,
    required this.emoji,
    required this.onRestart,
  });

  final String title;
  final String message;
  final String emoji;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(onPressed: onRestart, child: const Text('もう一度挑戦する')),
        ],
      ),
    );
  }
}
