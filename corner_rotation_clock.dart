import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/theme_provider.dart';

class CornerRotationClockScreen extends StatefulWidget {
  final ClockTheme theme;
  const CornerRotationClockScreen({Key? key, required this.theme}) : super(key: key);

  @override
  State<CornerRotationClockScreen> createState() =>
      _CornerRotationClockScreenState();
}

class _CornerRotationClockScreenState extends State<CornerRotationClockScreen>
    with TickerProviderStateMixin {
  late DateTime _now;
  late DateTime _previousTime;
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _previousTime = _now;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      final newTime = DateTime.now();
      if (newTime.minute != _now.minute) {
        _animationController.forward(from: 0);
      }
      if (mounted) {
        setState(() {
          _previousTime = _now;
          _now = newTime;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Wrapped in a FittedBox to ensure it scales down for previews.
    return FittedBox(
      fit: BoxFit.contain,
      child: CustomPaint(
        // Give the painter a defined size to scale from.
        size: MediaQuery.of(context).size,
        painter: RotatingTimePainter(
          now: _now,
          previousTime: _previousTime,
          animationValue: CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ).value,
          theme: widget.theme,
        ),
      ),
    );
  }
}

class RotatingTimePainter extends CustomPainter {
  final ClockTheme theme;
  final DateTime now;
  final DateTime previousTime;
  final double animationValue;
  final Map<String, double> radii = {};

  static const double _ringWidth = 80.0;
  static const double _ringSpacingMultiplier = 1.25;
  static const double _blurSigma = 4.0;
  static const double _shadowOffset = 2.0;
  static const double _glowArcDegrees = 50.0;

  RotatingTimePainter({
    required this.now,
    required this.previousTime,
    required this.animationValue,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.bottomRight(Offset.zero);
    final double shortSide = math.min(size.width, size.height);

    radii['hour'] = shortSide - (_ringWidth * 0.75);
    radii['minute'] = shortSide - (_ringWidth * (0.75 + _ringSpacingMultiplier));
    radii['second'] = shortSide - (_ringWidth * (0.75 + _ringSpacingMultiplier * 2));
    radii['ampm'] = shortSide - (_ringWidth * (0.75 + _ringSpacingMultiplier * 3));

    _drawNeumorphicArc(canvas, center, radii['hour']!);
    _drawNeumorphicArc(canvas, center, radii['minute']!);
    _drawNeumorphicArc(canvas, center, radii['second']!);
    _drawNeumorphicArc(canvas, center, radii['ampm']!);

    _drawFixedGlow(canvas, center, radii['hour']!);
    _drawFixedGlow(canvas, center, radii['minute']!);
    _drawFixedGlow(canvas, center, radii['second']!);
    _drawFixedGlow(canvas, center, radii['ampm']!);

    _drawHourLabels(canvas, center);
    _drawMinuteLabels(canvas, center);
    _drawSecondLabels(canvas, center);
    _drawAmPmLabels(canvas, center);
  }

  void _drawNeumorphicArc(Canvas canvas, Offset center, double radius) {
    final Paint mainPaint = Paint()..color = theme.backgroundColor..style = PaintingStyle.stroke..strokeWidth = _ringWidth;
    final Paint shadowPaint = Paint()..color = Colors.black.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = _ringWidth..maskFilter = const MaskFilter.blur(BlurStyle.normal, _blurSigma);
    final Paint highlightPaint = Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = _ringWidth..maskFilter = const MaskFilter.blur(BlurStyle.normal, _blurSigma);
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(Rect.fromCircle(center: center.translate(_shadowOffset, _shadowOffset), radius: radius), math.pi, math.pi / 2, false, shadowPaint);
    canvas.drawArc(Rect.fromCircle(center: center.translate(-_shadowOffset, -_shadowOffset), radius: radius), math.pi, math.pi / 2, false, highlightPaint);
    canvas.drawArc(rect, math.pi, math.pi / 2, false, mainPaint);
  }

  void _drawFixedGlow(Canvas canvas, Offset center, double radius) {
    const double centerAngle = math.pi * 1.25;
    final double startAngle = centerAngle - (math.pi * _glowArcDegrees / 180.0 / 2);
    final double sweepAngle = math.pi * _glowArcDegrees / 180.0;
    final glowPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = _ringWidth + 4.0;
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [Colors.transparent, theme.glowColor.withOpacity(0.9), Colors.transparent],
      stops: const [0.0, 0.5, 1.0],
    );
    glowPaint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, glowPaint);
  }

  void _drawHourLabels(Canvas canvas, Offset center) {
    final bool hourChanged = now.hour != previousTime.hour;
    final double hourAnimation = hourChanged ? animationValue : 0.0;
    final int baseHour24 = hourChanged ? previousTime.hour : now.hour;
    final int baseHour12 = baseHour24 % 12 == 0 ? 12 : baseHour24 % 12;
    for (int i = -4; i <= 4; i++) {
      final int hour = (baseHour12 - 1 + i + 12) % 12 + 1;
      final double angleOffset = (i - hourAnimation) * (math.pi / 12);
      final double angle = (math.pi * 1.25) + angleOffset;
      final double opacity = math.max(0, 1.0 - ((i - hourAnimation).abs() / 4.0));
      _drawText(canvas, '$hour', center, radii['hour']!, angle, opacity);
    }
  }

  void _drawMinuteLabels(Canvas canvas, Offset center) {
    final bool minuteChanged = now.minute != previousTime.minute;
    final int baseMinute = minuteChanged ? previousTime.minute : now.minute;
    final double minuteAnimation = minuteChanged ? animationValue : 0.0;
    for (int i = -4; i <= 4; i++) {
      final int minute = (baseMinute + i + 60) % 60;
      final double angleOffset = (i - minuteAnimation) * (math.pi / 12);
      final double angle = (math.pi * 1.25) + angleOffset;
      final double opacity = math.max(0, 1.0 - ((i - minuteAnimation).abs() / 4.0));
      _drawText(canvas, minute.toString().padLeft(2, '0'), center, radii['minute']!, angle, opacity);
    }
  }

  void _drawSecondLabels(Canvas canvas, Offset center) {
    final double continuousOffset = now.second + (now.millisecond / 1000.0);
    for (int i = -4; i <= 4; i++) {
      final int second = (continuousOffset.floor() + i + 60) % 60;
      final double angleOffset = (i - (continuousOffset - continuousOffset.floor())) * (math.pi / 9);
      final double angle = (math.pi * 1.25) + angleOffset;
      final double opacity = math.max(0, 1.0 - ((i - (continuousOffset - continuousOffset.floor())).abs() / 4.0));
      _drawText(canvas, second.toString().padLeft(2, '0'), center, radii['second']!, angle, opacity, fontSizeMultiplier: 0.8);
    }
  }

  void _drawAmPmLabels(Canvas canvas, Offset center) {
    final bool currentIsAm = now.hour < 12;
    final labels = currentIsAm ? { -1: "PM", 0: "AM", 1: "PM" } : { -1: "AM", 0: "PM", 1: "AM" };
    for (int i in labels.keys) {
      final double angle = (math.pi * 1.25) + i * (math.pi / 2.0);
      final double opacity = math.max(0, 1.0 - (i.abs() / 2.0));
      _drawText(canvas, labels[i]!, center, radii['ampm']!, angle, opacity, fontSizeMultiplier: 0.65);
    }
  }

  void _drawText(Canvas canvas, String text, Offset center, double radius, double angle, double opacity, {double fontSizeMultiplier = 1.0}) {
    if (opacity <= 0) return;
    final double minFontSize = _ringWidth * 0.35 * fontSizeMultiplier;
    final double maxFontSize = _ringWidth * 0.55 * fontSizeMultiplier;
    final double fontSize = minFontSize + (maxFontSize - minFontSize) * opacity;
    final textStyle = TextStyle(
      color: theme.primaryColor.withOpacity(opacity),
      fontSize: fontSize,
      fontWeight: opacity > 0.9 ? FontWeight.bold : FontWeight.normal,
      fontFamily: theme.fontFamily,
    );
    final textPainter = TextPainter(text: TextSpan(text: text, style: textStyle), textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout();
    final textPosition = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
    canvas.save();
    canvas.translate(textPosition.dx, textPosition.dy);
    canvas.rotate(angle + math.pi / 2);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RotatingTimePainter oldDelegate) {
    return oldDelegate.now != now || oldDelegate.animationValue != animationValue || oldDelegate.theme != theme;
  }
}
