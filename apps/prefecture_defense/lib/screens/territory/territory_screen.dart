import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefecture_defense/config/constants.dart';
import 'package:prefecture_defense/models/prefecture_record.dart';
import 'package:prefecture_defense/providers/prefecture_records_provider.dart';
import 'package:prefecture_defense/utils/prefecture_data.dart';
import 'japan_map_widget.dart';
import 'prefecture_detail.dart';

class TerritoryScreen extends ConsumerWidget {
  const TerritoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(prefectureRecordsProvider);

    return recordsAsync.when(
      data: (records) => _buildContent(context, records, ref),
      loading: () => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.cyan.shade50],
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade100, Colors.red.shade50],
          ),
        ),
        child: Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, PrefectureRecord> records,
    WidgetRef ref,
  ) {
    final clearedCount = records.length;
    final totalCount = allPrefectures.length;
    final progressPercent = (clearedCount / totalCount * 100).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade100, Colors.cyan.shade50],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 統一度プログレス
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildProgressCard(context, clearedCount, totalCount, progressPercent),
              ),
              // 日本地図
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: JapanMapWidget(
                  records: records,
                  onPrefectureTap: (prefectureCode) {
                    _showPrefectureDetail(context, prefectureCode, records);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // 統計情報
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildStatsCard(context, records),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, int cleared, int total, String percent) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '日本統一度',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '$cleared/$total',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: LinearProgressIndicator(
                value: cleared / total,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  cleared == total ? Colors.green.shade600 : Colors.blue.shade600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, Map<String, PrefectureRecord> records) {
    final totalClears = records.values.fold(0, (sum, record) => sum + record.totalClears);
    final avgLevel = records.isEmpty
        ? 0.0
        : records.values.fold<int>(0, (sum, record) => sum + record.currentLevel) / records.length;
    final highScore = records.isEmpty
        ? 0
        : records.values.fold<int>(0, (max, record) => record.bestScore > max ? record.bestScore : max);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 統計情報',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatRow('総クリア回数', '$totalClears 回'),
            _buildStatRow('平均レベル', avgLevel.toStringAsFixed(1)),
            _buildStatRow('最高スコア', highScore.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrefectureDetail(
    BuildContext context,
    String prefectureCode,
    Map<String, PrefectureRecord> records,
  ) {
    final record = records[prefectureCode];
    final prefecture = getPrefectureByCode(prefectureCode);

    if (prefecture == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => PrefectureDetailSheet(
        prefecture: prefecture,
        record: record,
      ),
    );
  }
}
