import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Cài đặt'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Theme settings
          const _SectionHeader(title: '🎨 Giao diện'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Chế độ tối bảo vệ mắt'),
            secondary: const Icon(Icons.dark_mode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(),

          // Cloud Sync
          const _SectionHeader(title: '☁️ Đồng bộ'),
          SwitchListTile(
            title: const Text('Cloud Sync'),
            subtitle: Text(taskProvider.cloudSyncEnabled
                ? 'Đang đồng bộ với Firebase'
                : 'Chỉ lưu cục bộ'),
            secondary: const Icon(Icons.cloud),
            value: taskProvider.cloudSyncEnabled,
            onChanged: (_) => taskProvider.toggleCloudSync(),
          ),
          const Divider(),

          // Export/Import
          const _SectionHeader(title: '📤 Dữ liệu'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export dữ liệu'),
            subtitle: const Text('Xuất tất cả tasks ra file JSON'),
            onTap: () => _exportData(context, taskProvider),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import dữ liệu'),
            subtitle: const Text('Nhập tasks từ file JSON'),
            onTap: () => _importData(context, taskProvider),
          ),
          const Divider(),

          // About
          const _SectionHeader(title: 'ℹ️ Thông tin'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Về GTD Manager Pro'),
            subtitle: const Text('Version 2.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Hướng dẫn GTD'),
            onTap: () => _showGTDGuide(context),
          ),
          const Divider(),

          // Danger zone
          const _SectionHeader(title: '⚠️ Nguy hiểm'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Xóa tất cả dữ liệu', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Không thể hoàn tác'),
            onTap: () => _confirmDeleteAll(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, TaskProvider provider) async {
    try {
      final jsonData = provider.exportToJson();
      final fileName = 'gtd_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      await Share.shareXFiles(
        [XFile.fromData(jsonData.codeUnits, name: fileName, mimeType: 'application/json')],
        subject: 'GTD Manager Backup',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Export thành công!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, TaskProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        await provider.importFromJson(jsonString);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Import thành