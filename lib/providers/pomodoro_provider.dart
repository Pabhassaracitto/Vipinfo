import 'dart:async';
import 'package:flutter/material.dart';

enum PomodoroState { work, shortBreak, longBreak, stopped }

class PomodoroProvider with ChangeNotifier {
  PomodoroState _state = PomodoroState.stopped;
  int _workMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _remainingSeconds = 25 * 60;
  int _completedPomodoros = 0;
  Timer? _timer;

  PomodoroState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get completedPomodoros => _completedPomodoros;
  bool get isRunning => _timer != null && _timer!.isActive;

  String get displayTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startWork() {
    _state = PomodoroState.work;
    _remainingSeconds = _workMinutes * 60;
    _startTimer();
  }

  void startBreak({bool isLong = false}) {
    _state = isLong ? PomodoroState.longBreak : PomodoroState.shortBreak;
    _remainingSeconds = isLong ? _longBreakMinutes * 60 : _shortBreakMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
    notifyListeners();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    if (_state == PomodoroState.work) {
      _completedPomodoros++;
      // Auto start break
      startBreak(isLong: _completedPomodoros % 4 == 0);
    } else {
      _state = PomodoroState.stopped;
    }
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _state = PomodoroState.stopped;
    _remainingSeconds = _workMinutes * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}