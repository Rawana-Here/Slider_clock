// lib/screens/timer_screen.dart


import 'dart:async'; // For Timer functionality
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/theme_provider.dart';

class TimerScreen extends StatefulWidget {
  final ClockTheme theme;
  const TimerScreen({Key? key, required this.theme}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  Duration _duration = const Duration(minutes: 10);
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed || status == AnimationStatus.completed) {
        setState(() {
          _isRunning = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startStopTimer() {
    if (_isRunning) {
      _controller.stop();
    } else {
       if (_controller.value == 0) {
         _controller.duration = _duration;
         _controller.reverse(from: 1.0);
       } else {
         _controller.reverse();
       }
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _controller.reset();
     setState(() {
      _isRunning = false;
    });
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hms,
            initialTimerDuration: _duration,
            onTimerDurationChanged: (Duration newDuration) {
              if (!_isRunning) {
                setState(() {
                  _duration = newDuration;
                  _controller.duration = _duration;
                });
              }
            },
          ),
        );
      },
    );
  }

  String get _timerString {
    final duration = _controller.duration! * _controller.value;
    return '${(duration.inHours).toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Timer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) {
                    return Text(
                      _timerString,
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        fontFamily: widget.theme.fontFamily,
                        color: widget.theme.primaryColor,
                        shadows: [
                          Shadow(
                            color: widget.theme.glowColor.withOpacity(0.7),
                            blurRadius: 15,
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: TextButton(
                  onPressed: _isRunning ? null : _showDurationPicker,
                  child: Text(
                    'Set Duration: ${_duration.inHours}h ${_duration.inMinutes % 60}m ${_duration.inSeconds % 60}s',
                    style: TextStyle(
                      color: widget.theme.primaryColor.withOpacity(0.8),
                      fontSize: 18
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    text: _isRunning ? "Pause" : "Start",
                    onPressed: _startStopTimer,
                    color: _isRunning ? Colors.orangeAccent : widget.theme.glowColor,
                  ),
                  _buildButton(text: "Reset", onPressed: _resetTimer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed, Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color ?? widget.theme.primaryColor.withOpacity(0.3),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
      ),
      child: Text(text),
    );
  }
}
