/// 本部強化（恒久アップグレード）システム
/// クリアで貯まる「研究ポイント」を使い、全プレイ共通の永続強化を購入する

enum HqUpgradeTrack { attack, coin, hp }

extension HqUpgradeTrackX on HqUpgradeTrack {
  String get title {
    switch (this) {
      case HqUpgradeTrack.attack:
        return '⚔️ 兵器開発';
      case HqUpgradeTrack.coin:
        return '💰 経済政策';
      case HqUpgradeTrack.hp:
        return '🏯 城壁強化';
    }
  }

  String get description {
    switch (this) {
      case HqUpgradeTrack.attack:
        return '全施設のダメージが永続的にアップ';
      case HqUpgradeTrack.coin:
        return '敵撃破時のコイン獲得量が永続的にアップ';
      case HqUpgradeTrack.hp:
        return '全ステージの初期HPが永続的にアップ';
    }
  }

  static const maxLevel = 10;

  /// 次レベルへのコスト（レベルが上がるほど高騰）
  int costForLevel(int currentLevel) => 20 + currentLevel * 15;
}

class HqUpgradeState {
  final Map<HqUpgradeTrack, int> levels;
  final int researchPoints;

  const HqUpgradeState({required this.levels, required this.researchPoints});

  factory HqUpgradeState.initial() => const HqUpgradeState(
        levels: {
          HqUpgradeTrack.attack: 0,
          HqUpgradeTrack.coin: 0,
          HqUpgradeTrack.hp: 0,
        },
        researchPoints: 0,
      );

  int levelOf(HqUpgradeTrack t) => levels[t] ?? 0;

  /// 施設ダメージ倍率（1.0 = ボーナスなし）
  double get attackMultiplier =>
      1.0 + levelOf(HqUpgradeTrack.attack) * 0.02;

  /// コイン獲得倍率（1.0 = ボーナスなし）
  double get coinMultiplier => 1.0 + levelOf(HqUpgradeTrack.coin) * 0.02;

  /// 初期HPボーナス（加算）
  int get hpBonus => levelOf(HqUpgradeTrack.hp);

  HqUpgradeState copyWith({
    Map<HqUpgradeTrack, int>? levels,
    int? researchPoints,
  }) =>
      HqUpgradeState(
        levels: levels ?? this.levels,
        researchPoints: researchPoints ?? this.researchPoints,
      );
}
