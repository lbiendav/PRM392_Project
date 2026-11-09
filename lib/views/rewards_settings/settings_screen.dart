import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import 'help_and_faq_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài Đặt Hệ Thống')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mục Giao diện Sáng / Tối
          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Giao diện Tối (Dark Mode)'),
              subtitle: Text(isDarkMode ? 'Đang bật' : 'Đang tắt'),
              value: isDarkMode,
              activeThumbColor: AppColors.primary,
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 12),

          // Nhận thông báo FCM
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.secondary),
              title: const Text('Thông báo đẩy (FCM)'),
              subtitle: const Text('Nhận tin ưu đãi và cập nhật đơn hàng'),
              value: _notificationsEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Ngôn ngữ
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_rounded, color: AppColors.primary),
              title: const Text('Ngôn ngữ'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'Tiếng Việt', child: Text('Tiếng Việt 🇻🇳')),
                  DropdownMenuItem(value: 'English', child: Text('English 🇺🇸')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Trợ giúp & FAQ
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
              title: const Text('Trung tâm Trợ giúp & Góp ý (FAQ)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HelpAndFAQScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}