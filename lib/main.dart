import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/services/fcm_service.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';
import 'views/auth/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo SharedPreferences instance dùng chung
  await SharedPrefsService.getInstance();

  // 2. Khởi tạo Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // 3. Khởi tạo FCM Service
    // await FCMService().initialize();
  } catch (e) {
    debugPrint('Firebase/FCM initialize note: $e');
  }

  runApp(
    const ProviderScope(
      child: CoffeeCraftApp(),
    ),
  );
}

class CoffeeCraftApp extends ConsumerWidget {
  const CoffeeCraftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // home: const WelcomeScreenPlaceholder(),
      home: const OnboardingScreen(),
    );
  }
}

/// Màn hình chờ kiểm tra môi trường ban đầu
/// Khi Thành viên 1 hoàn thành OnboardingScreen và LoginScreen theo file MD,
/// chỉ cần đổi `home: const WelcomeScreenPlaceholder()` thành `home: const AuthGate()` hoặc màn hình tương ứng.
class WelcomeScreenPlaceholder extends StatelessWidget {
  const WelcomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.coffee_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Cấu trúc Shared Core & Packages Đã Sẵn Sàng!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Các thư mục views/ của 5 thành viên đã được làm sạch và giữ nguyên cấu trúc package (.gitkeep).\n\nHãy mở file HUONG_DAN_MEMBER_1_AUTH.md để tiến hành code tay 5 màn hình của Thành viên 1!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimaryLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
