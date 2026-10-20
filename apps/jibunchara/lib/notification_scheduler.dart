import 'notification_picker.dart';
import 'notification_prefs.dart';

/// 時間帯ごとの通知時刻（時）。設定で変えられるようにする場合はここを差し替える。
const slotHours = <NotifSlot, int>{
  NotifSlot.morning: 8,
  NotifSlot.noon: 12,
  NotifSlot.evening: 18,
  NotifSlot.night: 21,
};

/// 予約する通知1件分
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.when,
    required this.slot,
    required this.kind,
    required this.message,
  });

  /// OS側の通知ID（日付と時間帯から決まる。同じ予定は同じIDになり上書きできる）
  final int id;
  final DateTime when;
  final NotifSlot slot;
  final NotifKind kind;
  final NotifMessage message;
}

/// 実機では flutter_local_notifications 等で実装する（未実装）。
abstract class NotificationScheduler {
  Future<void> cancelAll();
  Future<void> schedule(PlannedNotification n);
}

int _notificationId(DateTime day, NotifSlot slot) =>
    (day.year * 10000 + day.month * 100 + day.day) * 10 + slot.index;

/// 設定から、今後 [days] 日分の通知予定を作る。
///
/// - [from] より過去の時刻は含めない。
/// - 休む曜日・頻度・1日の上限は [NotifPrefs] に従う。
/// - 内容は時間帯ごとに順番に回す。週のふりかえりは日曜だけ。
/// - 同じ文面が連続しないよう、直近の文面と今回の計画内の文面を避ける。
List<PlannedNotification> planSchedule({
  required NotifPrefs prefs,
  required CompanionProfile profile,
  required DateTime from,
  int days = 7,
  Set<String> recentIds = const {},
}) {
  final result = <PlannedNotification>[];
  final used = {...recentIds};
  final slots = prefs.effectiveSlots();
  final kinds = NotifKind.values.where(prefs.kinds.contains).toList();
  if (slots.isEmpty || kinds.isEmpty) return result;

  for (var d = 0; d < days; d++) {
    final day = DateTime(from.year, from.month, from.day + d);
    if (!prefs.shouldSendOn(day)) continue;
    final todayKinds = kinds
        .where((k) => k != NotifKind.weeklyReview || day.weekday == DateTime.sunday)
        .toList();
    if (todayKinds.isEmpty) continue;

    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      final when = DateTime(day.year, day.month, day.day, slotHours[slot]!);
      if (!when.isAfter(from)) continue;
      final kind = todayKinds[(d + i) % todayKinds.length];
      final msg = pickMessage(
        kind: kind,
        tone: prefs.tone,
        profile: profile,
        day: day,
        recentIds: used,
      );
      used.add(msg.id);
      result.add(PlannedNotification(
        id: _notificationId(day, slot),
        when: when,
        slot: slot,
        kind: kind,
        message: msg,
      ));
    }
  }
  return result;
}

/// 既存の予約を消して作り直す。失敗してもアプリは落とさず false を返す。
Future<bool> reschedule(
  NotificationScheduler scheduler,
  List<PlannedNotification> plan,
) async {
  try {
    await scheduler.cancelAll();
    for (final n in plan) {
      await scheduler.schedule(n);
    }
    return true;
  } catch (_) {
    return false;
  }
}
