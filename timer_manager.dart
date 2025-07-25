// lib/models/timer_manager.dart


import 'dart:async';
import 'package:flutter/material.dart';

class TimerManager extends ChangeNotifier {
  late AnimationController _controller;
  Duration _duration = const Duration(minutes: 10);
  bool _isRunning = false;

  TimerManager({required TickerProvider vsync}) {
    _controller = AnimationController(
      vsync: vsync,
      duration: _duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed || status == AnimationStatus.completed) {
          _isRunning = false;
          notifyListeners();
        }
      });
  }

  Duration get duration => _duration;
  bool get isRunning => _isRunning;
  AnimationController get controller => _controller;

  String get timerString {
    final duration = _controller.duration! * _controller.value;
    return '${(duration.inHours).toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void setDuration(Duration newDuration) {
    if (!_isRunning) {
      _duration = newDuration;
      _controller.duration = _duration;
      notifyListeners();
    }
  }

  void startStop() {
    if (_isRunning) {
      _controller.stop();
    } else {
      if (_controller.value == 0.0) {
        _controller.duration = _duration;
        _controller.reverse(from: 1.0);
      } else {
        _controller.reverse();
      }
    }
    _isRunning = !_isRunning;
    notifyListeners();
  }

  void reset() {
    _controller.reset();
    _isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
