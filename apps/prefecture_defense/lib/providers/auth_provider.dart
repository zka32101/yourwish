import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geography_puzzle_king/models/user_model.dart';

final authStateProvider = StateProvider<AuthState>((ref) => AuthState.initial);

final currentUserProvider = StateProvider<User?>((ref) => null);

final authServiceProvider = Provider((ref) => AuthService(ref));

class AuthService {
  final Ref ref;
  AuthService(this.ref);

  static const _keyUser = 'local_user_v1';

  // ── 起動時にローカル保存ユーザーを読み込む ─────────────────────────────────

  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) {
      ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
      return;
    }
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final user = User(
        uid:          m['uid']          as String,
        nickname:     m['nickname']     as String,
        email:        m['email']        as String? ?? '',
        level:        m['level']        as int? ?? 1,
        experience:   m['experience']   as int? ?? 0,
        hometownCode: m['hometownCode'] as String? ?? '',
        isPremium:    m['isPremium']    as bool? ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      );
      ref.read(currentUserProvider.notifier).state = user;
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;
    } catch (_) {
      ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode({
      'uid':          user.uid,
      'nickname':     user.nickname,
      'email':        user.email,
      'level':        user.level,
      'experience':   user.experience,
      'hometownCode': user.hometownCode,
      'isPremium':    user.isPremium,
      'createdAt':    user.createdAt.millisecondsSinceEpoch,
    }));
  }

  // ── ニックネームで新規登録（Firebase なし） ────────────────────────────────

  Future<void> signup(String nickname, [String email = '', String password = '']) async {
    ref.read(authStateProvider.notifier).state = AuthState.loading;
    try {
      final user = User(
        uid:          'local_${DateTime.now().millisecondsSinceEpoch}',
        nickname:     nickname.isEmpty ? 'たんけんか' : nickname,
        email:        email,
        level:        1,
        experience:   0,
        hometownCode: '',
        isPremium:    false,
        createdAt:    DateTime.now(),
      );
      await _saveUser(user);
      ref.read(currentUserProvider.notifier).state = user;
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;
    } catch (e) {
      ref.read(authStateProvider.notifier).state = AuthState.error;
      throw AuthException(e.toString());
    }
  }

  // ── ログイン（ローカルユーザーがあればそのまま通す） ──────────────────────

  Future<void> login(String email, String password) async {
    ref.read(authStateProvider.notifier).state = AuthState.loading;
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyUser);
      if (raw != null) {
        await loadSavedUser();
      } else {
        // ゲストとして自動作成
        await signup('たんけんか');
      }
    } catch (e) {
      ref.read(authStateProvider.notifier).state = AuthState.error;
      throw AuthException(e.toString());
    }
  }

  // ── ログアウト ─────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    ref.read(currentUserProvider.notifier).state = null;
    ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
  }

  void updateUser(User user) {
    ref.read(currentUserProvider.notifier).state = user;
    _saveUser(user);
  }
}
