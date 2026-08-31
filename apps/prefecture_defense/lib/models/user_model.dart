/// ユーザーモデル
class User {
  final String uid;
  final String nickname;
  final String email;
  final int level;
  final int experience;
  final String hometownCode; // 本拠地の県コード
  final bool isPremium;
  final DateTime createdAt;

  const User({
    required this.uid,
    required this.nickname,
    required this.email,
    required this.level,
    required this.experience,
    required this.hometownCode,
    required this.isPremium,
    required this.createdAt,
  });

  /// コピーメソッド
  User copyWith({
    String? uid,
    String? nickname,
    String? email,
    int? level,
    int? experience,
    String? hometownCode,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      hometownCode: hometownCode ?? this.hometownCode,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'User(uid: $uid, nickname: $nickname, level: $level, hometownCode: $hometownCode)';
}

/// ログイン状態
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// 認証エラー
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
