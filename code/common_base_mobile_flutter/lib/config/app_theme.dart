import 'package:flutter/material.dart';

/// 应用主题配置类
///
/// 功能说明：
/// - 定义应用的亮色主题和暗色主题配置
/// - 使用Material 3设计规范
/// - 基于ColorScheme.fromSeed生成协调的色彩方案
/// - 提供统一的视觉设计规范
///
/// 设计特色：
/// - 使用蓝色系(#2196F3)作为种子颜色
/// - 现代化的Material 3设计
/// - 一致的圆角和阴影效果
class AppTheme {
  /// 亮色主题配置
  ///
  /// 特点：
  /// - 使用Material 3设计规范
  /// - 基于种子颜色生成协调的色彩方案
  /// - 白色背景，清晰的文字对比度
  /// - 圆角设计，现代化的视觉体验
  static ThemeData get lightTheme {
    return ThemeData(
      // 启用Material 3设计
      useMaterial3: true,

      // 基于种子颜色生成色彩方案，并显式指定 primary 为浅蓝色
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF42A5F5), // 阳光天空蓝
        brightness: Brightness.light, // 亮色模式
      ).copyWith(
        primary: const Color(0xFF42A5F5), // 浅蓝色主色
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFBBDEFB), // 浅蓝容器色
        onPrimaryContainer: const Color(0xFF004A77),
      ),

      // 应用栏主题配置
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, // 白色背景
        elevation: 0, // 无阴影
        surfaceTintColor: Colors.transparent, // 透明表面色调
        iconTheme: IconThemeData(
          color: Colors.black87, // 图标颜色
        ),
        titleTextStyle: TextStyle(
          color: Colors.black87, // 标题颜色
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 输入框装饰主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // 填充背景
        fillColor: Colors.grey.shade50, // 浅灰色背景
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 圆角12
          borderSide: BorderSide.none, // 无边框
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF42A5F5), // 聚焦时显示浅蓝色边框
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42A5F5), // 阳光蓝色背景
          foregroundColor: Colors.white, // 白色文字
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 圆角12
          ),
          elevation: 0, // 无阴影
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 2, // 轻微阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 圆角12
        ),
        margin: const EdgeInsets.all(8),
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 圆角16
        ),
        elevation: 4,
      ),
    );
  }

  /// 暗色主题配置
  ///
  /// 特点：
  /// - 同样使用Material 3设计规范
  /// - 基于相同的种子颜色生成暗色色彩方案
  /// - 深色背景，减少眼睛疲劳
  /// - 保持与亮色主题一致的视觉风格
  static ThemeData get darkTheme {
    return ThemeData(
      // 启用Material 3设计
      useMaterial3: true,

      // 暗色模式
      brightness: Brightness.dark,

      // 基于种子颜色生成暗色色彩方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF42A5F5), // 同样的阳光蓝色
        brightness: Brightness.dark, // 暗色模式
      ),

      // 应用栏主题配置（暗色版本）
      appBarTheme: const AppBarTheme(
        elevation: 0, // 无阴影
        surfaceTintColor: Colors.transparent, // 透明表面色调
      ),

      // 输入框装饰主题（暗色版本）
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // 填充背景
        fillColor: Colors.grey.shade800, // 深灰色背景
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 保持一致的圆角
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: const Color(0xFF2196F3), // 同样的蓝色边框
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // 按钮主题（暗色版本）
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3), // 同样的蓝色系
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 保持一致的圆角
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // 卡片主题（暗色版本）
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 保持一致的圆角
        ),
        margin: const EdgeInsets.all(8),
      ),

      // 对话框主题（暗色版本）
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 保持一致的圆角
        ),
        elevation: 4,
      ),
    );
  }

  /// 获取当前主题的文字样式配置
  ///
  /// 参数：
  /// - isDark：是否为暗色模式
  ///
  /// 返回值：包含文字样式的TextTheme
  static TextTheme getTextTheme(bool isDark) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white60 : Colors.grey.shade700,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}
