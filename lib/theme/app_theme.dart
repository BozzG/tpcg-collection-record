import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class GradeColors extends ThemeExtension<GradeColors> {
  const GradeColors({
    required this.tier1,
    required this.tier2,
    required this.tier3,
    required this.tier4,
    required this.tierDefault,
  });

  final Color tier1;       // 黑10 — 最高级
  final Color tier2;       // 紫10 — 二级
  final Color tier3;       // 蓝9  — 三级
  final Color tier4;       // 绿8  — 四级
  final Color tierDefault; // 默认/未评级

  @override
  GradeColors copyWith({
    Color? tier1, Color? tier2, Color? tier3, Color? tier4, Color? tierDefault,
  }) {
    return GradeColors(
      tier1: tier1 ?? this.tier1,
      tier2: tier2 ?? this.tier2,
      tier3: tier3 ?? this.tier3,
      tier4: tier4 ?? this.tier4,
      tierDefault: tierDefault ?? this.tierDefault,
    );
  }

  @override
  GradeColors lerp(covariant GradeColors? other, double t) {
    if (other is! GradeColors) return this;
    return GradeColors(
      tier1: Color.lerp(tier1, other.tier1, t)!,
      tier2: Color.lerp(tier2, other.tier2, t)!,
      tier3: Color.lerp(tier3, other.tier3, t)!,
      tier4: Color.lerp(tier4, other.tier4, t)!,
      tierDefault: Color.lerp(tierDefault, other.tierDefault, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    // v2.0：显式 16 槽位 ColorScheme（街头潮玩 × 收藏卡牌）
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1B1A57),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD8D7E8),
      onPrimaryContainer: Color(0xFF1B1A57),
      secondary: Color(0xFFE67B3B),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFAD9C2),
      onSecondaryContainer: Color(0xFF8C3A0A),
      tertiary: Color(0xFFD44569),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFAD3DC),
      onTertiaryContainer: Color(0xFF7D1F35),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFFFFBFE),
      onSurface: Color(0xFF060606),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF6F2F4),
      surfaceContainer: Color(0xFFEEEAEC),
      surfaceContainerHigh: Color(0xFFE8E4E6),
      surfaceContainerHighest: Color(0xFFE2DEE0),
      onSurfaceVariant: Color(0xFF49454F),
      outline: Color(0xFF060606),
      outlineVariant: Color(0xFFCAC4CC),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF1C1B1F),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFB6B5DC),
      surfaceTint: Color(0x00000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF989C94), // 灰绿桌面
      // Decision-01：AppBar 实色 #1B1A57 包装顶饰条
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B1A57),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        actionsIconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
      ),
      // Decision-02：Card 黑描边 + 圆角 14 + elevation 0
      cardTheme: const CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: Color(0xFFFFFBFE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(
            color: Color(0xFF060606),
            width: 1.0,
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // Decision-07：TextField 黑描边 filled
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2.0,
          ),
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Decision-06：FAB 橙底黑描边
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFE67B3B),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: StadiumBorder(
          side: BorderSide(
            color: Color(0xFF060606),
            width: 1.0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Decision-05：GradeColors v2.0 五档锁定
      extensions: const <ThemeExtension<dynamic>>[
        GradeColors(
          tier1: Color(0xFF060606),       // 黑10
          tier2: Color(0xFF1B1A57),       // 紫10（与 primary 一致）
          tier3: Color(0xFF457B9D),       // 蓝9
          tier4: Color(0xFF2E7D5B),       // 绿8
          tierDefault: Color(0xFFE67B3B), // 默认（与 secondary 一致）
        ),
      ],
    );
  }

  static ThemeData dark() {
    // v2.1：暗色衍生 ColorScheme（基于 v2.0 亮色色板）
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFB6B5DC),         // 亮色 inversePrimary 提亮
      onPrimary: Color(0xFF1B1A57),       // 亮色 primary 反转
      primaryContainer: Color(0xFF3D3C6E), // 亮色 primaryContainer 暗化
      onPrimaryContainer: Color(0xFFD8D7E8),
      secondary: Color(0xFFE67B3B),       // 橙色保持（金额色）
      onSecondary: Color(0xFF1B1A57),
      secondaryContainer: Color(0xFF8C3A0A),
      onSecondaryContainer: Color(0xFFFAD9C2),
      tertiary: Color(0xFFD44569),        // 玫红保持
      onTertiary: Color(0xFF1B1A57),
      tertiaryContainer: Color(0xFF7D1F35),
      onTertiaryContainer: Color(0xFFFAD3DC),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF1C1B1F),         // 暗色 surface
      onSurface: Color(0xFFE6E1E5),       // 亮文本
      surfaceContainerLowest: Color(0xFF0F0D13),
      surfaceContainerLow: Color(0xFF1C1B1F),
      surfaceContainer: Color(0xFF211F26),
      surfaceContainerHigh: Color(0xFF2B2930),
      surfaceContainerHighest: Color(0xFF36343B),
      onSurfaceVariant: Color(0xFFCAC4CC),
      outline: Color(0xFF938F99),         // 暗色描边（适配暗底可见）
      outlineVariant: Color(0xFF49454F),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF1C1B1F),
      inversePrimary: Color(0xFF1B1A57),
      surfaceTint: Color(0x00000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF1A1A1E), // 深灰绿暗底
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B1A57),   // 保持紫蓝
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        actionsIconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: Color(0xFF211F26),             // 暗色 card 背景
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(
            color: Color(0xFF938F99),          // 暗色描边
            width: 1.0,
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2.0,
          ),
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFE67B3B),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: StadiumBorder(
          side: BorderSide(
            color: Color(0xFF938F99),          // 暗色描边
            width: 1.0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      // GradeColors 五档颜色保持不变（lerp 自动过渡）
      extensions: const <ThemeExtension<dynamic>>[
        GradeColors(
          tier1: Color(0xFF060606),       // 黑10
          tier2: Color(0xFF1B1A57),       // 紫10
          tier3: Color(0xFF457B9D),       // 蓝9
          tier4: Color(0xFF2E7D5B),       // 绿8
          tierDefault: Color(0xFFE67B3B), // 默认
        ),
      ],
    );
  }
}
