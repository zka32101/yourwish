import 'package:flutter/material.dart';

/// 直近に受け取った投票コメントを横スクロールのチップで流す
/// 共通ウィジェット。配信画面に「今コメントが流れている」感を出す用途。
class CommentTicker extends StatelessWidget {
  const CommentTicker({super.key, required this.recentComments, this.height = 32});

  final List<String> recentComments;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (recentComments.isEmpty) return SizedBox(height: height);
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: recentComments
            .map(
              (c) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('視聴者: $c', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            )
            .toList(),
      ),
    );
  }
}
