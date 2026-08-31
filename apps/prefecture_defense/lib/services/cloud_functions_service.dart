import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  static final _functions = FirebaseFunctions.instanceFor(region: 'asia-northeast1');

  /// スコアを送信（自己ベストのみ更新）
  static Future<Map<String, dynamic>> submitScore({
    required String prefectureCode,
    required int score,
    required String difficulty,
    required String playerName,
    required bool showInRanking,
  }) async {
    final callable = _functions.httpsCallable('submitScore');
    final result = await callable.call({
      'prefectureCode': prefectureCode,
      'score': score,
      'difficulty': difficulty,
      'playerName': playerName,
      'showInRanking': showInRanking,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  /// 都道府県別ランキング取得（上位20件）
  static Future<List<Map<String, dynamic>>> getRanking(String prefectureCode) async {
    final callable = _functions.httpsCallable('getRanking');
    final result = await callable.call({'prefectureCode': prefectureCode});
    final data = Map<String, dynamic>.from(result.data as Map);
    return List<Map<String, dynamic>>.from(
      (data['entries'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  /// 全国ランキング取得（全都道府県スコア合計）
  static Future<List<Map<String, dynamic>>> getGlobalRanking() async {
    final callable = _functions.httpsCallable('getGlobalRanking');
    final result = await callable.call({});
    final data = Map<String, dynamic>.from(result.data as Map);
    return List<Map<String, dynamic>>.from(
      (data['entries'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  /// デイリーボーナスを受け取る
  static Future<Map<String, dynamic>> claimDailyBonus() async {
    final callable = _functions.httpsCallable('claimDailyBonus');
    final result = await callable.call({});
    return Map<String, dynamic>.from(result.data as Map);
  }
}
