import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_puzzle_king/config/constants.dart';
import 'package:geography_puzzle_king/models/td_model.dart';
import 'package:geography_puzzle_king/providers/game_provider.dart';
import 'package:geography_puzzle_king/screens/game/result_screen.dart';
import 'package:geography_puzzle_king/services/audio_service.dart';
import 'package:geography_puzzle_king/services/td_engine.dart';
import 'package:geography_puzzle_king/utils/game_assets.dart';
import 'package:geography_puzzle_king/utils/history_stage_data.dart';
import 'package:geography_puzzle_king/utils/prefecture_data.dart';
import 'package:geography_puzzle_king/utils/region_data.dart';

// ─── ビジュアルエフェクト データクラス ───────────────────────────────────

class _Projectile {
  final String facilityId;
  final String enemyId;
  final Offset from;
  final Offset to;
  double progress; // 0 → 1
  final Color color;

  _Projectile({
    required this.facilityId,
    required this.enemyId,
    required this.from,
    required this.to,
    required this.color,
    this.progress = 0,
  });
}

class _FloatingText {
  Offset pos;
  final String text;
  final Color color;
  double life;
  final double maxLife;

  _FloatingText({
    required this.pos,
    required this.text,
    required this.color,
    required this.maxLife,
  }) : life = maxLife;
}

class _Particle {
  Offset pos;
  Offset vel;
  double life;
  final double maxLife;
  final Color color;

  _Particle({
    required this.pos,
    required this.vel,
    required this.maxLife,
    required this.color,
  }) : life = maxLife;
}

class _AttackFlash {
  final String facilityId;
  double life; // counts down

  _AttackFlash({required this.facilityId, required this.life});
}

/// 施設配置時の拡大リングエフェクト（0→1で拡大しつつフェードアウト）
class _PlaceRing {
  final Offset pos; // グリッド単位
  final Color color;
  double life;
  final double maxLife;

  _PlaceRing({required this.pos, required this.color, this.maxLife = 0.45})
      : life = maxLife;

  double get progress => 1.0 - (life / maxLife).clamp(0.0, 1.0);
}

// ─── ショップアイテム ─────────────────────────────────────────────────────

class _ShopItem {
  final String emoji;
  final String name;
  final String description;
  final int cost;
  final String effectKey;

  const _ShopItem({
    required this.emoji,
    required this.name,
    required this.description,
    required this.cost,
    required this.effectKey,
  });
}

const _allShopItems = [
  _ShopItem(emoji: '💊', name: '応急修理',   description: '+2 HP回復',           cost: 60,  effectKey: 'heal2'),
  _ShopItem(emoji: '💰', name: '金の稲穂',   description: '+120コイン',           cost: 0,   effectKey: 'coins120'),
  _ShopItem(emoji: '⚔️', name: '施設強化',   description: '全施設ダメージ+30%',   cost: 80,  effectKey: 'dmgBonus'),
  _ShopItem(emoji: '🛡️', name: '防衛バリア', description: '次3回の敵侵入を防ぐ',  cost: 120, effectKey: 'shield3'),
  _ShopItem(emoji: '🌀', name: '速度低下',   description: '敵速度-25%（以降永続）', cost: 70,  effectKey: 'speedDown'),
  _ShopItem(emoji: '🔧', name: '施設整備',   description: '全施設クールダウンリセット', cost: 80, effectKey: 'facilityRepair'),
];

// ─── スキルシステム ──────────────────────────────────────────────────────

class _SkillChoice {
  final String emoji;
  final String name;
  final String description;
  final String effectKey;

  const _SkillChoice({
    required this.emoji,
    required this.name,
    required this.description,
    required this.effectKey,
  });
}

const _waveSkillChoices = [
  _SkillChoice(emoji: '💪', name: '攻撃力UP', description: '次ウェーブ施設ダメージ+25%', effectKey: 'waveAtkBonus'),
  _SkillChoice(emoji: '📏', name: '射程UP', description: '次ウェーブ全施設射程+1セル', effectKey: 'waveRangeBonus'),
  _SkillChoice(emoji: '🪙', name: 'コイン獲得', description: '次ウェーブ敵撃破時コイン+20%', effectKey: 'waveCoinBonus'),
  _SkillChoice(emoji: '⚡', name: '攻撃速度UP', description: '次ウェーブ全施設攻撃速度+15%', effectKey: 'waveAtkSpeedBonus'),
];

// ─── クイズ ───────────────────────────────────────────────────────────────

class _QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// ─── ゲーム画面 ──────────────────────────────────────────────────────────

class GameScreen extends ConsumerStatefulWidget {
  final String prefectureCode;
  final String difficulty;
  final String regionCode;

  const GameScreen({
    Key? key,
    required this.prefectureCode,
    required this.difficulty,
    this.regionCode = '',
  }) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late TdGameState _gameState;
  final WaveSpawner _spawner = WaveSpawner();
  late Ticker _ticker;
  double _elapsed = 0;
  double _totalTime = 0;
  double _gameSpeed = 1.0;
  FacilityType _selectedFacility = FacilityType.farm;
  GridPos? _previewPos;
  bool _navigated = false;

  // オーディオ
  final _audio = AudioService();
  double _lastAttackSfxTime = 0;
  int _lastWaveForBgm = 0;

  // ビジュアルエフェクト
  final List<_Projectile> _projectiles = [];
  final List<_FloatingText> _floatingTexts = [];
  final List<_Particle> _particles = [];
  final List<_AttackFlash> _flashes = [];
  int _killCount = 0;

  // コンボシステム
  int _comboCount = 0;
  double _comboTimer = 0;

  // 必殺技システム（敵撃破でゲージが溜まり、満タンで全画面攻撃）
  double _ultimateCharge = 0;    // 0.0 〜 1.0
  bool _ultimateActive = false;  // 発動演出中
  double _ultimateFlashTime = 0; // 発動時の白フラッシュ残り秒

  // 実績トラッキング（新機能）
  bool _usedUltimateThisGame = false;
  int _criticalCount = 0;
  int _maxSynergyDirections = 0;

  // 演出: 画面シェイク（迫力演出）
  double _shakeTime = 0;
  double _shakeMaxTime = 0;
  double _shakeIntensity = 0;

  // 演出: 施設配置エフェクト用リング
  final List<_PlaceRing> _placeRings = [];

  // 演出: HPダメージ時の赤フラッシュ
  double _hitFlashTime = 0;

  // アニメーション用ゲーム時間（path arrows 用）
  double _gameTime = 0;

  // HP追跡（バー表示用）
  int _initialHp = 10;

  // 実績トラッキング
  final Set<String> _facilitiesUsed = {};
  int _bossKillCount = 0;

  // ショップ
  bool _shopOpen = false;
  List<_ShopItem> _currentShopItems = [];

  // クイズ
  _QuizQuestion? _currentQuiz;
  bool _quizAnswered = false;
  int? _quizSelectedIndex;

  // 演出: ウェーブ/ボス登場バナー
  late AnimationController _bannerCtrl;
  String _bannerTitle = '';
  String _bannerSub = '';
  bool _bannerIsBoss = false;
  int _lastWaveForBanner = 0;

  // ご当地相棒
  String _companionLine = '';
  double _companionLineLife = 0; // 吹き出し残り秒
  double _cheerTimer = 14; // 応援クールダウン（秒）

  final _rng = Random();

  static const _facilityColors = {
    FacilityType.farm:    Color(0xFF4CAF50),
    FacilityType.fishery: Color(0xFF2196F3),
    FacilityType.factory: Color(0xFFFF9800),
    FacilityType.mine:    Color(0xFF9E9E9E),
    FacilityType.castle:  Color(0xFFB8860B),
    FacilityType.shrine:  Color(0xFFE91E63),
  };

  PrefectureData? get _prefecture =>
      getPrefectureByCode(widget.prefectureCode);

  RegionData? get _region => (!widget.regionCode.startsWith('h') && widget.regionCode.isNotEmpty)
      ? getRegionByCode(widget.regionCode)
      : null;

  HistoryStageData? get _historyStage =>
      widget.regionCode.startsWith('h') ? getHistoryStageByCode(widget.regionCode) : null;

  Color get _prefColor {
    final history = _historyStage;
    if (history != null) return history.color;
    final region = _region;
    if (region != null) return region.color;
    final pref = _prefecture;
    if (pref != null) {
      try {
        return Color(int.parse(pref.color.replaceFirst('#', '0xff')));
      } catch (_) {}
    }
    return const Color(0xFF1A2332);
  }

  @override
  void initState() {
    super.initState();
    final hq = ref.read(hqUpgradeProvider);
    _gameState = TdEngine.createInitial(
      widget.difficulty,
      widget.prefectureCode,
      widget.regionCode,
      hq.hpBonus,
      hq.attackMultiplier - 1.0,
      hq.coinMultiplier,
    );

    // クイズ生成（地方決戦では無効）
    if (widget.regionCode.isEmpty) {
      final prefForQuiz = getPrefectureByCode(widget.prefectureCode);
      if (prefForQuiz != null) {
        _currentQuiz = _generateQuiz(prefForQuiz, allPrefectures);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(gameServiceProvider)
          .startGame(widget.prefectureCode, widget.difficulty);
    });

    _initialHp = _gameState.baseHp;
    _audio.init().then((_) => _audio.playGameBgm());
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _ticker = createTicker(_onTick)..start();

    // 画像プリロード（パフォーマンス向上）
    _preloadImages();

    // 開始セリフ
    final history = _historyStage;
    final region = _region;
    final p = _prefecture;
    if (history != null) {
      _say('「${history.name}の決戦だ！歴史を守れ！」', 4.0);
    } else if (region != null) {
      _say('「${region.name}地方の決戦だ！全力で戦うぞ！」', 4.0);
    } else if (p != null) {
      _say('「${p.name}を守るぞ！ぼくにまかせて！」', 4.0);
    }
  }

  // ─── 相棒セリフ ──────────────────────────────────────────────────────
  void _say(String line, double seconds) {
    _companionLine = line;
    _companionLineLife = seconds;
  }

  // ─── 演出: 画面シェイク ──────────────────────────────────────────────
  void _triggerShake(double intensity, {double duration = 0.3}) {
    // より強い揺れが来たら上書き（弱い揺れが強い揺れを打ち消さないように）
    if (intensity >= _shakeIntensity || _shakeTime <= 0) {
      _shakeIntensity = intensity;
      _shakeTime = duration;
      _shakeMaxTime = duration;
    }
  }

  // ─── 必殺技: 超・領土防衛 ────────────────────────────────────────────
  void _activateUltimate() {
    if (_ultimateCharge < 1.0 || _ultimateActive) return;
    if (_gameState.phase != GamePhase.wave) return; // 戦闘中のみ発動可

    setState(() {
      _ultimateActive = true;
      _ultimateCharge = 0;
      _ultimateFlashTime = 0.5;
      _usedUltimateThisGame = true;
    });

    // 迫力ある全画面演出
    _triggerShake(18, duration: 0.7);
    _audio.playVictory();
    _say('「くらえ！ 必殺・領土防衛ッ！」', 3.0);

    // 全敵に大ダメージ（各敵の最大HPの70%）＋撃破エフェクト
    final path = _gameState.path;
    final enemies = _gameState.enemies;
    int killedRewards = 0;
    for (final e in enemies) {
      if (e.isDead) continue;
      final ep = e.posOnPath(path);
      final dmg = (e.maxHp * 0.7).round();
      e.hp -= dmg;

      _floatingTexts.add(_FloatingText(
        pos: Offset(ep.dx + 0.5, ep.dy + 0.5),
        text: '💥$dmg',
        color: Colors.orangeAccent,
        maxLife: 1.2,
      ));
      // 各敵位置で爆発パーティクル
      for (var i = 0; i < 10; i++) {
        final angle = (i / 10) * 2 * pi + _rng.nextDouble() * 0.4;
        final spd = 2.0 + _rng.nextDouble() * 2.5;
        _particles.add(_Particle(
          pos: Offset(ep.dx + 0.5, ep.dy + 0.5),
          vel: Offset(cos(angle) * spd, sin(angle) * spd),
          maxLife: 0.6 + _rng.nextDouble() * 0.4,
          color: HSVColor.fromAHSV(1.0, _rng.nextDouble() * 45, 0.9, 1.0).toColor(),
        ));
      }

      if (e.hp <= 0) {
        e.isDead = true;
        killedRewards += 12 + _gameState.currentWave * 2;
      }
    }
    enemies.removeWhere((e) => e.isDead);
    if (killedRewards > 0) {
      _gameState = _gameState.copyWith(coins: _gameState.coins + killedRewards);
    }

    // 演出終了処理（0.6秒後にフラグ解除）
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _ultimateActive = false);
    });
  }

  // ─── 画像プリロード ──────────────────────────────────────────────────
  Future<void> _preloadImages() async {
    // 画像キャッシング用の簡略実装（将来の詳細化に向けて予約）
    // 敵・施設画像は widgets ツリーで自動的にキャッシュされます
  }

  // ─── ウェーブ/ボスバナー演出 ─────────────────────────────────────────
  void _showWaveBanner(int wave) {
    final isBossWave = wave >= _gameState.totalWaves;
    final pref = _prefecture;
    final region = _region;
    final history = _historyStage;
    setState(() {
      _bannerIsBoss = isBossWave;
      if (isBossWave) {
        if (history != null) {
          _bannerTitle = '${history.bossEmoji} ${history.bossName} 降臨！';
          _bannerSub = '歴史決戦「${history.name}」最終決戦！';
        } else if (region != null) {
          _bannerTitle = '${region.bossEmoji} ${region.bossName} 登場！';
          _bannerSub = '地方決戦「${region.name}」最終決戦！';
        } else if (pref != null) {
          _bannerTitle = '👹 ${pref.boss.name} 登場！';
          _bannerSub = 'スキル「${pref.boss.skill}」に警戒せよ';
        }
      } else {
        // 特殊ウェーブ判定（あれば予告を優先表示）
        final mod = TdEngine.waveModifier(
            _gameState.prefCode, wave, _gameState.totalWaves);
        final modInfo = _waveModifierInfo(mod);
        _bannerTitle = modInfo != null
            ? '${modInfo.$1} $wave / ${_gameState.totalWaves}'
            : 'WAVE $wave / ${_gameState.totalWaves}';
        _bannerSub = modInfo != null
            ? modInfo.$2
            : history != null
                ? '${history.emoji} ${history.subTitle}'
                : region != null
                    ? '${region.emoji} ${region.name}地方の精鋭が迫る…'
                    : pref != null
                        ? '${pref.geographyIcon} ${pref.geographyName}の敵が迫る…'
                        : '敵が迫る…';
      }
    });
    _bannerCtrl.forward(from: 0);
    if (isBossWave) {
      _triggerShake(10, duration: 0.6);
      _say('「ボスが来た…ここがふんばりどころ！」', 4.0);
    } else if (history != null) {
      _say('「ウェーブ$wave！歴史の脅威が押し寄せる！」', 3.0);
    } else if (region != null) {
      _say('「ウェーブ$wave、地方最強の敵が来るぞ！」', 3.0);
    } else if (pref != null) {
      final mod = TdEngine.waveModifier(
          _gameState.prefCode, wave, _gameState.totalWaves);
      final line = _waveModifierLine(mod);
      _say(line ?? '「ウェーブ$wave、いくよ！」', 3.0);
    }
  }

  /// 特殊ウェーブのバナー表示情報 (絵文字付きタイトル, サブ説明)。none なら null
  (String, String)? _waveModifierInfo(String mod) {
    switch (mod) {
      case 'elite':
        return ('💪 精鋭ウェーブ', '⚠️ 装甲を固めた強敵が来る！火力で押し切れ');
      case 'swarm':
        return ('🐝 大群ウェーブ', '💨 数で押し寄せる！取りこぼしに注意');
      case 'blitz':
        return ('⚡ 電撃ウェーブ', '💨 高速の敵！射程と足止めがカギ');
      case 'bounty':
        return ('💰 ボーナスウェーブ', '🪙 撃破報酬2倍！稼ぎのチャンス');
      default:
        return null;
    }
  }

  /// 特殊ウェーブの相棒セリフ
  String? _waveModifierLine(String mod) {
    switch (mod) {
      case 'elite':
        return '「精鋭部隊だ…気を引き締めて！」';
      case 'swarm':
        return '「うわっ、すごい数！囲まれるな！」';
      case 'blitz':
        return '「速い！止められるか…！？」';
      case 'bounty':
        return '「チャンスだ！コインをがっぽり稼ごう！」';
      default:
        return null;
    }
  }

  void _onTick(Duration elapsed) {
    final dtRaw = (elapsed.inMicroseconds - _elapsed) / 1e6;
    _elapsed = elapsed.inMicroseconds.toDouble();
    if (dtRaw <= 0 || dtRaw > 0.2) return; // 最初フレームや大きな跳びを無視

    final dt = dtRaw * _gameSpeed;
    _totalTime += dtRaw;
    _gameTime += dtRaw;

    // ゲームロジック tick
    List<String> events = [];
    if (_gameState.phase == GamePhase.wave ||
        _gameState.phase == GamePhase.waveEnd) {
      final result =
          TdEngine.tick(_gameState, dt, widget.difficulty, _spawner);

      // イベント処理（tick 結果より）
      events = result.events;
      final newState = result.state;

      // ウェーブクリア時にスポーナーをリセット
      if (events.contains('wave_clear') || events.contains('victory')) {
        _spawner.reset();
      }

      // ウェーブ開始 SFX（ウェーブ番号が増えた瞬間に一度だけ）
      if (result.state.currentWave > _lastWaveForBgm &&
          result.state.phase == GamePhase.wave) {
        _lastWaveForBgm = result.state.currentWave;
        _audio.playWave();
      }

      // ウェーブ/ボス登場バナー演出（ウェーブ番号が増えた瞬間に一度だけ）
      if (result.state.currentWave > _lastWaveForBanner &&
          result.state.phase == GamePhase.wave) {
        _lastWaveForBanner = result.state.currentWave;
        _gameState = newState; // バナー判定で最新ウェーブを参照
        _showWaveBanner(result.state.currentWave);
      }

      setState(() {
        _gameState = newState;
        _processEvents(events, newState);
        _advanceEffects(dtRaw);
      });

      if (!_navigated &&
          (_gameState.phase == GamePhase.victory ||
              _gameState.phase == GamePhase.defeat)) {
        _navigated = true;
        _ticker.stop();
        _endGame();
      }
    } else {
      setState(() {
        _advanceEffects(dtRaw);
      });
    }
  }

  void _processEvents(List<String> events, TdGameState state) {
    for (final ev in events) {
      if (ev.startsWith('hit:')) {
        // hit:{facilityCol}_{facilityRow}:{enemyId}:{damage}:{enemyPathX}:{enemyPathY}:{isCrit}
        final parts = ev.substring(4).split(':');
        if (parts.length < 5) continue;
        final fParts = parts[0].split('_');
        if (fParts.length < 2) continue;
        final fCol = int.tryParse(fParts[0]) ?? 0;
        final fRow = int.tryParse(fParts[1]) ?? 0;
        final damage = int.tryParse(parts[2]) ?? 0;
        final ex = double.tryParse(parts[3]) ?? 0;
        final ey = double.tryParse(parts[4]) ?? 0;
        final isCrit = parts.length >= 6 && parts[5] == '1';
        if (isCrit) _criticalCount++;

        // 施設タイプ取得
        final fPos = GridPos(fCol, fRow);
        final facility = state.facilities[fPos];
        final fType = facility?.type ?? FacilityType.farm;
        final fColor = _facilityColors[fType] ?? Colors.white;

        // 発射体追加: from=施設中心(グリッド単位), to=敵位置(グリッド単位)
        _projectiles.add(_Projectile(
          facilityId: '${fCol}_$fRow',
          enemyId: parts[1],
          from: Offset(fCol + 0.5, fRow + 0.5),
          to: Offset(ex + 0.5, ey + 0.5),
          color: isCrit ? Colors.yellowAccent : fColor,
        ));

        // ダメージ浮遊テキスト（クリティカルは大きく金色で「CRITICAL!」付き）
        _floatingTexts.add(_FloatingText(
          pos: Offset(ex + 0.5, ey + 0.5),
          text: isCrit ? '⚡$damage CRITICAL!' : '-$damage',
          color: isCrit ? Colors.yellowAccent : Colors.redAccent,
          maxLife: isCrit ? 1.2 : 0.8,
        ));

        // クリティカル時: 追加演出（黄色パーティクル＋軽いシェイク）
        if (isCrit) {
          _triggerShake(4, duration: 0.18);
          for (var i = 0; i < 6; i++) {
            final angle = (i / 6) * 2 * pi + _rng.nextDouble() * 0.5;
            final spd = 2.0 + _rng.nextDouble() * 1.5;
            _particles.add(_Particle(
              pos: Offset(ex + 0.5, ey + 0.5),
              vel: Offset(cos(angle) * spd, sin(angle) * spd),
              maxLife: 0.4 + _rng.nextDouble() * 0.3,
              color: HSVColor.fromAHSV(1.0, 50 + _rng.nextDouble() * 15, 0.9, 1.0).toColor(),
            ));
          }
        }

        // 攻撃フラッシュ
        _flashes.removeWhere((f) => f.facilityId == '${fCol}_$fRow');
        _flashes.add(_AttackFlash(
          facilityId: '${fCol}_$fRow',
          life: 0.25,
        ));

        // 攻撃 SFX（0.1s レート制限）
        if (_gameTime - _lastAttackSfxTime > 0.1) {
          _lastAttackSfxTime = _gameTime;
          _audio.playAttack();
        }
      } else if (ev.startsWith('kill:')) {
        // kill:{enemyPathX}:{enemyPathY}:{coinReward}:{isBoss}
        final parts = ev.substring(5).split(':');
        if (parts.length < 3) continue;
        final ex = double.tryParse(parts[0]) ?? 0;
        final ey = double.tryParse(parts[1]) ?? 0;
        final reward = int.tryParse(parts[2]) ?? 0;
        final isBossKill = parts.length >= 4 && parts[3] == 'true';
        if (isBossKill) _bossKillCount++;

        _killCount++;
        _audio.playDie();
        _audio.playCoin();

        // 必殺技ゲージ加算（通常敵 +8%, ボス +40%）
        if (!_ultimateActive) {
          _ultimateCharge =
              (_ultimateCharge + (isBossKill ? 0.4 : 0.08)).clamp(0.0, 1.0);
        }

        // ボス撃破は迫力ある大きめシェイク
        if (isBossKill) _triggerShake(14, duration: 0.5);

        // パーティクルバースト（ボス撃破時は倍量・大きめ）
        final burstCount = isBossKill ? 20 : 8;
        for (var i = 0; i < burstCount; i++) {
          final angle = (i / burstCount) * 2 * pi + _rng.nextDouble() * 0.4;
          final speed = (isBossKill ? 2.5 : 1.5) + _rng.nextDouble() * 2.0;
          _particles.add(_Particle(
            pos: Offset(ex + 0.5, ey + 0.5),
            vel: Offset(cos(angle) * speed, sin(angle) * speed),
            maxLife: (isBossKill ? 0.8 : 0.5) + _rng.nextDouble() * 0.3,
            color: isBossKill
                ? HSVColor.fromAHSV(1.0, 45 + _rng.nextDouble() * 15, 0.9, 1.0).toColor()
                : HSVColor.fromAHSV(
                    1.0,
                    _rng.nextDouble() * 60, // 赤〜橙
                    0.8,
                    1.0,
                  ).toColor(),
          ));
        }

        // コイン浮遊テキスト
        _floatingTexts.add(_FloatingText(
          pos: Offset(ex + 0.5, ey + 0.5),
          text: '+$reward🪙',
          color: Colors.amberAccent,
          maxLife: 1.0,
        ));

        // コンボ更新
        _comboCount++;
        _comboTimer = 1.8;
        if (_comboCount == 5) {
          final bonus = 30;
          _gameState = _gameState.copyWith(coins: _gameState.coins + bonus);
          _floatingTexts.add(_FloatingText(
            pos: Offset(ex + 0.5, ey - 0.5),
            text: '🔥5コンボ! +$bonus🪙',
            color: Colors.orangeAccent,
            maxLife: 1.5,
          ));
        } else if (_comboCount == 10) {
          final bonus = 80;
          _gameState = _gameState.copyWith(coins: _gameState.coins + bonus);
          _floatingTexts.add(_FloatingText(
            pos: Offset(ex + 0.5, ey - 0.5),
            text: '💥10コンボ!! +$bonus🪙',
            color: Colors.redAccent,
            maxLife: 1.8,
          ));
          _triggerShake(6, duration: 0.3);
        } else if (_comboCount >= 20 && _comboCount % 10 == 0) {
          final bonus = 120;
          _gameState = _gameState.copyWith(coins: _gameState.coins + bonus);
          _floatingTexts.add(_FloatingText(
            pos: Offset(ex + 0.5, ey - 0.5),
            text: '⚡${_comboCount}コンボ!!! +$bonus🪙',
            color: Colors.purpleAccent,
            maxLife: 2.0,
          ));
          _triggerShake(9, duration: 0.35);
        }
      } else if (ev == 'reached_goal') {
        // ゴール到達: HP減少エフェクト＋赤フラッシュ＋シェイク（危機感を演出）
        final goalPos = _gameState.path.last;
        _floatingTexts.add(_FloatingText(
          pos: Offset(goalPos.col + 0.5, goalPos.row + 0.5),
          text: '-1 ❤',
          color: Colors.redAccent,
          maxLife: 1.0,
        ));
        _hitFlashTime = 0.35;
        _triggerShake(8, duration: 0.25);
      } else if (ev == 'shield_block') {
        // シールドブロック
        final goalPos = _gameState.path.last;
        _floatingTexts.add(_FloatingText(
          pos: Offset(goalPos.col + 0.5, goalPos.row + 0.5),
          text: '🛡️ガード!',
          color: Colors.cyanAccent,
          maxLife: 1.2,
        ));
      } else if (ev.startsWith('boss_skill:')) {
        // boss_skill:{skillName}:{bossX}:{bossY}
        final parts = ev.substring(11).split(':');
        if (parts.length >= 3) {
          final skillName = parts[0];
          final bx = double.tryParse(parts[1]) ?? 0;
          final by = double.tryParse(parts[2]) ?? 0;
          _triggerShake(7, duration: 0.3);
          String skillText;
          switch (skillName) {
            case 'speedBurst':
              skillText = '⚡速度UP!';
              break;
            case 'hpRegen':
              skillText = '💚回復!';
              break;
            case 'summon':
              skillText = '👾増援!';
              break;
            case 'stunFacility':
              skillText = '🌀施設停止!';
              break;
            default:
              skillText = '✨スキル!';
          }
          _floatingTexts.add(_FloatingText(
            pos: Offset(bx + 0.5, by + 0.5),
            text: skillText,
            color: Colors.purpleAccent,
            maxLife: 1.5,
          ));
          // 大きな紫パーティクルバースト（6個）
          for (var i = 0; i < 6; i++) {
            final angle = (i / 6) * 2 * pi + _rng.nextDouble() * 0.5;
            final spd = 2.0 + _rng.nextDouble() * 2.0;
            _particles.add(_Particle(
              pos: Offset(bx + 0.5, by + 0.5),
              vel: Offset(cos(angle) * spd, sin(angle) * spd),
              maxLife: 0.7 + _rng.nextDouble() * 0.4,
              color: HSVColor.fromAHSV(1.0, 270 + _rng.nextDouble() * 60, 0.9, 1.0).toColor(),
            ));
          }
        }
      } else if (ev == 'wave_clear') {
        // ウェーブクリア → ショップを開く（victoryでない場合のみ）
        if (!events.contains('victory')) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _openShop(state.currentWave));
        }
      }
    }
  }

  void _advanceEffects(double dt) {
    // 発射体を進める
    for (final p in _projectiles) {
      p.progress += dt * 4.0;
    }
    _projectiles.removeWhere((p) => p.progress >= 1.0);

    // 浮遊テキストを上へ移動（グリッド単位/秒, 描画側で cellSize を掛ける）
    for (final t in _floatingTexts) {
      t.pos = t.pos.translate(0, -0.6 * dt);
      t.life -= dt;
    }
    _floatingTexts.removeWhere((t) => t.life <= 0);

    // パーティクル移動
    for (final p in _particles) {
      p.pos = p.pos + p.vel * dt;
      p.vel = p.vel * 0.85;
      p.life -= dt;
    }
    _particles.removeWhere((p) => p.life <= 0);

    // フラッシュ
    for (final f in _flashes) {
      f.life -= dt;
    }
    _flashes.removeWhere((f) => f.life <= 0);

    // 施設配置リング
    for (final r in _placeRings) {
      r.life -= dt;
    }
    _placeRings.removeWhere((r) => r.life <= 0);

    // 画面シェイク減衰
    if (_shakeTime > 0) {
      _shakeTime -= dt;
      if (_shakeTime <= 0) {
        _shakeTime = 0;
        _shakeIntensity = 0;
      }
    }

    // ヒットフラッシュ（HPダメージ時の赤み）減衰
    if (_hitFlashTime > 0) {
      _hitFlashTime -= dt;
      if (_hitFlashTime < 0) _hitFlashTime = 0;
    }

    // 必殺技の白フラッシュ減衰
    if (_ultimateFlashTime > 0) {
      _ultimateFlashTime -= dt;
      if (_ultimateFlashTime < 0) _ultimateFlashTime = 0;
    }

    // 相棒セリフ寿命
    if (_companionLineLife > 0) {
      _companionLineLife -= dt;
    }

    // コンボタイマー減少
    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        _comboCount = 0;
      }
    }

    // 相棒の応援（ウェーブ中のみ・一定間隔で少額コイン＋セリフ）
    if (_gameState.phase == GamePhase.wave) {
      _cheerTimer -= dt;
      if (_cheerTimer <= 0) {
        _cheerTimer = 16 + _rng.nextDouble() * 6;
        final pref = _prefecture;
        const bonus = 8;
        _gameState = _gameState.copyWith(coins: _gameState.coins + bonus);
        // 応援コインの浮遊テキスト（ゴール付近）
        final goal = _gameState.path.last;
        _floatingTexts.add(_FloatingText(
          pos: Offset(goal.col + 0.5, goal.row - 0.2),
          text: '応援 +$bonus🪙',
          color: Colors.lightGreenAccent,
          maxLife: 1.2,
        ));
        if (pref != null) {
          final specialty =
              pref.specialties.isNotEmpty ? pref.specialties.first : '名産';
          final cheers = [
            '「$specialtyパワー、いっけー！」',
            '「その調子！おうえんするよ！」',
            '「まだまだ守れる、がんばろう！」',
          ];
          _say(cheers[_rng.nextInt(cheers.length)], 2.5);
        }
      }
    }
  }

  // ─── ショップ ────────────────────────────────────────────────────────

  void _openShop(int waveNumber) {
    if (!mounted || _shopOpen) return;
    _ticker.stop();
    final shuffled = List<_ShopItem>.from(_allShopItems)..shuffle(_rng);
    setState(() {
      _shopOpen = true;
      _currentShopItems = shuffled.take(3).toList();
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ウェーブ$waveNumberクリア！ショップ',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('アイテムを1つ選んでください',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
                ..._currentShopItems.map((item) {
                  final canAfford = _gameState.coins >= item.cost || item.cost == 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canAfford
                            ? () {
                                Navigator.of(ctx).pop();
                                setState(() {
                                  if (item.cost > 0) {
                                    _gameState = _gameState.copyWith(
                                        coins: _gameState.coins - item.cost);
                                  }
                                  _applyShopEffect(item.effectKey);
                                  _shopOpen = false;
                                });
                                _ticker.start();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A3545),
                          disabledBackgroundColor: Colors.white10,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          children: [
                            Text(item.emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  Text(item.description,
                                      style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                            Text(
                              item.cost == 0 ? '無料' : '🪙${item.cost}',
                              style: TextStyle(
                                  color: canAfford
                                      ? Colors.amberAccent
                                      : Colors.white30,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() => _shopOpen = false);
                    _ticker.start();
                  },
                  child: const Text('スキップ',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyShopEffect(String key) {
    switch (key) {
      case 'heal2':
        _gameState = _gameState.copyWith(baseHp: _gameState.baseHp + 2);
        break;
      case 'coins120':
        _gameState = _gameState.copyWith(coins: _gameState.coins + 120);
        break;
      case 'dmgBonus':
        _gameState = _gameState.copyWith(
            facilityDamageBonus: _gameState.facilityDamageBonus + 0.3);
        break;
      case 'shield3':
        _gameState =
            _gameState.copyWith(shieldHits: _gameState.shieldHits + 3);
        break;
      case 'speedDown':
        _gameState = _gameState.copyWith(
            enemySpeedPenalty: _gameState.enemySpeedPenalty + 0.25);
        break;
      case 'facilityRepair':
        final newFacilities = Map<GridPos, Facility>.from(_gameState.facilities)
            .map((k, v) => MapEntry(k, v.copyWith(attackCooldown: 0)));
        _gameState = _gameState.copyWith(facilities: newFacilities);
        break;
    }
  }

  // ─── クイズ ──────────────────────────────────────────────────────────

  _QuizQuestion _generateQuiz(PrefectureData pref, List<PrefectureData> allPrefs) {
    final type = _rng.nextInt(3);

    if (type == 0) {
      // 県庁所在地クイズ
      final wrongList = allPrefs
          .where((p) => p.code != pref.code)
          .map((p) => p.capitalCity)
          .toList()
        ..shuffle(_rng);
      final options = [pref.capitalCity, ...wrongList.take(3)]..shuffle(_rng);
      return _QuizQuestion(
        question: '${pref.name}の県庁所在地は？',
        options: options,
        correctIndex: options.indexOf(pref.capitalCity),
      );
    } else if (type == 1) {
      // 特産品クイズ
      final correct = pref.specialties.isNotEmpty ? pref.specialties.first : pref.name;
      final wrongPrefs = allPrefs.where((p) => p.code != pref.code).toList()..shuffle(_rng);
      final wrong = wrongPrefs
          .take(3)
          .map((p) => p.specialties.isNotEmpty ? p.specialties.first : p.name)
          .toList();
      final options = [correct, ...wrong]..shuffle(_rng);
      return _QuizQuestion(
        question: '${pref.name}の特産品は？',
        options: options,
        correctIndex: options.indexOf(correct),
      );
    } else {
      // ボス名クイズ
      final correct = pref.boss.name;
      final wrongPrefs = allPrefs.where((p) => p.code != pref.code).toList()..shuffle(_rng);
      final wrong = wrongPrefs.take(3).map((p) => p.boss.name).toList();
      final options = [correct, ...wrong]..shuffle(_rng);
      return _QuizQuestion(
        question: '${pref.name}のボスの名前は？',
        options: options,
        correctIndex: options.indexOf(correct),
      );
    }
  }

  void _onQuizAnswer(int index) {
    final quiz = _currentQuiz;
    if (quiz == null || _quizAnswered) return;
    setState(() {
      _quizSelectedIndex = index;
      if (index == quiz.correctIndex) {
        _gameState = _gameState.copyWith(coins: _gameState.coins + 40);
        final path = _gameState.path;
        final midPos = path[path.length ~/ 2];
        _floatingTexts.add(_FloatingText(
          pos: Offset(midPos.col + 0.5, midPos.row + 0.5),
          text: '🎉+40🪙',
          color: Colors.amber,
          maxLife: 1.5,
        ));
      }
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _quizAnswered = true);
    });
  }

  void _endGame() {
    final isCleared = _gameState.phase == GamePhase.victory;
    if (isCleared) {
      _audio.playVictory();
    } else {
      _audio.playDefeat();
    }
    _audio.stopBgm();

    if (widget.regionCode.startsWith('h')) {
      ref.read(gameServiceProvider).endHistoryBattle(
        histCode: widget.regionCode,
        finalScore: _gameState.score,
        finalTime: _totalTime.round(),
        isCleared: isCleared,
      );
    } else if (widget.regionCode.isNotEmpty) {
      ref.read(gameServiceProvider).endRegionBattle(
        regionCode: widget.regionCode,
        finalScore: _gameState.score,
        finalTime: _totalTime.round(),
        isCleared: isCleared,
      );
    } else {
      ref.read(gameServiceProvider).endGame(
        finalScore: _gameState.score,
        finalTime: _totalTime.round(),
        finalMistakes: _gameState.mistakes,
        isCleared: isCleared,
        facilitiesUsed: _facilitiesUsed,
        bossKills: _bossKillCount,
        usedUltimate: _usedUltimateThisGame,
        maxSynergyDirections: _maxSynergyDirections,
        criticalCount: _criticalCount,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            prefectureCode: widget.prefectureCode,
            regionCode: widget.regionCode,
            difficulty: widget.difficulty,
            score: _gameState.score,
            clearTime: _totalTime.round(),
            mistakes: _gameState.mistakes,
            isCleared: isCleared,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bannerCtrl.dispose();
    _audio.stopBgm();
    super.dispose();
  }

  // ─── タップ処理 ──────────────────────────────────────────────────────

  void _handleTap(GridPos pos) {
    // 既存施設をタップ → アップグレードシート
    if (_gameState.facilities.containsKey(pos)) {
      _showUpgradeSheet(pos);
      return;
    }

    // パス上はスキップ
    if (_gameState.pathSet.contains(pos)) return;

    // prep または wave フェーズ中なら配置可能
    if (_gameState.phase == GamePhase.prep ||
        _gameState.phase == GamePhase.wave) {
      // プレビュー表示またはそのまま配置
      if (_previewPos == pos) {
        // 同じセルを再タップ → 配置確定
        final newState =
            TdEngine.placeFacility(_gameState, pos, _selectedFacility);
        if (newState != null) {
          _facilitiesUsed.add(_selectedFacility.name);
          setState(() {
            _gameState = newState;
            _previewPos = null;
            _placeRings.add(_PlaceRing(
              pos: Offset(pos.col + 0.5, pos.row + 0.5),
              color: _facilityColors[_selectedFacility] ?? Colors.white,
            ));
          });
          _triggerShake(3, duration: 0.15);
          _audio.playPlace();

          // シナジー発生時のフィードバック（隣接同種施設あり）
          final placed = newState.facilities[pos];
          if (placed != null) {
            final mult = TdEngine.synergyMultiplier(newState, placed);
            if (mult > 1.0) {
              final pct = ((mult - 1.0) * 100).round();
              final directions = (pct / 15).round();
              if (directions > _maxSynergyDirections) {
                _maxSynergyDirections = directions;
              }
              _floatingTexts.add(_FloatingText(
                pos: Offset(pos.col + 0.5, pos.row - 0.3),
                text: '✨シナジー +$pct%',
                color: Colors.cyanAccent,
                maxLife: 1.5,
              ));
            }
          }
        } else {
          // 配置失敗 → 理由をユーザーに表示
          String reason = '施設を配置できません';
          if (_gameState.coins < _selectedFacility.cost) {
            reason = '金貨が足りません';
          } else if (_gameState.pathSet.contains(pos)) {
            reason = '道を塞いでます';
          } else if (_gameState.facilities.containsKey(pos)) {
            reason = 'すでに施設があります';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reason),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red.shade800,
            ),
          );

          setState(() => _previewPos = null);
        }
      } else {
        // 別のセルをタップ → プレビュー更新
        // 配置可能性を事前チェック（不可の場合は理由を即座に表示）
        final canPlace = !_gameState.pathSet.contains(pos) &&
            !_gameState.facilities.containsKey(pos) &&
            _gameState.coins >= _selectedFacility.cost;

        if (canPlace) {
          setState(() => _previewPos = pos);
        } else {
          String reason = '施設を配置できません';
          if (_gameState.coins < _selectedFacility.cost) {
            reason = '🪙 金貨が足りません (必要: ${_selectedFacility.cost}, 保持: ${_gameState.coins})';
          } else if (_gameState.pathSet.contains(pos)) {
            reason = '🛤️ この場所は道を塞ぎます';
          } else if (_gameState.facilities.containsKey(pos)) {
            reason = '⚠️ この場所には既に施設があります';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reason),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red.shade800,
            ),
          );

          setState(() => _previewPos = null);
        }
      }
    }
  }

  // ─── ウェーブスキル選択シート ──────────────────────────────────────
  void _showSkillSelectionSheet() {
    // ランダムに4スキルから3個を選択（毎回異なる選択肢）
    final availableSkills = List<_SkillChoice>.from(_waveSkillChoices)..shuffle(_rng);
    final selectedSkills = availableSkills.take(3).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                Text(
                  '⭐ ウェーブスキルを選択',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '次のウェーブで効果が適用されます',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // スキルカード一覧
                ...selectedSkills.map((skill) => GestureDetector(
                  onTap: () {
                    // スキルを選択 → 状態を更新 → シートを閉じる
                    setState(() {
                      _gameState = _gameState.copyWith(selectedSkill: skill.effectKey);
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // スキルアイコン
                        Text(skill.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        // スキル名と説明
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                skill.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                skill.description,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // チェックマーク
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.orangeAccent,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpgradeSheet(GridPos pos) {
    final f = _gameState.facilities[pos];
    if (f == null) return;
    final fColor = _facilityColors[f.type] ?? Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final current = _gameState.facilities[pos];
          if (current == null) {
            Navigator.of(ctx).pop();
            return const SizedBox.shrink();
          }
          final canUpgrade = _gameState.coins >= current.upgradeCost;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(current.type.emoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.type.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Lv ${current.level}',
                          style: TextStyle(
                              color: fColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('⚔️', '攻撃力', '${current.damage}'),
                      _statItem('🎯', '射程', '${current.range.toStringAsFixed(1)}'),
                      _statItem('⚡', '速度', '${current.type.attackSpeed.toStringAsFixed(1)}/s'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: canUpgrade
                      ? () {
                          final newState =
                              TdEngine.upgradeFacility(_gameState, pos);
                          if (newState != null) {
                            setState(() => _gameState = newState);
                            setSheetState(() {}); // シート内再描画
                            _audio.playPlace();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fColor,
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    canUpgrade
                        ? 'アップグレード 🪙${current.upgradeCost}'
                        : 'コイン不足 (必要: ${current.upgradeCost})',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    final newState =
                        TdEngine.removeFacility(_gameState, pos);
                    setState(() => _gameState = newState);
                    Navigator.of(ctx).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    '売却 (+${(current.type.cost / 2).round()}🪙)',
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statItem(String icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ],
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pref = _prefecture;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onBackPressed();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Color.lerp(const Color(0xFF0F1620), _prefColor, 0.12)!,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(pref),
              Expanded(
                child: Transform.translate(
                  offset: _currentShakeOffset,
                  child: Stack(
                    children: [
                      _buildGameField(),
                      // HPダメージ時の赤フラッシュ（危機感の演出）
                      if (_hitFlashTime > 0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              color: Colors.red.withOpacity(
                                0.28 * (_hitFlashTime / 0.35).clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                        ),
                      // 必殺技発動時の白/金フラッシュ
                      if (_ultimateFlashTime > 0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              color: Colors.amberAccent.withOpacity(
                                0.5 * (_ultimateFlashTime / 0.5).clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _buildControlPanel(),
            ],
          ),
        ),
      ),
    );
  }

  /// 現在のフレームの画面シェイクオフセットを計算（減衰しながら振動）
  Offset get _currentShakeOffset {
    if (_shakeTime <= 0 || _shakeMaxTime <= 0) return Offset.zero;
    final decay = (_shakeTime / _shakeMaxTime).clamp(0.0, 1.0);
    final mag = _shakeIntensity * decay;
    final dx = sin(_gameTime * 60) * mag;
    final dy = cos(_gameTime * 47) * mag * 0.6;
    return Offset(dx, dy);
  }

  Future<bool> _onBackPressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text('中断しますか？',
            style: TextStyle(color: Colors.white)),
        content: const Text('ゲームを中断してトップに戻りますか？',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('続ける', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('中断', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  Widget _buildTopBar(PrefectureData? pref) {
    final region = _region;
    final history = _historyStage;
    final diffColor = history != null
        ? history.color
        : region != null
            ? region.color
            : (pref != null ? _getDifficultyColor(pref.difficultyRating) : Colors.white54);
    final hpRatio =
        (_initialHp > 0 ? _gameState.baseHp / _initialHp : 1.0).clamp(0.0, 1.0);
    final hpColor = hpRatio > 0.5
        ? Colors.greenAccent
        : hpRatio > 0.25
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Container(
      color: const Color(0xFF0F1620),
      padding: const EdgeInsets.fromLTRB(4, 2, 8, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上段: ナビ・地理アイコン・県名・コイン・ウェーブ
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white54, size: 18),
                onPressed: () async {
                  if (await _onBackPressed() && mounted) {
                    Navigator.of(context).pop();
                  }
                },
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              if (history != null) ...[
                Text(history.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
              ] else if (region != null) ...[
                Text(region.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
              ] else if (pref != null) ...[
                Text(pref.geographyIcon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      history != null
                          ? history.name
                          : region != null
                              ? '${region.name}地方 決戦'
                              : pref?.name ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (history != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: history.color.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '歴史決戦 ${history.totalWaves}波',
                          style: TextStyle(
                            color: history.color,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (region != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: region.color.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '地方決戦 7波',
                          style: TextStyle(
                            color: region.color,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (pref != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(pref.difficultyStars,
                              style: const TextStyle(fontSize: 9)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: diffColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pref.difficultyLabel,
                              style: TextStyle(
                                color: diffColor,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // コイン（大きく）
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  Text(
                    ' ${_gameState.coins}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // ウェーブカウンター（目立つバッジ）
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.orangeAccent.withOpacity(0.6), width: 1),
                ),
                child: Text(
                  'W${_gameState.currentWave}/${_gameState.totalWaves}',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // 下段: HP バー
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 3, 0, 0),
            child: Row(
              children: [
                Icon(Icons.favorite, color: hpColor, size: 13),
                const SizedBox(width: 4),
                Text(
                  '${_gameState.baseHp}',
                  style: TextStyle(
                    color: hpColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: hpRatio,
                      minHeight: 5,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(hpColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '⏱ ${_totalTime.toInt()}s',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 難易度に応じた色を取得
  Color _getDifficultyColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.deepPurple;
      default:
        return Colors.white54;
    }
  }

  Widget _buildGameField() {
    return LayoutBuilder(builder: (context, constraints) {
      final cellSize = min(
        constraints.maxWidth / TdEngine.cols,
        constraints.maxHeight / TdEngine.rows,
      );
      final fieldW = cellSize * TdEngine.cols;
      final fieldH = cellSize * TdEngine.rows;

      // プレビューセルが施設なし・パスなしのセルか確認
      GridPos? validPreview;
      if (_previewPos != null &&
          !_gameState.pathSet.contains(_previewPos!) &&
          !_gameState.facilities.containsKey(_previewPos!)) {
        validPreview = _previewPos;
      }

      final gameField = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final localX = (details.localPosition.dx - (constraints.maxWidth - fieldW) / 2);
          final localY = (details.localPosition.dy - (constraints.maxHeight - fieldH) / 2);
          final col = (localX / cellSize).floor();
          final row = (localY / cellSize).floor();
          if (col < 0 || col >= TdEngine.cols || row < 0 || row >= TdEngine.rows) {
            setState(() => _previewPos = null);
            return;
          }
          _handleTap(GridPos(col, row));
        },
        child: Center(
          child: SizedBox(
            width: fieldW,
            height: fieldH,
            child: Stack(
              children: [
                // 背景画像（history stage の場合）
                if (widget.regionCode.startsWith('h'))
                  _buildBackgroundImage(widget.regionCode),
                // ゲームフィールド
                CustomPaint(
                  painter: _GameFieldPainter(
                    state: _gameState,
                    cellSize: cellSize,
                    projectiles: _projectiles,
                    floatingTexts: _floatingTexts,
                    particles: _particles,
                    flashes: _flashes,
                    placeRings: _placeRings,
                    previewPos: validPreview,
                    selectedFacility: _selectedFacility,
                    gameTime: _gameTime,
                    facilityColors: _GameScreenState._facilityColors,
                    prefectureCode: widget.prefectureCode,
                    geography: _prefecture?.geography ?? 'mixed',
                    weather: _prefecture?.weather ?? 'clear',
                  ),
                ),
                // 敵の画像レイヤー
                ..._buildEnemyImageLayers(cellSize, fieldW, fieldH),
                // 施設の画像レイヤー
                ..._buildFacilityImageLayers(cellSize, fieldW, fieldH),
              ],
            ),
          ),
        ),
      );

      final quiz = _currentQuiz;
      final showQuiz = quiz != null && !_quizAnswered && _gameState.phase == GamePhase.prep;

      return Stack(
        children: [
          gameField,
          // ウェーブ/ボス登場バナー
          _buildWaveBanner(),
          // ご当地相棒の吹き出し
          if (_companionLineLife > 0) _buildCompanionBubble(),
          // クイズ（prepフェーズ）
          if (showQuiz) _buildQuizOverlay(quiz),
        ],
      );
    });
  }

  // ─── ウェーブ/ボス登場バナー ─────────────────────────────────────────
  Widget _buildWaveBanner() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _bannerCtrl,
          builder: (context, child) {
            final v = _bannerCtrl.value;
            if (v == 0 || v >= 1) return const SizedBox.shrink();
            // フェードイン→保持→フェードアウト
            final opacity = v < 0.2
                ? (v / 0.2)
                : v > 0.8
                    ? (1 - (v - 0.8) / 0.2)
                    : 1.0;
            // 横スライド
            final slide = (1 - opacity) * 40 * (v < 0.5 ? -1 : 1);
            final accent =
                _bannerIsBoss ? Colors.redAccent : AppColors.accent;

            // 登場時にオーバーシュートする弾むスケール（ボス戦はより大きく弾む）
            final entrance = (v / 0.2).clamp(0.0, 1.0);
            final overshoot = _bannerIsBoss ? 0.28 : 0.12;
            final scale = v >= 0.2
                ? 1.0
                : 1.0 - overshoot + overshoot * (1 - (1 - entrance) * (1 - entrance));

            // ボス戦のみ: 脈動するグロー
            final pulse = _bannerIsBoss
                ? 0.5 + 0.5 * sin(_gameTime * 6)
                : 0.0;

            return Center(
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(slide, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 40),
                      padding: EdgeInsets.symmetric(
                          vertical: _bannerIsBoss ? 22 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(_bannerIsBoss ? 0.85 : 0.75),
                            Colors.black.withOpacity(0),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                              color: accent, width: _bannerIsBoss ? 3 : 2),
                          bottom: BorderSide(
                              color: accent, width: _bannerIsBoss ? 3 : 2),
                        ),
                        boxShadow: _bannerIsBoss
                            ? [
                                BoxShadow(
                                  color: accent.withOpacity(0.35 + 0.35 * pulse),
                                  blurRadius: 24 + 16 * pulse,
                                  spreadRadius: 2 + 3 * pulse,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _bannerTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accent,
                              fontSize: _bannerIsBoss ? 32 : 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: _bannerIsBoss ? 3 : 2,
                              shadows: [
                                const Shadow(color: Colors.black, blurRadius: 8),
                                if (_bannerIsBoss)
                                  Shadow(
                                    color: accent.withOpacity(0.8),
                                    blurRadius: 16 + 10 * pulse,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _bannerSub,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: _bannerIsBoss ? 14 : 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── ご当地相棒の吹き出し ────────────────────────────────────────────
  Widget _buildCompanionBubble() {
    final pref = _prefecture;
    final emoji = pref?.companionEmoji ?? '🐾';
    final name = pref?.companion.name ?? '相棒';
    return Positioned(
      left: 8,
      right: 8,
      bottom: 8,
      child: IgnorePointer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.85),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1620).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _companionLine,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOverlay(_QuizQuestion quiz) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          color: const Color(0xFF1A2332),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '📝 クイズ！+40コイン',
                  style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 12),
                Text(
                  quiz.question,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...quiz.options.asMap().entries.map((e) {
                  Color btnColor = const Color(0xFF2A3545);
                  if (_quizSelectedIndex != null) {
                    if (e.key == quiz.correctIndex) {
                      btnColor = Colors.green.shade700;
                    } else if (e.key == _quizSelectedIndex) {
                      btnColor = Colors.red.shade700;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _quizSelectedIndex == null
                            ? () => _onQuizAnswer(e.key)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnColor,
                          disabledBackgroundColor: btnColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          e.value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }),
                if (_quizSelectedIndex != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _quizSelectedIndex == quiz.correctIndex
                          ? '🎉 正解！+40🪙'
                          : '❌ 残念！',
                      style: TextStyle(
                          color: _quizSelectedIndex == quiz.correctIndex
                              ? Colors.amber
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    final isWave = _gameState.phase == GamePhase.wave;
    final isWaveEnd = _gameState.phase == GamePhase.waveEnd;
    final totalEnemies = isWave
        ? (widget.regionCode.startsWith('h')
            ? TdEngine.historyBattleWaves(widget.regionCode, widget.difficulty)[_gameState.currentWave - 1].enemyCount
            : widget.regionCode.isNotEmpty
                ? TdEngine.regionBattleWaves(widget.regionCode, widget.difficulty)[_gameState.currentWave - 1].enemyCount
                : TdEngine.wavesForPrefecture(_gameState.prefCode, widget.difficulty)[_gameState.currentWave - 1].enemyCount)
        : 0;
    // 限定施設フィルター: この都道府県の限定施設のみ表示（地方決戦では全限定施設を非表示）
    final exclusiveForThisPref = widget.regionCode.isEmpty
        ? TdEngine.exclusiveFacilityForPrefecture(widget.prefectureCode)
        : null;
    final displayFacilities = FacilityType.values.where((type) {
      if (TdEngine.isExclusiveFacility(type)) {
        return type == exclusiveForThisPref;
      }
      return true;
    }).toList();
    final remaining = _gameState.enemies.length;

    return Container(
      color: const Color(0xFF0F1620),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ウェーブ進捗バー
          if (isWave) ...[
            _buildWaveProgressBar(remaining, totalEnemies),
            const SizedBox(height: 6),
          ],

          // スコア・時間・キル + コンボ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip(Icons.star, '${_gameState.score} pts', Colors.amber),
              _statChip(Icons.timer, '${_totalTime.toInt()}s', Colors.white70),
              _statChip(Icons.flash_on, '$_killCount kill', Colors.pinkAccent),
              if (_comboCount >= 2)
                _comboChip(_comboCount),
            ],
          ),
          const SizedBox(height: 6),

          // 次ウェーブ予告
          if (_gameState.phase == GamePhase.prep || isWaveEnd)
            _buildNextWavePreview(),
          if (_gameState.phase == GamePhase.prep || isWaveEnd)
            const SizedBox(height: 4),

          // 必殺技ゲージ（ウェーブ中のみ表示）
          if (isWave) ...[
            _buildUltimateBar(),
            const SizedBox(height: 6),
          ],

          // 施設ボタン（スクロール可能） + 2×スピードボタン
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: displayFacilities
                        .map((type) => _buildFacilityBtnFixed(type))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildSpeedBtn(),
            ],
          ),

          // ウェーブ間カウントダウン
          if (isWaveEnd) ...[
            const SizedBox(height: 6),
            // スキル選択ボタン（未選択時）
            if (_gameState.selectedSkill == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showSkillSelectionSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                    side: BorderSide(color: Colors.purpleAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    '⭐ ウェーブスキルを選択',
                    style: TextStyle(
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              )
            else
              // スキル選択済みの表示
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '✓ スキルが選択されました',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '次のウェーブまで ${_gameState.waveTimer.ceil()} 秒',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                ElevatedButton(
                  onPressed: () {
                    _spawner.reset();
                    setState(() {
                      _gameState = TdEngine.startWave(_gameState, widget.difficulty)
                          .copyWith(selectedSkill: null); // 次ウェーブのためにスキルをリセット
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    '今すぐ開始',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ],

          // prep フェーズ 開始ボタン
          if (_gameState.phase == GamePhase.prep) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _spawner.reset();
                  setState(() {
                    _gameState =
                        TdEngine.startWave(_gameState, widget.difficulty);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  '開始!',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaveProgressBar(int remaining, int total) {
    final progress = total > 0 ? 1.0 - (remaining / total) : 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ウェーブ ${_gameState.currentWave}/${_gameState.totalWaves}',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
            Text(
              '残り $remaining 体',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _comboChip(int combo) {
    final color = combo >= 10 ? Colors.purpleAccent : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        '${combo >= 10 ? "💥" : "🔥"}$combo COMBO',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBackgroundImage(String historyCode) {
    final backgroundImagePath = _getHistoryBackgroundImage(historyCode);
    if (backgroundImagePath == null) return const SizedBox.shrink();

    return Image.asset(
      backgroundImagePath,
      fit: BoxFit.cover,
      opacity: const AlwaysStoppedAnimation(0.3),
      errorBuilder: (context, error, stackTrace) {
        return Container(color: Colors.grey.shade800);
      },
    );
  }

  String? _getHistoryBackgroundImage(String historyCode) {
    switch (historyCode) {
      case 'h01':
        return 'assets/images/stages/H01. 神代の決戦 — 背景.jpg';
      case 'h02':
        return 'assets/images/stages/H02. 戦国の決戦 — 背景.jpg';
      case 'h03':
        return 'assets/images/stages/H03. 幕末・文明開化 — 背景.jpg';
      case 'h04':
        return 'assets/images/stages/H04. 令和の最終決戦 — 背景.jpg';
      default:
        return null;
    }
  }

  List<Widget> _buildEnemyImageLayers(double cellSize, double fieldW, double fieldH) {
    final List<Widget> layers = [];
    for (final enemy in _gameState.enemies) {
      if (enemy.isDead) continue;

      final ePos = enemy.posOnPath(_gameState.path);
      final cx = (ePos.dx + 0.5) * cellSize;
      final cy = (ePos.dy + 0.5) * cellSize;

      final imagePath = enemyTypeImages[enemy.enemyType.name];
      if (imagePath == null || imagePath.isEmpty) continue;

      final radius = (enemy.isBoss ? 0.44 : 0.3) * cellSize;
      final size = radius * 2;

      layers.add(
        Positioned(
          left: cx - radius,
          top: cy - radius,
          width: size,
          height: size,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }
    return layers;
  }

  List<Widget> _buildFacilityImageLayers(double cellSize, double fieldW, double fieldH) {
    final List<Widget> layers = [];
    for (final facility in _gameState.facilities.values) {
      final pos = facility.pos;
      final cx = (pos.col + 0.5) * cellSize;
      final cy = (pos.row + 0.5) * cellSize;

      final imagePath = facilityTypeImages[facility.type.name];
      if (imagePath == null || imagePath.isEmpty) continue;

      final radius = cellSize * 0.35;
      final size = radius * 2;

      layers.add(
        Positioned(
          left: cx - radius,
          top: cy - radius,
          width: size,
          height: size,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }
    return layers;
  }

  String _enemyTypeEmoji(EnemyType type) {
    switch (type) {
      case EnemyType.speedy:  return '💨';
      case EnemyType.armored: return '🛡️';
      case EnemyType.healer:  return '💚';
      default:                return '👾';
    }
  }

  Widget _buildNextWavePreview() {
    final nextWave = _gameState.currentWave + 1;
    if (nextWave > _gameState.totalWaves) return const SizedBox.shrink();
    final List<WaveDefinition> waves;
    if (widget.regionCode.startsWith('h')) {
      waves = TdEngine.historyBattleWaves(widget.regionCode, widget.difficulty);
    } else if (widget.regionCode.isNotEmpty) {
      waves = TdEngine.regionBattleWaves(widget.regionCode, widget.difficulty);
    } else {
      waves = TdEngine.wavesForPrefecture(_gameState.prefCode, widget.difficulty);
    }
    if (nextWave > waves.length) return const SizedBox.shrink();
    final waveDef = waves[nextWave - 1];
    final typeCount = <EnemyType, int>{};
    for (final t in waveDef.enemyTypes) {
      typeCount[t] = (typeCount[t] ?? 0) + 1;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            '次 W$nextWave:',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(width: 6),
          Text(
            '${waveDef.enemyCount}体  ',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          ...typeCount.entries.map((e) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              '${_enemyTypeEmoji(e.key)}×${e.value}',
              style: const TextStyle(fontSize: 12),
            ),
          )),
          if (waveDef.hasBoss) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('⚠️BOSS', style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFacilityBtnFixed(FacilityType type) {
    final isSelected = _selectedFacility == type;
    final canAfford = _gameState.coins >= type.cost;
    final fColor = _facilityColors[type] ?? Colors.white;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedFacility = type;
        _previewPos = null;
      }),
      child: Container(
        width: 68,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? fColor.withOpacity(0.35)
              : canAfford
                  ? Colors.white10
                  : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: fColor, width: 2.5)
              : Border.all(
                  color: canAfford ? Colors.white24 : Colors.white12,
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: fColor.withOpacity(0.45),
                      blurRadius: 10,
                      spreadRadius: 1)
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type.emoji, style: const TextStyle(fontSize: 20)),
            Text(
              type.label,
              style: TextStyle(
                color: canAfford ? Colors.white : Colors.white30,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '🪙${type.cost}',
              style: TextStyle(
                color: canAfford ? Colors.amberAccent : Colors.white30,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityBtn(FacilityType type) {
    final isSelected = _selectedFacility == type;
    final canAfford = _gameState.coins >= type.cost;
    final fColor = _facilityColors[type] ?? Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedFacility = type;
          _previewPos = null;
        }),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? fColor.withOpacity(0.3)
                : Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: fColor, width: 2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(type.emoji, style: const TextStyle(fontSize: 18)),
              Text(
                type.label,
                style: TextStyle(
                  color: canAfford ? Colors.white : Colors.white30,
                  fontSize: 9,
                ),
              ),
              Text(
                '🪙${type.cost}',
                style: TextStyle(
                  color: canAfford ? Colors.amber : Colors.white30,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUltimateBar() {
    final ready = _ultimateCharge >= 1.0;
    // 満タン時は脈動するグロー
    final pulse = ready ? (0.5 + 0.5 * sin(_gameTime * 8)) : 0.0;
    return GestureDetector(
      onTap: ready ? _activateUltimate : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ready
              ? Colors.orangeAccent.withOpacity(0.18 + 0.12 * pulse)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ready
                ? Colors.orangeAccent.withOpacity(0.7 + 0.3 * pulse)
                : Colors.white24,
            width: ready ? 2 : 1,
          ),
          boxShadow: ready
              ? [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.4 * pulse),
                    blurRadius: 12 * pulse,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              ready ? '🔥' : '⚡',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ready ? '必殺技 発動可能！タップ！' : '必殺・領土防衛',
                    style: TextStyle(
                      color: ready ? Colors.orangeAccent : Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _ultimateCharge,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ready ? Colors.orangeAccent : Colors.amber.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedBtn() {
    final speedLabel =
        _gameSpeed == 1.0 ? '1x' : _gameSpeed == 2.0 ? '2x' : '3x';
    final speedIcon =
        _gameSpeed == 1.0 ? '▶' : _gameSpeed == 2.0 ? '⚡' : '🔥';
    final speedColor = _gameSpeed == 1.0
        ? Colors.white54
        : _gameSpeed == 2.0
            ? Colors.deepPurpleAccent
            : Colors.redAccent;

    return GestureDetector(
      onTap: () => setState(() {
        if (_gameSpeed == 1.0) {
          _gameSpeed = 2.0;
        } else if (_gameSpeed == 2.0) {
          _gameSpeed = 3.0;
        } else {
          _gameSpeed = 1.0;
        }
      }),
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: _gameSpeed > 1.0
              ? speedColor.withOpacity(0.3)
              : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: _gameSpeed > 1.0
              ? Border.all(color: speedColor, width: 2)
              : Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(speedIcon, style: const TextStyle(fontSize: 16)),
            Text(
              speedLabel,
              style: TextStyle(
                color: speedColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CustomPainter ────────────────────────────────────────────────────────

class _GameFieldPainter extends CustomPainter {
  final TdGameState state;
  final double cellSize;
  final List<_Projectile> projectiles;
  final List<_FloatingText> floatingTexts;
  final List<_Particle> particles;
  final List<_AttackFlash> flashes;
  final List<_PlaceRing> placeRings;
  final GridPos? previewPos;
  final FacilityType selectedFacility;
  final double gameTime;
  final Map<FacilityType, Color> facilityColors;
  final String? prefectureCode;
  final String? geography;
  final String weather;

  _GameFieldPainter({
    required this.state,
    required this.cellSize,
    required this.projectiles,
    required this.floatingTexts,
    required this.particles,
    required this.flashes,
    this.placeRings = const [],
    required this.previewPos,
    required this.selectedFacility,
    required this.gameTime,
    required this.facilityColors,
    this.prefectureCode,
    this.geography = 'mixed',
    this.weather = 'clear',
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas);
    _drawTerrainTint(canvas, size);
    _drawPath(canvas);
    _drawRangePreview(canvas);
    _drawSynergyLinks(canvas);
    _drawFacilities(canvas);
    _drawPlaceRings(canvas);
    _drawProjectiles(canvas);
    _drawParticles(canvas);
    _drawEnemies(canvas);
    _drawWeather(canvas, size);
    _drawFloatingTexts(canvas);
    _drawOverlay(canvas, size);
  }

  // ─── 施設配置リング ──────────────────────────────────────────────────

  /// 施設配置時に拡大しながらフェードアウトするリング（配置の満足感を演出）
  void _drawPlaceRings(Canvas canvas) {
    for (final r in placeRings) {
      final cx = r.pos.dx * cellSize;
      final cy = r.pos.dy * cellSize;
      final alpha = (1.0 - r.progress).clamp(0.0, 1.0);
      final radius = cellSize * (0.3 + r.progress * 0.9);

      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()
          ..color = r.color.withOpacity(alpha * 0.8)
          ..strokeWidth = 3.0 * alpha + 0.5
          ..style = PaintingStyle.stroke,
      );
      // 内側にもう一段（二重リングでより華やかに）
      canvas.drawCircle(
        Offset(cx, cy),
        radius * 0.6,
        Paint()
          ..color = r.color.withOpacity(alpha * 0.5)
          ..strokeWidth = 2.0 * alpha + 0.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  // ─── 地形ティント & 天候 ─────────────────────────────────────────────

  /// 地形に応じた薄い色のオーバーレイ（戦場の雰囲気づけ）
  void _drawTerrainTint(Canvas canvas, Size size) {
    Color tint;
    switch (geography) {
      case 'sea':
        tint = const Color(0xFF1565C0).withOpacity(0.10);
        break;
      case 'mountain':
        tint = const Color(0xFF4E342E).withOpacity(0.10);
        break;
      case 'urban':
        tint = const Color(0xFF6A1B9A).withOpacity(0.10);
        break;
      case 'agriculture':
        tint = const Color(0xFF2E7D32).withOpacity(0.10);
        break;
      default:
        return; // mixed はティントなし
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = tint,
    );
  }

  /// 天候の環境パーティクル（雪・波・霧・ネオン・落葉）。gameTime で決定的に動かす。
  void _drawWeather(Canvas canvas, Size size) {
    switch (weather) {
      case 'snow':
        _drawFalling(canvas, size, Colors.white.withOpacity(0.8), 26, 0.5, round: true);
        break;
      case 'leaf':
        _drawFalling(canvas, size, const Color(0xFF8BC34A).withOpacity(0.7), 16, 0.6, round: false);
        break;
      case 'wave':
        _drawWaveLines(canvas, size);
        break;
      case 'fog':
        _drawFog(canvas, size);
        break;
      case 'neon':
        _drawNeon(canvas, size);
        break;
      default:
        break;
    }
  }

  // 落下系（雪・落葉）
  void _drawFalling(Canvas canvas, Size size, Color color, int count,
      double fallSpeed, {required bool round}) {
    final paint = Paint()..color = color;
    for (var i = 0; i < count; i++) {
      // 決定的な疑似乱数
      final seedX = (i * 73 % 100) / 100.0;
      final swing = sin(gameTime * 1.2 + i) * 0.02;
      final x = (seedX + swing) * size.width;
      final speed = fallSpeed * (0.6 + (i % 5) * 0.12);
      final y = ((gameTime * speed * size.height * 0.18) + i * 53) % size.height;
      final r = cellSize * (round ? 0.05 : 0.07) * (1 + (i % 3) * 0.2);
      if (round) {
        canvas.drawCircle(Offset(x, y), r, paint);
      } else {
        // 葉っぱは小さな回転矩形
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(gameTime * 1.5 + i);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: r * 2, height: r), paint);
        canvas.restore();
      }
    }
  }

  // 波（横方向の光のライン）
  void _drawWaveLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.10)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final path = Path();
      final baseY = (i + 0.5) / 6 * size.height;
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += cellSize * 0.5) {
        final y = baseY + sin((x / size.width * 4 * pi) + gameTime * 2 + i) * cellSize * 0.12;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  // 霧（漂う半透明の帯）
  void _drawFog(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final cx = ((gameTime * 8 * (i + 1)) % (size.width + 200)) - 100;
      final cy = (i + 1) / 4 * size.height;
      final rect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.7,
        height: cellSize * 1.4,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  // ネオン（都市・明滅するスキャンライン）
  void _drawNeon(Canvas canvas, Size size) {
    final glow = (sin(gameTime * 3) * 0.5 + 0.5);
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.04 + glow * 0.05)
      ..strokeWidth = 1;
    for (var i = 0; i < state.rows; i++) {
      final y = i * cellSize + (gameTime * cellSize * 2) % cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // ─── グリッド ────────────────────────────────────────────────────────

  void _drawGrid(Canvas canvas) {
    final paint1 = Paint()..color = const Color(0xFF1E2E3E);
    final paint2 = Paint()..color = const Color(0xFF253444);
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.5;

    for (var r = 0; r < state.rows; r++) {
      for (var c = 0; c < state.cols; c++) {
        canvas.drawRect(
          Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
          (r + c) % 2 == 0 ? paint1 : paint2,
        );
      }
    }
    for (var i = 0; i <= state.cols; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, state.rows * cellSize),
        linePaint,
      );
    }
    for (var i = 0; i <= state.rows; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(state.cols * cellSize, i * cellSize),
        linePaint,
      );
    }
  }

  // ─── パス & 矢印 ─────────────────────────────────────────────────────

  void _drawPath(Canvas canvas) {
    final pathPaint = Paint()..color = const Color(0xFF8B7355);
    final borderPaint = Paint()
      ..color = const Color(0xFFA08060).withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (final pos in state.pathSet) {
      final rect = Rect.fromLTWH(
          pos.col * cellSize, pos.row * cellSize, cellSize, cellSize);
      canvas.drawRect(rect, pathPaint);
      canvas.drawRect(rect, borderPaint);
    }

    // 方向矢印
    _drawPathArrows(canvas);

    // スタートマーカー
    _drawEmoji(canvas, '🏁', state.path.first, 0.65);
    // ゴールマーカー
    _drawEmoji(canvas, '🏰', state.path.last, 0.75);
  }

  void _drawPathArrows(Canvas canvas) {
    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // アニメーション: 矢印を点滅させる（0〜1でフェード）
    final phase = (gameTime * 1.5) % 1.0;

    for (var i = 0; i < state.path.length - 1; i++) {
      final a = state.path[i];
      final b = state.path[i + 1];
      final dx = (b.col - a.col).toDouble();
      final dy = (b.row - a.row).toDouble();

      // 矢印の表示位置（セル中心からオフセットしてアニメ）
      final t = ((i * 0.15 + phase) % 1.0);
      final cx = ((a.col + dx * t) + 0.5) * cellSize;
      final cy = ((a.row + dy * t) + 0.5) * cellSize;

      _drawArrowHead(canvas, arrowPaint, cx, cy, dx, dy);
    }
  }

  void _drawArrowHead(Canvas canvas, Paint paint, double cx, double cy,
      double dx, double dy) {
    final angle = atan2(dy, dx);
    final hs = cellSize * 0.18; // 矢印サイズ
    final tipX = cx + cos(angle) * hs;
    final tipY = cy + sin(angle) * hs;
    final leftX = cx + cos(angle + 2.4) * hs * 0.7;
    final leftY = cy + sin(angle + 2.4) * hs * 0.7;
    final rightX = cx + cos(angle - 2.4) * hs * 0.7;
    final rightY = cy + sin(angle - 2.4) * hs * 0.7;

    final path = Path()
      ..moveTo(tipX, tipY)
      ..lineTo(leftX, leftY)
      ..moveTo(tipX, tipY)
      ..lineTo(rightX, rightY);
    canvas.drawPath(path, paint);
  }

  // ─── 射程プレビュー ──────────────────────────────────────────────────

  void _drawRangePreview(Canvas canvas) {
    if (previewPos == null) return;
    final cx = (previewPos!.col + 0.5) * cellSize;
    final cy = (previewPos!.row + 0.5) * cellSize;
    final range = selectedFacility.range;
    final fColor = facilityColors[selectedFacility] ?? Colors.white;

    // グロー背景（より目立たせる）
    canvas.drawCircle(
      Offset(cx, cy),
      cellSize * 0.5 + cellSize * 0.2,
      Paint()
        ..color = fColor.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // セルハイライト（より明るく）
    canvas.drawRect(
      Rect.fromLTWH(
          previewPos!.col * cellSize, previewPos!.row * cellSize,
          cellSize, cellSize),
      Paint()..color = fColor.withOpacity(0.35),
    );

    // セル枠線（より太く）
    canvas.drawRect(
      Rect.fromLTWH(
          previewPos!.col * cellSize, previewPos!.row * cellSize,
          cellSize, cellSize),
      Paint()
        ..color = fColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // 射程円（ダッシュ風に複数の弧で近似）
    final dashPaint = Paint()
      ..color = fColor.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    const dashCount = 20;
    for (var i = 0; i < dashCount; i++) {
      if (i % 2 == 1) continue;
      final startAngle = (i / dashCount) * 2 * pi;
      final sweepAngle = (1 / dashCount) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: range * cellSize),
        startAngle,
        sweepAngle,
        false,
        dashPaint,
      );
    }

    // 施設プレビュー（より明るく、より大きく）
    canvas.drawCircle(
      Offset(cx, cy),
      cellSize * 0.42,
      Paint()..color = fColor.withOpacity(0.45),
    );
    _drawText(canvas, selectedFacility.emoji, Offset(cx, cy),
        cellSize * 0.65);
  }

  // ─── 施設シナジー線 ──────────────────────────────────────────────────

  /// 隣接する同種施設同士を脈動する光の線で結ぶ（シナジー可視化）
  void _drawSynergyLinks(Canvas canvas) {
    final facilities = state.facilities;
    final pulse = 0.5 + 0.5 * sin(gameTime * 4);
    for (final entry in facilities.entries) {
      final pos = entry.key;
      final f = entry.value;
      final color = facilityColors[f.type] ?? Colors.white;
      // 右・下方向のみチェック（線の重複描画を防止）
      for (final d in const [
        [1, 0],
        [0, 1],
      ]) {
        final np = GridPos(pos.col + d[0], pos.row + d[1]);
        final neighbor = facilities[np];
        if (neighbor != null && neighbor.type == f.type) {
          canvas.drawLine(
            Offset((pos.col + 0.5) * cellSize, (pos.row + 0.5) * cellSize),
            Offset((np.col + 0.5) * cellSize, (np.row + 0.5) * cellSize),
            Paint()
              ..color = color.withOpacity(0.4 + 0.4 * pulse)
              ..strokeWidth = cellSize * (0.05 + 0.02 * pulse)
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
      }
    }
  }

  // ─── 施設 ────────────────────────────────────────────────────────────

  void _drawFacilities(Canvas canvas) {
    for (final entry in state.facilities.entries) {
      final pos = entry.key;
      final f = entry.value;
      final cx = (pos.col + 0.5) * cellSize;
      final cy = (pos.row + 0.5) * cellSize;
      final fColor = facilityColors[f.type] ?? Colors.white;

      // アタックフラッシュ（グロー）
      final flashId = '${pos.col}_${pos.row}';
      final flash = flashes.where((fl) => fl.facilityId == flashId).firstOrNull;
      if (flash != null) {
        final glowAlpha = (flash.life / 0.25).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(cx, cy),
          cellSize * 0.52,
          Paint()
            ..color = fColor.withOpacity(0.55 * glowAlpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }

      // 背景円（タイプ色）
      canvas.drawCircle(
        Offset(cx, cy),
        cellSize * 0.4,
        Paint()..color = fColor.withOpacity(0.35),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        cellSize * 0.4,
        Paint()
          ..color = fColor.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // 絵文字
      _drawEmoji(canvas, f.type.emoji, pos, 0.7);

      // レベルバッジ
      if (f.level > 1) {
        final badgeOffset = Offset(cx + cellSize * 0.22, cy + cellSize * 0.22);
        canvas.drawCircle(
          badgeOffset,
          cellSize * 0.14,
          Paint()..color = Colors.amber,
        );
        _drawText(canvas, '${f.level}', badgeOffset, cellSize * 0.18);
      }
    }
  }

  // ─── 発射体 ──────────────────────────────────────────────────────────

  void _drawProjectiles(Canvas canvas) {
    for (final p in projectiles) {
      final pos = Offset.lerp(p.from, p.to, p.progress.clamp(0.0, 1.0))!;
      final sx = pos.dx * cellSize;
      final sy = pos.dy * cellSize;

      // 長めの発光トレイル（迫力アップ）
      if (p.progress > 0.05) {
        final prev = Offset.lerp(p.from, p.to, (p.progress - 0.22).clamp(0.0, 1.0))!;
        canvas.drawLine(
          Offset(prev.dx * cellSize, prev.dy * cellSize),
          Offset(sx, sy),
          Paint()
            ..color = p.color.withOpacity(0.5)
            ..strokeWidth = cellSize * 0.08
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }

      // グロー
      canvas.drawCircle(
        Offset(sx, sy),
        cellSize * 0.13,
        Paint()
          ..color = p.color.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // 弾本体（白い芯＋色付き外周で光弾らしく）
      canvas.drawCircle(
        Offset(sx, sy),
        cellSize * 0.08,
        Paint()..color = p.color,
      );
      canvas.drawCircle(
        Offset(sx, sy),
        cellSize * 0.04,
        Paint()..color = Colors.white.withOpacity(0.9),
      );
    }
  }

  // ─── パーティクル ────────────────────────────────────────────────────

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.pos.dx * cellSize, p.pos.dy * cellSize),
        cellSize * 0.06 * alpha,
        Paint()..color = p.color.withOpacity(alpha),
      );
    }
  }

  // ─── 敵 ──────────────────────────────────────────────────────────────

  void _drawEnemies(Canvas canvas) {
    for (final enemy in state.enemies) {
      if (enemy.isDead) continue;
      final ePos = enemy.posOnPath(state.path);
      final cx = (ePos.dx + 0.5) * cellSize;
      final cy = (ePos.dy + 0.5) * cellSize;
      final radius = (enemy.isBoss ? 0.44 : 0.3) * cellSize;

      // ボスは足元に脈動する赤いオーラ（威圧感の演出）
      if (enemy.isBoss) {
        final pulse = 0.5 + 0.5 * sin(gameTime * 4 + ePos.dx);
        canvas.drawCircle(
          Offset(cx, cy),
          radius * (1.15 + 0.15 * pulse),
          Paint()
            ..color = Colors.redAccent.withOpacity(0.25 + 0.2 * pulse)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }

      // HP バー（敵画像の上部に表示）
      final barW = cellSize * 0.78;
      const barH = 4.0;
      final barX = cx - barW / 2;
      final barY = cy - radius - 6;
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barW, barH),
        Paint()..color = Colors.black54,
      );
      final hpColor = enemy.hpRatio > 0.5
          ? Colors.greenAccent
          : enemy.hpRatio > 0.25
              ? Colors.orangeAccent
              : Colors.redAccent;
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barW * enemy.hpRatio, barH),
        Paint()..color = hpColor,
      );
    }
  }

  Color _getEnemyTypeColor(EnemyType type) {
    switch (type) {
      case EnemyType.normal:
        return const Color(0xFFEE4444); // 通常: 赤
      case EnemyType.speedy:
        return const Color(0xFFFFB300); // スピード: オレンジ
      case EnemyType.armored:
        return const Color(0xFF4A90E2); // 装甲: 青
      case EnemyType.healer:
        return const Color(0xFF66BB6A); // ヒーラー: 緑
    }
  }

  Color _getEnemyTypeOutlineColor(EnemyType type) {
    switch (type) {
      case EnemyType.normal:
        return const Color(0xFFFF6B6B); // 通常: 明るい赤
      case EnemyType.speedy:
        return const Color(0xFFFFC107); // スピード: 明るいオレンジ
      case EnemyType.armored:
        return const Color(0xFF64B5F6); // 装甲: 明るい青
      case EnemyType.healer:
        return const Color(0xFF81C784); // ヒーラー: 明るい緑
    }
  }

  // ─── 浮遊テキスト ────────────────────────────────────────────────────

  void _drawFloatingTexts(Canvas canvas) {
    for (final t in floatingTexts) {
      final alpha = (t.life / t.maxLife).clamp(0.0, 1.0);
      // pos はグリッド単位で保持。_advanceEffects で -0.6/s 移動し、描画側で cellSize 倍する
      final sx = t.pos.dx * cellSize;
      final sy = t.pos.dy * cellSize;

      final tp = TextPainter(
        text: TextSpan(
          text: t.text,
          style: TextStyle(
            color: t.color.withOpacity(alpha),
            fontSize: cellSize * 0.22,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(sx - tp.width / 2, sy - tp.height / 2));
    }
  }

  // ─── オーバーレイ ────────────────────────────────────────────────────

  void _drawOverlay(Canvas canvas, Size size) {
    if (state.phase == GamePhase.prep) {
      _drawCenteredText(
          canvas, size, '施設を配置して\n「開始!」を押してください',
          Colors.white54, 13);
    }
    // victory / defeat は ResultScreen へ遷移するので不要
  }

  // ─── ヘルパー ────────────────────────────────────────────────────────

  void _drawEmoji(Canvas canvas, String emoji, GridPos pos, double scale) {
    _drawText(
      canvas,
      emoji,
      Offset((pos.col + 0.5) * cellSize, (pos.row + 0.5) * cellSize),
      cellSize * scale,
    );
  }

  void _drawText(Canvas canvas, String text, Offset center, double size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawCenteredText(
      Canvas canvas, Size size, String text, Color color, double fontSize) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - 30, size.width, 60),
      Paint()..color = Colors.black38,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width);
    tp.paint(
        canvas,
        Offset(size.width / 2 - tp.width / 2,
            size.height / 2 - tp.height / 2));
  }

  @override
  bool shouldRepaint(_GameFieldPainter old) => true;
}
