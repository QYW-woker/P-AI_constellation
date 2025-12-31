import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  // 主色调 - 紫蓝渐变
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);

  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1B4B), Color(0xFF0F0A1A)],
  );

  // 背景色
  static const Color backgroundColor = Color(0xFF0F0A1A);
  static const Color surfaceColor = Color(0xFF1E1B4B);
  static const Color cardColor = Color(0xFF2D2A5A);

  // 文字颜色
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA5A3C7);
  static const Color textHint = Color(0xFF6B6994);

  // 功能色
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // 星座元素颜色
  static const Color fireElement = Color(0xFFFF6B6B);
  static const Color earthElement = Color(0xFF51CF66);
  static const Color airElement = Color(0xFF74C0FC);
  static const Color waterElement = Color(0xFFCC5DE8);

  // 圆角
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // 间距
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // 字体大小
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeTitle = 32.0;

  // 阴影
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryColor.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// 获取主题数据
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryLight,
        surface: surfaceColor,
        error: errorColor,
      ),
      fontFamily: 'PingFang',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'PingFang',
          fontSize: fontSizeXL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeXXL,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeXL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: fontSizeL,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: fontSizeM,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeL,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeM,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeS,
          color: textHint,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        hintStyle: const TextStyle(color: textHint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: const TextStyle(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3D3A6A),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// 星座图标和颜色
class ZodiacStyle {
  static const Map<String, IconData> icons = {
    'Aries': Icons.arrow_upward,
    'Taurus': Icons.park,
    'Gemini': Icons.people,
    'Cancer': Icons.water,
    'Leo': Icons.wb_sunny,
    'Virgo': Icons.grass,
    'Libra': Icons.balance,
    'Scorpio': Icons.pest_control,
    'Sagittarius': Icons.arrow_forward,
    'Capricorn': Icons.terrain,
    'Aquarius': Icons.air,
    'Pisces': Icons.waves,
  };

  static const Map<String, Color> colors = {
    'Aries': Color(0xFFFF6B6B),
    'Taurus': Color(0xFF51CF66),
    'Gemini': Color(0xFF74C0FC),
    'Cancer': Color(0xFFCC5DE8),
    'Leo': Color(0xFFFFD43B),
    'Virgo': Color(0xFF51CF66),
    'Libra': Color(0xFF74C0FC),
    'Scorpio': Color(0xFFCC5DE8),
    'Sagittarius': Color(0xFFFF6B6B),
    'Capricorn': Color(0xFF51CF66),
    'Aquarius': Color(0xFF74C0FC),
    'Pisces': Color(0xFFCC5DE8),
  };

  static const Map<String, String> chineseNames = {
    'Aries': '白羊座',
    'Taurus': '金牛座',
    'Gemini': '双子座',
    'Cancer': '巨蟹座',
    'Leo': '狮子座',
    'Virgo': '处女座',
    'Libra': '天秤座',
    'Scorpio': '天蝎座',
    'Sagittarius': '射手座',
    'Capricorn': '摩羯座',
    'Aquarius': '水瓶座',
    'Pisces': '双鱼座',
  };

  static const Map<String, String> elements = {
    'Aries': 'fire',
    'Taurus': 'earth',
    'Gemini': 'air',
    'Cancer': 'water',
    'Leo': 'fire',
    'Virgo': 'earth',
    'Libra': 'air',
    'Scorpio': 'water',
    'Sagittarius': 'fire',
    'Capricorn': 'earth',
    'Aquarius': 'air',
    'Pisces': 'water',
  };

  static Color getElementColor(String element) {
    switch (element) {
      case 'fire':
        return AppTheme.fireElement;
      case 'earth':
        return AppTheme.earthElement;
      case 'air':
        return AppTheme.airElement;
      case 'water':
        return AppTheme.waterElement;
      default:
        return AppTheme.primaryColor;
    }
  }
}
