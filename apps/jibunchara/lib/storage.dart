import 'package:shared_preferences/shared_preferences.dart';

/// 端末内の簡易キーバリュー保存（テストでは [MemoryStore] に差し替える）。
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class MemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;
}

class PrefsStore implements KeyValueStore {
  @override
  Future<String?> read(String key) async =>
      (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> write(String key, String value) async {
    await (await SharedPreferences.getInstance()).setString(key, value);
  }
}
