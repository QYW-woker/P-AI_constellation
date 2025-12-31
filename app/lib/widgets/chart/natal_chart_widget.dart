import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/user.dart';

/// 本命星盘可视化组件
class NatalChartWidget extends StatelessWidget {
  final NatalChart chart;
  final double size;
  final bool showLabels;
  final bool interactive;

  const NatalChartWidget({
    super.key,
    required this.chart,
    this.size = 300,
    this.showLabels = true,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.cardShadow,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: NatalChartPainter(
          chart: chart,
          showLabels: showLabels,
        ),
      ),
    );
  }
}

/// 星盘绘制器
class NatalChartPainter extends CustomPainter {
  final NatalChart chart;
  final bool showLabels;

  NatalChartPainter({
    required this.chart,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 绘制外圈（星座轮）
    _drawZodiacWheel(canvas, center, radius);

    // 绘制宫位线
    _drawHouseLines(canvas, center, radius);

    // 绘制行星
    _drawPlanets(canvas, center, radius);

    // 绘制相位线
    _drawAspects(canvas, center, radius);

    // 绘制中心
    _drawCenter(canvas, center, radius);
  }

  void _drawZodiacWheel(Canvas canvas, Offset center, double radius) {
    final outerRadius = radius * 0.95;
    final innerRadius = radius * 0.75;

    // 绘制外圈
    final outerPaint = Paint()
      ..color = AppTheme.cardColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, outerRadius, outerPaint);

    // 绘制星座分隔线
    final linePaint = Paint()
      ..color = AppTheme.textHint.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final start = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawLine(start, end, linePaint);
    }

    // 绘制内圈
    final innerPaint = Paint()
      ..color = AppTheme.surfaceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, innerPaint);

    // 绘制星座符号
    if (showLabels) {
      _drawZodiacSymbols(canvas, center, outerRadius, innerRadius);
    }
  }

  void _drawZodiacSymbols(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
  ) {
    final symbolRadius = (outerRadius + innerRadius) / 2;
    final signs = AppConstants.zodiacSigns;
    final colors = [
      AppTheme.fireElement,
      AppTheme.earthElement,
      AppTheme.airElement,
      AppTheme.waterElement,
    ];

    for (int i = 0; i < 12; i++) {
      final angle = ((i * 30 + 15) - 90) * math.pi / 180;
      final x = center.dx + symbolRadius * math.cos(angle);
      final y = center.dy + symbolRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: _getZodiacSymbol(signs[i]),
          style: TextStyle(
            color: colors[i % 4],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  String _getZodiacSymbol(String sign) {
    const symbols = {
      'Aries': '♈',
      'Taurus': '♉',
      'Gemini': '♊',
      'Cancer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Scorpio': '♏',
      'Sagittarius': '♐',
      'Capricorn': '♑',
      'Aquarius': '♒',
      'Pisces': '♓',
    };
    return symbols[sign] ?? '?';
  }

  void _drawHouseLines(Canvas canvas, Offset center, double radius) {
    final innerRadius = radius * 0.75;
    final houseRadius = radius * 0.35;

    final linePaint = Paint()
      ..color = AppTheme.textHint.withOpacity(0.2)
      ..strokeWidth = 1;

    for (final house in chart.houses) {
      final angle = (house.degree - 90) * math.pi / 180;
      final start = Offset(
        center.dx + houseRadius * math.cos(angle),
        center.dy + houseRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      canvas.drawLine(start, end, linePaint);

      // 绘制宫位数字
      if (showLabels) {
        final midRadius = (houseRadius + innerRadius) / 2;
        final nextHouse = chart.houses[(house.house % 12)];
        final midAngle = ((house.degree + nextHouse.degree) / 2 - 90) * math.pi / 180;
        final x = center.dx + midRadius * math.cos(midAngle);
        final y = center.dy + midRadius * math.sin(midAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${house.house}',
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  void _drawPlanets(Canvas canvas, Offset center, double radius) {
    final planetRadius = radius * 0.55;

    for (final planet in chart.planets) {
      final angle = (planet.degree - 90) * math.pi / 180;
      final x = center.dx + planetRadius * math.cos(angle);
      final y = center.dy + planetRadius * math.sin(angle);

      // 绘制行星圆点
      final planetPaint = Paint()
        ..color = _getPlanetColor(planet.planet)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 8, planetPaint);

      // 绘制行星符号
      if (showLabels) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: _getPlanetSymbol(planet.planet),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  String _getPlanetSymbol(String planet) {
    const symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mercury': '☿',
      'Venus': '♀',
      'Mars': '♂',
      'Jupiter': '♃',
      'Saturn': '♄',
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
    };
    return symbols[planet] ?? '?';
  }

  Color _getPlanetColor(String planet) {
    const colors = {
      'Sun': Color(0xFFFFD700),
      'Moon': Color(0xFFC0C0C0),
      'Mercury': Color(0xFF87CEEB),
      'Venus': Color(0xFFFFB6C1),
      'Mars': Color(0xFFFF6347),
      'Jupiter': Color(0xFFDDA0DD),
      'Saturn': Color(0xFF808080),
      'Uranus': Color(0xFF00CED1),
      'Neptune': Color(0xFF4169E1),
      'Pluto': Color(0xFF8B0000),
    };
    return colors[planet] ?? AppTheme.primaryColor;
  }

  void _drawAspects(Canvas canvas, Offset center, double radius) {
    final aspectRadius = radius * 0.55;

    for (final aspect in chart.aspects) {
      // 找到两个行星的位置
      final planet1 = chart.planets.firstWhere(
        (p) => p.planet == aspect.planet1,
        orElse: () => chart.planets.first,
      );
      final planet2 = chart.planets.firstWhere(
        (p) => p.planet == aspect.planet2,
        orElse: () => chart.planets.first,
      );

      final angle1 = (planet1.degree - 90) * math.pi / 180;
      final angle2 = (planet2.degree - 90) * math.pi / 180;

      final start = Offset(
        center.dx + aspectRadius * math.cos(angle1),
        center.dy + aspectRadius * math.sin(angle1),
      );
      final end = Offset(
        center.dx + aspectRadius * math.cos(angle2),
        center.dy + aspectRadius * math.sin(angle2),
      );

      final aspectPaint = Paint()
        ..color = _getAspectColor(aspect.type).withOpacity(0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, aspectPaint);
    }
  }

  Color _getAspectColor(String type) {
    switch (type) {
      case 'conjunction':
        return AppTheme.primaryColor;
      case 'opposition':
        return AppTheme.errorColor;
      case 'trine':
        return AppTheme.successColor;
      case 'square':
        return AppTheme.warningColor;
      case 'sextile':
        return AppTheme.infoColor;
      default:
        return AppTheme.textHint;
    }
  }

  void _drawCenter(Canvas canvas, Offset center, double radius) {
    final centerRadius = radius * 0.15;

    final centerPaint = Paint()
      ..color = AppTheme.cardColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, centerRadius, centerPaint);

    // 绘制地球符号
    final earthPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, centerRadius * 0.6, earthPaint);
    canvas.drawLine(
      Offset(center.dx - centerRadius * 0.4, center.dy),
      Offset(center.dx + centerRadius * 0.4, center.dy),
      earthPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - centerRadius * 0.4),
      Offset(center.dx, center.dy + centerRadius * 0.4),
      earthPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
