import 'dart:math';
import 'dart:ui';
import 'package:geography_puzzle_king/config/difficulty_config.dart';
import 'package:geography_puzzle_king/models/td_model.dart';
import 'package:geography_puzzle_king/utils/prefecture_data.dart';

/// タワーディフェンスゲームエンジン（純粋ロジック・UIなし）
class TdEngine {
  static const int cols = 8;
  static const int rows = 8;
  static final _rng = Random();
  static const int totalWaves = 5;
  static const double waveBreakDuration = 5.0; // 秒

  static const int regionTotalWaves = 7;

  static const Map<String, int> historyWaveCounts = {
    'h01': 8,
    'h02': 9,
    'h03': 9,
    'h04': 10,
  };

  /// 歴史ステージ用パスマップ（4種・各35/33/37/43マス）
  static const Map<String, List<GridPos>> _historyPathMap = {
    // h01: 大蛇の迷路 (35マス) - 外周ループ＋内部フック
    'h01': [
      GridPos(0,0), GridPos(1,0), GridPos(2,0), GridPos(3,0),
      GridPos(4,0), GridPos(5,0), GridPos(6,0), GridPos(7,0),
      GridPos(7,1), GridPos(7,2), GridPos(7,3), GridPos(7,4),
      GridPos(7,5), GridPos(7,6), GridPos(7,7),
      GridPos(6,7), GridPos(5,7), GridPos(4,7), GridPos(3,7),
      GridPos(2,7), GridPos(1,7),
      GridPos(1,6), GridPos(1,5), GridPos(1,4), GridPos(1,3),
      GridPos(2,3), GridPos(3,3), GridPos(4,3), GridPos(5,3), GridPos(6,3),
      GridPos(6,4), GridPos(6,5),
      GridPos(5,5), GridPos(4,5),
      GridPos(4,6),
    ],
    // h02: 戦陣の道 (33マス) - 3段横断
    'h02': [
      GridPos(0,1), GridPos(1,1), GridPos(2,1), GridPos(3,1),
      GridPos(4,1), GridPos(5,1), GridPos(6,1), GridPos(7,1),
      GridPos(7,2), GridPos(7,3),
      GridPos(6,3), GridPos(5,3), GridPos(4,3), GridPos(3,3),
      GridPos(2,3), GridPos(1,3), GridPos(0,3),
      GridPos(0,4), GridPos(0,5),
      GridPos(1,5), GridPos(2,5), GridPos(3,5), GridPos(4,5),
      GridPos(5,5), GridPos(6,5), GridPos(7,5),
      GridPos(7,6), GridPos(7,7),
      GridPos(6,7), GridPos(5,7), GridPos(4,7), GridPos(3,7), GridPos(2,7),
    ],
    // h03: 維新の道 (37マス) - 4段蛇行
    'h03': [
      GridPos(0,0), GridPos(1,0), GridPos(2,0), GridPos(3,0),
      GridPos(4,0), GridPos(5,0), GridPos(6,0), GridPos(7,0),
      GridPos(7,1),
      GridPos(6,1), GridPos(5,1), GridPos(4,1), GridPos(3,1),
      GridPos(2,1), GridPos(1,1), GridPos(0,1),
      GridPos(0,2),
      GridPos(1,2), GridPos(2,2), GridPos(3,2), GridPos(4,2),
      GridPos(5,2), GridPos(6,2), GridPos(7,2),
      GridPos(7,3),
      GridPos(6,3), GridPos(5,3), GridPos(4,3), GridPos(3,3),
      GridPos(2,3), GridPos(1,3), GridPos(0,3),
      GridPos(0,4), GridPos(0,5),
      GridPos(1,5), GridPos(2,5), GridPos(3,5),
    ],
    // h04: 最終決戦の道 (43マス) - 5段完全蛇行
    'h04': [
      GridPos(0,0), GridPos(1,0), GridPos(2,0), GridPos(3,0),
      GridPos(4,0), GridPos(5,0), GridPos(6,0), GridPos(7,0),
      GridPos(7,1),
      GridPos(6,1), GridPos(5,1), GridPos(4,1), GridPos(3,1),
      GridPos(2,1), GridPos(1,1), GridPos(0,1),
      GridPos(0,2),
      GridPos(1,2), GridPos(2,2), GridPos(3,2), GridPos(4,2),
      GridPos(5,2), GridPos(6,2), GridPos(7,2),
      GridPos(7,3),
      GridPos(6,3), GridPos(5,3), GridPos(4,3), GridPos(3,3),
      GridPos(2,3), GridPos(1,3), GridPos(0,3),
      GridPos(0,4),
      GridPos(1,4), GridPos(2,4), GridPos(3,4), GridPos(4,4),
      GridPos(5,4), GridPos(6,4), GridPos(7,4),
      GridPos(7,5), GridPos(7,6), GridPos(7,7),
    ],
  };

  /// 地方決戦用ロングパス（蛇行型・29マス）
  static const List<GridPos> regionBattlePath = [
    // Row 0 →
    GridPos(0, 0), GridPos(1, 0), GridPos(2, 0), GridPos(3, 0),
    GridPos(4, 0), GridPos(5, 0), GridPos(6, 0), GridPos(7, 0),
    // 右端を下へ
    GridPos(7, 1), GridPos(7, 2), GridPos(7, 3),
    // Row 3 ←
    GridPos(6, 3), GridPos(5, 3), GridPos(4, 3), GridPos(3, 3),
    GridPos(2, 3), GridPos(1, 3), GridPos(0, 3),
    // 左端を下へ
    GridPos(0, 4), GridPos(0, 5), GridPos(0, 6),
    // Row 6 →
    GridPos(1, 6), GridPos(2, 6), GridPos(3, 6), GridPos(4, 6),
    GridPos(5, 6), GridPos(6, 6), GridPos(7, 6),
    // ゴール
    GridPos(7, 7),
  ];

  /// 固定の敵進行ルート（S字型）
  static const List<GridPos> defaultPath = [
    GridPos(0, 1), GridPos(1, 1), GridPos(2, 1), GridPos(3, 1),
    GridPos(3, 2), GridPos(3, 3), GridPos(3, 4),
    GridPos(4, 4), GridPos(5, 4), GridPos(6, 4),
    GridPos(6, 5), GridPos(6, 6),
    GridPos(5, 6), GridPos(4, 6), GridPos(3, 6), GridPos(2, 6),
    GridPos(2, 7), GridPos(3, 7), GridPos(4, 7), GridPos(5, 7),
    GridPos(6, 7), GridPos(7, 7),
  ];

  /// 都道府県別敵進行ルートマップ（全47都道府県）
  static final Map<String, List<GridPos>> _prefecturePathMap = {
    // 北海道 (01) - 大型S字形（8x8ほぼ全体を使用）
    '01': [
      GridPos(0, 1), GridPos(1, 1), GridPos(2, 1), GridPos(3, 1), GridPos(4, 1), GridPos(5, 1),
      GridPos(6, 1), GridPos(7, 1),
      GridPos(7, 2), GridPos(7, 3), GridPos(7, 4), GridPos(7, 5),
      GridPos(6, 5), GridPos(5, 5), GridPos(4, 5), GridPos(3, 5), GridPos(2, 5), GridPos(1, 5),
      GridPos(1, 6), GridPos(1, 7),
    ],
    // 青森 (02) - 狭い上部パス
    '02': [
      GridPos(1, 1), GridPos(2, 1), GridPos(3, 1), GridPos(4, 1),
      GridPos(4, 2), GridPos(4, 3),
      GridPos(5, 3), GridPos(6, 3), GridPos(7, 3),
      GridPos(7, 4), GridPos(7, 5),
      GridPos(6, 5), GridPos(5, 5), GridPos(4, 5),
      GridPos(4, 6), GridPos(4, 7),
    ],
    // 岩手 (03) - 東側垂直パス
    '03': [
      GridPos(5, 1), GridPos(6, 1), GridPos(7, 1),
      GridPos(7, 2), GridPos(7, 3), GridPos(7, 4), GridPos(7, 5), GridPos(7, 6),
      GridPos(6, 6), GridPos(5, 6),
      GridPos(5, 7), GridPos(4, 7), GridPos(3, 7),
    ],
    // 宮城 (04) - 中央垂直
    '04': [
      GridPos(2, 1), GridPos(3, 1), GridPos(4, 1),
      GridPos(4, 2), GridPos(4, 3), GridPos(4, 4), GridPos(4, 5), GridPos(4, 6),
      GridPos(3, 6), GridPos(2, 6),
      GridPos(2, 7), GridPos(3, 7),
    ],
    // 秋田 (05) - 西側パス
    '05': [
      GridPos(1, 1), GridPos(1, 2), GridPos(1, 3), GridPos(1, 4),
      GridPos(2, 4), GridPos(3, 4), GridPos(3, 5),
      GridPos(2, 5), GridPos(2, 6), GridPos(2, 7),
      GridPos(3, 7), GridPos(4, 7), GridPos(5, 7),
    ],
    // 山形 (06) - ジグザグ上部
    '06': [
      GridPos(2, 1), GridPos(3, 1), GridPos(4, 1), GridPos(5, 1),
      GridPos(5, 2), GridPos(5, 3),
      GridPos(4, 3), GridPos(3, 3), GridPos(2, 3),
      GridPos(2, 4), GridPos(3, 4), GridPos(4, 4), GridPos(5, 4),
      GridPos(5, 5), GridPos(5, 6),
    ],
    // 福島 (07) - ジグザグ中央右
    '07': [
      GridPos(4, 1), GridPos(5, 1), GridPos(6, 1),
      GridPos(6, 2), GridPos(6, 3),
      GridPos(5, 3), GridPos(4, 3), GridPos(3, 3),
      GridPos(3, 4), GridPos(4, 4), GridPos(5, 4), GridPos(6, 4),
      GridPos(6, 5), GridPos(6, 6), GridPos(6, 7),
    ],
    // 茨城 (08) - 東側パス
    '08': [
      GridPos(5, 2), GridPos(6, 2), GridPos(7, 2),
      GridPos(7, 3), GridPos(7, 4), GridPos(7, 5),
      GridPos(6, 5), GridPos(5, 5), GridPos(4, 5),
      GridPos(4, 6), GridPos(5, 6), GridPos(6, 6), GridPos(7, 6),
      GridPos(7, 7),
    ],
    // 栃木 (09) - 北中央パス
    '09': [
      GridPos(3, 1), GridPos(4, 1), GridPos(5, 1), GridPos(6, 1),
      GridPos(6, 2), GridPos(6, 3),
      GridPos(5, 3), GridPos(4, 3), GridPos(3, 3), GridPos(2, 3),
      GridPos(2, 4), GridPos(3, 4), GridPos(4, 4),
      GridPos(4, 5), GridPos(4, 6),
    ],
    // 群馬 (10) - 西中央パス
    '10': [
      GridPos(1, 2), GridPos(2, 2), GridPos(3, 2),
      GridPos(3, 3), GridPos(3, 4), GridPos(3, 5),
      GridPos(2, 5), GridPos(1, 5),
      GridPos(1, 6), GridPos(2, 6), GridPos(3, 6), GridPos(4, 6),
      GridPos(4, 7),
    ],
    // 埼玉 (11) - 中央長方形ループ
    '11': [
      GridPos(2, 2), GridPos(3, 2), GridPos(4, 2), GridPos(5, 2),
      GridPos(5, 3), GridPos(5, 4),
      GridPos(4, 4), GridPos(3, 4), GridPos(2, 4),
      GridPos(2, 5), GridPos(3, 5), GridPos(4, 5), GridPos(5, 5),
      GridPos(5, 6), GridPos(4, 6), GridPos(3, 6),
    ],
    // 東京 (12) - 中央ストライト
    '12': [
      GridPos(3, 2), GridPos(4, 2), GridPos(5, 2),
      GridPos(5, 3), GridPos(5, 4), GridPos(5, 5), GridPos(5, 6),
      GridPos(4, 6), GridPos(3, 6), GridPos(2, 6),
      GridPos(2, 7),
    ],
    // 神奈川 (13) - 南東パス
    '13': [
      GridPos(5, 4), GridPos(6, 4), GridPos(7, 4),
      GridPos(7, 5), GridPos(7, 6), GridPos(7, 7),
      GridPos(6, 7), GridPos(5, 7),
      GridPos(5, 6), GridPos(4, 6),
    ],
    // 千葉 (14) - 東右ループ
    '14': [
      GridPos(6, 2), GridPos(7, 2), GridPos(7, 3),
      GridPos(6, 3), GridPos(5, 3), GridPos(5, 4), GridPos(5, 5),
      GridPos(6, 5), GridPos(7, 5), GridPos(7, 6),
      GridPos(6, 6), GridPos(5, 6),
    ],
    // 新潟 (15) - 長い西側垂直
    '15': [
      GridPos(1, 1), GridPos(1, 2), GridPos(1, 3), GridPos(1, 4), GridPos(1, 5), GridPos(1, 6),
      GridPos(2, 6), GridPos(3, 6), GridPos(4, 6),
      GridPos(4, 7), GridPos(3, 7), GridPos(2, 7),
    ],
    // 富山 (16) - コンパクト北パス
    '16': [
      GridPos(2, 1), GridPos(3, 1), GridPos(4, 1), GridPos(5, 1),
      GridPos(5, 2), GridPos(4, 2), GridPos(3, 2),
      GridPos(3, 3), GridPos(4, 3), GridPos(5, 3),
      GridPos(5, 4),
    ],
    // 石川 (17) - 中央西ループ
    '17': [
      GridPos(2, 2), GridPos(3, 2), GridPos(4, 2),
      GridPos(4, 3), GridPos(4, 4), GridPos(4, 5),
      GridPos(3, 5), GridPos(2, 5),
      GridPos(2, 6), GridPos(3, 6), GridPos(4, 6),
      GridPos(4, 7),
    ],
    // 福井 (18) - 狭い垂直
    '18': [
      GridPos(3, 1), GridPos(3, 2), GridPos(3, 3), GridPos(3, 4), GridPos(3, 5),
      GridPos(2, 5), GridPos(2, 6),
      GridPos(3, 6), GridPos(4, 6), GridPos(4, 7),
    ],
    // 山梨 (19) - 南中央パス
    '19': [
      GridPos(3, 3), GridPos(4, 3), GridPos(5, 3),
      GridPos(5, 4), GridPos(5, 5),
      GridPos(4, 5), GridPos(3, 5),
      GridPos(3, 6), GridPos(4, 6), GridPos(5, 6), GridPos(6, 6),
      GridPos(6, 7),
    ],
    // 長野 (20) - 複雑なジグザグ（山型）
    '20': [
      GridPos(2, 1), GridPos(3, 1), GridPos(4, 1), GridPos(5, 1), GridPos(6, 1),
      GridPos(6, 2), GridPos(5, 2), GridPos(4, 2), GridPos(3, 2),
      GridPos(3, 3), GridPos(4, 3), GridPos(5, 3),
      GridPos(5, 4), GridPos(4, 4), GridPos(3, 4),
      GridPos(3, 5), GridPos(4, 5), GridPos(5, 5),
      GridPos(5, 6), GridPos(4, 6),
    ],
    // 岐阜 (21) - 中央対角線
    '21': [
      GridPos(2, 2), GridPos(3, 2), GridPos(4, 2),
      GridPos(4, 3), GridPos(4, 4), GridPos(4, 5),
      GridPos(3, 5), GridPos(2, 5), GridPos(1, 5),
      GridPos(1, 6), GridPos(2, 6), GridPos(3, 6), GridPos(4, 6),
      GridPos(5, 6),
    ],
    // 静岡 (22) - 南東垂直
    '22': [
      GridPos(6, 2), GridPos(6, 3), GridPos(6, 4), GridPos(6, 5),
      GridPos(5, 5), GridPos(4, 5),
      GridPos(4, 6), GridPos(5, 6), GridPos(6, 6), GridPos(7, 6),
      GridPos(7, 7),
    ],
    // 愛知 (23) - 南中央ループ
    '23': [
      GridPos(3, 3), GridPos(4, 3), GridPos(5, 3), GridPos(6, 3),
      GridPos(6, 4), GridPos(6, 5),
      GridPos(5, 5), GridPos(4, 5), GridPos(3, 5),
      GridPos(3, 6), GridPos(4, 6), GridPos(5, 6), GridPos(6, 6),
      GridPos(6, 7),
    ],
    // 三重 (24) - 南東パス
    '24': [
      GridPos(5, 4), GridPos(6, 4), GridPos(7, 4),
      GridPos(7, 5), GridPos(7, 6),
      GridPos(6, 6), GridPos(5, 6), GridPos(4, 6),
      GridPos(4, 7), GridPos(5, 7), GridPos(6, 7),
    ],
    // 滋賀 (25) - 中央北ループ
    '25': [
      GridPos(3, 2), GridPos(4, 2), GridPos(5, 2),
      GridPos(5, 3), GridPos(5, 4),
      GridPos(4, 4), GridPos(3, 4),
      GridPos(3, 5), GridPos(4, 5), GridPos(5, 5),
      GridPos(5, 6),
    ],
    // 京都 (26) - 中央北パス
    '26': [
      GridPos(2, 1), GridPos(3, 1), GridPos(4, 1), GridPos(5, 1),
      GridPos(5, 2), GridPos(5, 3),
      GridPos(4, 3), GridPos(3, 3), GridPos(2, 3),
      GridPos(2, 4), GridPos(3, 4), GridPos(4, 4), GridPos(5, 4),
      GridPos(5, 5),
    ],
    // 兵庫 (27) - 西中央広幅
    '27': [
      GridPos(1, 2), GridPos(2, 2), GridPos(3, 2), GridPos(4, 2), GridPos(5, 2),
      GridPos(5, 3), GridPos(5, 4),
      GridPos(4, 4), GridPos(3, 4), GridPos(2, 4), GridPos(1, 4),
      GridPos(1, 5), GridPos(2, 5), GridPos(3, 5), GridPos(4, 5),
      GridPos(4, 6),
    ],
    // 大阪 (28) - コンパクト中央
    '28': [
      GridPos(3, 3), GridPos(4, 3), GridPos(5, 3),
      GridPos(5, 4), GridPos(4, 4), GridPos(3, 4),
      GridPos(3, 5), GridPos(4, 5), GridPos(5, 5),
      GridPos(5, 6),
    ],
    // 奈良 (29) - 中央東パス
    '29': [
      GridPos(4, 2), GridPos(5, 2), GridPos(6, 2),
      GridPos(6, 3), GridPos(6, 4), GridPos(6, 5),
      GridPos(5, 5), GridPos(4, 5),
      GridPos(4, 6), GridPos(5, 6), GridPos(6, 6),
    ],
    // 和歌山 (30) - 南隅長パス
    '30': [
      GridPos(5, 4), GridPos(5, 5), GridPos(5, 6), GridPos(5, 7),
      GridPos(6, 7), GridPos(7, 7),
      GridPos(7, 6), GridPos(6, 6),
    ],
    // 鳥取 (31) - 狭い北部
    '31': [
      GridPos(2, 1), GridPos(3, 1), GridPos(4, 1),
      GridPos(4, 2), GridPos(4, 3),
      GridPos(3, 3), GridPos(2, 3),
      GridPos(2, 4), GridPos(3, 4),
    ],
    // 島根 (32) - 西側パス
    '32': [
      GridPos(1, 2), GridPos(1, 3), GridPos(1, 4), GridPos(1, 5),
      GridPos(2, 5), GridPos(3, 5), GridPos(4, 5),
      GridPos(4, 6), GridPos(3, 6), GridPos(2, 6), GridPos(1, 6),
    ],
    // 岡山 (33) - 中央北パス
    '33': [
      GridPos(3, 1), GridPos(4, 1), GridPos(5, 1), GridPos(6, 1),
      GridPos(6, 2), GridPos(6, 3),
      GridPos(5, 3), GridPos(4, 3), GridPos(3, 3),
      GridPos(3, 4), GridPos(4, 4), GridPos(5, 4),
    ],
    // 広島 (34) - 中央パス
    '34': [
      GridPos(3, 3), GridPos(4, 3), GridPos(5, 3), GridPos(6, 3),
      GridPos(6, 4), GridPos(6, 5),
      GridPos(5, 5), GridPos(4, 5), GridPos(3, 5),
      GridPos(3, 6), GridPos(4, 6),
    ],
    // 山口 (35) - 南西長パス
    '35': [
      GridPos(1, 4), GridPos(1, 5), GridPos(1, 6), GridPos(2, 6), GridPos(3, 6),
      GridPos(3, 7), GridPos(2, 7),
    ],
    // 香川 (36) - 北中央
    '36': [
      GridPos(3, 2), GridPos(4, 2), GridPos(5, 2), GridPos(6, 2),
      GridPos(6, 3), GridPos(5, 3), GridPos(4, 3), GridPos(3, 3),
      GridPos(3, 4), GridPos(4, 4),
    ],
    // 徳島 (37) - 東側パス
    '37': [
      GridPos(5, 2), GridPos(6, 2), GridPos(7, 2),
      GridPos(7, 3), GridPos(7, 4), GridPos(7, 5),
      GridPos(6, 5), GridPos(5, 5),
      GridPos(5, 6), GridPos(6, 6),
    ],
    // 愛媛 (38) - 西側スパイラル
    '38': [
      GridPos(1, 3), GridPos(2, 3), GridPos(3, 3),
      GridPos(3, 4), GridPos(3, 5),
      GridPos(2, 5), GridPos(1, 5),
      GridPos(1, 6), GridPos(2, 6), GridPos(3, 6), GridPos(4, 6),
      GridPos(4, 7),
    ],
    // 高知 (39) - 南側長パス
    '39': [
      GridPos(3, 5), GridPos(4, 5), GridPos(5, 5), GridPos(6, 5),
      GridPos(6, 6), GridPos(6, 7),
      GridPos(5, 7), GridPos(4, 7), GridPos(3, 7), GridPos(2, 7),
    ],
    // 福岡 (40) - 北西パス
    '40': [
      GridPos(1, 1), GridPos(2, 1), GridPos(3, 1), GridPos(4, 1),
      GridPos(4, 2), GridPos(4, 3),
      GridPos(3, 3), GridPos(2, 3), GridPos(1, 3),
      GridPos(1, 4), GridPos(2, 4), GridPos(3, 4),
    ],
    // 佐賀 (41) - 北西隅
    '41': [
      GridPos(1, 1), GridPos(2, 1),
      GridPos(2, 2), GridPos(2, 3),
      GridPos(1, 3), GridPos(1, 4),
      GridPos(2, 4), GridPos(3, 4), GridPos(4, 4),
    ],
    // 長崎 (42) - 西側スパイラル
    '42': [
      GridPos(1, 2), GridPos(1, 3), GridPos(1, 4), GridPos(1, 5),
      GridPos(2, 5), GridPos(3, 5), GridPos(4, 5),
      GridPos(4, 6), GridPos(3, 6), GridPos(2, 6), GridPos(1, 6),
    ],
    // 熊本 (43) - 中央パス
    '43': [
      GridPos(3, 2), GridPos(4, 2), GridPos(5, 2),
      GridPos(5, 3), GridPos(5, 4),
      GridPos(4, 4), GridPos(3, 4), GridPos(2, 4),
      GridPos(2, 5), GridPos(3, 5), GridPos(4, 5), GridPos(5, 5),
      GridPos(5, 6),
    ],
    // 大分 (44) - 東側パス
    '44': [
      GridPos(5, 2), GridPos(6, 2), GridPos(7, 2),
      GridPos(7, 3), GridPos(7, 4), GridPos(7, 5),
      GridPos(6, 5), GridPos(5, 5),
      GridPos(5, 6), GridPos(6, 6),
    ],
    // 宮崎 (45) - 東右パス
    '45': [
      GridPos(6, 3), GridPos(7, 3), GridPos(7, 4), GridPos(7, 5),
      GridPos(6, 5), GridPos(5, 5),
      GridPos(5, 6), GridPos(6, 6), GridPos(7, 6),
      GridPos(7, 7),
    ],
    // 鹿児島 (46) - 南西長パス
    '46': [
      GridPos(1, 4), GridPos(2, 4), GridPos(3, 4), GridPos(4, 4),
      GridPos(4, 5), GridPos(4, 6),
      GridPos(3, 6), GridPos(2, 6), GridPos(1, 6),
      GridPos(1, 7), GridPos(2, 7), GridPos(3, 7),
    ],
    // 沖縄 (47) - コンパクト南パス
    '47': [
      GridPos(4, 5), GridPos(5, 5), GridPos(6, 5), GridPos(7, 5),
      GridPos(7, 6), GridPos(7, 7),
      GridPos(6, 7), GridPos(5, 7),
    ],
  };

  /// ウェーブ定義（難度別） — 内部用
  static List<WaveDefinition> _baseWavesForDifficulty(String difficulty) {
    final modifier = difficultyModifiers[difficulty] ?? difficultyModifiers['normal']!;
    final waveCount = (totalWaves + modifier.waveAddition).clamp(1, 10);

    return List.generate(waveCount, (i) {
      final w = i + 1;
      return WaveDefinition(
        waveNumber: w,
        enemyCount: 3 + w * 2,
        baseHp: (40 * w * modifier.hpMultiplier).round(),
        baseAttack: (5 + w * 2 * modifier.hpMultiplier).round(),
        spawnInterval: max(0.5, 1.5 - w * 0.15),
        hasBoss: w == waveCount,
      );
    });
  }

  /// 都道府県テーマを適用したウェーブ定義
  static List<WaveDefinition> wavesForPrefecture(String prefCode, String difficulty) {
    final base = _baseWavesForDifficulty(difficulty);
    return base.map((w) => _applyPrefectureTheme(w, prefCode)).toList();
  }

  /// 後方互換: 旧 wavesForDifficulty の呼び出し元用
  static List<WaveDefinition> wavesForDifficulty(String difficulty) =>
      _baseWavesForDifficulty(difficulty);

  /// 地方決戦ウェーブ定義（7波・通常より強め）
  static List<WaveDefinition> regionBattleWaves(String regionCode, String difficulty) {
    final modifier = difficultyModifiers[difficulty] ?? difficultyModifiers['normal']!;
    final baseMult = 1.2; // 地方決戦の基本倍率
    final types = _regionEnemyTheme(regionCode);

    return List.generate(regionTotalWaves, (i) {
      final w = i + 1;
      return WaveDefinition(
        waveNumber: w,
        enemyCount: 4 + w * 2,
        baseHp: (70 * w * baseMult * modifier.hpMultiplier).round(),
        baseAttack: (6 * w * baseMult * modifier.hpMultiplier).round(),
        spawnInterval: max(0.4, 1.4 - w * 0.12),
        hasBoss: w == regionTotalWaves,
        enemyTypes: types,
      );
    });
  }

  /// 歴史ステージウェーブ定義（8〜10波・地方決戦より強め）
  static List<WaveDefinition> historyBattleWaves(String histCode, String difficulty) {
    final modifier = difficultyModifiers[difficulty] ?? difficultyModifiers['normal']!;
    final baseMult = 1.4; // 歴史ステージの基本倍率
    final stageMult = switch (histCode) {
      'h02' => 1.1,
      'h03' => 1.25,
      'h04' => 1.45,
      _ => 1.0,
    };
    final waves = historyWaveCounts[histCode] ?? 8;
    final types = _historyEnemyTheme(histCode);
    return List.generate(waves, (i) {
      final w = i + 1;
      return WaveDefinition(
        waveNumber: w,
        enemyCount: 5 + w * 2,
        baseHp: (80 * w * baseMult * stageMult * modifier.hpMultiplier).round(),
        baseAttack: (8 + w * 4 * baseMult * stageMult * modifier.hpMultiplier).round(),
        spawnInterval: max(0.3, 1.3 - w * 0.1),
        hasBoss: w == waves,
        enemyTypes: types,
      );
    });
  }

  static List<EnemyType> _historyEnemyTheme(String histCode) {
    switch (histCode) {
      case 'h01': return [EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy];
      case 'h02': return [EnemyType.armored, EnemyType.speedy, EnemyType.armored, EnemyType.armored, EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.speedy, EnemyType.armored];
      case 'h03': return [EnemyType.speedy, EnemyType.healer, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy];
      case 'h04': return [EnemyType.armored, EnemyType.healer, EnemyType.armored, EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.armored, EnemyType.healer];
      default:    return [EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.healer];
    }
  }

  static BossSkillType _bossSkillForHistory(String histCode) {
    switch (histCode) {
      case 'h01': return BossSkillType.summon;
      case 'h02': return BossSkillType.speedBurst;
      case 'h03': return BossSkillType.hpRegen;
      case 'h04': return BossSkillType.stunFacility;
      default:    return BossSkillType.summon;
    }
  }

  static List<EnemyType> _regionEnemyTheme(String regionCode) {
    switch (regionCode) {
      case 'r01': return [EnemyType.speedy, EnemyType.speedy, EnemyType.normal, EnemyType.armored, EnemyType.speedy, EnemyType.normal, EnemyType.speedy];
      case 'r02': return [EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.speedy, EnemyType.healer, EnemyType.normal, EnemyType.speedy];
      case 'r03': return [EnemyType.armored, EnemyType.armored, EnemyType.healer, EnemyType.armored, EnemyType.speedy, EnemyType.armored, EnemyType.healer];
      case 'r04': return [EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.armored];
      case 'r05': return [EnemyType.healer, EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.healer];
      case 'r06': return [EnemyType.healer, EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.normal];
      case 'r07': return [EnemyType.speedy, EnemyType.healer, EnemyType.speedy, EnemyType.normal, EnemyType.speedy, EnemyType.healer, EnemyType.armored];
      case 'r08': return [EnemyType.armored, EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.speedy, EnemyType.armored, EnemyType.healer];
      default:    return [EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.armored, EnemyType.normal];
    }
  }

  static BossSkillType _bossSkillForRegion(String regionCode) {
    switch (regionCode) {
      case 'r01': return BossSkillType.speedBurst;
      case 'r02': return BossSkillType.summon;
      case 'r03': return BossSkillType.stunFacility;
      case 'r04': return BossSkillType.speedBurst;
      case 'r05': return BossSkillType.hpRegen;
      case 'r06': return BossSkillType.hpRegen;
      case 'r07': return BossSkillType.speedBurst;
      default:    return BossSkillType.summon; // r08
    }
  }

  /// 都道府県の産業ボーナスマップを生成
  static Map<FacilityType, double> generateFacilityBonusMap(String prefCode) {
    final pref = allPrefectures.firstWhere(
      (p) => p.code == prefCode,
      orElse: () => allPrefectures.first,
    );
    final bonus = <FacilityType, double>{};
    for (final type in FacilityType.values) {
      bonus[type] = (type == pref.primaryIndustry) ? pref.industryBonus : 1.0;
    }
    return bonus;
  }

  static BossSkillType _bossSkillForPrefecture(String prefCode) {
    final code = int.tryParse(prefCode) ?? 0;
    if (code <= 7) return BossSkillType.speedBurst;    // 北海道・東北
    if (code <= 14) return BossSkillType.stunFacility; // 関東
    if (code <= 23) return BossSkillType.summon;       // 中部
    if (code <= 30) return BossSkillType.hpRegen;      // 近畿
    if (code <= 35) return BossSkillType.hpRegen;      // 中国
    if (code <= 39) return BossSkillType.speedBurst;   // 四国
    return BossSkillType.summon;                        // 九州・沖縄
  }

  static final Map<String, List<EnemyType>> _prefectureEnemyTypes = {
    // 北海道・東北 (01-07): スピード型
    '01': [EnemyType.speedy, EnemyType.speedy, EnemyType.normal, EnemyType.speedy, EnemyType.normal],
    '02': [EnemyType.speedy, EnemyType.normal, EnemyType.speedy, EnemyType.normal, EnemyType.speedy],
    '03': [EnemyType.speedy, EnemyType.speedy, EnemyType.armored, EnemyType.speedy, EnemyType.normal],
    '04': [EnemyType.normal, EnemyType.speedy, EnemyType.speedy, EnemyType.armored, EnemyType.speedy],
    '05': [EnemyType.speedy, EnemyType.normal, EnemyType.normal, EnemyType.speedy, EnemyType.speedy],
    '06': [EnemyType.speedy, EnemyType.armored, EnemyType.speedy, EnemyType.healer, EnemyType.speedy],
    '07': [EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.speedy, EnemyType.healer],
    // 関東 (08-14): 装甲型
    '08': [EnemyType.armored, EnemyType.normal, EnemyType.armored, EnemyType.speedy, EnemyType.armored],
    '09': [EnemyType.normal, EnemyType.armored, EnemyType.armored, EnemyType.speedy, EnemyType.armored],
    '10': [EnemyType.armored, EnemyType.speedy, EnemyType.armored, EnemyType.normal, EnemyType.armored],
    '11': [EnemyType.armored, EnemyType.armored, EnemyType.normal, EnemyType.healer, EnemyType.armored],
    '12': [EnemyType.normal, EnemyType.armored, EnemyType.speedy, EnemyType.armored, EnemyType.healer],
    '13': [EnemyType.armored, EnemyType.armored, EnemyType.normal, EnemyType.armored, EnemyType.healer],
    '14': [EnemyType.armored, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.armored],
    // 中部 (15-23): バランス型
    '15': [EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.normal],
    '16': [EnemyType.speedy, EnemyType.normal, EnemyType.healer, EnemyType.armored, EnemyType.speedy],
    '17': [EnemyType.healer, EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.healer],
    '18': [EnemyType.normal, EnemyType.healer, EnemyType.speedy, EnemyType.normal, EnemyType.armored],
    '19': [EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.normal, EnemyType.speedy],
    '20': [EnemyType.normal, EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.normal],
    '21': [EnemyType.armored, EnemyType.normal, EnemyType.speedy, EnemyType.healer, EnemyType.armored],
    '22': [EnemyType.normal, EnemyType.armored, EnemyType.speedy, EnemyType.normal, EnemyType.healer],
    '23': [EnemyType.armored, EnemyType.speedy, EnemyType.normal, EnemyType.armored, EnemyType.healer],
    // 近畿 (24-30): 回復×スピード混合
    '24': [EnemyType.healer, EnemyType.speedy, EnemyType.normal, EnemyType.healer, EnemyType.armored],
    '25': [EnemyType.healer, EnemyType.normal, EnemyType.healer, EnemyType.speedy, EnemyType.normal],
    '26': [EnemyType.healer, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy],
    '27': [EnemyType.speedy, EnemyType.normal, EnemyType.healer, EnemyType.armored, EnemyType.speedy],
    '28': [EnemyType.healer, EnemyType.armored, EnemyType.speedy, EnemyType.healer, EnemyType.normal],
    '29': [EnemyType.healer, EnemyType.normal, EnemyType.speedy, EnemyType.healer, EnemyType.armored],
    '30': [EnemyType.healer, EnemyType.speedy, EnemyType.healer, EnemyType.normal, EnemyType.speedy],
    // 中国 (31-35): 回復型
    '31': [EnemyType.healer, EnemyType.normal, EnemyType.healer, EnemyType.speedy, EnemyType.healer],
    '32': [EnemyType.healer, EnemyType.armored, EnemyType.healer, EnemyType.normal, EnemyType.healer],
    '33': [EnemyType.normal, EnemyType.healer, EnemyType.armored, EnemyType.healer, EnemyType.normal],
    '34': [EnemyType.armored, EnemyType.healer, EnemyType.normal, EnemyType.healer, EnemyType.speedy],
    '35': [EnemyType.healer, EnemyType.normal, EnemyType.healer, EnemyType.armored, EnemyType.healer],
    // 四国 (36-39): 海洋型（スピード×回復）
    '36': [EnemyType.speedy, EnemyType.healer, EnemyType.speedy, EnemyType.normal, EnemyType.healer],
    '37': [EnemyType.speedy, EnemyType.normal, EnemyType.healer, EnemyType.speedy, EnemyType.armored],
    '38': [EnemyType.healer, EnemyType.speedy, EnemyType.normal, EnemyType.healer, EnemyType.speedy],
    '39': [EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.speedy, EnemyType.healer],
    // 九州・沖縄 (40-47): 装甲×スピード混合
    '40': [EnemyType.armored, EnemyType.speedy, EnemyType.normal, EnemyType.armored, EnemyType.speedy],
    '41': [EnemyType.speedy, EnemyType.armored, EnemyType.speedy, EnemyType.normal, EnemyType.armored],
    '42': [EnemyType.armored, EnemyType.speedy, EnemyType.healer, EnemyType.armored, EnemyType.speedy],
    '43': [EnemyType.armored, EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.healer],
    '44': [EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.armored],
    '45': [EnemyType.armored, EnemyType.healer, EnemyType.speedy, EnemyType.armored, EnemyType.normal],
    '46': [EnemyType.armored, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.speedy],
    '47': [EnemyType.healer, EnemyType.normal, EnemyType.healer, EnemyType.speedy, EnemyType.armored],
  };

  static WaveDefinition _applyPrefectureTheme(WaveDefinition w, String prefCode) {
    final types = _prefectureEnemyTypes[prefCode] ??
        [EnemyType.normal, EnemyType.speedy, EnemyType.armored, EnemyType.healer, EnemyType.normal];
    return WaveDefinition(
      waveNumber: w.waveNumber,
      enemyCount: w.enemyCount,
      baseHp: w.baseHp,
      baseAttack: w.baseAttack,
      spawnInterval: w.spawnInterval,
      hasBoss: w.hasBoss,
      enemyTypes: types,
    );
  }

  /// 初期ゲーム状態を生成
  static TdGameState createInitial(
    String difficulty, [
    String prefCode = '',
    String regionCode = '',
    int hqHpBonus = 0,
    double hqAttackBonus = 0.0,
    double hqCoinMultiplier = 1.0,
  ]) {
    final isSpecial = regionCode.isNotEmpty;
    final isHistory = regionCode.startsWith('h');
    final List<GridPos> path;
    if (isHistory) {
      path = _historyPathMap[regionCode] ?? defaultPath;
    } else if (isSpecial) {
      path = regionBattlePath;
    } else if (prefCode.isNotEmpty && _prefecturePathMap.containsKey(prefCode)) {
      path = _prefecturePathMap[prefCode]!;
    } else {
      path = defaultPath;
    }
    final pathSet = path.toSet();
    final bonusMap = prefCode.isNotEmpty ? generateFacilityBonusMap(prefCode) : <FacilityType, double>{};
    final int startCoins;
    final int baseHp;
    final int waves;
    if (isHistory) {
      startCoins = _startCoinsHistory(difficulty, regionCode);
      baseHp = _baseHpForHistory(regionCode);
      waves = historyWaveCounts[regionCode] ?? 8;
    } else if (isSpecial) {
      startCoins = _startCoinsRegion(difficulty);
      baseHp = 15;
      waves = regionTotalWaves;
    } else {
      startCoins = _startCoins(difficulty);
      baseHp = 12;
      waves = totalWaves;
    }
    return TdGameState(
      cols: cols,
      rows: rows,
      path: path,
      pathSet: pathSet,
      facilities: const {},
      enemies: const [],
      coins: startCoins,
      baseHp: baseHp + hqHpBonus,
      score: 0,
      currentWave: 0,
      totalWaves: waves,
      phase: GamePhase.prep,
      waveTimer: 0,
      mistakes: 0,
      prefCode: prefCode,
      facilityDamageBonus: hqAttackBonus,
      facilityBonusMap: bonusMap,
      isRegionBattle: isSpecial,
      regionCode: regionCode,
      hqCoinMultiplier: hqCoinMultiplier,
    );
  }

  static int _startCoinsHistory(String diff, String histCode) {
    final bonus = switch (histCode) {
      'h02' => 10,
      'h03' => 20,
      'h04' => 40,
      _ => 0,
    };
    return switch (diff) {
      'easy' => 270 + bonus,
      'hard' => 200 + bonus,
      _ => 240 + bonus,
    };
  }

  static int _baseHpForHistory(String histCode) {
    return switch (histCode) {
      'h02' => 20,
      'h03' => 22,
      'h04' => 25,
      _ => 18,
    };
  }

  static int _startCoins(String diff) => switch (diff) {
    'easy' => 200,
    'hard' => 145,
    _ => 160,
  };

  static int _startCoinsRegion(String diff) => switch (diff) {
    'easy' => 240,
    'hard' => 180,
    _ => 210,
  };

  /// 施設配置（prep フェーズ・wave フェーズ両対応。コインが足りなければ null を返す）
  static TdGameState? placeFacility(
    TdGameState state,
    GridPos pos,
    FacilityType type,
  ) {
    if (state.phase != GamePhase.prep && state.phase != GamePhase.wave) {
      return null;
    }
    if (state.pathSet.contains(pos)) return null;
    if (state.facilities.containsKey(pos)) return null;

    // 都道府県限定施設の配置検証
    if (!canPlaceInPrefecture(type, state.prefCode)) {
      return null;
    }

    final bonus = state.facilityBonusMap[type] ?? 1.0;
    final actualCost = (type.cost / bonus).round();
    if (state.coins < actualCost) return null;

    // specialFacility を取得
    final specialFacility = _getSpecialFacilityForPrefecture(state.prefCode);

    final facility = Facility(
      id: 'f_${pos.col}_${pos.row}',
      type: type,
      pos: pos,
      specialFacility: specialFacility,
    );
    final newFacilities = Map<GridPos, Facility>.from(state.facilities)
      ..[pos] = facility;

    return state.copyWith(
      facilities: newFacilities,
      coins: state.coins - actualCost,
    );
  }

  /// 施設撤去（半額返還）
  static TdGameState removeFacility(TdGameState state, GridPos pos) {
    if (!state.facilities.containsKey(pos)) return state;
    final newFacilities = Map<GridPos, Facility>.from(state.facilities)
      ..remove(pos);
    final refund = (state.facilities[pos]!.type.cost / 2).round();
    return state.copyWith(
      facilities: newFacilities,
      coins: state.coins + refund,
    );
  }

  /// 施設アップグレード（コストが足りなければ null を返す）
  static TdGameState? upgradeFacility(TdGameState state, GridPos pos) {
    final f = state.facilities[pos];
    if (f == null) return null;
    final bonus = state.facilityBonusMap[f.type] ?? 1.0;
    final cost = (f.upgradeCost / bonus).round();
    if (state.coins < cost) return null;
    final upgraded = f.copyWith(level: f.level + 1, attackCooldown: f.attackCooldown);
    final newFacilities = Map<GridPos, Facility>.from(state.facilities)..[pos] = upgraded;
    return state.copyWith(facilities: newFacilities, coins: state.coins - cost);
  }

  /// ウェーブ開始
  static TdGameState startWave(TdGameState state, String difficulty) {
    if (state.phase != GamePhase.prep && state.phase != GamePhase.waveEnd) {
      return state;
    }
    final nextWave = state.currentWave + 1;
    if (nextWave > state.totalWaves) return state;

    var newState = state.copyWith(
      phase: GamePhase.wave,
      currentWave: nextWave,
      enemies: const [],
    );

    // スキル効果を適用
    if (state.selectedSkill != null) {
      newState = applySkillEffect(newState, state.selectedSkill!);
    }

    return newState;
  }

  /// ウェーブスキル効果を適用
  /// 注: 実際の効果計算は tick() 内で selectedSkill を都度チェックして適用する
  /// （facilityBonusMap に永続書き込みすると、複数ウェーブで選択するたびに
  ///   効果が複利で積み上がってしまうため、「次ウェーブのみ」の説明と矛盾する）
  static TdGameState applySkillEffect(TdGameState state, String effectKey) {
    const validKeys = {
      'waveAtkBonus',
      'waveAtkSpeedBonus',
      'waveRangeBonus',
      'waveCoinBonus',
    };
    if (!validKeys.contains(effectKey)) return state;
    return state.copyWith(waveSkillActive: true);
  }

  /// 1フレーム分の更新（dt: 経過秒）
  /// イベント形式:
  ///   'hit:{facilityCol}_{facilityRow}:{enemyId}:{damage}:{enemyPathX}:{enemyPathY}'
  ///   'kill:{enemyPathX}:{enemyPathY}:{coinReward}:{isBoss}'
  ///   'reached_goal'
  ///   'wave_clear'
  ///   'victory'
  ///   'defeat'
  static ({TdGameState state, List<String> events}) tick(
    TdGameState state,
    double dt,
    String difficulty,
    _WaveSpawner spawner,
  ) {
    if (state.phase != GamePhase.wave) {
      // ウェーブ間カウントダウン
      if (state.phase == GamePhase.waveEnd) {
        final newTimer = state.waveTimer - dt;
        if (newTimer <= 0) {
          return (state: startWave(state, difficulty), events: []);
        }
        return (state: state.copyWith(waveTimer: newTimer), events: []);
      }
      return (state: state, events: []);
    }

    final events = <String>[];
    var enemies = state.enemies.map((e) => _cloneEnemy(e)).toList();
    var facilities = Map<GridPos, Facility>.from(state.facilities);
    var coins = state.coins;
    var baseHp = state.baseHp;
    var score = state.score;
    var mistakes = state.mistakes;
    var shieldHits = state.shieldHits;

    // ── 敵スポーン ──────────────────────────────────────────────────
    final waveDef = state.isRegionBattle
        ? (state.regionCode.startsWith('h')
            ? historyBattleWaves(state.regionCode, difficulty)[state.currentWave - 1]
            : regionBattleWaves(state.regionCode, difficulty)[state.currentWave - 1])
        : wavesForPrefecture(state.prefCode, difficulty)[state.currentWave - 1];
    spawner.accumulator += dt;
    while (spawner.spawned < waveDef.enemyCount &&
        spawner.accumulator >= waveDef.spawnInterval) {
      spawner.accumulator -= waveDef.spawnInterval;
      final isBoss =
          waveDef.hasBoss && spawner.spawned == waveDef.enemyCount - 1;
      final eType = waveDef.enemyTypes[spawner.spawned % waveDef.enemyTypes.length];
      final hpMult = eType.hpMult;

      // 特殊ウェーブ修飾子（HP・速度に影響。ボスには適用しない）
      final mod = waveModifier(state.prefCode, state.currentWave, state.totalWaves);
      double modHp = 1.0;
      double modSpd = 1.0;
      if (!isBoss) {
        switch (mod) {
          case 'elite':
            modHp = 1.6; // 精鋭: 硬い
            modSpd = 0.85;
            break;
          case 'swarm':
            modHp = 0.5; // 大群: 脆いが速い
            modSpd = 1.15;
            break;
          case 'blitz':
            modSpd = 1.5; // 電撃: 非常に速い
            break;
          // bounty は HP/速度そのまま、報酬のみ増加（kill時に処理）
        }
      }

      // ボスHPは2.5倍（旧3倍は過剰。スキルで十分な脅威になる）
      final hp = isBoss
          ? (waveDef.baseHp * 2.5).round()
          : (waveDef.baseHp * hpMult * modHp).round();
      final baseSpd = eType.speedMult * (isBoss ? 0.6 : 1.2) * modSpd;
      final spd = baseSpd * max(0.3, 1.0 - state.enemySpeedPenalty);
      enemies.add(Enemy(
        id: 'e_${state.currentWave}_${spawner.spawned}',
        isBoss: isBoss,
        hp: hp,
        maxHp: hp,
        attack: waveDef.baseAttack,
        speed: spd,
        enemyType: eType,
        bossSkillCooldown: isBoss ? 8.0 : 0.0,
        bossSkillType: isBoss
            ? (state.regionCode.startsWith('h')
                ? _bossSkillForHistory(state.regionCode)
                : state.isRegionBattle
                    ? _bossSkillForRegion(state.regionCode)
                    : _bossSkillForPrefecture(state.prefCode))
            : null,
      ));
      spawner.spawned++;
    }

    // ── 敵移動 ──────────────────────────────────────────────────────
    final path = state.path;
    final deadIds = <String>{};
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0; // 現在時刻（秒）

    for (final enemy in enemies) {
      if (enemy.isDead) continue;

      // デバフ期限を更新
      if (enemy.speedPenaltyEndTime <= now) {
        enemy.speedPenaltyEndTime = 0;
      }
      if (enemy.alpineSlowEndTime <= now) {
        enemy.alpineSlowEndTime = 0;
      }
      if (enemy.umeSakeSlowEndTime <= now) {
        enemy.umeSakeSlowEndTime = 0;
      }
      if (enemy.stunEndTime <= now) {
        enemy.isStunned = false;
        enemy.stunEndTime = 0;
      }

      // 敵移動（スタン中は移動しない）
      if (enemy.isStunned && enemy.stunEndTime > now) {
        // スタン中は移動なし
      } else {
        // 現在の速度を計算（デバフ適用）
        double effectiveSpeed = enemy.speed;

        // dairyFarm: 速度 -20%
        if (enemy.speedPenaltyEndTime > now) {
          effectiveSpeed *= 0.8;
        }

        // alpineWatch: スロー（速度 *0.7）
        if (enemy.alpineSlowEndTime > now) {
          effectiveSpeed *= 0.7;
        }

        // umeSakeBrewery: スロー（速度 *0.65）
        if (enemy.umeSakeSlowEndTime > now) {
          effectiveSpeed *= 0.65;
        }

        enemy.pathProgress += effectiveSpeed * dt;
      }
      if (enemy.pathProgress >= path.length - 1) {
        // ゴール到達
        enemy.isDead = true;
        deadIds.add(enemy.id);
        if (shieldHits > 0) {
          // シールドが吸収
          shieldHits--;
          events.add('shield_block');
        } else {
          baseHp--;
          mistakes++;
          events.add('reached_goal');
        }
        continue;
      }

      // ヒーラーの再生処理
      if (enemy.enemyType == EnemyType.healer && enemy.enemyType.regenInterval > 0) {
        enemy.regenCooldown -= dt;
        if (enemy.regenCooldown <= 0) {
          enemy.regenCooldown = enemy.enemyType.regenInterval;
          enemy.hp = min(enemy.maxHp, enemy.hp + enemy.enemyType.regenAmount);
        }
      }

      // ボス特殊スキル処理
      if (enemy.isBoss && enemy.bossSkillType != null) {
        enemy.bossSkillCooldown -= dt;
        if (enemy.bossSkillCooldown <= 0) {
          final skill = enemy.bossSkillType!;
          final ePos = enemy.posOnPath(path);
          switch (skill) {
            case BossSkillType.speedBurst:
              enemy.speed *= 2.0;
              break;
            case BossSkillType.hpRegen:
              enemy.hp = min(enemy.maxHp, enemy.hp + enemy.maxHp ~/ 4);
              break;
            case BossSkillType.summon:
              // 2体の増援を追加（ボスの少し後ろにスポーン）
              final spawnProgress = max(0.0, enemy.pathProgress - 0.5);
              final waveDef2 = state.regionCode.startsWith('h')
                  ? historyBattleWaves(state.regionCode, difficulty)[state.currentWave - 1]
                  : state.isRegionBattle
                      ? regionBattleWaves(state.regionCode, difficulty)[state.currentWave - 1]
                      : wavesForPrefecture(state.prefCode, difficulty)[state.currentWave - 1];
              for (var si = 0; si < 2; si++) {
                enemies.add(Enemy(
                  id: 'boss_summon_${spawner.spawned}_$si',
                  isBoss: false,
                  hp: waveDef2.baseHp ~/ 2,
                  maxHp: waveDef2.baseHp ~/ 2,
                  attack: waveDef2.baseAttack,
                  speed: 1.2,
                  enemyType: EnemyType.normal,
                  pathProgress: spawnProgress,
                ));
              }
              break;
            case BossSkillType.stunFacility:
              // 全施設の攻撃クールダウンを3秒追加
              for (final fEntry in facilities.entries) {
                fEntry.value.attackCooldown += 3.0;
              }
              break;
          }
          events.add('boss_skill:${skill.name}:${ePos.dx.toStringAsFixed(2)}:${ePos.dy.toStringAsFixed(2)}');
          enemy.bossSkillCooldown = 10.0 + _rng.nextDouble() * 5.0;
        }
      }
    }

    // ── 施設攻撃 ────────────────────────────────────────────────────
    for (final entry in facilities.entries) {
      final pos = entry.key;
      final f = entry.value;

      // specialFacility による攻撃速度修正を計算
      // 空港: 攻速ボーナスは「+50% かつ 最大 +0.6/秒」の加算上限。
      // 高速施設（工業1.5・神社2.5）への過剰な乗算スタックを防ぐ。
      double effectiveAttackSpeed = f.type.attackSpeed;
      if (f.specialFacility == 'airport') {
        final bonus = min(f.type.attackSpeed * 0.5, 0.6);
        effectiveAttackSpeed = f.type.attackSpeed + bonus;
      }

      // waveAtkSpeedBonus スキル: 攻撃速度 +15%（発射頻度そのものが上がる）
      if (state.selectedSkill == 'waveAtkSpeedBonus' && state.waveSkillActive) {
        effectiveAttackSpeed *= 1.15;
      }

      f.attackCooldown = max(0, f.attackCooldown - dt);
      if (f.attackCooldown > 0) continue;

      // 射程内の生存敵を探す（最も進行度が高い敵を優先）
      // 射程ボーナス: waveRangeBonus スキル選択時は +1 セル
      final rangeBonus = (state.selectedSkill == 'waveRangeBonus' && state.waveSkillActive) ? 1.0 : 0.0;
      final effectiveRange = f.range + rangeBonus;

      Enemy? target;
      double bestProgress = -1;
      for (final enemy in enemies) {
        if (enemy.isDead) continue;
        final ePos = enemy.posOnPath(path);
        final dx = ePos.dx - f.pos.col;
        final dy = ePos.dy - f.pos.row;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist <= effectiveRange && enemy.pathProgress > bestProgress) {
          target = enemy;
          bestProgress = enemy.pathProgress;
        }
      }

      if (target != null) {
        var typeBonus = state.facilityBonusMap[f.type] ?? 1.0;
        // waveAtkBonus スキル: 全施設ダメージ +25%（選択中のウェーブのみ）
        if (state.selectedSkill == 'waveAtkBonus' && state.waveSkillActive) {
          typeBonus *= 1.25;
        }
        // 施設シナジー: 隣接する同種施設で強化
        typeBonus *= synergyMultiplier(state, f);
        var rawDamage = (f.damage * typeBonus * (1.0 + state.facilityDamageBonus)).round();

        // kiyomizuTemple: 敵ダメージ+40%（乗算）
        if (f.type == FacilityType.kiyomizuTemple) {
          rawDamage = (rawDamage * 1.4).round();
        }

        // kiyomizuTemple による damageMultiplier ボーナスも適用
        rawDamage = (rawDamage * target.damageMultiplier).round();

        // クリティカルヒット（15%確率で2倍ダメージ＝爽快感）
        final isCrit = _rng.nextDouble() < 0.15;
        if (isCrit) {
          rawDamage = (rawDamage * 2).round();
        }

        final actualDamage = max(1, rawDamage - target.enemyType.armorReduction);

        // peaceShrine: シールドダメージ吸収（20%）
        int finalDamage = actualDamage;
        if (target.shieldHp > 0) {
          final shieldAbsorb = min(target.shieldHp, finalDamage);
          finalDamage -= shieldAbsorb;
          target.shieldHp -= shieldAbsorb;
        }

        target.hp -= finalDamage;

        // specialFacility による攻撃速度修正を適用（空港は加算上限済み）
        f.attackCooldown = 1.0 / effectiveAttackSpeed;

        // ヒットイベント: 施設グリッド座標 + 敵パス座標（浮動小数）+ クリティカルフラグ
        final ePos = target.posOnPath(path);
        events.add(
          'hit:${pos.col}_${pos.row}:${target.id}:$finalDamage:${ePos.dx.toStringAsFixed(3)}:${ePos.dy.toStringAsFixed(3)}:${isCrit ? 1 : 0}',
        );

        // 都道府県限定施設の特殊能力を実行
        _applyExclusiveFacilityAbility(f, target, ePos);

        // base（基地）施設: 3x3範囲の敵に+50%ダメージを追加
        if (f.specialFacility == 'base' && target.hp > 0) {
          _applyBaseAreaDamage(f, enemies, path, ePos);
        }

        if (target.hp <= 0) {
          target.isDead = true;
          deadIds.add(target.id);
          // 撃破報酬 wave スケール: 基本12 + wave×3（後半の高HP敵に見合う報酬に）
          final reward = target.isBoss
              ? 60 + state.currentWave * 5
              : 12 + state.currentWave * 3;

          // toyotaFactory: コイン生成ボーナス（+10）
          final coinBonus = f.type == FacilityType.toyotaFactory ? 10 : 0;

          // waveCoinBonus スキル: コイン +20%
          var totalReward = reward + coinBonus;
          if (state.selectedSkill == 'waveCoinBonus' && state.waveSkillActive) {
            totalReward = (totalReward * 1.2).round();
          }
          // bounty（ボーナスウェーブ）: 報酬2倍
          if (waveModifier(state.prefCode, state.currentWave, state.totalWaves) ==
              'bounty') {
            totalReward *= 2;
          }
          // 本部強化: コイン獲得倍率
          totalReward = (totalReward * state.hqCoinMultiplier).round();

          coins += totalReward;

          score += target.isBoss ? 200 : 50;
          // キルイベント: 敵パス座標 + 報酬コイン + isBoss フラグ
          events.add(
            'kill:${ePos.dx.toStringAsFixed(3)}:${ePos.dy.toStringAsFixed(3)}:$totalReward:${target.isBoss}',
          );
        }
      }
    }

    // 死亡敵を除去
    enemies.removeWhere((e) => e.isDead);

    // ── 終了判定 ────────────────────────────────────────────────────
    GamePhase nextPhase = state.phase;
    double nextTimer = state.waveTimer;

    if (baseHp <= 0) {
      nextPhase = GamePhase.defeat;
      events.add('defeat');
    } else if (enemies.isEmpty && spawner.spawned >= waveDef.enemyCount) {
      // ウェーブクリア
      score += 100;
      if (state.currentWave >= totalWaves) {
        nextPhase = GamePhase.victory;
        events.add('victory');
      } else {
        nextPhase = GamePhase.waveEnd;
        nextTimer = waveBreakDuration;
        events.add('wave_clear');
      }
    }

    final newState = state.copyWith(
      enemies: enemies,
      facilities: facilities,
      coins: coins,
      baseHp: baseHp,
      score: score,
      phase: nextPhase,
      waveTimer: nextTimer,
      mistakes: mistakes,
      shieldHits: shieldHits,
    );
    return (state: newState, events: events);
  }

  /// base（基地）施設: 3x3範囲内の敵に+50%ダメージを追加
  /// 特殊ウェーブ修飾子を決定論的に判定（同じ県・同じウェーブなら常に同じ結果）
  /// 'none' | 'elite' | 'swarm' | 'blitz' | 'bounty'
  /// wave1 とボスウェーブは常に 'none'（導入とボス戦を邪魔しない）
  static String waveModifier(String prefCode, int wave, int totalWaves) {
    if (wave <= 1 || wave >= totalWaves) return 'none';
    final h = (prefCode.hashCode ^ (wave * 2654435761)) & 0x7fffffff;
    // 40%の確率で特殊ウェーブ、内訳を h で振り分け
    if (h % 100 < 40) {
      switch ((h ~/ 100) % 4) {
        case 0:
          return 'elite';
        case 1:
          return 'swarm';
        case 2:
          return 'blitz';
        default:
          return 'bounty';
      }
    }
    return 'none';
  }

  /// 施設シナジー: 上下左右に隣接する同種施設1つにつき +15%ダメージ（最大4方向 +60%）
  /// 戦略的なまとめ配置を報酬づける
  static double synergyMultiplier(TdGameState state, Facility f) {
    const dirs = [
      [0, -1],
      [0, 1],
      [-1, 0],
      [1, 0],
    ];
    var count = 0;
    for (final d in dirs) {
      final neighbor = state.facilities[GridPos(f.pos.col + d[0], f.pos.row + d[1])];
      if (neighbor != null && neighbor.type == f.type) count++;
    }
    return 1.0 + count * 0.15;
  }

  static void _applyBaseAreaDamage(
    Facility facility,
    List<Enemy> enemies,
    List<GridPos> path,
    Offset targetPos,
  ) {
    // 3x3範囲（中心 ± 1グリッド）内の敵を探す
    for (final enemy in enemies) {
      if (enemy.isDead || enemy.id == '' && enemy == enemies.last) continue;
      final ePos = enemy.posOnPath(path);
      final dx = (ePos.dx - targetPos.dx).abs();
      final dy = (ePos.dy - targetPos.dy).abs();

      // 3x3範囲チェック（中心から±1.5セル以内）
      if (dx <= 1.5 && dy <= 1.5 && (ePos.dx != targetPos.dx || ePos.dy != targetPos.dy)) {
        // +50%ダメージを適用
        final bonusDamage = ((facility.damage * 0.5) * enemy.damageMultiplier).round();
        final actualBonus = max(1, bonusDamage - enemy.enemyType.armorReduction);
        enemy.hp -= actualBonus;
      }
    }
  }

  /// 都道府県限定施設の特殊能力を敵に適用
  static void _applyExclusiveFacilityAbility(
    Facility facility,
    Enemy target,
    Offset ePos,
  ) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0; // 現在時刻（秒）

    switch (facility.type) {
      case FacilityType.dairyFarm:
        // 敵速度 -20% を2秒間付与
        if (target.speedPenaltyEndTime <= now) {
          target.speedPenaltyEndTime = now + 2.0;
        }
        break;

      case FacilityType.alpineWatch:
        // 30% 確率でスロー（速度 *0.7）を1秒間付与
        if (_rng.nextDouble() < 0.3) {
          if (target.alpineSlowEndTime <= now) {
            target.alpineSlowEndTime = now + 1.0;
          }
        }
        break;

      case FacilityType.toyotaFactory:
        // 攻撃速度30%高速化は既に type.attackSpeed で反映
        // コイン生成ボーナスは tick() の kill イベント時に実行
        break;

      case FacilityType.kiyomizuTemple:
        // ダメージ+40%は既に tick() の攻撃処理で反映
        break;

      case FacilityType.peaceShrine:
        // 敵にシールド付与（敵の maxHp の20%）
        if (target.shieldHp <= 0) {
          target.shieldHp = (target.maxHp * 0.2).ceil();
        }
        break;

      case FacilityType.heimeyuriTower:
        // 40% 確率でスタン1秒
        if (_rng.nextDouble() < 0.4) {
          if (!target.isStunned && target.stunEndTime <= now) {
            target.isStunned = true;
            target.stunEndTime = now + 1.0;
          }
        }
        break;

      case FacilityType.umeSakeBrewery:
        // 50% 確率でスロー（速度 *0.65）を1.5秒間
        if (_rng.nextDouble() < 0.5) {
          if (target.umeSakeSlowEndTime <= now) {
            target.umeSakeSlowEndTime = now + 1.5;
          }
        }
        break;

      case FacilityType.udonShop:
        // 特殊能力なし（低コスト+高速のみ）
        break;

      case FacilityType.farm:
      case FacilityType.fishery:
      case FacilityType.factory:
      case FacilityType.mine:
      case FacilityType.castle:
      case FacilityType.shrine:
        // 通常施設は特殊能力なし
        break;
    }
  }

  /// 都道府県限定施設かどうかを判定
  static bool isExclusiveFacility(FacilityType type) {
    return [
      FacilityType.dairyFarm,
      FacilityType.alpineWatch,
      FacilityType.toyotaFactory,
      FacilityType.kiyomizuTemple,
      FacilityType.peaceShrine,
      FacilityType.heimeyuriTower,
      FacilityType.umeSakeBrewery,
      FacilityType.udonShop,
    ].contains(type);
  }

  /// 都道府県コード → 限定施設の対応表
  static const Map<String, FacilityType> _exclusiveByPrefecture = {
    '01': FacilityType.dairyFarm,      // 北海道
    '20': FacilityType.alpineWatch,    // 長野
    '23': FacilityType.toyotaFactory,  // 愛知
    '26': FacilityType.kiyomizuTemple, // 京都
    '34': FacilityType.peaceShrine,    // 広島
    '47': FacilityType.heimeyuriTower, // 沖縄
    '30': FacilityType.umeSakeBrewery, // 和歌山
    '40': FacilityType.udonShop,       // 福岡
  };

  /// 施設が指定された都道府県に配置可能かどうかを判定
  static bool canPlaceInPrefecture(FacilityType type, String prefCode) {
    if (!isExclusiveFacility(type)) return true; // 通常施設は常に配置可能
    return _exclusiveByPrefecture[prefCode] == type;
  }

  /// 指定都道府県の限定施設を取得（なければ null）
  static FacilityType? exclusiveFacilityForPrefecture(String prefCode) {
    return _exclusiveByPrefecture[prefCode];
  }

  /// 指定都道府県の特殊施設（airport/base）を取得
  static String? _getSpecialFacilityForPrefecture(String prefCode) {
    if (prefCode.isEmpty) return null;
    final pref = allPrefectures.firstWhere(
      (p) => p.code == prefCode,
      orElse: () => allPrefectures.first,
    );
    return pref.specialFacility;
  }

  static Enemy _cloneEnemy(Enemy e) {
    final cloned = Enemy(
      id: e.id,
      isBoss: e.isBoss,
      hp: e.hp,
      maxHp: e.maxHp,
      attack: e.attack,
      speed: e.speed,
      enemyType: e.enemyType,
      pathProgress: e.pathProgress,
      isDead: e.isDead,
      regenCooldown: e.regenCooldown,
      bossSkillCooldown: e.bossSkillCooldown,
      isStunned: e.isStunned,
      bossSkillType: e.bossSkillType,
      speedPenaltyEndTime: e.speedPenaltyEndTime,
      alpineSlowEndTime: e.alpineSlowEndTime,
      umeSakeSlowEndTime: e.umeSakeSlowEndTime,
      shieldHp: e.shieldHp,
      damageMultiplier: e.damageMultiplier,
    );
    return cloned;
  }
}

/// ウェーブスポーン進行状態（ゲーム画面で保持）
class _WaveSpawner {
  int spawned = 0;
  double accumulator = 0;
}

/// 外部から使えるスポーナー
class WaveSpawner extends _WaveSpawner {
  void reset() {
    spawned = 0;
    accumulator = 0;
  }
}
