import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // FIXED: Removed unused import
import '../models/theme_provider.dart';

class StopwatchScreen extends StatefulWidget {
  final ClockTheme theme;
  const StopwatchScreen({Key? key, required this.theme}) : super(key: key);

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _displayTime = "00:00:00.00";
  final List<String> _laps = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          _displayTime = _formatTime(_stopwatch.elapsedMilliseconds);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate() % 60;
    int hours = (milliseconds / (1000 * 60 * 60)).truncate();

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr.$hundredsStr";
  }

  void _startStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    setState(() {}); // Re-render to update button text
  }

  void _recordLap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _displayTime);
      });
    }
  }

  void _reset() {
    _stopwatch.reset();
    _stopwatch.stop();
    setState(() {
      _displayTime = "00:00:00.00";
      _laps.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Stopwatch'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Time Display
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  _displayTime,
                  style: TextStyle(
                    fontSize: 56,
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
                ),
              ),
            ),
            // Lap List
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: _laps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lap ${ _laps.length - index}",
                          style: TextStyle(
                            color: widget.theme.primaryColor.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _laps[index],
                          style: TextStyle(
                            color: widget.theme.primaryColor,
                            fontSize: 16,
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Buttons
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    text: _stopwatch.isRunning ? "Stop" : "Start",
                    onPressed: _startStop,
                    color: _stopwatch.isRunning ? Colors.redAccent : widget.theme.glowColor,
                  ),
                  _buildButton(text: "Lap", onPressed: _recordLap),
                  _buildButton(text: "Reset", onPressed: _reset),
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
