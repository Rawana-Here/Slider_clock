import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/theme_provider.dart';

class OrbitalClockScreen extends StatefulWidget {
  final ClockTheme theme;
  const OrbitalClockScreen({Key? key, required this.theme}) : super(key: key);

  @override
  State<OrbitalClockScreen> createState() => _OrbitalClockScreenState();
}

class _OrbitalClockScreenState extends State<OrbitalClockScreen> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double clockSize = math.min(screenSize.width, screenSize.height) * 0.98;

    // FIXED: Wrapped the content in a FittedBox to make it responsive.
    return FittedBox(
      fit: BoxFit.contain,
      child: Center(
        child: SizedBox(
          width: clockSize,
          height: clockSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ..._buildRings(clockSize),
              ..._buildClockHands(clockSize),
              _buildCenterCircle(clockSize),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRings(double clockSize) {
    return [
      _buildRing(
        clockSize: clockSize,
        count: 60,
        radiusRatio: 0.48,
        currentValue: _now.second,
        digitSize: clockSize * 0.04,
        fontSize: clockSize * 0.025,
      ),
      _buildRing(
        clockSize: clockSize,
        count: 60,
        radiusRatio: 0.36,
        currentValue: _now.minute,
        digitSize: clockSize * 0.045,
        fontSize: clockSize * 0.028,
      ),
      _buildRing(
        clockSize: clockSize,
        count: 12,
        radiusRatio: 0.24,
        currentValue: _now.hour % 12,
        digitSize: clockSize * 0.055,
        fontSize: clockSize * 0.035,
      ),
    ];
  }

  Widget _buildRing({
    required double clockSize,
    required int count,
    required double radiusRatio,
    required int currentValue,
    required double digitSize,
    required double fontSize,
  }) {
    final double radius = clockSize * radiusRatio;
    return SizedBox(
      width: clockSize,
      height: clockSize,
      child: Stack(
        children: List.generate(count, (i) {
          final double angle = (i / count) * 2 * math.pi - math.pi / 2;
          final double x = clockSize / 2 + radius * math.cos(angle);
          final double y = clockSize / 2 + radius * math.sin(angle);
          final bool isActive = i == currentValue;
          
          return Positioned(
            left: x - digitSize / 2,
            top: y - digitSize / 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: digitSize,
              height: digitSize,
              decoration: BoxDecoration(
                color: isActive ? widget.theme.primaryColor : widget.theme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: widget.theme.glowColor,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isActive ? 1.4 : 1.0,
                child: Center(
                  child: Text(
                    (count > 12 ? i.toString().padLeft(2, '0') : (i == 0 ? '12' : i.toString())),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isActive ? widget.theme.backgroundColor : widget.theme.primaryColor.withOpacity(0.6),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontFamily: widget.theme.fontFamily,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildClockHands(double clockSize) {
    final double secondFraction = _now.millisecond / 1000.0;
    final double minuteFraction = (_now.second + secondFraction) / 60.0;
    final double hourFraction = (_now.minute + minuteFraction) / 60.0;
    
    final int hour12 = _now.hour % 12;
    final double hourDeg = (hour12 + hourFraction) * 30;
    final double minuteDeg = (_now.minute + minuteFraction) * 6;
    final double secondDeg = (_now.second + secondFraction) * 6;

    return [
      _buildHand(clockSize: clockSize, height: clockSize * 0.15, width: clockSize * 0.008, color: widget.theme.primaryColor, angle: hourDeg * math.pi / 180),
      _buildHand(clockSize: clockSize, height: clockSize * 0.22, width: clockSize * 0.006, color: widget.theme.primaryColor.withOpacity(0.7), angle: minuteDeg * math.pi / 180),
      _buildHand(clockSize: clockSize, height: clockSize * 0.28, width: clockSize * 0.004, color: widget.theme.glowColor, angle: secondDeg * math.pi / 180, hasGlow: true),
    ];
  }

  Widget _buildHand({
    required double clockSize,
    required double height,
    required double width,
    required Color color,
    required double angle,
    bool hasGlow = false,
  }) {
    return Transform.rotate(
      angle: angle,
      origin: Offset(0, height * 0.5),
      child: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width / 2),
            boxShadow: hasGlow ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 1)] : [],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterCircle(double clockSize) {
    return Container(
      width: clockSize * 0.04,
      height: clockSize * 0.04,
      decoration: BoxDecoration(
        color: widget.theme.glowColor,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: widget.theme.glowColor, blurRadius: 10, spreadRadius: 2)],
      ),
    );
  }
}
