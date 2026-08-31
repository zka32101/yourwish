/// ゲームセッションモデル
class GameSession {
  final String gameId;
  final String prefectureCode;
  final String difficulty; // easy, normal, hard
  final int score;
  final int clearTime; // 秒
  final int mistakes;
  final bool isCleared;
  final int earnedExp;
  final DateTime timestamp;

  const GameSession({
    required this.gameId,
    required this.prefectureCode,
    required this.difficulty,
    required this.score,
    required this.clearTime,
    required this.mistakes,
    required this.isCleared,
    required this.earnedExp,
    required this.timestamp,
  });

  GameSession copyWith({
    String? gameId,
    String? prefectureCode,
    String? difficulty,
    int? score,
    int? clearTime,
    int? mistakes,
    bool? isCleared,
    int? earnedExp,
    DateTime? timestamp,
  }) {
    return GameSession(
      gameId: gameId ?? this.gameId,
      prefectureCode: prefectureCode ?? this.prefectureCode,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      clearTime: clearTime ?? this.clearTime,
      mistakes: mistakes ?? this.mistakes,
      isCleared: isCleared ?? this.isCleared,
      earnedExp: earnedExp ?? this.earnedExp,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'GameSession(gameId: $gameId, prefecture: $prefectureCode, score: $score, cleared: $isCleared)';
}

/// ゲーム進行中の状態
class GameInProgress {
  final String gameId;
  final String prefectureCode;
  final String difficulty;
  final int currentScore;
  final int currentTime; // 経過秒数
  final int currentMistakes;
  final bool isActive;

  const GameInProgress({
    required this.gameId,
    required this.prefectureCode,
    required this.difficulty,
    required this.currentScore,
    required this.currentTime,
    required this.currentMistakes,
    required this.isActive,
  });

  GameInProgress copyWith({
    String? gameId,
    String? prefectureCode,
    String? difficulty,
    int? currentScore,
    int? currentTime,
    int? currentMistakes,
    bool? isActive,
  }) {
    return GameInProgress(
      gameId: gameId ?? this.gameId,
      prefectureCode: prefectureCode ?? this.prefectureCode,
      difficulty: difficulty ?? this.difficulty,
      currentScore: currentScore ?? this.currentScore,
      currentTime: currentTime ?? this.currentTime,
      currentMistakes: currentMistakes ?? this.currentMistakes,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// ゲーム統計
class GameStats {
  final int totalGamesPlayed;
  final int totalClearedPrefectures;
  final int totalScore;
  final int totalPlayTime; // 分
  final int totalMistakes;
  final Map<String, int> difficultyClearedCount; // easy/normal/hard ごとのクリア数

  const GameStats({
    required this.totalGamesPlayed,
    required this.totalClearedPrefectures,
    required this.totalScore,
    required this.totalPlayTime,
    required this.totalMistakes,
    required this.difficultyClearedCount,
  });

  GameStats copyWith({
    int? totalGamesPlayed,
    int? totalClearedPrefectures,
    int? totalScore,
    int? totalPlayTime,
    int? totalMistakes,
    Map<String, int>? difficultyClearedCount,
  }) {
    return GameStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalClearedPrefectures:
          totalClearedPrefectures ?? this.totalClearedPrefectures,
      totalScore: totalScore ?? this.totalScore,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      difficultyClearedCount:
          difficultyClearedCount ?? this.difficultyClearedCount,
    );
  }
}
