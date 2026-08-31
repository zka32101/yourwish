/// ゲーム内の画像アセット管理

/// 敵タイプ別の画像パス
const Map<String, String> enemyTypeImages = {
  'normal': 'assets/images/characters/1. ノーマル (Normal Enemy).jpg',
  'speedy': 'assets/images/characters/2. スピード (Speedy Enemy).jpg',
  'armored': 'assets/images/characters/3. 装甲 (Armored Enemy).jpg',
  'healer': 'assets/images/characters/4. ヒーラー (Healer Enemy).jpg',
};

/// 施設タイプ別の画像パス
const Map<String, String> facilityTypeImages = {
  'farm': 'assets/images/facilities/農場.jpg',
  'fishery': 'assets/images/facilities/漁場.jpg',
  'factory': 'assets/images/facilities/工場.jpg',
  'mine': 'assets/images/facilities/鉱山.jpg',
  'castle': 'assets/images/facilities/城.jpg',
  'shrine': 'assets/images/facilities/神社.jpg',
  // 都道府県限定施設（特別感を演出する専用ビジュアル）
  'dairyFarm': 'assets/images/facilities/北海道酪農.jpg',
  'alpineWatch': 'assets/images/facilities/高山番所.jpg',
  'toyotaFactory': 'assets/images/facilities/トヨタ.jpg',
  'kiyomizuTemple': 'assets/images/facilities/清水寺.jpg',
  'peaceShrine': 'assets/images/facilities/広島平和.jpg',
  'heimeyuriTower': 'assets/images/facilities/沖縄ひめゆり.jpg',
  'umeSakeBrewery': 'assets/images/facilities/梅酒.jpg',
  'udonShop': 'assets/images/facilities/博多うどん.jpg',
};

String? getEnemyImage(String enemyType) => enemyTypeImages[enemyType];
String? getFacilityImage(String facilityType) => facilityTypeImages[facilityType];
