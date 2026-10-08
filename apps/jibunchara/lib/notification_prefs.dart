/// 通知の設定モデル（端末ローカル保存を想定。保存層は未実装）。

enum NotifKind { fortune, action, mood, weeklyReview, typeTrivia }

enum NotifTone { gentle, energetic, cool, teacher }

enum NotifSlot { morning, noon, evening, night }

enum NotifFrequency { daily, weekdays, threePerWeek }

/// 1日に届く通知の上限
const maxNotifsPerDay = 3;

class NotifPrefs {
  const NotifPrefs({
    this.slots = const {NotifSlot.morning, NotifSlot.night},
    this.kinds = const {NotifKind.fortune, NotifKind.action},
    this.tone = NotifTone.gentle,
    this.frequency = NotifFrequency.daily,
    this.restDays = const {},
  });

  final Set<NotifSlot> slots;
  final Set<NotifKind> kinds;
  final NotifTone tone;
  final NotifFrequency frequency;

  /// 通知を休む曜日（DateTime.monday=1 ... sunday=7）
  final Set<int> restDays;

  NotifPrefs copyWith({
    Set<NotifSlot>? slots,
    Set<NotifKind>? kinds,
    NotifTone? tone,
    NotifFrequency? frequency,
    Set<int>? restDays,
  }) =>
      NotifPrefs(
        slots: slots ?? this.slots,
        kinds: kinds ?? this.kinds,
        tone: tone ?? this.tone,
        frequency: frequency ?? this.frequency,
        restDays: restDays ?? this.restDays,
      );

  /// この日に通知を出すか
  bool shouldSendOn(DateTime day) {
    if (restDays.contains(day.weekday)) return false;
    switch (frequency) {
      case NotifFrequency.daily:
        return true;
      case NotifFrequency.weekdays:
        return day.weekday <= DateTime.friday;
      case NotifFrequency.threePerWeek:
        // 月・水・金
        return day.weekday == DateTime.monday ||
            day.weekday == DateTime.wednesday ||
            day.weekday == DateTime.friday;
    }
  }

  /// 実際に予約する時間帯（上限を超える分は朝→夜の順で優先して残す）
  List<NotifSlot> effectiveSlots() {
    final ordered = NotifSlot.values.where(slots.contains).toList();
    return ordered.take(maxNotifsPerDay).toList();
  }
}
