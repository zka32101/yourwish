import 'package:flutter/material.dart';

import 'app_repository.dart';
import 'user_profile.dart';

const _mbtiAxes = <(String, String, String, String)>[
  ('E', '外向 E', 'I', '内向 I'),
  ('S', '現実 S', 'N', '直感 N'),
  ('T', '論理 T', 'F', '感情 F'),
  ('J', '計画 J', 'P', '柔軟 P'),
];

/// 相棒の名前・タイプ・誕生日（月日）・血液型を入力する画面。
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.repository,
    required this.initial,
    required this.onSaved,
  });

  final AppRepository repository;
  final UserProfile initial;
  final ValueChanged<UserProfile> onSaved;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserProfile _p = widget.initial;
  late final TextEditingController _name =
      TextEditingController(text: widget.initial.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _setLetter(int axis, String letter) {
    final chars = _p.mbti.split('');
    chars[axis] = letter;
    setState(() => _p = _p.copyWith(mbti: chars.join()));
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('相棒の名前を入れてね')));
      return;
    }
    final next = _p.copyWith(name: name);
    await widget.repository.saveProfile(next);
    widget.onSaved(next);
    if (!mounted) return;
    setState(() => _p = next);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('ほぞんしたよ！')));
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleSmall;
    final zodiac = _p.zodiac;
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('相棒の名前', style: title),
          TextField(
            controller: _name,
            maxLength: 10,
            decoration: const InputDecoration(hintText: 'ミルク'),
          ),
          const SizedBox(height: 8),
          Text('タイプ（${_p.mbti}）', style: title),
          for (var i = 0; i < _mbtiAxes.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: _mbtiAxes[i].$1, label: Text(_mbtiAxes[i].$2)),
                  ButtonSegment(
                      value: _mbtiAxes[i].$3, label: Text(_mbtiAxes[i].$4)),
                ],
                selected: {_p.mbti[i]},
                onSelectionChanged: (s) => _setLetter(i, s.first),
              ),
            ),
          const SizedBox(height: 16),
          Text('属性', style: title),
          Wrap(spacing: 8, children: [
            for (final e in elementLabels.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: _p.element == e.key,
                onSelected: (_) =>
                    setState(() => _p = _p.copyWith(element: e.key)),
              ),
          ]),
          const SizedBox(height: 16),
          Text('誕生日（月と日だけ。年は聞きません）', style: title),
          Row(children: [
            DropdownButton<int?>(
              value: _p.birthMonth,
              hint: const Text('月'),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('未設定')),
                for (var m = 1; m <= 12; m++)
                  DropdownMenuItem<int?>(value: m, child: Text('$m月')),
              ],
              onChanged: (m) => setState(() {
                if (m == null) {
                  _p = _p.copyWith(birthMonth: null, birthDay: null);
                } else {
                  final d = _p.birthDay;
                  _p = _p.copyWith(
                    birthMonth: m,
                    birthDay: d != null && d > daysInMonth(m)
                        ? daysInMonth(m)
                        : d,
                  );
                }
              }),
            ),
            const SizedBox(width: 16),
            DropdownButton<int?>(
              value: _p.birthDay,
              hint: const Text('日'),
              items: [
                for (var d = 1;
                    d <= (_p.birthMonth == null ? 31 : daysInMonth(_p.birthMonth!));
                    d++)
                  DropdownMenuItem<int?>(value: d, child: Text('$d日')),
              ],
              onChanged: _p.birthMonth == null
                  ? null
                  : (d) => setState(() => _p = _p.copyWith(birthDay: d)),
            ),
            const SizedBox(width: 16),
            if (zodiac != null) Text(zodiacLabels[zodiac]!),
          ]),
          const SizedBox(height: 16),
          Text('血液型（わかれば）', style: title),
          Wrap(spacing: 8, children: [
            for (final b in BloodType.values)
              ChoiceChip(
                label: Text(bloodLabels[b]!),
                selected: _p.bloodType == b,
                onSelected: (sel) =>
                    setState(() => _p = _p.copyWith(bloodType: sel ? b : null)),
              ),
          ]),
          const SizedBox(height: 16),
          Text(
            '診断や占いは、楽しみと自己理解のきっかけです。当たる・当たらないを'
            '決めつけるものではありません。入力した内容はこの端末の中だけに保存されます。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('ほぞんする')),
        ],
      ),
    );
  }
}
