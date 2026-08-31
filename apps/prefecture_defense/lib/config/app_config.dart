/// アプリケーション設定
class AppConfig {
  // API設定
  static const String apiBaseUrl = 'https://api.example.com';

  // Firebase設定（Flavorごとに異なる）
  static const bool useFirebase = false; // 本実装時にtrueに変更

  // デバッグフラグ
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;

  // アプリバージョン
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // 対応OS
  static const int minIosVersion = 14;
  static const int minAndroidVersion = 21; // Android 5.0

  // ゲーム設定
  static const int totalPrefectures = 47;
  static const int maxCompanions = 3; // 防衛戦に連れて行く相棒数
}

/// 環境別設定
enum Flavor {
  dev,
  stg,
  prod,
}

class FlavorConfig {
  static Flavor flavor = Flavor.dev;

  static String get apiUrl {
    switch (flavor) {
      case Flavor.dev:
        return 'https://dev-api.example.com';
      case Flavor.stg:
        return 'https://stg-api.example.com';
      case Flavor.prod:
        return 'https://api.example.com';
    }
  }

  static bool get isProduction => flavor == Flavor.prod;
  static bool get isDevelopment => flavor == Flavor.dev;
}
