import 'dart:async';
import 'package:flutter/material.dart';
import '../models/theme_provider.dart';

class TextClockScreen extends StatefulWidget {
  final ClockTheme theme;
  const TextClockScreen({Key? key, required this.theme}) : super(key: key);

  @override
  State<TextClockScreen> createState() => _TextClockScreenState();
}

class _TextClockScreenState extends State<TextClockScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  DateTime _now = DateTime.now();
  Set<String> _activeWords = {'it', 'is'};
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    
    _updateClock();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateClock();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _updateClock() {
    setState(() {
      _now = DateTime.now();
      _activeWords = _calculateActiveWords(_now);
    });
  }

  Set<String> _calculateActiveWords(DateTime time) {
    final Set<String> active = {'it', 'is'};
    int hours = time.hour;
    final minutes = time.minute;
    
    if (minutes > 34) {
      hours = (hours + 1) % 24;
    }
    
    if (hours == 0) hours = 12;
    if (hours > 12) hours -= 12;

    const Map<int, String> hourWords = {
      1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five-h',
      6: 'six', 7: 'seven', 8: 'eight', 9: 'nine', 10: 'ten-h',
      11: 'eleven', 12: 'twelve'
    };
    if (hourWords.containsKey(hours)) {
      active.add(hourWords[hours]!);
    }

    if (minutes >= 0 && minutes < 5) active.add('oclock');
    if (minutes >= 5 && minutes < 10) active.addAll(['five', 'past']);
    if (minutes >= 10 && minutes < 15) active.addAll(['ten', 'past']);
    if (minutes >= 15 && minutes < 20) active.addAll(['a', 'quarter', 'past']);
    if (minutes >= 20 && minutes < 25) active.addAll(['twenty', 'past']);
    if (minutes >= 25 && minutes < 30) active.addAll(['twenty', 'five', 'past']);
    if (minutes >= 30 && minutes < 35) active.addAll(['half', 'past']);
    if (minutes >= 35 && minutes < 40) active.addAll(['twenty', 'five', 'to']);
    if (minutes >= 40 && minutes < 45) active.addAll(['twenty', 'to']);
    if (minutes >= 45 && minutes < 50) active.addAll(['a', 'quarter', 'to']);
    if (minutes >= 50 && minutes < 55) active.addAll(['ten', 'to']);
    if (minutes >= 55 && minutes < 60) active.addAll(['five', 'to']);

    return active;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double baseFontSize = screenSize.width * 0.075;

    return Center(
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          // FIXED: Wrapped the content in a FittedBox to make it responsive.
          return FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
              child: SizedBox( // Give the content a defined size to scale from
                width: screenSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextLine(['it', 'is', 'l', 'twenty'], baseFontSize),
                    _buildTextLine(['a', 'm', 'half', 'ten-q'], baseFontSize),
                    _buildTextLine(['quarter', 'c', 'to'], baseFontSize),
                    _buildTextLine(['past', 'gru', 'nine'], baseFontSize),
                    _buildTextLine(['one', 'six', 'three'], baseFontSize),
                    _buildTextLine(['four', 'five-h', 'two'], baseFontSize),
                    _buildTextLine(['eight', 'eleven'], baseFontSize),
                    _buildTextLine(['seven', 'twelve'], baseFontSize),
                    _buildTextLine(['ten-h', 'se', 'oclock'], baseFontSize),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextLine(List<String> words, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: words.map((word) => _buildGlowWord(word, fontSize)).toList(),
    );
  }

  Widget _buildGlowWord(String text, double fontSize) {
    final bool isActive = _activeWords.contains(text);
    final Color activeColor = widget.theme.primaryColor;
    final Color inactiveColor = widget.theme.primaryColor.withOpacity(0.15);
    
    return Text(
      text.toUpperCase().replaceAll('-', ''),
      style: TextStyle(
        color: isActive ? activeColor : inactiveColor,
        fontSize: fontSize,
        fontFamily: widget.theme.fontFamily,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
        letterSpacing: 1.5,
        shadows: isActive
            ? [
                Shadow(color: widget.theme.glowColor.withOpacity(_glowAnimation.value * 0.8), blurRadius: 15 * _glowAnimation.value),
                Shadow(color: widget.theme.glowColor.withOpacity(_glowAnimation.value * 0.5), blurRadius: 25 * _glowAnimation.value),
              ]
            : [],
      ),
    );
  }
}
