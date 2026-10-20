import 'package:flutter/material.dart';

import 'app_repository.dart';
import 'growth.dart';
import 'notification_picker.dart';
import 'notification_prefs.dart';
import 'streak.dart';
import 'widget_sync.dart';

const _pink = Color(0xFFFF8FB1);
const _mint = Color(0xFF7FD8C3);

/// 今日の1アクションを確認してチェックする画面。
class ActionCheckPage extends StatefulWidget {
  const ActionCheckPage({
    super.key,
    required this.repository,
    this.profile = const CompanionProfile(
        name: 'ミルク', mbti: 'INFP', element: 'water'),
    this.now = DateTime.now,
    this.widgetSink,
  });

  final AppRepository repository;
  final CompanionProfile profile;
  final DateTime Function() now;

  /// 指定すると、記録のたびにホーム画面ウィジェット用データを更新する。
  final WidgetSink? widgetSink;

  @override
  State<ActionCheckPage> createState() => _ActionCheckPageState();
}

class _ActionCheckPageState extends State<ActionCheckPage> {
  StreakState? _streak;
  GrowthState _growth = const GrowthState();
  String? _evolved;
  NotifPrefs _prefs = const NotifPrefs();

  DateTime get _today {
    final n = widget.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await widget.repository.loadStreak();
    final p = await widget.repository.loadPrefs();
    final g = await widget.repository.loadGrowth();
    if (!mounted) return;
    setState(() {
      _streak = s;
      _prefs = p;
      _growth = g;
    });
  }

  /// 行動を完了したときだけXPを付与する（おやすみカードでは増減しない）
  Future<void> _complete(StreakState current) async {
    final today = _today;
    final next = current.markCompleted(today);
    final a = _growth.award(XpAction.action, today);
    final b = a.state.awardBonuses(next, today);
    setState(() {
      _growth = b.state;
      _evolved = (a.stageUp || b.stageUp)
          ? stageLabels[b.state.stage]
          : null;
    });
    await widget.repository.saveGrowth(b.state);
    await _update(next);
  }

  Future<void> _update(StreakState next) async {
    setState(() => _streak = next);
    await widget.repository.saveStreak(next);
    final sink = widget.widgetSink;
    if (sink != null) {
      await syncWidget(sink, next, widget.now(), growth: _growth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = _streak;
    if (streak == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final today = _today;
    final done = streak.completed.contains(today);
    final rested = streak.rested.contains(today);
    final msg = pickMessage(
      kind: NotifKind.action,
      tone: _prefs.tone,
      profile: widget.profile,
      day: today,
    );
    final weekDays = streak.daysCompletedInWeek(today);

    return Scaffold(
      appBar: AppBar(title: const Text('今日の1アクション')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Text(_stageEmoji(_growth.stage), style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(done ? 'できたね！えらい！' : msg.body),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text('🔥 ${streak.currentStreak(today)} 日れんぞく',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (weekDays / weeklyGoalDays).clamp(0.0, 1.0),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                  color: _mint,
                ),
                const SizedBox(height: 4),
                Text('今週 $weekDays / $weeklyGoalDays 日'
                    '${streak.weeklyGoalAchieved(today) ? '（達成！）' : ''}'),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          _GrowthCard(growth: _growth, evolvedTo: _evolved),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: _pink, minimumSize: const Size.fromHeight(52)),
            onPressed: done ? null : () => _complete(streak),
            child: Text(done ? 'きょうは完了！' : 'できた！'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: streak.canUseRestCard(today, today)
                ? () => _update(streak.useRestCard(today, today))
                : null,
            child: Text(rested
                ? 'きょうはおやすみ中'
                : 'おやすみカードを使う（のこり ${streak.restCardsLeft(today)} 枚）'),
          ),
        ],
      ),
    );
  }
}

String _stageEmoji(GrowthStage s) => switch (s) {
      GrowthStage.egg => '🥚',
      GrowthStage.child => '🐣',
      GrowthStage.adult => '🐱',
      GrowthStage.special => '🌟',
    };

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.growth, this.evolvedTo});
  final GrowthState growth;
  final String? evolvedTo;

  @override
  Widget build(BuildContext context) {
    final next = growth.xpToNext;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (evolvedTo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('✨ $evolvedTo に成長したよ！',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          Text('${stageLabels[growth.stage]}  ${growth.totalXp} XP'),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: growth.progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            color: _pink,
          ),
          const SizedBox(height: 4),
          Text(next == null ? '最高のすがた！' : 'つぎの成長まであと $next XP'),
        ]),
      ),
    );
  }
}
