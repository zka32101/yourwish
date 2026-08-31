import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  double _bgmVolume = 0.4;
  double _sfxVolume = 0.7;

  bool get bgmEnabled => _bgmEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmVolume);
    await _sfxPlayer.setVolume(_sfxVolume);

    // Load settings
    final prefs = await SharedPreferences.getInstance();
    _bgmEnabled = prefs.getBool('audio_bgm_enabled') ?? true;
    _sfxEnabled = prefs.getBool('audio_sfx_enabled') ?? true;
    _bgmVolume  = prefs.getDouble('audio_bgm_volume') ?? 0.4;
    _sfxVolume  = prefs.getDouble('audio_sfx_volume') ?? 0.7;
    await _bgmPlayer.setVolume(_bgmEnabled ? _bgmVolume : 0.0);
  }

  // ── BGM ─────────────────────────────────────────────────────────────────

  Future<void> playGameBgm() async {
    if (!_bgmEnabled) return;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource('audio/bgm_game.wav'));
    } catch (_) {
      // 一部端末で音声再生に失敗することがあるが、ゲーム進行には影響させない
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBgm() async {
    if (_bgmEnabled) await _bgmPlayer.resume();
  }

  // ── SFX ─────────────────────────────────────────────────────────────────

  Future<void> playPlace()   => _playSfx('audio/sfx_place.wav');
  Future<void> playAttack()  => _playSfx('audio/sfx_attack.wav');
  Future<void> playDie()     => _playSfx('audio/sfx_die.wav');
  Future<void> playCoin()    => _playSfx('audio/sfx_coin.wav');
  Future<void> playWave()    => _playSfx('audio/sfx_wave.wav');
  Future<void> playVictory() => _playSfx('audio/sfx_victory.wav');
  Future<void> playDefeat()  => _playSfx('audio/sfx_defeat.wav');

  Future<void> _playSfx(String asset) async {
    if (!_sfxEnabled) return;
    final p = AudioPlayer();
    p.onPlayerComplete.listen((_) => p.dispose());
    try {
      await p.setVolume(_sfxVolume);
      await p.play(AssetSource(asset));
    } catch (_) {
      // 一部端末で音声再生に失敗することがあるが、ゲーム進行には影響させない
      await p.dispose();
    }
  }

  // ── 設定 ────────────────────────────────────────────────────────────────

  Future<void> setBgmEnabled(bool v) async {
    _bgmEnabled = v;
    await _bgmPlayer.setVolume(v ? _bgmVolume : 0.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_bgm_enabled', v);
  }

  Future<void> setSfxEnabled(bool v) async {
    _sfxEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_sfx_enabled', v);
  }

  Future<void> setBgmVolume(double v) async {
    _bgmVolume = v;
    if (_bgmEnabled) await _bgmPlayer.setVolume(v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('audio_bgm_volume', v);
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
