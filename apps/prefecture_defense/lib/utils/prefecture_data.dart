import 'package:prefecture_defense/models/td_model.dart';

class PrefectureData {
  final String code;
  final String name;
  final String kana;
  final String capitalCity;
  final int population;
  final int area;
  final List<String> specialties;
  final String region;
  final String color;
  final BossData boss;
  final CompanionData companion;
  final FacilityType? primaryIndustry;
  final double industryBonus;
  final String geography; // 'sea', 'mountain', 'urban', 'agriculture', 'mixed'
  final int difficultyRating; // 1-5 stars
  final String? specialFacility; // 'airport', 'base', or null

  const PrefectureData({
    required this.code,
    required this.name,
    required this.kana,
    required this.capitalCity,
    required this.population,
    required this.area,
    required this.specialties,
    required this.region,
    required this.color,
    required this.boss,
    required this.companion,
    this.primaryIndustry,
    this.industryBonus = 1.0,
    required this.geography,
    required this.difficultyRating,
    this.specialFacility,
  });
}

class BossData {
  final String name;
  final String type;
  final int baseHp;
  final int baseAttack;
  final String skill;

  const BossData({
    required this.name,
    required this.type,
    required this.baseHp,
    required this.baseAttack,
    required this.skill,
  });
}

class CompanionData {
  final String id;
  final String name;
  final String description;
  final String rarity; // common, rare, legend
  final List<String> skills;

  const CompanionData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.skills,
  });
}

/// 地域定数
class Region {
  static const hokkaido = 'Hokkaido';
  static const tohoku = 'Tohoku';
  static const kanto = 'Kanto';
  static const chubu = 'Chubu';
  static const kinki = 'Kinki';
  static const chugoku = 'Chugoku';
  static const shikoku = 'Shikoku';
  static const kyushu = 'Kyushu';
}

/// 地域表示名
const Map<String, String> regionNames = {
  Region.hokkaido: '北海道',
  Region.tohoku: '東北',
  Region.kanto: '関東',
  Region.chubu: '中部',
  Region.kinki: '近畿',
  Region.chugoku: '中国',
  Region.shikoku: '四国',
  Region.kyushu: '九州・沖縄',
};

/// 都道府県ボスキャラ画像パス
const Map<String, String> prefectureBossImages = {
  '01': 'assets/images/characters/01. ジャガイモ大王 — 北海道.jpg',
  '02': 'assets/images/characters/02. りんご騎士 — 青森.jpg',
  '03': 'assets/images/characters/03. 南部鉄の騎士 — 岩手.jpg',
  '04': 'assets/images/characters/04. 牛タン将軍 — 宮城.jpg',
  '05': 'assets/images/characters/05. きりたんぽ師 — 秋田.jpg',
  '06': 'assets/images/characters/06. さくらんぼ伯爵 — 山形.jpg',
  '07': 'assets/images/characters/07. 柿の王 — 福島.jpg',
  '08': 'assets/images/characters/08. アンコウ王 — 茨城.jpg',
  '09': 'assets/images/characters/09. ぎょうざマスター — 栃木.jpg',
  '10': 'assets/images/characters/10. こんにゃく王 — 群馬.jpg',
  '11': 'assets/images/characters/11. 枝豆将軍 — 埼玉.jpg',
  '12': 'assets/images/characters/12. ピーナッツ侯爵 — 千葉.jpg',
  '13': 'assets/images/characters/13. もんじゃ皇帝 — 東京.jpg',
  '14': 'assets/images/characters/14. シウマイ大帝 — 神奈川.jpg',
  '15': 'assets/images/characters/15. 米の王 — 新潟.jpg',
  '16': 'assets/images/characters/16. ほたるいか将軍 — 富山.jpg',
  '17': 'assets/images/characters/17. 金箔大名 — 石川.jpg',
  '18': 'assets/images/characters/18. 越前ガニの王 — 福井.jpg',
  '19': 'assets/images/characters/19. ぶどう武将 — 山梨.jpg',
  '20': 'assets/images/characters/20. そば師匠 — 長野.jpg',
  '21': 'assets/images/characters/21. 飛騨牛の王 — 岐阜.jpg',
  '22': 'assets/images/characters/22. お茶の仙人 — 静岡.jpg',
  '23': 'assets/images/characters/23. 天下人の影 — 愛知.jpg',
  '24': 'assets/images/characters/24. 伊勢エビ神官 — 三重.jpg',
  '25': 'assets/images/characters/25. 鮒ずしの怪 — 滋賀.jpg',
  '26': 'assets/images/characters/26. 千年の都の鬼 — 京都.jpg',
  '27': 'assets/images/characters/27. たこ焼き大将 — 大阪.jpg',
  '28': 'assets/images/characters/28. 神戸牛の王 — 兵庫.jpg',
  '29': 'assets/images/characters/29. 古都の大仏 — 奈良.jpg',
  '30': 'assets/images/characters/30. 梅の魔女 — 和歌山.jpg',
  '31': 'assets/images/characters/31. 砂丘の魔神 — 鳥取.jpg',
  '32': 'assets/images/characters/32. 出雲の大神 — 島根.jpg',
  '33': 'assets/images/characters/33. 桃太郎の鬼 — 岡山.jpg',
  '34': 'assets/images/characters/34. 牡蠣の大将 — 広島.jpg',
  '35': 'assets/images/characters/35. ふぐの王者 — 山口.jpg',
  '36': 'assets/images/characters/36. 阿波踊りの鬼 — 徳島.jpg',
  '37': 'assets/images/characters/37. うどん大魔王 — 香川.jpg',
  '38': 'assets/images/characters/38. みかん大名 — 愛媛.jpg',
  '39': 'assets/images/characters/39. 海賊船長 — 高知.jpg',
  '40': 'assets/images/characters/40. 博多のラーメン王 — 福岡.jpg',
  '41': 'assets/images/characters/41. 有明の泥人形 — 佐賀.jpg',
  '42': 'assets/images/characters/42. 南蛮商人 — 長崎.jpg',
  '43': 'assets/images/characters/43. 火の国の熊将軍 — 熊本.jpg',
  '44': 'assets/images/characters/44. 温泉の湯鬼 — 大分.jpg',
  '45': 'assets/images/characters/45. 日向の神 — 宮崎.jpg',
  '46': 'assets/images/characters/46. 桜島の噴火鬼 — 鹿児島.jpg',
  '47': 'assets/images/characters/47. シーサーの王 — 沖縄.jpg',
};

/// 全47都道府県マスターデータ
const List<PrefectureData> allPrefectures = [
  // ── 北海道 ──────────────────────────────
  PrefectureData(
    code: '01', name: '北海道', kana: 'ほっかいどう',
    capitalCity: '札幌市', population: 5100000, area: 83424,
    specialties: ['じゃがいも', 'ほたて', 'ラム肉', 'とうもろこし'],
    region: Region.hokkaido, color: '#1E90FF',
    boss: BossData(name: 'ジャガイモ大王', type: 'potato', baseHp: 150, baseAttack: 20, skill: 'ジャガイモ砲'),
    companion: CompanionData(id: 'hokkaido_wolf', name: 'エゾオオカミ', description: '北海道の大地を守る白き狼', rarity: 'rare', skills: ['howl', 'pack_attack']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.25,
    geography: 'agriculture', difficultyRating: 2,
    specialFacility: 'airport',
  ),

  // ── 東北 ──────────────────────────────
  PrefectureData(
    code: '02', name: '青森県', kana: 'あおもりけん',
    capitalCity: '青森市', population: 1200000, area: 9646,
    specialties: ['りんご', 'ニンニク', 'イカ', 'ねぶた'],
    region: Region.tohoku, color: '#DC143C',
    boss: BossData(name: 'りんご騎士', type: 'apple', baseHp: 120, baseAttack: 18, skill: 'りんご落とし'),
    companion: CompanionData(id: 'aomori_kite', name: '金鵄', description: '津軽の空を舞う金色の鳥', rarity: 'common', skills: ['dive', 'talon']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.20,
    geography: 'sea', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '03', name: '岩手県', kana: 'いわてけん',
    capitalCity: '盛岡市', population: 1200000, area: 15275,
    specialties: ['わんこそば', '南部鉄器', 'どんこ', '短角牛'],
    region: Region.tohoku, color: '#4169E1',
    boss: BossData(name: '南部鉄の騎士', type: 'iron', baseHp: 160, baseAttack: 22, skill: '鉄の壁'),
    companion: CompanionData(id: 'iwate_dragon', name: '座敷童', description: '幸運を呼ぶ不思議な存在', rarity: 'rare', skills: ['fortune', 'hide']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.20,
    geography: 'mountain', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '04', name: '宮城県', kana: 'みやぎけん',
    capitalCity: '仙台市', population: 2300000, area: 7282,
    specialties: ['牛タン', '笹かまぼこ', 'ずんだ餅', 'はらこ飯'],
    region: Region.tohoku, color: '#228B22',
    boss: BossData(name: '牛タン将軍', type: 'meat', baseHp: 140, baseAttack: 25, skill: '肉焼き爆炎'),
    companion: CompanionData(id: 'miyagi_crane', name: '松島の鶴', description: '日本三景・松島を守る聖なる鶴', rarity: 'rare', skills: ['dance', 'heal']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.20,
    geography: 'mixed', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '05', name: '秋田県', kana: 'あきたけん',
    capitalCity: '秋田市', population: 950000, area: 11637,
    specialties: ['きりたんぽ', 'いぶりがっこ', '秋田犬', '比内地鶏'],
    region: Region.tohoku, color: '#DAA520',
    boss: BossData(name: 'きりたんぽ師', type: 'food', baseHp: 110, baseAttack: 16, skill: 'きりたんぽ突き'),
    companion: CompanionData(id: 'akita_dog', name: '秋田犬', description: '忠義の象徴・秋田の守り犬', rarity: 'rare', skills: ['loyal', 'guard']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.20,
    geography: 'mountain', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '06', name: '山形県', kana: 'やまがたけん',
    capitalCity: '山形市', population: 1070000, area: 9323,
    specialties: ['さくらんぼ', 'だし', '芋煮', '米沢牛'],
    region: Region.tohoku, color: '#FF1493',
    boss: BossData(name: 'さくらんぼ伯爵', type: 'fruit', baseHp: 100, baseAttack: 14, skill: 'さくらんぼ乱射'),
    companion: CompanionData(id: 'yamagata_bear', name: '出羽の熊', description: '羽黒山を守護する山の守り神', rarity: 'common', skills: ['claw', 'roar']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.20,
    geography: 'mountain', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '07', name: '福島県', kana: 'ふくしまけん',
    capitalCity: '福島市', population: 1850000, area: 13784,
    specialties: ['あんぽ柿', '会津ラーメン', '喜多方ラーメン', '白桃'],
    region: Region.tohoku, color: '#FF6347',
    boss: BossData(name: '柿の王', type: 'fruit', baseHp: 130, baseAttack: 19, skill: '柿嵐'),
    companion: CompanionData(id: 'fukushima_fox', name: '白狐', description: '会津の神社に宿る霊狐', rarity: 'common', skills: ['illusion', 'dash']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.20,
    geography: 'agriculture', difficultyRating: 2,
    specialFacility: null,
  ),

  // ── 関東 ──────────────────────────────
  PrefectureData(
    code: '08', name: '茨城県', kana: 'いばらきけん',
    capitalCity: '水戸市', population: 2860000, area: 6097,
    specialties: ['メロン', 'アンコウ', 'れんこん', '納豆'],
    region: Region.kanto, color: '#1E90FF',
    boss: BossData(name: 'アンコウ王', type: 'fish', baseHp: 135, baseAttack: 20, skill: 'アンコウ鍋地獄'),
    companion: CompanionData(id: 'ibaraki_tengu', name: '水戸天狗', description: '偕楽園を守る風の精霊', rarity: 'common', skills: ['wind', 'fly']),
    primaryIndustry: FacilityType.factory, industryBonus: 1.18,
    geography: 'agriculture', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '09', name: '栃木県', kana: 'とちぎけん',
    capitalCity: '宇都宮市', population: 1940000, area: 6408,
    specialties: ['ぎょうざ', 'イチゴ', '日光湯葉', 'かんぴょう'],
    region: Region.kanto, color: '#FF6347',
    boss: BossData(name: 'ぎょうざマスター', type: 'food', baseHp: 120, baseAttack: 18, skill: 'ぎょうざ乱舞'),
    companion: CompanionData(id: 'tochigi_dragon', name: '日光の龍', description: '東照宮に眠る神聖な龍', rarity: 'legend', skills: ['thunder', 'divine']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.18,
    geography: 'agriculture', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '10', name: '群馬県', kana: 'ぐんまけん',
    capitalCity: '前橋市', population: 1960000, area: 6362,
    specialties: ['こんにゃく', 'ダルマ', 'キャベツ', '上州牛'],
    region: Region.kanto, color: '#8B008B',
    boss: BossData(name: 'こんにゃく王', type: 'food', baseHp: 115, baseAttack: 17, skill: 'こんにゃく地獄'),
    companion: CompanionData(id: 'gunma_horse', name: '上毛野の馬', description: '古の武将が乗った勇ましい戦馬', rarity: 'common', skills: ['charge', 'stomp']),
    primaryIndustry: FacilityType.factory, industryBonus: 1.18,
    geography: 'mixed', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '11', name: '埼玉県', kana: 'さいたまけん',
    capitalCity: 'さいたま市', population: 7340000, area: 3797,
    specialties: ['枝豆', 'うなぎ', '深谷ねぎ', '草加せんべい'],
    region: Region.kanto, color: '#2E8B57',
    boss: BossData(name: '枝豆将軍', type: 'vegetable', baseHp: 125, baseAttack: 19, skill: '枝豆砲'),
    companion: CompanionData(id: 'saitama_kappa', name: '川越の河童', description: '荒川に棲む悪戯好きな水の精', rarity: 'common', skills: ['water', 'trick']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.17,
    geography: 'urban', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '12', name: '千葉県', kana: 'ちばけん',
    capitalCity: '千葉市', population: 6290000, area: 5158,
    specialties: ['なし', 'ピーナッツ', 'あさり', 'びわ'],
    region: Region.kanto, color: '#FFD700',
    boss: BossData(name: 'ピーナッツ侯爵', type: 'nut', baseHp: 140, baseAttack: 21, skill: 'ピーナッツ雨'),
    companion: CompanionData(id: 'chiba_whale', name: '九十九里の鯨', description: '太平洋の守護者・巨大な海の精霊', rarity: 'rare', skills: ['wave', 'sonar']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.18,
    geography: 'sea', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '13', name: '東京都', kana: 'とうきょうと',
    capitalCity: '東京', population: 14010000, area: 2194,
    specialties: ['もんじゃ焼き', '東京ラーメン', 'べったら漬', '小松菜'],
    region: Region.kanto, color: '#FF0000',
    boss: BossData(name: 'もんじゃ皇帝', type: 'food', baseHp: 200, baseAttack: 30, skill: 'もんじゃ大爆発'),
    companion: CompanionData(id: 'tokyo_phoenix', name: '東京の不死鳥', description: '東京タワーに宿る炎の守護者', rarity: 'legend', skills: ['blaze', 'rebirth']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.15,
    geography: 'urban', difficultyRating: 5,
    specialFacility: 'base',
  ),
  PrefectureData(
    code: '14', name: '神奈川県', kana: 'かながわけん',
    capitalCity: '横浜市', population: 9240000, area: 2416,
    specialties: ['シウマイ', 'かまぼこ', 'サンマー麺', 'レモン'],
    region: Region.kanto, color: '#4169E1',
    boss: BossData(name: 'シウマイ大帝', type: 'food', baseHp: 180, baseAttack: 28, skill: 'シウマイ爆撃'),
    companion: CompanionData(id: 'kanagawa_mermaid', name: '江の島の人魚', description: '相模湾を守る美しい水の精霊', rarity: 'rare', skills: ['sing', 'heal']),
    primaryIndustry: FacilityType.factory, industryBonus: 1.20,
    geography: 'urban', difficultyRating: 4,
    specialFacility: 'base',
  ),

  // ── 中部 ──────────────────────────────
  PrefectureData(
    code: '15', name: '新潟県', kana: 'にいがたけん',
    capitalCity: '新潟市', population: 2200000, area: 12584,
    specialties: ['コシヒカリ', '日本酒', 'へぎそば', 'のっぺ'],
    region: Region.chubu, color: '#20B2AA',
    boss: BossData(name: '米の王', type: 'rice', baseHp: 145, baseAttack: 22, skill: '米俵投げ'),
    companion: CompanionData(id: 'niigata_swan', name: '瓢湖の白鳥', description: '瓢湖に飛来する優雅な渡り鳥', rarity: 'common', skills: ['grace', 'fly']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.22,
    geography: 'agriculture', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '16', name: '富山県', kana: 'とやまけん',
    capitalCity: '富山市', population: 1040000, area: 4248,
    specialties: ['ます寿司', '白えび', 'ほたるいか', '富山ブラック'],
    region: Region.chubu, color: '#00CED1',
    boss: BossData(name: 'ほたるいか将軍', type: 'squid', baseHp: 130, baseAttack: 19, skill: '発光攻撃'),
    companion: CompanionData(id: 'toyama_firefly', name: '蛍のいか', description: '富山湾の深海から来た光の使者', rarity: 'rare', skills: ['glow', 'blind']),
    primaryIndustry: FacilityType.fishery, industryBonus: 1.18,
    geography: 'mountain', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '17', name: '石川県', kana: 'いしかわけん',
    capitalCity: '金沢市', population: 1140000, area: 4186,
    specialties: ['加賀料理', '金箔', '輪島塗', 'ズワイガニ'],
    region: Region.chubu, color: '#B8860B',
    boss: BossData(name: '金箔大名', type: 'gold', baseHp: 155, baseAttack: 23, skill: '金箔嵐'),
    companion: CompanionData(id: 'ishikawa_geisha', name: '金沢の芸妓', description: '兼六園に宿る雅な精霊', rarity: 'legend', skills: ['dance', 'charm']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.16,
    geography: 'sea', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '18', name: '福井県', kana: 'ふくいけん',
    capitalCity: '福井市', population: 770000, area: 4190,
    specialties: ['越前がに', '越前そば', '羽二重餅', '水ようかん'],
    region: Region.chubu, color: '#556B2F',
    boss: BossData(name: '越前ガニの王', type: 'crab', baseHp: 140, baseAttack: 21, skill: '蟹ハサミ'),
    companion: CompanionData(id: 'fukui_dino', name: '恐竜ダイノ', description: '勝山で発掘された太古の守護者', rarity: 'legend', skills: ['stomp', 'roar']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.16,
    geography: 'mountain', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '19', name: '山梨県', kana: 'やまなしけん',
    capitalCity: '甲府市', population: 810000, area: 4465,
    specialties: ['ぶどう', '桃', 'ほうとう', '吉田うどん'],
    region: Region.chubu, color: '#9400D3',
    boss: BossData(name: 'ぶどう武将', type: 'fruit', baseHp: 125, baseAttack: 18, skill: 'ぶどう酒爆弾'),
    companion: CompanionData(id: 'yamanashi_fuji', name: '富士の精', description: '富士山麓に宿る霊峰の守護神', rarity: 'legend', skills: ['eruption', 'mountain']),
    primaryIndustry: FacilityType.mine, industryBonus: 1.17,
    geography: 'mountain', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '20', name: '長野県', kana: 'ながのけん',
    capitalCity: '長野市', population: 2050000, area: 13562,
    specialties: ['信州そば', 'りんご', '野沢菜', 'おやき'],
    region: Region.chubu, color: '#228B22',
    boss: BossData(name: 'そば師匠', type: 'food', baseHp: 135, baseAttack: 20, skill: 'そば竜巻'),
    companion: CompanionData(id: 'nagano_monkey', name: '地獄谷の猿', description: '温泉に入る知恵ある山猿', rarity: 'common', skills: ['climb', 'throw']),
    primaryIndustry: FacilityType.mine, industryBonus: 1.17,
    geography: 'mountain', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '21', name: '岐阜県', kana: 'ぎふけん',
    capitalCity: '岐阜市', population: 1990000, area: 10621,
    specialties: ['飛騨牛', '鮎', '朴葉味噌', '柿'],
    region: Region.chubu, color: '#8B4513',
    boss: BossData(name: '飛騨牛の王', type: 'meat', baseHp: 150, baseAttack: 24, skill: '牛突進'),
    companion: CompanionData(id: 'gifu_eagle', name: '長良川の鵜', description: '鵜飼の伝統を守る古来の霊鳥', rarity: 'rare', skills: ['dive', 'catch']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.19,
    geography: 'mountain', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '22', name: '静岡県', kana: 'しずおかけん',
    capitalCity: '静岡市', population: 3640000, area: 7777,
    specialties: ['お茶', 'みかん', 'うなぎ', 'わさび'],
    region: Region.chubu, color: '#32CD32',
    boss: BossData(name: 'お茶の仙人', type: 'tea', baseHp: 130, baseAttack: 19, skill: 'お茶嵐'),
    companion: CompanionData(id: 'shizuoka_fuji', name: '富士の鷹', description: '霊峰富士を舞う雄大な鷹', rarity: 'legend', skills: ['soar', 'precision']),
    primaryIndustry: FacilityType.fishery, industryBonus: 1.18,
    geography: 'sea', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '23', name: '愛知県', kana: 'あいちけん',
    capitalCity: '名古屋市', population: 7540000, area: 5173,
    specialties: ['ひつまぶし', '味噌煮込みうどん', 'えびふりゃー', '手羽先'],
    region: Region.chubu, color: '#FF8C00',
    boss: BossData(name: '天下人の影', type: 'warrior', baseHp: 190, baseAttack: 29, skill: '天下布武'),
    companion: CompanionData(id: 'aichi_tiger', name: '尾張の虎', description: '信長の旗を持つ武の守護者', rarity: 'legend', skills: ['slash', 'intimidate']),
    primaryIndustry: FacilityType.factory, industryBonus: 1.25,
    geography: 'urban', difficultyRating: 4,
    specialFacility: 'airport',
  ),

  // ── 近畿 ──────────────────────────────
  PrefectureData(
    code: '24', name: '三重県', kana: 'みえけん',
    capitalCity: '津市', population: 1780000, area: 5774,
    specialties: ['伊勢えび', '牡蠣', '松阪牛', '伊勢うどん'],
    region: Region.kinki, color: '#FF4500',
    boss: BossData(name: '伊勢エビ神官', type: 'shrimp', baseHp: 140, baseAttack: 21, skill: '伊勢神威'),
    companion: CompanionData(id: 'mie_dolphin', name: '伊勢の海豚', description: '伊勢湾に遊ぶ神聖な海の使者', rarity: 'rare', skills: ['swim', 'echo']),
    primaryIndustry: FacilityType.fishery, industryBonus: 1.19,
    geography: 'sea', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '25', name: '滋賀県', kana: 'しがけん',
    capitalCity: '大津市', population: 1410000, area: 4017,
    specialties: ['鮒寿司', '近江牛', '丁字麩', 'いとこ煮'],
    region: Region.kinki, color: '#1E90FF',
    boss: BossData(name: '鮒ずしの怪', type: 'fish', baseHp: 120, baseAttack: 17, skill: 'すっぱい攻撃'),
    companion: CompanionData(id: 'shiga_biwa', name: '琵琶湖の竜', description: '日本最大の湖を守護する水の龍', rarity: 'legend', skills: ['rain', 'wave']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.18,
    geography: 'mixed', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '26', name: '京都府', kana: 'きょうとふ',
    capitalCity: '京都市', population: 2580000, area: 4612,
    specialties: ['湯豆腐', '八ツ橋', '京野菜', '西陣織'],
    region: Region.kinki, color: '#DC143C',
    boss: BossData(name: '千年の都の鬼', type: 'spirit', baseHp: 185, baseAttack: 27, skill: '呪術陣'),
    companion: CompanionData(id: 'kyoto_fox', name: '伏見の白狐', description: '千年の都を守る稲荷神の使い', rarity: 'legend', skills: ['illusion', 'divine']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.16,
    geography: 'urban', difficultyRating: 4,
    specialFacility: null,
  ),
  PrefectureData(
    code: '27', name: '大阪府', kana: 'おおさかふ',
    capitalCity: '大阪市', population: 8820000, area: 1905,
    specialties: ['たこ焼き', 'お好み焼き', '串カツ', 'なにわ料理'],
    region: Region.kinki, color: '#FF6347',
    boss: BossData(name: 'たこ焼き大将', type: 'food', baseHp: 175, baseAttack: 26, skill: 'たこ焼き乱射'),
    companion: CompanionData(id: 'osaka_octopus', name: '難波のタコ', description: 'ど根性のなにわの海の荒くれ者', rarity: 'rare', skills: ['ink', 'stretch']),
    primaryIndustry: FacilityType.factory, industryBonus: 1.20,
    geography: 'urban', difficultyRating: 5,
    specialFacility: null,
  ),
  PrefectureData(
    code: '28', name: '兵庫県', kana: 'ひょうごけん',
    capitalCity: '神戸市', population: 5470000, area: 8401,
    specialties: ['神戸牛', '但馬牛', '明石焼き', '播州ラーメン'],
    region: Region.kinki, color: '#4169E1',
    boss: BossData(name: '神戸牛の王', type: 'meat', baseHp: 165, baseAttack: 25, skill: '神戸突進'),
    companion: CompanionData(id: 'hyogo_crane', name: '城崎の鶴', description: '城崎温泉に舞い降りる優美な鶴', rarity: 'rare', skills: ['grace', 'heal']),
    primaryIndustry: FacilityType.factory, industryBonus: 1.20,
    geography: 'urban', difficultyRating: 4,
    specialFacility: 'airport',
  ),
  PrefectureData(
    code: '29', name: '奈良県', kana: 'ならけん',
    capitalCity: '奈良市', population: 1340000, area: 3691,
    specialties: ['柿の葉寿司', '三輪素麺', 'あすか鍋', '柿'],
    region: Region.kinki, color: '#8B4513',
    boss: BossData(name: '古都の大仏', type: 'spirit', baseHp: 200, baseAttack: 15, skill: '神仏加護'),
    companion: CompanionData(id: 'nara_deer', name: '奈良の神鹿', description: '春日大社の神の使い・聖なる鹿', rarity: 'legend', skills: ['divine', 'speed']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.17,
    geography: 'mountain', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '30', name: '和歌山県', kana: 'わかやまけん',
    capitalCity: '和歌山市', population: 920000, area: 4725,
    specialties: ['みかん', '梅干し', '高野豆腐', 'クエ'],
    region: Region.kinki, color: '#FF8C00',
    boss: BossData(name: '梅の魔女', type: 'fruit', baseHp: 130, baseAttack: 19, skill: '梅酸攻撃'),
    companion: CompanionData(id: 'wakayama_tanuki', name: '高野の狸', description: '高野山を守る神通力を持つ狸', rarity: 'common', skills: ['transform', 'trick']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.18,
    geography: 'sea', difficultyRating: 3,
    specialFacility: null,
  ),

  // ── 中国 ──────────────────────────────
  PrefectureData(
    code: '31', name: '鳥取県', kana: 'とっとりけん',
    capitalCity: '鳥取市', population: 550000, area: 3507,
    specialties: ['松葉ガニ', '二十世紀梨', 'スナバコーヒー', '砂丘らっきょう'],
    region: Region.chugoku, color: '#DEB887',
    boss: BossData(name: '砂丘の魔神', type: 'sand', baseHp: 125, baseAttack: 18, skill: '砂嵐'),
    companion: CompanionData(id: 'tottori_crab', name: '松葉蟹の精', description: '日本海の荒波に鍛えられた甲羅の戦士', rarity: 'rare', skills: ['pinch', 'bubble']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.16,
    geography: 'sea', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '32', name: '島根県', kana: 'しまねけん',
    capitalCity: '松江市', population: 670000, area: 6708,
    specialties: ['のどぐろ', '出雲そば', '島根和牛', '赤てん'],
    region: Region.chugoku, color: '#708090',
    boss: BossData(name: '出雲の大神', type: 'deity', baseHp: 180, baseAttack: 20, skill: '縁結び'),
    companion: CompanionData(id: 'shimane_deity', name: '大国主命', description: '出雲大社に宿る縁結びの神の化身', rarity: 'legend', skills: ['bind', 'fortune']),
    primaryIndustry: FacilityType.fishery, industryBonus: 1.17,
    geography: 'sea', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '33', name: '岡山県', kana: 'おかやまけん',
    capitalCity: '岡山市', population: 1900000, area: 7114,
    specialties: ['桃', 'きびだんご', '牡蠣', 'マスカット'],
    region: Region.chugoku, color: '#FF69B4',
    boss: BossData(name: '桃太郎の鬼', type: 'demon', baseHp: 155, baseAttack: 23, skill: '鬼ノ牙'),
    companion: CompanionData(id: 'okayama_pheasant', name: '吉備の雉', description: '桃太郎を助けた聖なる吉備の雉', rarity: 'rare', skills: ['pierce', 'fly']),
    primaryIndustry: FacilityType.factory, industryBonus: 1.17,
    geography: 'mountain', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '34', name: '広島県', kana: 'ひろしまけん',
    capitalCity: '広島市', population: 2820000, area: 8479,
    specialties: ['お好み焼き', '牡蠣', '穴子', 'レモン'],
    region: Region.chugoku, color: '#FF4500',
    boss: BossData(name: '牡蠣の大将', type: 'shellfish', baseHp: 160, baseAttack: 24, skill: '牡蠣殻嵐'),
    companion: CompanionData(id: 'hiroshima_dove', name: '平和の鳩', description: '平和公園に集う希望の象徴', rarity: 'legend', skills: ['peace', 'heal']),
    primaryIndustry: FacilityType.fishery, industryBonus: 1.18,
    geography: 'sea', difficultyRating: 4,
    specialFacility: null,
  ),
  PrefectureData(
    code: '35', name: '山口県', kana: 'やまぐちけん',
    capitalCity: '山口市', population: 1360000, area: 6112,
    specialties: ['ふぐ', 'ういろう', '岩国れんこん', '長門ゆずきち'],
    region: Region.chugoku, color: '#483D8B',
    boss: BossData(name: 'ふぐの王者', type: 'fish', baseHp: 150, baseAttack: 22, skill: 'ふぐ毒霧'),
    companion: CompanionData(id: 'yamaguchi_samurai', name: '維新の志士', description: '幕末の英傑の魂を宿す霊的な存在', rarity: 'legend', skills: ['slash', 'inspire']),
    primaryIndustry: FacilityType.fishery, industryBonus: 1.17,
    geography: 'sea', difficultyRating: 3,
    specialFacility: 'base',
  ),

  // ── 四国 ──────────────────────────────
  PrefectureData(
    code: '36', name: '徳島県', kana: 'とくしまけん',
    capitalCity: '徳島市', population: 730000, area: 4147,
    specialties: ['阿波おどり', '鳴門金時', 'すだち', '阿波牛'],
    region: Region.shikoku, color: '#FF6347',
    boss: BossData(name: '阿波踊りの鬼', type: 'dancer', baseHp: 125, baseAttack: 18, skill: '乱舞'),
    companion: CompanionData(id: 'tokushima_dancer', name: '阿波の踊り子', description: '夏祭りに現れる軽やかな精霊', rarity: 'rare', skills: ['dance', 'charm']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.16,
    geography: 'agriculture', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '37', name: '香川県', kana: 'かがわけん',
    capitalCity: '高松市', population: 960000, area: 1877,
    specialties: ['讃岐うどん', '骨付鳥', '小豆島のオリーブ', 'オリーブ牛'],
    region: Region.shikoku, color: '#3CB371',
    boss: BossData(name: 'うどん大魔王', type: 'noodle', baseHp: 145, baseAttack: 21, skill: 'うどん絡み'),
    companion: CompanionData(id: 'kagawa_olive', name: '小豆島の妖精', description: '地中海の島に宿るオリーブの精', rarity: 'rare', skills: ['heal', 'calm']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.16,
    geography: 'sea', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '38', name: '愛媛県', kana: 'えひめけん',
    capitalCity: '松山市', population: 1340000, area: 5676,
    specialties: ['みかん', '鯛めし', 'じゃこ天', 'タルト'],
    region: Region.shikoku, color: '#FF8C00',
    boss: BossData(name: 'みかん大名', type: 'fruit', baseHp: 130, baseAttack: 19, skill: 'みかん爆弾'),
    companion: CompanionData(id: 'ehime_tai', name: '道後の鯛', description: '道後温泉に涌く霊泉を守る聖魚', rarity: 'rare', skills: ['splash', 'speed']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.17,
    geography: 'agriculture', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '39', name: '高知県', kana: 'こうちけん',
    capitalCity: '高知市', population: 700000, area: 7103,
    specialties: ['かつおのたたき', '土佐文旦', '龍馬', 'ゆず'],
    region: Region.shikoku, color: '#DC143C',
    boss: BossData(name: '海賊船長', type: 'pirate', baseHp: 160, baseAttack: 25, skill: '海賊突進'),
    companion: CompanionData(id: 'kochi_whale', name: '土佐の鯨', description: '太平洋を自由に泳ぐ巨大な海の王者', rarity: 'legend', skills: ['breach', 'sonar']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.15,
    geography: 'sea', difficultyRating: 3,
    specialFacility: null,
  ),

  // ── 九州・沖縄 ──────────────────────────────
  PrefectureData(
    code: '40', name: '福岡県', kana: 'ふくおかけん',
    capitalCity: '福岡市', population: 5130000, area: 4986,
    specialties: ['博多ラーメン', '明太子', '水炊き', '辛子明太子'],
    region: Region.kyushu, color: '#FF0000',
    boss: BossData(name: '博多のラーメン王', type: 'noodle', baseHp: 170, baseAttack: 26, skill: 'とんこつ波'),
    companion: CompanionData(id: 'fukuoka_hawk', name: '志賀島の鷹', description: '玄界灘を制す天空の猛禽', rarity: 'rare', skills: ['soar', 'precision']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.20,
    geography: 'urban', difficultyRating: 4,
    specialFacility: 'airport',
  ),
  PrefectureData(
    code: '41', name: '佐賀県', kana: 'さがけん',
    capitalCity: '佐賀市', population: 820000, area: 2441,
    specialties: ['佐賀牛', '有明海苔', '唐津くんち', 'ムツゴロウ'],
    region: Region.kyushu, color: '#6495ED',
    boss: BossData(name: '有明の泥人形', type: 'clay', baseHp: 130, baseAttack: 18, skill: '泥まみれ'),
    companion: CompanionData(id: 'saga_balloon', name: '気球の精', description: 'バルーンフェスタを彩る風の精霊', rarity: 'common', skills: ['float', 'wind']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.18,
    geography: 'sea', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '42', name: '長崎県', kana: 'ながさきけん',
    capitalCity: '長崎市', population: 1310000, area: 4132,
    specialties: ['ちゃんぽん', 'カステラ', '皿うどん', '対馬の穴子'],
    region: Region.kyushu, color: '#4682B4',
    boss: BossData(name: '南蛮商人', type: 'trader', baseHp: 145, baseAttack: 20, skill: '南蛮砲'),
    companion: CompanionData(id: 'nagasaki_angel', name: '出島の天使', description: '開港の地から世界を見つめる希望の象徴', rarity: 'legend', skills: ['light', 'inspire']),
    primaryIndustry: FacilityType.fishery, industryBonus: 1.20,
    geography: 'sea', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '43', name: '熊本県', kana: 'くまもとけん',
    capitalCity: '熊本市', population: 1760000, area: 7409,
    specialties: ['馬刺し', 'いきなり団子', '辛子蓮根', 'くまモン'],
    region: Region.kyushu, color: '#FF0000',
    boss: BossData(name: '火の国の熊将軍', type: 'bear', baseHp: 175, baseAttack: 27, skill: '火山爆発'),
    companion: CompanionData(id: 'kumamoto_bear', name: 'くまモン', description: '熊本を元気にする愛されキャラ', rarity: 'legend', skills: ['cheer', 'inspire']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.19,
    geography: 'agriculture', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '44', name: '大分県', kana: 'おおいたけん',
    capitalCity: '大分市', population: 1140000, area: 6341,
    specialties: ['とり天', 'ごまさば', '関あじ', 'ゆずこしょう'],
    region: Region.kyushu, color: '#20B2AA',
    boss: BossData(name: '温泉の湯鬼', type: 'steam', baseHp: 140, baseAttack: 20, skill: '蒸気噴出'),
    companion: CompanionData(id: 'oita_hotspring', name: '別府の湯の神', description: '日本一の湧出量を誇る温泉の守護神', rarity: 'rare', skills: ['heal', 'steam']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.18,
    geography: 'mixed', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '45', name: '宮崎県', kana: 'みやざきけん',
    capitalCity: '宮崎市', population: 1080000, area: 7735,
    specialties: ['地鶏の炭火焼き', 'マンゴー', '冷汁', '高鍋ねぎ'],
    region: Region.kyushu, color: '#FF8C00',
    boss: BossData(name: '日向の神', type: 'deity', baseHp: 155, baseAttack: 22, skill: '天孫降臨'),
    companion: CompanionData(id: 'miyazaki_hawk', name: '日向の鷹', description: '天孫降臨の地・高千穂を守る霊鳥', rarity: 'legend', skills: ['divine', 'soar']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.19,
    geography: 'agriculture', difficultyRating: 2,
    specialFacility: null,
  ),
  PrefectureData(
    code: '46', name: '鹿児島県', kana: 'かごしまけん',
    capitalCity: '鹿児島市', population: 1590000, area: 9187,
    specialties: ['黒豚', 'さつまいも', '桜島大根', '知覧茶'],
    region: Region.kyushu, color: '#8B0000',
    boss: BossData(name: '桜島の噴火鬼', type: 'volcano', baseHp: 180, baseAttack: 28, skill: '大噴火'),
    companion: CompanionData(id: 'kagoshima_pig', name: '薩摩の黒豚', description: '鹿児島の豊かな大地で育まれた魂', rarity: 'common', skills: ['charge', 'tough']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.21,
    geography: 'agriculture', difficultyRating: 3,
    specialFacility: null,
  ),
  PrefectureData(
    code: '47', name: '沖縄県', kana: 'おきなわけん',
    capitalCity: '那覇市', population: 1470000, area: 2281,
    specialties: ['ゴーヤーチャンプルー', 'ラフテー', 'ちんすこう', '泡盛'],
    region: Region.kyushu, color: '#00CED1',
    boss: BossData(name: 'シーサーの王', type: 'lion', baseHp: 170, baseAttack: 25, skill: 'シーサー咆哮'),
    companion: CompanionData(id: 'okinawa_shisa', name: 'シーサー', description: '琉球の守護神・魔除けの聖獣', rarity: 'legend', skills: ['guard', 'roar']),
    primaryIndustry: FacilityType.farm, industryBonus: 1.21,
    geography: 'sea', difficultyRating: 4,
    specialFacility: 'base',
  ),
];

/// コードで検索
PrefectureData? getPrefectureByCode(String code) {
  try {
    return allPrefectures.firstWhere((p) => p.code == code);
  } catch (_) {
    return null;
  }
}

/// 名前で検索（部分一致）
List<PrefectureData> searchPrefectures(String query) {
  if (query.isEmpty) return allPrefectures;
  final lower = query.toLowerCase();
  return allPrefectures
      .where((p) =>
          p.name.contains(query) ||
          p.kana.contains(lower) ||
          p.capitalCity.contains(query))
      .toList();
}

/// 地域別で取得
List<PrefectureData> getPrefecturesByRegion(String region) {
  return allPrefectures.where((p) => p.region == region).toList();
}

/// レアリティ別の相棒を取得
List<PrefectureData> getPrefecturesByCompanionRarity(String rarity) {
  return allPrefectures.where((p) => p.companion.rarity == rarity).toList();
}

/// スコア計算
int calculateScore({
  required String difficulty,
  required int clearTime,
  required int mistakes,
}) {
  const baseScore = 1000;
  final timeBonus = (300 - clearTime).clamp(0, 300) * 2;
  final mistakeBonus = ((10 - mistakes).clamp(0, 10)) * 50;
  final multiplier = switch (difficulty) {
    'easy' => 1.0,
    'hard' => 2.0,
    _ => 1.5, // normal
  };
  return ((baseScore + timeBonus + mistakeBonus) * multiplier).round();
}

/// Prefecture地理情報拡張
extension PrefectureGeographyX on PrefectureData {
  /// 地理タイプに対応するアイコンを取得
  String get geographyIcon {
    switch (geography) {
      case 'sea':
        return '🌊';
      case 'mountain':
        return '⛰️';
      case 'urban':
        return '🏙️';
      case 'agriculture':
        return '🌾';
      case 'mixed':
        return '🗺️';
      default:
        return '🗾';
    }
  }

  /// 難易度星表記を取得（⭐ × rating）
  String get difficultyStars {
    return '⭐' * difficultyRating;
  }

  /// 難易度名を取得
  String get difficultyLabel {
    switch (difficultyRating) {
      case 1:
        return '超簡単';
      case 2:
        return '簡単';
      case 3:
        return '普通';
      case 4:
        return '難しい';
      case 5:
        return '超難しい';
      default:
        return '普通';
    }
  }

  /// 地形タイプの日本語名
  String get geographyName {
    switch (geography) {
      case 'sea':
        return '海・沿岸';
      case 'mountain':
        return '山岳';
      case 'urban':
        return '都市';
      case 'agriculture':
        return '農業';
      case 'mixed':
        return '複合';
      default:
        return '—';
    }
  }

  /// 相棒の見た目絵文字（地形ベース・敵と区別される友好的なキャラ）
  String get companionEmoji {
    switch (geography) {
      case 'sea':
        return '🐬';
      case 'mountain':
        return '🦌';
      case 'urban':
        return '🐱';
      case 'agriculture':
        return '🐕';
      case 'mixed':
        return '🦊';
      default:
        return '🐾';
    }
  }

  /// 戦場の天候テーマ（地形＋地域から決定）
  /// 'snow' | 'wave' | 'fog' | 'neon' | 'leaf' | 'clear'
  String get weather {
    final c = int.tryParse(code) ?? 0;
    // 北海道・東北は雪
    if (c == 1 || (c >= 2 && c <= 7)) return 'snow';
    switch (geography) {
      case 'sea':
        return 'wave';
      case 'mountain':
        return 'fog';
      case 'urban':
        return 'neon';
      case 'agriculture':
        return 'leaf';
      default:
        return 'clear';
    }
  }

  /// 制圧トリビア（データから自動生成する豆知識を1つ返す）
  String get trivia {
    final c = int.tryParse(code) ?? 0;
    final facts = <String>[
      '${name}の県庁所在地は${capitalCity}だよ。',
      '面積は約${area}km²。全国でも特徴的な広さなんだ。',
      '人口は約${(population / 10000).round()}万人が暮らしているよ。',
      if (specialties.isNotEmpty)
        '名産品の「${specialties.first}」がとくに有名なんだ。',
      '地形は「${geographyName}」タイプ。だから敵もその土地らしいんだ。',
    ];
    // code をシード代わりにして毎回同じ県は同じ豆知識
    return facts[c % facts.length];
  }
}
