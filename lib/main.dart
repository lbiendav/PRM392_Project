import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'models/product_model.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/onboarding_screen.dart';
import 'views/auth/profile_screen.dart';
import 'views/checkout_order/checkout_data.dart';
import 'views/checkout_order/checkout_notifications.dart';
import 'views/checkout_order/order_history_screen.dart';
import 'views/checkout_order/order_tracking_screen.dart';
import 'views/home_catalog/category_menu_screen.dart';
import 'views/home_catalog/home_screen.dart';
import 'views/home_catalog/search_screen.dart';
import 'views/home_catalog/store_branch_screen.dart';
import 'views/product_cart/cart_screen.dart';
import 'views/product_cart/favorites_screen.dart';
import 'views/product_cart/product_detail_screen.dart';
import 'views/rewards_settings/loyalty_rewards_screen.dart';
import 'views/rewards_settings/notification_center_screen.dart';

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

    if (authState.isLoading && authState.firebaseUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (authState.isAuthenticated) {
      final uid = authState.firebaseUser!.uid;
      return MainNavigationScreen(key: ValueKey(uid), uid: uid);
    }

    if (!authState.hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    return const LoginScreen();
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  final String uid;

  const MainNavigationScreen({super.key, required this.uid});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final CheckoutNotifications _notifications = CheckoutNotifications(
    widget.uid,
  );
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  @override
  void initState() {
    super.initState();
    if (CheckoutNotifications.supported) {
      unawaited(_notifications.start());
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleOrderPush,
      );
      _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
        if (message.data['type'] != 'checkout_order_status' || !mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.notification?.body ?? 'Đơn hàng của bạn có cập nhật mới.',
            ),
            action: SnackBarAction(
              label: 'Xem',
              onPressed: () => _handleOrderPush(message),
            ),
          ),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final initial = await FirebaseMessaging.instance.getInitialMessage();
        if (initial != null) _handleOrderPush(initial);
      });
    }
  }

  @override
  void dispose() {
    unawaited(_openedSub?.cancel());
    unawaited(_foregroundSub?.cancel());
    unawaited(_notifications.close());
    super.dispose();
  }

  void _handleOrderPush(RemoteMessage message) {
    if (!mounted || ref.read(checkoutUserIdProvider) != widget.uid) return;
    final id = message.data['orderId'];
    if (message.data['type'] == 'checkout_order_status' &&
        id is String &&
        id.isNotEmpty &&
        !id.contains('/')) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderTrackingScreen(orderId: id),
        ),
      );
    }
  }

  void _openProduct(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await _notifications.close(unregister: true);
    if (!mounted) return;
    ref.read(cartProvider.notifier).clearCart();
    await ref.read(authNotifierProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onOpenSearch: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SearchScreen(onOpenProduct: _openProduct),
          ),
        ),
        onOpenBranch: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const StoreBranchScreen()),
        ),
        onOpenCategory: (category) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CategoryMenuScreen(
                initialCategory: category,
                onOpenProduct: _openProduct,
              ),
            ),
          );
        },
        onOpenProduct: _openProduct,
        onOpenFavorites: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const FavoritesScreen())),
        onOpenNotifications: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const NotificationCenterScreen(),
          ),
        ),
        onOpenCart: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CartScreen())),
      ),
      CategoryMenuScreen(initialCategory: 'all', onOpenProduct: _openProduct),
      const OrderHistoryScreen(),
      const LoyaltyRewardsScreen(),
      ProfileScreen(onLogout: _handleLogout),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_cafe_outlined),
            selectedIcon: Icon(Icons.local_cafe),
            label: 'Thực đơn',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard),
            label: 'Ưu đãi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
