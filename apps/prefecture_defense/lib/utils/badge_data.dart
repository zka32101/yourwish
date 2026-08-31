import 'package:flutter/material.dart';

class BadgeData {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color color;

  const BadgeData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
  });
}

// ── 地方バッジ (8) ─────────────────────────────────────────────────────────

const List<BadgeData> regionBadges = [
  BadgeData(id: 'region_r01', name: '北海道制覇', emoji: '❄️', description: '北海道地方決戦クリア', color: Color(0xFF1565C0)),
  BadgeData(id: 'region_r02', name: '東北制覇',   emoji: '⛰️', description: '東北地方決戦クリア',   color: Color(0xFF2E7D32)),
  BadgeData(id: 'region_r03', name: '関東制覇',   emoji: '🏙️', description: '関東地方決戦クリア',   color: Color(0xFF6A1B9A)),
  BadgeData(id: 'region_r04', name: '中部制覇',   emoji: '🗻', description: '中部地方決戦クリア',   color: Color(0xFFC62828)),
  BadgeData(id: 'region_r05', name: '近畿制覇',   emoji: '⛩️', description: '近畿地方決戦クリア',   color: Color(0xFFE65100)),
  BadgeData(id: 'region_r06', name: '中国制覇',   emoji: '🌊', description: '中国地方決戦クリア',   color: Color(0xFF00695C)),
  BadgeData(id: 'region_r07', name: '四国制覇',   emoji: '🌸', description: '四国地方決戦クリア',   color: Color(0xFFAD1457)),
  BadgeData(id: 'region_r08', name: '九州・沖縄制覇', emoji: '🔥', description: '九州・沖縄地方決戦クリア', color: Color(0xFFBF360C)),
];

// ── 歴史バッジ (4) ─────────────────────────────────────────────────────────

const List<BadgeData> historyBadges = [
  BadgeData(id: 'hist_h01', name: '古代の守護者', emoji: '⚔️', description: '神代の決戦クリア',      color: Color(0xFF4527A0)),
  BadgeData(id: 'hist_h02', name: '戦国の覇者',   emoji: '🏯', description: '戦国の決戦クリア',      color: Color(0xFFB71C1C)),
  BadgeData(id: 'hist_h03', name: '維新の英傑',   emoji: '🚢', description: '幕末・文明開化クリア',  color: Color(0xFF1A237E)),
  BadgeData(id: 'hist_h04', name: '令和の伝説',   emoji: '🌅', description: '令和の最終決戦クリア', color: Color(0xFFBF360C)),
];

// ── 特別バッジ (5) ────────────────────────────────────────────────────────

const List<BadgeData> specialBadges = [
  BadgeData(
    id: 'national',
    name: '全国制覇',
    emoji: '🗾',
    description: '47都道府県をすべてクリア',
    color: Color(0xFF1565C0),
  ),
  BadgeData(
    id: 'national_hard',
    name: 'ハードマスター',
    emoji: '💎',
    description: '47都道府県すべてをハードでクリア',
    color: Color(0xFF6A1B9A),
  ),
  BadgeData(
    id: 'all_regions',
    name: '地方の覇者',
    emoji: '🏆',
    description: '全8地方決戦をクリア',
    color: Color(0xFFE65100),
  ),
  BadgeData(
    id: 'all_history',
    name: '歴史の守護者',
    emoji: '⚔️',
    description: '全4歴史決戦をクリア',
    color: Color(0xFF4527A0),
  ),
  BadgeData(
    id: 'legend',
    name: '伝説の覇者',
    emoji: '👑',
    description: '全都道府県ハード＋全地方＋全歴史決戦を制覇',
    color: Color(0xFFFFAB00),
  ),
];

// ── 全バッジリスト ──────────────────────────────────────────────────────────

List<BadgeData> get allBadges => [
  ...specialBadges,
  ...regionBadges,
  ...historyBadges,
];
