import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/theme_provider.dart';

class ClockScreen extends StatefulWidget {
  final ClockTheme theme;
  const ClockScreen({super.key, required this.theme});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // We define the ideal full-screen size here
    final clockWidth = math.min(screenSize.width, screenSize.height) * 0.9;
    final ringHeight = clockWidth * 0.3;

    // FIXED: Wrapped the content in a FittedBox.
    // This allows the clock, which is designed to be large, to scale down
    // gracefully when it's placed in a small preview card.
    return FittedBox(
      fit: BoxFit.contain,
      child: Center(
        child: SizedBox( // Give the content a defined size to scale from
          width: clockWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeRing(
                value: _currentTime.hour % 12 == 0 ? 12 : _currentTime.hour % 12,
                maxValue: 12,
                startFrom: 1,
                size: Size(clockWidth, ringHeight),
              ),
              const SizedBox(height: 8),
              _buildTimeRing(
                value: _currentTime.minute,
                maxValue: 60,
                size: Size(clockWidth, ringHeight),
              ),
              const SizedBox(height: 8),
              _buildTimeRing(
                value: _currentTime.second,
                maxValue: 60,
                size: Size(clockWidth, ringHeight),
              ),
              const SizedBox(height: 40),
              _buildDateDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRing({
    required int value,
    required int maxValue,
    int startFrom = 0,
    required Size size,
  }) {
    const double perspective = 0.002;
    const double maxAngle = math.pi / 3;
    const int visibleItems = 5;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size.width * 0.9,
            height: size.height * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size.height),
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, perspective)
              ..rotateX(math.pi / 6),
            alignment: Alignment.center,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: List.generate(visibleItems, (index) {
                  final offset = index - visibleItems ~/ 2;
                  final adjustedValue = (value + offset) % maxValue;
                  final displayValue = adjustedValue < 0 
                      ? maxValue + adjustedValue 
                      : adjustedValue;
                  final isCenter = offset == 0;
                  final angle = offset * maxAngle / (visibleItems ~/ 2);
                  final scale = 1.0 - (0.2 * offset.abs() / (visibleItems ~/ 2));
                  final opacity = 1.0 - (0.7 * offset.abs() / (visibleItems ~/ 2));

                  return Transform(
                    transform: Matrix4.identity()
                      ..translate(offset * size.width * 0.18, 0.0, 0.0)
                      ..rotateY(angle)
                      ..scale(scale, scale),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        (startFrom == 1 && maxValue == 12) 
                            ? displayValue.toString() 
                            : displayValue.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isCenter ? size.height * 0.7 : size.height * 0.5,
                          fontWeight: FontWeight.w300,
                          color: isCenter 
                              ? widget.theme.primaryColor 
                              : widget.theme.primaryColor.withOpacity(0.5),
                          fontFamily: widget.theme.fontFamily,
                          shadows: isCenter
                              ? [
                                  Shadow(
                                    color: widget.theme.glowColor.withOpacity(0.7),
                                    blurRadius: 20,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDisplay() {
    final day = DateFormat('EEE').format(_currentTime).toUpperCase();
    final month = DateFormat('MMM').format(_currentTime).toUpperCase();
    final date = _currentTime.day;
    final period = DateFormat('a').format(_currentTime).toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '$day $month $date $period',
        style: TextStyle(
          color: widget.theme.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
