import 'package:flutter/material.dart';

class DifficultyModifier {
  final double hpMultiplier;
  final int waveAddition;
  final double scoreMultiplier;
  final String description;
  final Color color;

  const DifficultyModifier({
    required this.hpMultiplier,
    required this.waveAddition,
    required this.scoreMultiplier,
    required this.description,
    required this.color,
  });
}

const Map<String, DifficultyModifier> difficultyModifiers = {
  'easy': DifficultyModifier(
    hpMultiplier: 0.8,
    waveAddition: -1,
    scoreMultiplier: 0.8,
    description: '敵HP -20%\n波数 -1\nスコア ×0.8',
    color: Color(0xFF4CAF50),
  ),
  'normal': DifficultyModifier(
    hpMultiplier: 1.0,
    waveAddition: 0,
    scoreMultiplier: 1.0,
    description: '標準難度\n敵HP ±0%\n波数 ±0',
    color: Color(0xFF2196F3),
  ),
  'hard': DifficultyModifier(
    hpMultiplier: 1.15,
    waveAddition: 2,
    scoreMultiplier: 1.5,
    description: '敵HP +15%\n波数 +2\nスコア ×1.5',
    color: Color(0xFFE53935),
  ),
};

String getDifficultyLabel(String difficulty) {
  switch (difficulty) {
    case 'easy':
      return 'イージー';
    case 'hard':
      return 'ハード';
    default:
      return 'ノーマル';
  }
}
