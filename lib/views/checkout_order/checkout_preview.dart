import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/shared_prefs_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../firebase_options.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../repositories/product_repository.dart';
import '../auth/login_screen.dart';
import 'address_management_screen.dart';
import 'checkout_data.dart';
import 'checkout_notifications.dart';
import 'checkout_screen.dart';
import 'order_history_screen.dart';
import 'order_tracking_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsService.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: _CheckoutPreview()));
}

class _CheckoutPreview extends ConsumerWidget {
  const _CheckoutPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'CoffeeCraft Checkout',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      home: const _PreviewGate(),
    );
  }
}

class _PreviewGate extends ConsumerWidget {
  const _PreviewGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    if (auth.isLoading && auth.firebaseUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = auth.firebaseUser?.uid;
    return uid == null
        ? const LoginScreen()
        : _PreviewHome(key: ValueKey(uid), uid: uid);
  }
}

class _PreviewHome extends ConsumerStatefulWidget {
  const _PreviewHome({super.key, required this.uid});
  final String uid;

  @override
  ConsumerState<_PreviewHome> createState() => _PreviewHomeState();
}

class _PreviewHomeState extends ConsumerState<_PreviewHome> {
  late final _notifications = CheckoutNotifications(widget.uid);
  late Future<List<ProductModel>> _products;
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<RemoteMessage>? _foreground;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _products = ProductRepository().getProducts();
    if (CheckoutNotifications.supported) {
      unawaited(_notifications.start());
      _opened = FirebaseMessaging.onMessageOpenedApp.listen(_openOrder);
      _foreground = FirebaseMessaging.onMessage.listen((message) {
        if (message.data['type'] != 'checkout_order_status' || !mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.notification?.body ?? 'Đơn hàng có cập nhật mới.',
            ),
            action: SnackBarAction(
              label: 'Xem',
              onPressed: () => _openOrder(message),
            ),
          ),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final initial = await FirebaseMessaging.instance.getInitialMessage();
        if (initial != null) _openOrder(initial);
      });
    }
  }

  @override
  void dispose() {
    unawaited(_opened?.cancel());
    unawaited(_foreground?.cancel());
    unawaited(_notifications.close());
    super.dispose();
  }

  void _openOrder(RemoteMessage message) {
    if (!mounted || ref.read(checkoutUserIdProvider) != widget.uid) return;
    final id = message.data['orderId'];
    if (message.data['type'] == 'checkout_order_status' &&
        id is String &&
        id.isNotEmpty &&
        !id.contains('/')) {
      _open(OrderTrackingScreen(orderId: id));
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await _notifications.close(unregister: true);
      if (!mounted) return;
      ref.read(cartProvider.notifier).clearCart();
      await ref.read(authNotifierProvider.notifier).logout();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đăng xuất. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout · Thành viên 4'),
        actions: [
          IconButton(
            tooltip: 'Sổ địa chỉ',
            onPressed: () => _open(const AddressManagementScreen()),
            icon: const Icon(Icons.location_on_outlined),
          ),
          IconButton(
            tooltip: 'Lịch sử đơn hàng',
            onPressed: () => _open(const OrderHistoryScreen()),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: _loggingOut ? null : _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(
                  () => _products = ProductRepository().getProducts(),
                ),
                child: const Text('Không tải được sản phẩm. Thử lại'),
              ),
            );
          }
          final items = snapshot.data!
              .where((item) => item.isAvailable)
              .toList();
          if (items.isEmpty) {
            return const Center(
              child: Text('Chưa có sản phẩm trong Firestore.'),
            );
          }
          return ListView(
            children: [
              for (final item in items)
                ListTile(
                  title: Text(item.name),
                  subtitle: Text(AppFormatters.formatCurrency(item.price)),
                  trailing: IconButton(
                    tooltip: 'Thêm vào giỏ thử',
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => ref
                        .read(cartProvider.notifier)
                        .addItem(
                          OrderItemModel(
                            productId: item.id,
                            productName: item.name,
                            imageUrl: item.imageUrl,
                            price: item.price,
                            size: item.sizes.contains('M')
                                ? 'M'
                                : item.sizes.firstOrNull ?? 'M',
                            quantity: 1,
                          ),
                        ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: cart.items.isEmpty
              ? null
              : () => _open(const CheckoutScreen()),
          icon: const Icon(Icons.shopping_cart_checkout),
          label: Text('Đặt hàng (${cart.totalItemCount} món)'),
        ),
      ),
    );
  }
}
