import 'dart:convert';

import 'storage.dart';
import 'streak.dart';
import 'widget_snapshot.dart';

/// ウィジェットへ値を渡す先。実機では home_widget 等のネイティブ連携を実装し、
/// テストでは [MemoryStore] を使う。
abstract class WidgetSink {
  Future<void> push(String json);
}

class StoreWidgetSink implements WidgetSink {
  StoreWidgetSink(this._store);
  final KeyValueStore _store;

  static const key = 'widget_snapshot_v1';

  @override
  Future<void> push(String json) => _store.write(key, json);
}

/// アクション完了時・日付変更時に呼ぶ。失敗してもアプリは落とさない。
Future<bool> syncWidget(WidgetSink sink, StreakState s, DateTime now) async {
  try {
    await sink.push(jsonEncode(buildSnapshot(s, now).toMap()));
    return true;
  } catch (_) {
    return false;
  }
}
