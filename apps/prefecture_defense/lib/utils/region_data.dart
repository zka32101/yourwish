import 'package:flutter/material.dart';

class RegionData {
  final String code;
  final String name;
  final String emoji;
  final Color color;
  final List<String> prefectureCodes;
  final String bossName;
  final String bossEmoji;
  final String bossSkill;
  final int difficultyRating;

  const RegionData({
    required this.code,
    required this.name,
    required this.emoji,
    required this.color,
    required this.prefectureCodes,
    required this.bossName,
    required this.bossEmoji,
    required this.bossSkill,
    required this.difficultyRating,
  });
}

const List<RegionData> allRegions = [
  RegionData(
    code: 'r01',
    name: '北海道',
    emoji: '❄️',
    color: Color(0xFF1565C0),
    prefectureCodes: ['01'],
    bossName: '白熊の大王',
    bossEmoji: '🐻‍❄️',
    bossSkill: 'スピードバースト',
    difficultyRating: 3,
  ),
  RegionData(
    code: 'r02',
    name: '東北',
    emoji: '⛰️',
    color: Color(0xFF2E7D32),
    prefectureCodes: ['02', '03', '04', '05', '06', '07'],
    bossName: '荒波の将軍',
    bossEmoji: '🌊',
    bossSkill: '増援召喚',
    difficultyRating: 4,
  ),
  RegionData(
    code: 'r03',
    name: '関東',
    emoji: '🏙️',
    color: Color(0xFF6A1B9A),
    prefectureCodes: ['08', '09', '10', '11', '12', '13', '14'],
    bossName: '鋼鉄の守護者',
    bossEmoji: '🤖',
    bossSkill: '施設停止',
    difficultyRating: 5,
  ),
  RegionData(
    code: 'r04',
    name: '中部',
    emoji: '🗻',
    color: Color(0xFFC62828),
    prefectureCodes: ['15', '16', '17', '18', '19', '20', '21', '22', '23'],
    bossName: '富士の龍神',
    bossEmoji: '🐉',
    bossSkill: 'スピードバースト',
    difficultyRating: 6,
  ),
  RegionData(
    code: 'r05',
    name: '近畿',
    emoji: '⛩️',
    color: Color(0xFFE65100),
    prefectureCodes: ['24', '25', '26', '27', '28', '29', '30'],
    bossName: '千年の怨霊',
    bossEmoji: '👻',
    bossSkill: 'HP再生',
    difficultyRating: 6,
  ),
  RegionData(
    code: 'r06',
    name: '中国',
    emoji: '🌊',
    color: Color(0xFF00695C),
    prefectureCodes: ['31', '32', '33', '34', '35'],
    bossName: '瀬戸の覇者',
    bossEmoji: '⛵',
    bossSkill: 'HP再生',
    difficultyRating: 5,
  ),
  RegionData(
    code: 'r07',
    name: '四国',
    emoji: '🌸',
    color: Color(0xFFAD1457),
    prefectureCodes: ['36', '37', '38', '39'],
    bossName: '黒潮の覇王',
    bossEmoji: '🐋',
    bossSkill: 'スピードバースト',
    difficultyRating: 5,
  ),
  RegionData(
    code: 'r08',
    name: '九州・沖縄',
    emoji: '🔥',
    color: Color(0xFFBF360C),
    prefectureCodes: ['40', '41', '42', '43', '44', '45', '46', '47'],
    bossName: '南海の火龍',
    bossEmoji: '🐲',
    bossSkill: '増援召喚',
    difficultyRating: 7,
  ),
];

RegionData? getRegionByCode(String code) {
  try {
    return allRegions.firstWhere((r) => r.code == code);
  } catch (_) {
    return null;
  }
}

RegionData? getRegionForPrefecture(String prefCode) {
  try {
    return allRegions.firstWhere((r) => r.prefectureCodes.contains(prefCode));
  } catch (_) {
    return null;
  }
}
