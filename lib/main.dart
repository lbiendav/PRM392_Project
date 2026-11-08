import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';
import 'models/product_model.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/onboarding_screen.dart';
import 'views/home_catalog/category_menu_screen.dart';
import 'views/home_catalog/home_screen.dart';
import 'views/product_cart/cart_summary_sheet.dart';
import 'views/product_cart/product_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefsService.getInstance();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialize note: $e');
  }

  runApp(const ProviderScope(child: CoffeeCraftApp()));
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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return HomeScreen(
        onOpenCategory: (category) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CategoryMenuScreen(
                initialCategory: category,
                onOpenProduct: (product) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
            ),
          );
        },
        onOpenProduct: (ProductModel product) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        onOpenCart: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (_) => const CartSummarySheet(),
          );
        },
        onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
      );
    }

    if (!authState.hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    return const LoginScreen();
  }
}
