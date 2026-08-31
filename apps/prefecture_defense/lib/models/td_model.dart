import 'dart:math';
import 'dart:ui';

/// ボス特殊スキルタイプ
enum BossSkillType { speedBurst, hpRegen, summon, stunFacility }

/// グリッド上の位置
class GridPos {
  final int col;
  final int row;

  const GridPos(this.col, this.row);

  @override
  bool operator ==(Object other) =>
      other is GridPos && other.col == col && other.row == row;

  @override
  int get hashCode => col * 100 + row;

  @override
  String toString() => '($col,$row)';
}

/// 施設タイプ
enum FacilityType {
  farm,
  fishery,
  factory,
  mine,
  castle,
  shrine,
  // 都道府県限定施設
  dairyFarm,        // 北海道 (01)
  alpineWatch,      // 長野 (20)
  toyotaFactory,    // 愛知 (23)
  kiyomizuTemple,   // 京都 (26)
  peaceShrine,      // 広島 (34)
  heimeyuriTower,   // 沖縄 (47)
  umeSakeBrewery,   // 和歌山 (30)
  udonShop,         // 福岡 (40)
}

extension FacilityTypeX on FacilityType {
  String get label {
    switch (this) {
      case FacilityType.farm:         return '農業';
      case FacilityType.fishery:      return '漁業';
      case FacilityType.factory:      return '工業';
      case FacilityType.mine:         return '鉱業';
      case FacilityType.castle:       return '城';
      case FacilityType.shrine:       return '神社';
      case FacilityType.dairyFarm:    return '酪農施設';
      case FacilityType.alpineWatch:  return '高山見張所';
      case FacilityType.toyotaFactory: return 'トヨタ工場';
      case FacilityType.kiyomizuTemple: return '清水寺';
      case FacilityType.peaceShrine:  return '平和記念碑';
      case FacilityType.heimeyuriTower: return 'ひめゆりの塔';
      case FacilityType.umeSakeBrewery: return '紀州梅酒醸造所';
      case FacilityType.udonShop:     return 'うどん店';
    }
  }

  int get cost {
    switch (this) {
      case FacilityType.farm:         return 50;
      case FacilityType.fishery:      return 70;
      case FacilityType.factory:      return 100; // 工業: 圧倒的優位を緩和
      case FacilityType.mine:         return 55;  // 鉱業: 少し安く誘引
      case FacilityType.castle:       return 150;
      case FacilityType.shrine:       return 100;
      case FacilityType.dairyFarm:    return 120;
      case FacilityType.alpineWatch:  return 130;
      case FacilityType.toyotaFactory: return 140;
      case FacilityType.kiyomizuTemple: return 110;
      case FacilityType.peaceShrine:  return 125;
      case FacilityType.heimeyuriTower: return 135;
      case FacilityType.umeSakeBrewery: return 115;
      case FacilityType.udonShop:     return 80;
    }
  }

  int get damage {
    switch (this) {
      case FacilityType.farm:         return 10;
      case FacilityType.fishery:      return 18; // 漁業バフ: DPS 12→14.4（射程2.0の遠距離役）
      case FacilityType.factory:      return 16; // 工業ナーフ: DPS 30→24（最強格を緩和）
      case FacilityType.mine:         return 22; // 鉱業: 高ダメ低速スナイパーに
      case FacilityType.castle:       return 40;
      case FacilityType.shrine:       return 12; // 神社: 装甲に4ダメは入るように
      case FacilityType.dairyFarm:    return 18;
      case FacilityType.alpineWatch:  return 16;
      case FacilityType.toyotaFactory: return 24;
      case FacilityType.kiyomizuTemple: return 22;
      case FacilityType.peaceShrine:  return 14;
      case FacilityType.heimeyuriTower: return 15;
      case FacilityType.umeSakeBrewery: return 13;
      case FacilityType.udonShop:     return 11;
    }
  }

  double get range {
    switch (this) {
      case FacilityType.farm:         return 1.5;
      case FacilityType.fishery:      return 2.0;
      case FacilityType.factory:      return 1.2;
      case FacilityType.mine:         return 1.8;
      case FacilityType.castle:       return 2.5;
      case FacilityType.shrine:       return 2.2;
      case FacilityType.dairyFarm:    return 1.8;
      case FacilityType.alpineWatch:  return 3.0;
      case FacilityType.toyotaFactory: return 1.6;
      case FacilityType.kiyomizuTemple: return 1.9;
      case FacilityType.peaceShrine:  return 2.1;
      case FacilityType.heimeyuriTower: return 1.7;
      case FacilityType.umeSakeBrewery: return 2.0;
      case FacilityType.udonShop:     return 1.4;
    }
  }

  double get attackSpeed { // attacks per second
    switch (this) {
      case FacilityType.farm:         return 1.0;
      case FacilityType.fishery:      return 0.8;
      case FacilityType.factory:      return 1.5;
      case FacilityType.mine:         return 0.5; // 低速維持（役割の明確化）
      case FacilityType.castle:       return 0.6; // 攻撃速度UP → DPS 24に改善
      case FacilityType.shrine:       return 2.5;
      case FacilityType.dairyFarm:    return 1.8;
      case FacilityType.alpineWatch:  return 0.9;
      case FacilityType.toyotaFactory: return 1.9;
      case FacilityType.kiyomizuTemple: return 1.2;
      case FacilityType.peaceShrine:  return 0.7;
      case FacilityType.heimeyuriTower: return 1.0;
      case FacilityType.umeSakeBrewery: return 1.1;
      case FacilityType.udonShop:     return 2.0;
    }
  }

  String get emoji {
    switch (this) {
      case FacilityType.farm:         return '🌾';
      case FacilityType.fishery:      return '🐟';
      case FacilityType.factory:      return '🏭';
      case FacilityType.mine:         return '⛏️';
      case FacilityType.castle:       return '🏯';
      case FacilityType.shrine:       return '⛩️';
      case FacilityType.dairyFarm:    return '🚜';
      case FacilityType.alpineWatch:  return '🏔️';
      case FacilityType.toyotaFactory: return '🏗️';
      case FacilityType.kiyomizuTemple: return '🕯️';
      case FacilityType.peaceShrine:  return '🛡️';
      case FacilityType.heimeyuriTower: return '🏝️';
      case FacilityType.umeSakeBrewery: return '🫖';
      case FacilityType.udonShop:     return '🍲';
    }
  }
}

/// 敵タイプ
enum EnemyType { normal, speedy, armored, healer }

extension EnemyTypeX on EnemyType {
  String get emoji {
    switch (this) {
      case EnemyType.normal:  return '👺';
      case EnemyType.speedy:  return '💨';
      case EnemyType.armored: return '🛡️';
      case EnemyType.healer:  return '💊';
    }
  }

  double get speedMult {
    switch (this) {
      case EnemyType.speedy:  return 1.8; // 短パス県でも対応可能な速度に
      case EnemyType.armored: return 0.7;
      default:                return 1.0;
    }
  }

  int get armorReduction {
    switch (this) {
      case EnemyType.armored: return 8;
      default:                return 0;
    }
  }

  double get regenInterval {
    switch (this) {
      case EnemyType.healer: return 2.0;
      default:               return 0;
    }
  }

  int get regenAmount {
    switch (this) {
      case EnemyType.healer: return 8; // 回復量UP（ヒーラーをより脅威に）
      default:               return 0;
    }
  }

  double get hpMult {
    switch (this) {
      case EnemyType.speedy:  return 0.5;
      case EnemyType.armored: return 2.0;
      case EnemyType.healer:  return 1.3;
      default:                return 1.0;
    }
  }

  /// 地理タイプに基づいて敵の絵文字を取得
  String getEmojiForGeography(String geography) {
    switch (geography) {
      case 'sea':
        switch (this) {
          case EnemyType.normal:  return '🧛'; // pirate
          case EnemyType.speedy:  return '🏴‍☠️'; // speedy pirate
          case EnemyType.armored: return '⛵'; // armored ship
          case EnemyType.healer:  return '🧚'; // sea spirit
        }
      case 'mountain':
        switch (this) {
          case EnemyType.normal:  return '👹'; // mountain demon
          case EnemyType.speedy:  return '🐅'; // mountain cat
          case EnemyType.armored: return '🐻'; // bear
          case EnemyType.healer:  return '🧙'; // wizard
        }
      case 'urban':
        switch (this) {
          case EnemyType.normal:  return '🤖'; // robot
          case EnemyType.speedy:  return '🚁'; // helicopter
          case EnemyType.armored: return '🦾'; // cyborg
          case EnemyType.healer:  return '🧬'; // scientist
        }
      case 'agriculture':
        switch (this) {
          case EnemyType.normal:  return '👨‍🌾'; // farmer
          case EnemyType.speedy:  return '🐴'; // horse
          case EnemyType.armored: return '🐂'; // ox
          case EnemyType.healer:  return '🌿'; // nature spirit
        }
      default: // 'mixed'
        return emoji;
    }
  }
}

/// 配置済み施設
class Facility {
  final String id;
  final FacilityType type;
  final GridPos pos;
  int level;
  double attackCooldown; // remaining cooldown in seconds
  // 特殊能力タイマー（都道府県限定施設用）
  double speedPenaltyEndTime;   // dairyFarm のデバフ期限
  double slowEndTime;            // 減速効果の期限
  int shieldHp;                  // peaceShrine のシールドHP
  bool isStunned;                // heimeyuriTower のスタン状態
  double stunEndTime;            // スタン期限
  String? specialFacility;        // 'airport' (1.5x攻撃速度), 'base' (3x3範囲ダメージ), or null

  Facility({
    required this.id,
    required this.type,
    required this.pos,
    this.level = 1,
    this.attackCooldown = 0,
    this.speedPenaltyEndTime = 0,
    this.slowEndTime = 0,
    this.shieldHp = 0,
    this.isStunned = false,
    this.stunEndTime = 0,
    this.specialFacility,
  });

  int get damage => (type.damage * level * 1.0).round();
  double get range => type.range + (level - 1) * 0.2;
  int get upgradeCost => type.cost * level * 2;

  Facility copyWith({
    int? level,
    double? attackCooldown,
    double? speedPenaltyEndTime,
    double? slowEndTime,
    int? shieldHp,
    bool? isStunned,
    double? stunEndTime,
    String? specialFacility,
  }) =>
      Facility(
        id: id,
        type: type,
        pos: pos,
        level: level ?? this.level,
        attackCooldown: attackCooldown ?? this.attackCooldown,
        speedPenaltyEndTime: speedPenaltyEndTime ?? this.speedPenaltyEndTime,
        slowEndTime: slowEndTime ?? this.slowEndTime,
        shieldHp: shieldHp ?? this.shieldHp,
        isStunned: isStunned ?? this.isStunned,
        stunEndTime: stunEndTime ?? this.stunEndTime,
        specialFacility: specialFacility ?? this.specialFacility,
      );
}

/// 敵キャラ
class Enemy {
  final String id;
  final bool isBoss;
  final EnemyType enemyType;
  int hp;
  final int maxHp;
  final int attack;
  double speed; // grid cells per second (mutable for boss speed burst)
  double pathProgress; // 0.0 〜 path.length-1
  bool isDead;
  double regenCooldown; // mutable, for healer regen timer
  double bossSkillCooldown; // only used if isBoss
  bool isStunned; // used for stunned state
  final BossSkillType? bossSkillType; // null for non-boss
  // 特殊施設デバフ
  double speedPenaltyEndTime; // dairyFarm の速度ペナルティ期限（-20%）
  double alpineSlowEndTime; // alpineWatch のスロー期限（×0.7）
  double umeSakeSlowEndTime; // umeSakeBrewery のスロー期限（×0.65）
  int shieldHp; // peaceShrine のシールド（敵が生成するテンポラリHP）
  double damageMultiplier; // kiyomizuTemple による最終ダメージボーナス倍率
  double stunEndTime; // heimeyuriTower のスタン期限

  Enemy({
    required this.id,
    required this.isBoss,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.speed,
    this.enemyType = EnemyType.normal,
    this.pathProgress = 0,
    this.isDead = false,
    this.regenCooldown = 0,
    this.bossSkillCooldown = 0,
    this.isStunned = false,
    this.bossSkillType,
    this.speedPenaltyEndTime = 0,
    this.alpineSlowEndTime = 0,
    this.umeSakeSlowEndTime = 0,
    this.shieldHp = 0,
    this.damageMultiplier = 1.0,
    this.stunEndTime = 0,
  });

  double get hpRatio => hp / maxHp;

  Offset posOnPath(List<GridPos> path) {
    final i = pathProgress.floor().clamp(0, path.length - 2);
    final t = pathProgress - i;
    final a = path[i];
    final b = path[i + 1];
    return Offset(
      a.col + (b.col - a.col) * t,
      a.row + (b.row - a.row) * t,
    );
  }
}

/// ウェーブ定義
class WaveDefinition {
  final int waveNumber;
  final int enemyCount;
  final int baseHp;
  final int baseAttack;
  final double spawnInterval; // seconds between spawns
  final bool hasBoss;
  final List<EnemyType> enemyTypes; // which types spawn in this wave (cycling)

  const WaveDefinition({
    required this.waveNumber,
    required this.enemyCount,
    required this.baseHp,
    required this.baseAttack,
    required this.spawnInterval,
    required this.hasBoss,
    this.enemyTypes = const [EnemyType.normal],
  });
}

/// ゲームフェーズ
enum GamePhase { prep, wave, waveEnd, victory, defeat }

/// ゲームフィールド状態
class TdGameState {
  final int cols;
  final int rows;
  final List<GridPos> path;         // 敵の進行ルート
  final Set<GridPos> pathSet;       // 高速検索用
  final Map<GridPos, Facility> facilities;
  final List<Enemy> enemies;
  final int coins;
  final int baseHp;                 // ゴールのHP（敵が到達するたび減少）
  final int score;
  final int currentWave;
  final int totalWaves;
  final GamePhase phase;
  final double waveTimer;           // 次ウェーブまでのカウントダウン
  final int mistakes;               // 敵がゴールに到達した回数
  final String prefCode;            // 都道府県コード（ウェーブテーマ用）
  final double facilityDamageBonus; // multiplier added to facility damage (0.0 = no bonus)
  final double enemySpeedPenalty;   // subtracted from enemy speed (0.0 = no penalty)
  final int shieldHits;             // absorbs this many HP losses from enemies reaching goal
  final Map<FacilityType, double> facilityBonusMap; // per-type cost multiplier (< 1.0) and damage bonus (> 1.0)
  final bool isRegionBattle;
  final String regionCode;
  final String? selectedSkill; // current wave skill effect key ('waveAtkBonus', 'waveRangeBonus', etc)
  final bool waveSkillActive; // whether skill effect is currently applied
  final double hqCoinMultiplier; // 本部強化: コイン獲得倍率（1.0 = ボーナスなし）

  const TdGameState({
    required this.cols,
    required this.rows,
    required this.path,
    required this.pathSet,
    required this.facilities,
    required this.enemies,
    required this.coins,
    required this.baseHp,
    required this.score,
    required this.currentWave,
    required this.totalWaves,
    required this.phase,
    required this.waveTimer,
    required this.mistakes,
    this.prefCode = '',
    this.facilityDamageBonus = 0.0,
    this.enemySpeedPenalty = 0.0,
    this.shieldHits = 0,
    this.facilityBonusMap = const {},
    this.isRegionBattle = false,
    this.regionCode = '',
    this.selectedSkill,
    this.waveSkillActive = false,
    this.hqCoinMultiplier = 1.0,
  });

  bool get isGameOver => baseHp <= 0 || phase == GamePhase.defeat;
  bool get isVictory => phase == GamePhase.victory;

  TdGameState copyWith({
    Map<GridPos, Facility>? facilities,
    List<Enemy>? enemies,
    int? coins,
    int? baseHp,
    int? score,
    int? currentWave,
    GamePhase? phase,
    double? waveTimer,
    int? mistakes,
    String? prefCode,
    double? facilityDamageBonus,
    double? enemySpeedPenalty,
    int? shieldHits,
    Map<FacilityType, double>? facilityBonusMap,
    String? selectedSkill,
    bool? waveSkillActive,
    double? hqCoinMultiplier,
  }) {
    return TdGameState(
      cols: cols,
      rows: rows,
      path: path,
      pathSet: pathSet,
      facilities: facilities ?? this.facilities,
      enemies: enemies ?? this.enemies,
      coins: coins ?? this.coins,
      baseHp: baseHp ?? this.baseHp,
      score: score ?? this.score,
      currentWave: currentWave ?? this.currentWave,
      totalWaves: totalWaves,
      phase: phase ?? this.phase,
      waveTimer: waveTimer ?? this.waveTimer,
      mistakes: mistakes ?? this.mistakes,
      prefCode: prefCode ?? this.prefCode,
      facilityDamageBonus: facilityDamageBonus ?? this.facilityDamageBonus,
      enemySpeedPenalty: enemySpeedPenalty ?? this.enemySpeedPenalty,
      shieldHits: shieldHits ?? this.shieldHits,
      facilityBonusMap: facilityBonusMap ?? this.facilityBonusMap,
      isRegionBattle: isRegionBattle,
      regionCode: regionCode,
      selectedSkill: selectedSkill ?? this.selectedSkill,
      waveSkillActive: waveSkillActive ?? this.waveSkillActive,
      hqCoinMultiplier: hqCoinMultiplier ?? this.hqCoinMultiplier,
    );
  }
}
