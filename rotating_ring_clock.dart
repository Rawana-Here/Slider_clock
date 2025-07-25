import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/theme_provider.dart';

class RotatingRingClockScreen extends StatefulWidget {
  final ClockTheme theme;
  const RotatingRingClockScreen({Key? key, required this.theme}) : super(key: key);

  @override
  State<RotatingRingClockScreen> createState() => _RotatingRingClockScreenState();
}

class _RotatingRingClockScreenState extends State<RotatingRingClockScreen>
    with TickerProviderStateMixin {
  late DateTime _now;
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double vmin = math.min(screenSize.width, screenSize.height);
    final double clockSize = vmin * 0.88;

    // FIXED: Wrapped the content in a FittedBox to make it responsive.
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: clockSize, // Give the content a defined size to scale from
        height: clockSize * 1.2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: clockSize,
                height: clockSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildClockFace(clockSize),
                    _buildTimeIndicator(vmin),
                    ..._buildClockRings(clockSize),
                  ],
                ),
              ),
              SizedBox(height: vmin * 0.06),
              _buildDateDisplay(vmin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClockFace(double clockSize) {
    return Container(
      width: clockSize,
      height: clockSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            widget.theme.backgroundColor.withBlue(30).withGreen(30),
            widget.theme.backgroundColor,
            widget.theme.backgroundColor.withRed(10).withGreen(10),
          ],
        ),
        boxShadow: [
          const BoxShadow(color: Colors.black87, blurRadius: 80, spreadRadius: -10),
          BoxShadow(color: widget.theme.glowColor.withOpacity(0.1), blurRadius: 40, spreadRadius: -20),
        ],
      ),
    );
  }

  Widget _buildTimeIndicator(double vmin) {
    return Positioned(
      top: vmin * 0.015,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: vmin * 0.006,
              height: vmin * 0.03,
              decoration: BoxDecoration(
                color: widget.theme.glowColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(color: widget.theme.glowColor, blurRadius: 15, spreadRadius: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildClockRings(double clockSize) {
    final secondFraction = _now.millisecond / 1000;
    final minuteFraction = (_now.second + secondFraction) / 60;
    final hourFraction = (_now.minute + minuteFraction) / 60;

    final double secondAngle = -((_now.second + secondFraction) / 60) * 2 * math.pi;
    final double minuteAngle = -((_now.minute + minuteFraction) / 60) * 2 * math.pi;
    
    final currentHour12 = _now.hour % 12;
    final normalizedHour = currentHour12 == 0 ? 12 : currentHour12;
    final double hourAngle = -((normalizedHour - 1 + hourFraction) / 12) * 2 * math.pi;

    return [
      _buildRing(
        size: clockSize * 1.0,
        count: 60,
        currentValue: _now.second,
        angle: secondAngle,
        fontSize: clockSize * 0.018,
        fontWeight: FontWeight.w400,
      ),
      _buildRing(
        size: clockSize * 0.82,
        count: 60,
        currentValue: _now.minute,
        angle: minuteAngle,
        fontSize: clockSize * 0.022,
        fontWeight: FontWeight.w700,
      ),
      _buildRing(
        size: clockSize * 0.55,
        count: 12,
        currentValue: normalizedHour - 1,
        angle: hourAngle,
        fontSize: clockSize * 0.05,
        fontWeight: FontWeight.w700,
        startFromOne: true,
      ),
    ];
  }

  Widget _buildRing({
    required double size,
    required int count,
    required int currentValue,
    required double angle,
    required double fontSize,
    required FontWeight fontWeight,
    bool startFromOne = false,
  }) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: List.generate(count, (i) {
            final digitAngle = (i / count) * 2 * math.pi;
            final bool isCurrent = i == currentValue;
            final radius = size / 2 * 0.88;
            final x = radius * math.cos(digitAngle - math.pi / 2);
            final y = radius * math.sin(digitAngle - math.pi / 2);

            return Positioned(
              left: size / 2 + x - (fontSize * 1.5),
              top: size / 2 + y - (fontSize * 1.5),
              child: Transform.rotate(
                angle: -angle,
                child: AnimatedScale(
                  scale: isCurrent ? 2.2 : 1.0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  child: Text(
                    startFromOne ? (i + 1).toString() : i.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      fontFamily: widget.theme.fontFamily,
                      color: isCurrent ? widget.theme.primaryColor : widget.theme.primaryColor.withOpacity(0.4),
                      shadows: isCurrent
                          ? [
                              Shadow(color: widget.theme.glowColor, blurRadius: 12),
                              Shadow(color: widget.theme.glowColor, blurRadius: 6),
                            ]
                          : [],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDateDisplay(double vmin) {
    final formattedDate = DateFormat('E MMM d').format(_now).toUpperCase();
    return Text(
      formattedDate,
      style: TextStyle(
        fontSize: vmin * 0.032,
        letterSpacing: 4,
        color: widget.theme.primaryColor.withOpacity(0.6),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
