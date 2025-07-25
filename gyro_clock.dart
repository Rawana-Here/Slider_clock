import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../models/theme_provider.dart';

/// GyroClockScreen is a StatefulWidget that displays a dynamic clock
/// with three rotating arcs for hours, minutes, and seconds.
/// The current time is highlighted with a glowing effect.
class GyroClockScreen extends StatefulWidget {
  final ClockTheme theme;
  const GyroClockScreen({Key? key, required this.theme}) : super(key: key);

  @override
  State<GyroClockScreen> createState() => _GyroClockScreenState();
}

class _GyroClockScreenState extends State<GyroClockScreen>
    with TickerProviderStateMixin {
  late DateTime _now;
  late Timer _dateTimer;
  late AnimationController _secondController;
  late AnimationController _minuteController;
  late AnimationController _hourController;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    
    // High frequency timer for smoother seconds animation
    _dateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() => _now = DateTime.now());
        _updateControllerValues();
      }
    });

    // Smoother animation controllers
    _secondController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _minuteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _hourController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Initialize controller values
    _updateControllerValues();
  }

  void _updateControllerValues() {
    if (!mounted) return;
    
    // Smooth transitions with millisecond precision
    final secondValue = (_now.second + _now.millisecond / 1000) / 60.0;
    final minuteValue = (_now.minute + _now.second / 60.0 + _now.millisecond / 3600000) / 60.0;
    final hourValue = ((_now.hour % 12) + _now.minute / 60.0 + _now.second / 3600.0) / 12.0;

    _secondController.animateTo(secondValue, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
    _minuteController.animateTo(minuteValue, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
    _hourController.animateTo(hourValue, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(covariant GyroClockScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _dateTimer.cancel();
    _secondController.dispose();
    _minuteController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  String get _dateLabel {
    final d = _now;
    return '${DateFormat('EEE').format(d).toUpperCase()} ${DateFormat('MMM').format(d).toUpperCase()} ${d.day} ${DateFormat('a').format(d)}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ringWidth = math.min(size.width, size.height) * 0.75;
    
    return SafeArea(
      child: Padding(
        // Reduced top padding to move clock higher on screen
        padding: const EdgeInsets.only(top: 20.0, left: 12.0, right: 12.0, bottom: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Changed from center to start
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40), // Add some space from top
            
            // Hour Arc Ring - Improved centering
            SizedBox(
              height: ringWidth * 0.50,
              child: Center(
                child: AnimatedBuilder(
                  animation: _hourController,
                  builder: (context, child) {
                    return ClockArcRing(
                      currentValue: _hourController.value * 12.0,
                      total: 12,
                      visible: 6,
                      arc: math.pi * 0.8, // Slightly increased for better edge-to-edge
                      ringWidth: ringWidth,
                      fontSize: ringWidth * 0.15,
                      color: widget.theme.primaryColor,
                      glowColor: widget.theme.glowColor,
                      pad: 0,
                      startFrom: 1,
                      dxMultiplier: 0.40, // Adjusted for better centering
                      dyMultiplier: 0.22, // Adjusted for better centering
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            
            // Minute Arc Ring - Improved centering
            SizedBox(
              height: ringWidth * 0.28,
              child: Center(
                child: AnimatedBuilder(
                  animation: _minuteController,
                  builder: (context, child) {
                    return ClockArcRing(
                      currentValue: _minuteController.value * 60.0,
                      total: 60,
                      visible: 18, // Reduced for better spacing
                      arc: math.pi * 1.25, // Slightly increased
                      ringWidth: ringWidth,
                      fontSize: ringWidth * 0.055,
                      color: widget.theme.primaryColor,
                      glowColor: widget.theme.glowColor,
                      pad: 2,
                      dxMultiplier: 0.57, // Adjusted for better centering
                      dyMultiplier: 0.17, // Adjusted for better centering
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            
            // Second Arc Ring - Fixed edge-to-edge and centering
            SizedBox(
              height: ringWidth * 0.28,
              child: Center(
                child: AnimatedBuilder(
                  animation: _secondController,
                  builder: (context, child) {
                    return ClockArcRing(
                      currentValue: _secondController.value * 60.0,
                      total: 60,
                      visible: 22, // Reduced from 25 for better spacing
                      arc: math.pi * 1.45, // Increased for true edge-to-edge
                      ringWidth: ringWidth,
                      fontSize: ringWidth * 0.055,
                      color: widget.theme.primaryColor,
                      glowColor: widget.theme.glowColor,
                      pad: 2,
                      dxMultiplier: 0.57, // Adjusted for better centering
                      dyMultiplier: 0.17, // Adjusted for better centering
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            
            // Date Label Display - Improved positioning
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.black.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: widget.theme.glowColor.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                child: Text(
                  _dateLabel,
                  style: TextStyle(
                    color: widget.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2.5,
                    fontFamily: widget.theme.fontFamily,
                    shadows: [
                      Shadow(blurRadius: 25, color: widget.theme.glowColor.withOpacity(0.9)),
                      Shadow(color: widget.theme.primaryColor, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ClockArcRing - Improved centering and edge-to-edge display
class ClockArcRing extends StatelessWidget {
  final double currentValue;
  final int total;
  final int visible;
  final int pad;
  final int startFrom;
  final double arc;
  final double ringWidth;
  final double fontSize;
  final Color color;
  final Color glowColor;
  final double dxMultiplier;
  final double dyMultiplier;

  const ClockArcRing({
    Key? key,
    required this.currentValue,
    required this.total,
    required this.visible,
    required this.arc,
    required this.ringWidth,
    required this.fontSize,
    required this.color,
    required this.glowColor,
    this.pad = 2,
    this.startFrom = 0,
    required this.dxMultiplier,
    required this.dyMultiplier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final centerIdx = visible ~/ 2;
    final digits = <Widget>[];
    final fractionalValue = currentValue - currentValue.truncate();
    final arcPerItem = arc / (visible - 1);
    final halfArc = arc / 2;

    for (int k = -centerIdx; k <= centerIdx; k++) {
      int val = ((currentValue.round() + k - startFrom + total) % total);
      if (startFrom == 1 && val == 0) val = total;
      String text = (startFrom == 1) ? val.toString() : val.toString().padLeft(pad, '0');

      // Improved positioning calculation for better centering
      double t = arcPerItem * (k - fractionalValue);

      // Only show numbers within the arc bounds with improved edge detection
      if (t.abs() > halfArc * 1.1) continue; // Slightly extended bounds for edge-to-edge

      final dx = math.sin(t) * ringWidth * dxMultiplier;
      final dy = -math.cos(t) * ringWidth * dyMultiplier;

      final arcPosition = t.abs() / halfArc;
      final normalizedDistance = k.abs().toDouble() / centerIdx;
      final combinedDistance = math.max(normalizedDistance, arcPosition);

      // Improved scaling for better visual effect
      final scale = math.max(0.6, 1.0 - 0.15 * math.pow(combinedDistance, 1.5));
      
      // Improved opacity calculation for smoother fade
      final opacity = (1.0 - math.pow(normalizedDistance, 3.0)).clamp(0.1, 1.0);

      if (opacity < 0.1) continue;

      final isActive = k == 0;

      final textPainter = TextPainter(
        text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      final textWidth = textPainter.width;
      final textHeight = textPainter.height;

      digits.add(
        Positioned(
          // Improved centering calculation
          top: (ringWidth * 0.25) + dy - (textHeight / 2),
          left: (ringWidth / 2) + dx - (textWidth / 2),
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? color : color.withOpacity(0.7),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono',
                  shadows: isActive
                      ? [
                          Shadow(color: glowColor.withOpacity(0.9), blurRadius: 30),
                          Shadow(color: color, blurRadius: 8),
                          Shadow(color: glowColor.withOpacity(0.5), blurRadius: 12),
                        ]
                      : [
                          const Shadow(color: Colors.black, blurRadius: 3)
                        ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: ringWidth,
          height: constraints.maxHeight,
          child: Stack(
            clipBehavior: Clip.none, // Changed to Clip.none for edge-to-edge display
            children: digits,
          ),
        );
      },
    );
  }
}