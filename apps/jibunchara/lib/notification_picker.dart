import 'notification_prefs.dart';

/// 相棒（ユーザー）の特徴。文面の出し分けに使う。
class CompanionProfile {
  const CompanionProfile({
    required this.name,
    required this.mbti,
    required this.element,
  });

  final String name;
  final String mbti; // 例: 'INFP'
  final String element; // 'fire' | 'wind' | 'earth' | 'water'
}

class NotifMessage {
  const NotifMessage({required this.id, required this.title, required this.body});
  final String id;
  final String title;
  final String body;
}

class _Template {
  const _Template(this.id, this.text, {this.mbtiLetter});
  final String id;

  /// {name} が相棒名に置換される
  final String text;

  /// 特定の文字（E/I/J/P など）を持つタイプ向け。null は全タイプ共通。
  final String? mbtiLetter;
}

const _templates = <NotifKind, Map<NotifTone, List<_Template>>>{
  NotifKind.action: {
    NotifTone.gentle: [
      _Template('act_g_1', 'きょうはゆっくりでだいじょうぶ。ひとつだけ、いっしょにやってみる？'),
      _Template('act_g_2', 'ちいさな一歩でじゅうぶんだよ。{name}がそばにいるね。', mbtiLetter: 'I'),
      _Template('act_g_3', 'きょうの気分に合わせて、えらんでみよう。'),
    ],
    NotifTone.energetic: [
      _Template('act_e_1', '今日の目標、決めよう！まず1つ、15分だけ！'),
      _Template('act_e_2', 'いっしょにやろう！{name}が応援してるよ！', mbtiLetter: 'E'),
      _Template('act_e_3', 'さっそくひとつ、やってみよう！'),
    ],
    NotifTone.cool: [
      _Template('act_c_1', '今日の1アクション、確認しておこう。'),
      _Template('act_c_2', '計画どおりに進めよう。まず1つ。', mbtiLetter: 'J'),
      _Template('act_c_3', '気が向いたら、ひとつだけどうぞ。', mbtiLetter: 'P'),
    ],
    NotifTone.teacher: [
      _Template('act_t_1', '今日の課題は1つだけです。できたらチェックしましょう。'),
      _Template('act_t_2', '小さな積み重ねが大切ですよ。'),
      _Template('act_t_3', '昨日より少しだけ、進めてみましょう。'),
    ],
  },
  NotifKind.fortune: {
    NotifTone.gentle: [
      _Template('for_g_1', '今日の運勢が届いたよ。のぞいてみる？'),
      _Template('for_g_2', 'きょうはどんな日かな。{name}といっしょに見よう。'),
      _Template('for_g_3', 'ゆるっと今日の運勢、見にきてね。'),
    ],
    NotifTone.energetic: [
      _Template('for_e_1', '今日の運勢、チェックしよう！'),
      _Template('for_e_2', '今日はどんな日？{name}と確かめよう！'),
      _Template('for_e_3', '運勢が届いたよ！見にきて！'),
    ],
    NotifTone.cool: [
      _Template('for_c_1', '今日の運勢が更新された。'),
      _Template('for_c_2', '今日の傾向、確認しておこう。'),
      _Template('for_c_3', '運勢の更新があるよ。'),
    ],
    NotifTone.teacher: [
      _Template('for_t_1', '今日の運勢をお知らせします。'),
      _Template('for_t_2', '朝のうちに今日の傾向を確認しましょう。'),
      _Template('for_t_3', '運勢が更新されました。ご確認ください。'),
    ],
  },
  NotifKind.mood: {
    NotifTone.gentle: [
      _Template('moo_g_1', '今日はどんな気分だった？ひとつえらんでね。'),
      _Template('moo_g_2', '{name}は今日のあなたの気分がきになるな。'),
      _Template('moo_g_3', '1タップで、今日をふりかえろう。'),
    ],
    NotifTone.energetic: [
      _Template('moo_e_1', '今日の気分、教えて！'),
      _Template('moo_e_2', '1タップで記録しよう！'),
      _Template('moo_e_3', '{name}に今日の調子を教えてね！'),
    ],
    NotifTone.cool: [
      _Template('moo_c_1', '今日の気分を記録しておこう。'),
      _Template('moo_c_2', '1タップで完了する。'),
      _Template('moo_c_3', '調子を記録しておくと、あとで役に立つ。'),
    ],
    NotifTone.teacher: [
      _Template('moo_t_1', '今日の気分を記録しましょう。'),
      _Template('moo_t_2', 'ふりかえりの時間です。1タップで済みます。'),
      _Template('moo_t_3', '記録を続けると傾向が見えてきますよ。'),
    ],
  },
  NotifKind.weeklyReview: {
    NotifTone.gentle: [
      _Template('wee_g_1', '今週のふりかえりができたよ。いっしょに見よう。'),
      _Template('wee_g_2', 'おつかれさま。{name}と今週をふりかえろう。'),
      _Template('wee_g_3', '今週のがんばり、まとめておいたよ。'),
    ],
    NotifTone.energetic: [
      _Template('wee_e_1', '今週のまとめが届いたよ！見てみよう！'),
      _Template('wee_e_2', '今週もおつかれさま！{name}と振り返ろう！'),
      _Template('wee_e_3', '今週の成長をチェックしよう！'),
    ],
    NotifTone.cool: [
      _Template('wee_c_1', '週次レポートが生成された。'),
      _Template('wee_c_2', '今週の変化を確認しておこう。'),
      _Template('wee_c_3', 'レポートの準備ができた。'),
    ],
    NotifTone.teacher: [
      _Template('wee_t_1', '週次レポートが完成しました。'),
      _Template('wee_t_2', '今週の学びを振り返りましょう。'),
      _Template('wee_t_3', '今週の成果をご確認ください。'),
    ],
  },
  NotifKind.typeTrivia: {
    NotifTone.gentle: [
      _Template('tri_g_1', 'きょうのタイプ豆知識、見てみる？'),
      _Template('tri_g_2', '{name}のタイプのこと、ちょっとだけ知ってね。'),
      _Template('tri_g_3', '自分のことを知る、ちいさなヒントだよ。'),
    ],
    NotifTone.energetic: [
      _Template('tri_e_1', '今日のタイプ豆知識！チェックしよう！'),
      _Template('tri_e_2', '知ってた？新しい発見があるよ！'),
      _Template('tri_e_3', '{name}のタイプ、もっと知ろう！'),
    ],
    NotifTone.cool: [
      _Template('tri_c_1', 'タイプ豆知識を1つ。'),
      _Template('tri_c_2', '今日の傾向のヒントがある。'),
      _Template('tri_c_3', '自己理解のためのメモを置いておく。'),
    ],
    NotifTone.teacher: [
      _Template('tri_t_1', '今日のタイプ豆知識です。'),
      _Template('tri_t_2', '自己理解を一歩深めましょう。'),
      _Template('tri_t_3', '今日学べるポイントがあります。'),
    ],
  },
};

/// 条件に合う文面を1つ選ぶ。
///
/// - [recentIds]（直近に使った文面ID）は除外する。全て除外されたら除外を解く。
/// - タイプ限定の文面は、該当する文字を持つタイプにだけ出す。
/// - 同じ [day] と入力なら同じ結果になる（テスト可能な決定論的選択）。
NotifMessage pickMessage({
  required NotifKind kind,
  required NotifTone tone,
  required CompanionProfile profile,
  required DateTime day,
  Set<String> recentIds = const {},
}) {
  final all = _templates[kind]![tone]!;
  final letters = profile.mbti.toUpperCase().split('').toSet();
  var pool = all
      .where((t) => t.mbtiLetter == null || letters.contains(t.mbtiLetter))
      .toList();
  final fresh = pool.where((t) => !recentIds.contains(t.id)).toList();
  if (fresh.isNotEmpty) pool = fresh;

  final seed = day.year * 10000 + day.month * 100 + day.day + kind.index;
  final t = pool[seed % pool.length];
  return NotifMessage(
    id: t.id,
    title: '${profile.name}（${profile.mbti}）',
    body: t.text.replaceAll('{name}', profile.name),
  );
}
