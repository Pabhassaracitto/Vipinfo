import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final stats = provider.weeklyStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Dashboard & Analytics'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklySummary(stats),
            const SizedBox(height: 24),
            _buildCategoryChart(provider),
            const SizedBox(height: 24),
            _buildCompletionChart(provider),
            const SizedBox(height: 24),
            _buildProductivityInsights(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📅 Tuần này', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCard('Hoàn thành', stats['completed'].toString(), Colors.green),
                _statCard('Tạo mới', stats['created'].toString(), Colors.blue),
                _statCard('Năng suất', '${stats['productivity']}%', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryChart(TaskProvider provider) {
    final counts = provider.taskCounts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📂 Phân bố theo danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: TaskCategory.values.map((cat) {
                    final count = counts[cat] ?? 0;
                    return PieChartSectionData(
                      value: count.toDouble(),
                      title: count > 0 ? count.toString() : '',
                      color: _getCategoryColor(cat),
                      radius: 50,
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionChart(TaskProvider provider) {
    final last7Days = List.generate(7, (i) => DateTime.now