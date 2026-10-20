import 'package:flutter/material.dart';

import 'app_repository.dart';
import 'notification_picker.dart';
import 'notification_prefs.dart';

const _slotLabels = {
  NotifSlot.morning: '朝',
  NotifSlot.noon: '昼',
  NotifSlot.evening: '夕',
  NotifSlot.night: '夜',
};

const _kindLabels = {
  NotifKind.fortune: '今日の運勢',
  NotifKind.action: '1アクションの提案',
  NotifKind.mood: '気分チェック',
  NotifKind.weeklyReview: '週のふりかえり',
  NotifKind.typeTrivia: 'タイプ豆知識',
};

const _toneLabels = {
  NotifTone.gentle: 'やさしい',
  NotifTone.energetic: '元気',
  NotifTone.cool: 'クール',
  NotifTone.teacher: '先生っぽい',
};

const _frequencyLabels = {
  NotifFrequency.daily: '毎日',
  NotifFrequency.weekdays: '平日のみ',
  NotifFrequency.threePerWeek: '週3回（月水金）',
};

const _weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];

/// 通知の時間帯・内容・トーン・頻度・休む曜日を選ぶ画面。変更は即保存する。
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({
    super.key,
    required this.repository,
    this.profile = const CompanionProfile(
        name: 'ミルク', mbti: 'INFP', element: 'water'),
    this.now = DateTime.now,
  });

  final AppRepository repository;
  final CompanionProfile profile;
  final DateTime Function() now;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  NotifPrefs? _prefs;

  @override
  void initState() {
    super.initState();
    widget.repository.loadPrefs().then((p) {
      if (mounted) setState(() => _prefs = p);
    });
  }

  Future<void> _set(NotifPrefs next) async {
    setState(() => _prefs = next);
    await widget.repository.savePrefs(next);
  }

  Set<T> _toggle<T>(Set<T> set, T value, {bool keepOne = false}) {
    final next = {...set};
    if (!next.remove(value)) {
      next.add(value);
    } else if (keepOne && next.isEmpty) {
      return set; // 最低1つは残す
    }
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final p = _prefs;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final sample = pickMessage(
      kind: p.kinds.isEmpty ? NotifKind.action : p.kinds.first,
      tone: p.tone,
      profile: widget.profile,
      day: widget.now(),
    );
    final title = Theme.of(context).textTheme.titleSmall;
    final overLimit = p.slots.length > maxNotifsPerDay;

    return Scaffold(
      appBar: AppBar(title: const Text('通知の設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Text('🐱', style: TextStyle(fontSize: 32)),
              title: Text(sample.title),
              subtitle: Text(sample.body),
            ),
          ),
          const SizedBox(height: 16),
          Text('届く時間（1日${maxNotifsPerDay}件まで）', style: title),
          Wrap(spacing: 8, children: [
            for (final s in NotifSlot.values)
              FilterChip(
                label: Text(_slotLabels[s]!),
                selected: p.slots.contains(s),
                onSelected: (_) =>
                    _set(p.copyWith(slots: _toggle(p.slots, s, keepOne: true))),
              ),
          ]),
          if (overLimit)
            Text('上限を超える分は、朝→夜の順で${maxNotifsPerDay}件だけ届きます',
                style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Text('内容', style: title),
          Wrap(spacing: 8, children: [
            for (final k in NotifKind.values)
              FilterChip(
                label: Text(_kindLabels[k]!),
                selected: p.kinds.contains(k),
                onSelected: (_) =>
                    _set(p.copyWith(kinds: _toggle(p.kinds, k, keepOne: true))),
              ),
          ]),
          const SizedBox(height: 16),
          Text('相棒の話し方', style: title),
          Wrap(spacing: 8, children: [
            for (final t in NotifTone.values)
              ChoiceChip(
                label: Text(_toneLabels[t]!),
                selected: p.tone == t,
                onSelected: (_) => _set(p.copyWith(tone: t)),
              ),
          ]),
          const SizedBox(height: 16),
          Text('頻度', style: title),
          Wrap(spacing: 8, children: [
            for (final f in NotifFrequency.values)
              ChoiceChip(
                label: Text(_frequencyLabels[f]!),
                selected: p.frequency == f,
                onSelected: (_) => _set(p.copyWith(frequency: f)),
              ),
          ]),
          const SizedBox(height: 16),
          Text('おやすみする曜日', style: title),
          Wrap(spacing: 8, children: [
            for (var d = DateTime.monday; d <= DateTime.sunday; d++)
              FilterChip(
                label: Text(_weekdayLabels[d - 1]),
                selected: p.restDays.contains(d),
                onSelected: (_) =>
                    _set(p.copyWith(restDays: _toggle(p.restDays, d))),
              ),
          ]),
          const SizedBox(height: 16),
          Text(
            '通知はいつでもここで変えられます。届かなくても連続記録や成長は減りません。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
