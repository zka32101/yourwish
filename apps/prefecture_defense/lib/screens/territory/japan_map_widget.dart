import 'package:flutter/material.dart';
import 'package:prefecture_defense/config/constants.dart';
import 'package:prefecture_defense/models/prefecture_record.dart';
import 'package:prefecture_defense/utils/prefecture_data.dart';

const Map<String, String> prefectureEmojis = {
  '01': '🏔️', '02': '🌲', '03': '🌲', '04': '🏔️', '05': '🌲', '06': '🌊',
  '07': '🌲', '08': '🗻', '09': '⛩️', '10': '🏛️', '11': '🌆', '12': '🏞️',
  '13': '🗼', '14': '🌊', '15': '🏔️', '16': '⛩️', '17': '🏔️', '18': '🌲',
  '19': '⛩️', '20': '🏔️', '21': '🌊', '22': '🏔️', '23': '🏭', '24': '🏔️',
  '25': '⛩️', '26': '🏯', '27': '🌲', '28': '🏞️', '29': '🌊', '30': '🏛️',
  '31': '🏞️', '32': '🌊', '33': '🏔️', '34': '🌲', '35': '⛩️', '36': '🌊',
  '37': '⛩️', '38': '🌊', '39': '🌲', '40': '⛩️', '41': '🌊', '42': '🏔️',
  '43': '🌊', '44': '🏔️', '45': '🌲', '46': '⛩️', '47': '🌴',
};

class JapanMapWidget extends StatelessWidget {
  final Map<String, PrefectureRecord> records;
  final Function(String) onPrefectureTap;

  const JapanMapWidget({
    Key? key,
    required this.records,
    required this.onPrefectureTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '日本地図',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // 地方別グループ表示
        ..._buildRegionGroups(context),
      ],
    );
  }

  List<Widget> _buildRegionGroups(BuildContext context) {
    // 地方別に県をグループ化
    const Map<String, String> regionNames = {
      'hokkaido': '北海道',
      'tohoku': '東北',
      'kanto': '関東',
      'chubu': '中部',
      'kansai': '関西',
      'chugoku': '中国',
      'shikoku': '四国',
      'kyushu': '九州',
    };

    const Map<String, List<String>> regionPrefectures = {
      'hokkaido': ['01'],
      'tohoku': ['02', '03', '04', '05', '06', '07'],
      'kanto': ['08', '09', '10', '11', '12', '13', '14'],
      'chubu': ['15', '16', '17', '18', '19', '20', '21', '22', '23', '24'],
      'kansai': ['25', '26', '27', '28', '29', '30'],
      'chugoku': ['31', '32', '33', '34', '35'],
      'shikoku': ['36', '37', '38', '39'],
      'kyushu': ['40', '41', '42', '43', '44', '45', '46', '47'],
    };

    final List<Widget> regionWidgets = [];

    regionNames.forEach((key, regionName) {
      final prefectureCodes = regionPrefectures[key] ?? [];
      regionWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              regionName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.0,
              ),
              itemCount: prefectureCodes.length,
              itemBuilder: (context, index) {
                final code = prefectureCodes[index];
                final prefecture = getPrefectureByCode(code);
                final record = records[code];

                if (prefecture == null) {
                  return const SizedBox();
                }

                return _buildPrefectureCard(
                  context,
                  prefecture,
                  record,
                  code,
                  prefectureEmojis[code] ?? '🗾',
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    });

    return regionWidgets;
  }

  Widget _buildPrefectureCard(
    BuildContext context,
    PrefectureData prefecture,
    PrefectureRecord? record,
    String code,
    String emoji,
  ) {
    final isCleared = record != null;
    final level = record?.currentLevel ?? 0;
    final color = _getLevelColor(level, isCleared);

    return GestureDetector(
      onTap: () => onPrefectureTap(code),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(
            color: isCleared ? Colors.amber : Colors.grey.shade300,
            width: isCleared ? 2 : 1,
          ),
        ),
        elevation: isCleared ? 3 : 1,
        child: Stack(
          children: [
            // 背景グラデーション
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.7),
                    color,
                  ],
                ),
              ),
            ),
            // コンテンツ
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prefecture.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCleared) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text(
                        'Lv$level',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(int level, bool isCleared) {
    if (!isCleared) {
      return Colors.grey.shade200;
    }

    // Lv に応じた色分け
    if (level >= 8) {
      return Colors.yellow.shade600; // ゴールド
    } else if (level >= 5) {
      return Colors.blue.shade600; // ブルー
    } else if (level >= 2) {
      return Colors.orange.shade500; // オレンジ
    } else {
      return Colors.green.shade500; // グリーン
    }
  }
}
