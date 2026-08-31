import 'package:flutter/material.dart';

/// HP・残機などを ♥ アイコンの列で表示する共通ウィジェット。
///
/// 例: `LivesRow(current: 2, max: 3)` は ♥♥♡ を表示する。
class LivesRow extends StatelessWidget {
  const LivesRow({
    super.key,
    required this.current,
    required this.max,
    this.color = Colors.redAccent,
    this.size = 20,
  });

  final int current;
  final int max;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        max,
        (i) => Icon(
          i < current ? Icons.favorite : Icons.favorite_border,
          color: color,
          size: size,
        ),
      ),
    );
  }
}
