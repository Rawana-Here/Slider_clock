import 'package:flutter/material.dart';
import 'dart:async';
//import 'dart:math';
import 'package:intl/intl.dart';
import '../models/theme_provider.dart';

class SlidingClockScreen extends StatefulWidget {
  final ClockTheme theme;
  const SlidingClockScreen({Key? key, required this.theme}) : super(key: key);

  @override
  _SlidingClockScreenState createState() => _SlidingClockScreenState();
}

class _SlidingClockScreenState extends State<SlidingClockScreen>
    with TickerProviderStateMixin {
  DateTime _now = DateTime.now();
  late Timer _timer;

  final Map<String, List<int>> _digitSets = {
    'hour1': [0, 1, 2],
    'hour2': List.generate(10, (i) => i),
    'minute1': List.generate(6, (i) => i),
    'minute2': List.generate(10, (i) => i),
    'second1': List.generate(6, (i) => i),
    'second2': List.generate(10, (i) => i),
  };

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
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
    // FIXED: Wrapped the Column in a FittedBox.
    // This widget automatically scales its child down to fit the available space,
    // which is perfect for the small preview cards.
    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildClock(),
          const SizedBox(height: 20),
          _buildDateDisplay(),
        ],
      ),
    );
  }

  Widget _buildClock() {
    final String hour = _now.hour.toString().padLeft(2, '0');
    final String minute = _now.minute.toString().padLeft(2, '0');
    final String second = _now.second.toString().padLeft(2, '0');

    final int h1 = int.parse(hour[0]);
    final int h2 = int.parse(hour[1]);
    final int m1 = int.parse(minute[0]);
    final int m2 = int.parse(minute[1]);
    final int s1 = int.parse(second[0]);
    final int s2 = int.parse(second[1]);

    return SizedBox(
      height: 500, // We can keep the original intended size
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DigitBar(digit: h1, numbers: _digitSets['hour1']!, theme: widget.theme),
          const SizedBox(width: 15),
          DigitBar(digit: h2, numbers: _digitSets['hour2']!, theme: widget.theme),
          ColonWidget(color: widget.theme.primaryColor.withOpacity(0.8)),
          DigitBar(digit: m1, numbers: _digitSets['minute1']!, theme: widget.theme),
          const SizedBox(width: 15),
          DigitBar(digit: m2, numbers: _digitSets['minute2']!, theme: widget.theme),
          ColonWidget(color: widget.theme.primaryColor.withOpacity(0.8)),
          DigitBar(digit: s1, numbers: _digitSets['second1']!, theme: widget.theme),
          const SizedBox(width: 15),
          DigitBar(digit: s2, numbers: _digitSets['second2']!, theme: widget.theme),
        ],
      ),
    );
  }

  Widget _buildDateDisplay() {
    final String formattedDate = DateFormat('EEE. dd MMM').format(_now).toUpperCase();
    
    return Text(
      formattedDate,
      style: TextStyle(
        color: widget.theme.primaryColor.withOpacity(0.4),
        fontSize: 12,
        letterSpacing: 4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class DigitBar extends StatefulWidget {
  final int digit;
  final List<int> numbers;
  final ClockTheme theme;

  const DigitBar({
    Key? key,
    required this.digit,
    required this.numbers,
    required this.theme,
  }) : super(key: key);

  @override
  _DigitBarState createState() => _DigitBarState();
}

class _DigitBarState extends State<DigitBar> with TickerProviderStateMixin {
  late AnimationController _slideController;
  Animation<double>? _slideAnimation;
  double _currentOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _currentOffset = -widget.digit * 60.0;
    _initializeSlideAnimation();
  }

  void _initializeSlideAnimation() {
    _slideAnimation = Tween<double>(
      begin: _currentOffset,
      end: _currentOffset,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  void _updateSlideAnimation(double newOffset) {
    _slideAnimation = Tween<double>(
      begin: _currentOffset,
      end: newOffset,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(DigitBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit) {
      final double newOffset = -widget.digit * 60.0;
      _updateSlideAnimation(newOffset);
      _slideController.forward(from: 0).then((_) {
        _currentOffset = newOffset;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 500,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (_slideAnimation != null)
            AnimatedBuilder(
              animation: _slideAnimation!,
              builder: (context, child) {
                return Positioned(
                  top: _slideAnimation!.value + 220,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.numbers.map((num) {
                      return DigitTile(
                        digit: num,
                        isActive: num == widget.digit,
                        theme: widget.theme,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          Positioned(
            top: 220,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.glowColor.withOpacity(0.1),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DigitTile extends StatelessWidget {
  final int digit;
  final bool isActive;
  final ClockTheme theme;

  const DigitTile({
    Key? key,
    required this.digit,
    required this.isActive,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = isActive ? theme.primaryColor : theme.primaryColor.withOpacity(0.5);
    
    return Container(
      width: 40,
      height: 60,
      alignment: Alignment.center,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        style: TextStyle(
          fontSize: 36,
          color: textColor,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontFamily: theme.fontFamily,
          shadows: isActive ? [
            Shadow(
              color: theme.glowColor.withOpacity(0.5),
              blurRadius: 10,
            ),
          ] : [],
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: isActive ? 1.0 : 0.3,
          child: Text(
            digit.toString(),
          ),
        ),
      ),
    );
  }
}


class ColonWidget extends StatelessWidget {
  final Color color;
  const ColonWidget({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.5),
      child: Text(
        ':',
        style: TextStyle(
          color: color,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
