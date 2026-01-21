import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/task_provider.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pomodoro = Provider.of<PomodoroProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('⏱️ Pomodoro Timer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPomodoroInfo(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer Display
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(pomodoro.state, isDark),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getGradientColors(pomodoro.state, isDark)[0].withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pomodoro.displayTime,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStateLabel(pomodoro.state),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!pomodoro.isRunning && pomodoro.state == PomodoroState.stopped)
                    ElevatedButton.icon(
                      onPressed: () => pomodoro.startWork(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Bắt đầu'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),

                  if (pomodoro.isRunning) ...[
                    ElevatedButton.icon(
                      onPressed: () => pomodoro.pauseTimer(),
                      icon: const Icon(Icons.pause),
                      label: const Text('Tạm dừng'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => pomodoro.resetTimer(),
                      icon: const Icon(Icons.stop),
                      label: const Text('Dừng'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],

                  if (!pomodoro.isRunning && pomodoro.state != PomodoroState.stopped)
                    ElevatedButton.icon(
                      onPressed: () => pomodoro.startWork(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Tiếp tục'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('📊 Thống kê hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat('🍅', pomodoro.completedPomodoros.toString(), 'Pomodoro'),
                          _buildStat('⏰', '${pomodoro.completedPomodoros * 25}', 'Phút'),
                          _buildStat('☕', '${(pomodoro.completedPomodoros / 4).floor()}', 'Nghỉ dài'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions
              const Text('⚡ Nhanh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: () => pomodoro.startBreak(isLong: false),
                    child: const Text('Nghỉ ngắn (5 phút)'),
                  ),
                  OutlinedButton(
                    onPressed: () => pomodoro.startBreak(isLong: true),
                    child: const Text('Nghỉ dài (15 phút)'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  List<Color> _getGradientColors(PomodoroState state, bool isDark) {
    switch (state) {
      case PomodoroState.work:
        return [Colors.red.shade400, Colors.red.shade700];
      case PomodoroState.shortBreak:
        return [Colors.green.shade400, Colors.green.shade700];
      case PomodoroState.longBreak:
        return [Colors.blue.shade400, Colors.blue.shade700];
      case PomodoroState.stopped:
        return isDark ? [Colors.grey.shade700, Colors.grey.shade900] : [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  String _getStateLabel(PomodoroState state) {
    switch (state) {
      case PomodoroState.work: return 'Làm việc';
      case PomodoroState.shortBreak: return 'Nghỉ ngắn';
      case PomodoroState.longBreak: return 'Nghỉ dài';
      case PomodoroState.stopped: return 'Sẵn sàng';
    }
  }

  void _showPomodoroInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍅 Pomodoro Technique'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kỹ thuật Pomodoro giúp tăng năng suất:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1️⃣ Làm việc tập trung 25 phút'),
              Text('2️⃣ Nghỉ ngắn 5 phút'),
              Text('3️⃣ Sau 4 Pomodoro, nghỉ dài 15 phút'),
              SizedBox(height: 12),
              Text('💡 Lợi ích:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Tăng sự tập trung'),
              Text('• Giảm căng thẳng'),
              Text('• Quản lý thời gian hiệu quả'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }
}