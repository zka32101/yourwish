import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32); // Green
  static const secondary = Color(0xFF1976D2); // Blue
  static const accent = Color(0xFFFFB300); // Gold
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF388E3C);
  static const warning = Color(0xFFF57C00);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const divider = Color(0xFFE0E0E0);
  static const disabled = Color(0xFFBDBDBD);

  // 防衛ゲームテーマ（深い藍〜緑のグラデーション）
  static const heroTop = Color(0xFF0D3B2E);    // 深緑
  static const heroBottom = Color(0xFF1B5E20);  // 緑
  static const navy = Color(0xFF102A43);        // 濃紺アクセント

  /// 難易度レーティング(1-5)に対応する色
  static Color difficulty(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFF43A047); // 緑
      case 2:
        return const Color(0xFF7CB342); // 黄緑
      case 3:
        return const Color(0xFFFB8C00); // 橙
      case 4:
        return const Color(0xFFE53935); // 赤
      case 5:
        return const Color(0xFF8E24AA); // 紫
      default:
        return const Color(0xFFFB8C00);
    }
  }
}

class AppTextStyles {
  static const headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const small = 4.0;
  static const medium = 8.0;
  static const large = 16.0;
  static const circle = 100.0;
}
