import 'package:flutter/material.dart';
import 'package:prefecture_defense/config/constants.dart';
import 'package:prefecture_defense/models/prefecture_record.dart';
import 'package:prefecture_defense/utils/prefecture_data.dart';
import 'japan_map_widget.dart' show prefectureEmojis;

class PrefectureDetailSheet extends StatelessWidget {
  final PrefectureData prefecture;
  final PrefectureRecord? record;

  const PrefectureDetailSheet({
    Key? key,
    required this.prefecture,
    this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCleared = record != null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCleared
              ? [Colors.blue.shade50, Colors.cyan.shade100]
              : [Colors.grey.shade100, Colors.grey.shade200],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ヘッダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prefecture.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                if (isCleared) ...[
                  // クリア済み表示
                  _buildClearedCard(context),
                ] else ...[
                  // 未クリア表示
                  Card(
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Text(
                            '未クリア',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'この県を防衛してクリアしよう！',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // 県情報
                _buildInfoCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearedCard(BuildContext context) {
    if (record == null) return const SizedBox();

    final levelProgress = record!.currentExp / record!.getNextLevelExpRequired();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // レベル表示
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Column(
                children: [
                  Text(
                    'Lv ${record!.currentLevel}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // EXP プログレスバー
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '経験値',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: LinearProgressIndicator(
                    value: levelProgress.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record!.currentExp}/${record!.getNextLevelExpRequired()}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // クリア記録
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: AppSpacing.md),
            _buildRecordRow(context, '総クリア', '${record!.totalClears}回'),
            _buildRecordRow(context, 'ハイスコア', '${record!.bestScore}点'),
            _buildRecordRow(
              context,
              '最高難易度',
              record!.highestDifficulty ?? '未挑戦',
            ),
            _buildRecordRow(
              context,
              '初クリア',
              _formatDate(record!.firstClearedAt),
            ),
            _buildRecordRow(
              context,
              '最終プレイ',
              _formatDate(record!.lastClearedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final emoji = prefectureEmojis[prefecture.code] ?? '🗾';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '県情報',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(context, '絵文字', emoji),
            _buildInfoRow(context, '都道府県コード', prefecture.code),
            if (prefecture.specialFacility != null)
              _buildInfoRow(
                context,
                '特殊施設',
                prefecture.specialFacility == 'airport' ? '🛫 空港' : '🎖️ 基地',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
  }
}
