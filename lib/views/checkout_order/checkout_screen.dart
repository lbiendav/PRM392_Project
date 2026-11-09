import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../models/address_model.dart';
import '../../models/order_model.dart';
import '../../models/voucher_model.dart';
import '../../providers/cart_provider.dart';
import 'address_management_screen.dart';
import 'checkout_data.dart';
import 'order_tracking_screen.dart';
import 'payment_method_screen.dart';
import '../rewards_settings/voucher_wallet_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutState();
}

class _CheckoutState extends ConsumerState<CheckoutScreen> {
  final _voucherCode = TextEditingController();
  bool _delivery = true;
  bool _placingOrder = false;
  bool _checkingVoucher = false;
  String? _selectedAddressId;
  VoucherModel? _voucher;
  CheckoutPayment _payment = CheckoutPayment.cash;

  double get _shipping => _delivery ? 18000 : 0;

  @override
  void dispose() {
    _voucherCode.dispose();
    super.dispose();
  }

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _chooseAddress() async {
    final address = await Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(
        builder: (_) => const AddressManagementScreen(isSelectMode: true),
      ),
    );
    if (mounted && address != null) {
      setState(() => _selectedAddressId = address.id);
    }
  }

  Future<void> _choosePayment() async {
    final payment = await Navigator.of(context).push<CheckoutPayment>(
      MaterialPageRoute(builder: (_) => PaymentMethodScreen(initial: _payment)),
    );
    if (mounted && payment != null) setState(() => _payment = payment);
  }

  Future<void> _chooseVoucherFromWallet() async {
    final selected = await Navigator.of(context).push<VoucherModel>(
      MaterialPageRoute(
        builder: (_) => const VoucherWalletScreen(isSelectMode: true),
      ),
    );
    if (mounted && selected != null) {
      setState(() {
        _voucherCode.text = selected.code;
        _voucher = selected;
      });
    }
  }

  Future<void> _applyVoucher() async {
    final code = _voucherCode.text.trim();
    if (code.isEmpty || _checkingVoucher) return;
    setState(() => _checkingVoucher = true);
    try {
      final voucher = await ref.read(checkoutDataProvider).findVoucher(code);
      if (!mounted) return;
      setState(() => _voucher = voucher);
      if (voucher == null) _notice('Mã giảm giá không hợp lệ hoặc đã hết hạn.');
    } catch (_) {
      if (mounted) _notice('Không thể kiểm tra mã giảm giá. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _checkingVoucher = false);
    }
  }

  Future<void> _placeOrder(
    String uid,
    AddressModel? address,
    double shownDiscount,
  ) async {
    if (_placingOrder ||
        _checkingVoucher ||
        ref.read(checkoutUserIdProvider) != uid) {
      return;
    }
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty || (_delivery && address == null)) return;
    final shipping = _shipping;
    final voucher = _voucher;
    final data = ref.read(checkoutDataProvider);
    setState(() => _placingOrder = true);

    try {
      final currentVoucher = voucher == null
          ? null
          : await data.findVoucher(voucher.code);
      if (!mounted || ref.read(checkoutUserIdProvider) != uid) return;
      final discount = checkoutDiscount(
        currentVoucher,
        cart.subtotal,
        shipping,
      );
      if (discount != shownDiscount) {
        setState(() => _voucher = currentVoucher);
        _notice('Ưu đãi đã thay đổi. Vui lòng kiểm tra lại tổng tiền.');
        return;
      }

      final orderId = await data.createOrder(
        OrderModel(
          id: '',
          userId: uid,
          items: cart.items,
          subtotal: cart.subtotal,
          shippingFee: shipping,
          discountAmount: discount,
          totalAmount: cart.subtotal + shipping - discount,
          deliveryType: _delivery ? 'delivery' : 'pickup',
          shippingAddress: _delivery ? address!.fullAddress : '',
          recipientName: _delivery ? address!.recipientName : '',
          recipientPhone: _delivery ? address!.recipientPhone : '',
          paymentMethod: _payment.code,
        ),
      );

      if (!mounted || ref.read(checkoutUserIdProvider) != uid) return;
      final latest = ref.read(cartProvider);
      final notifier = ref.read(cartProvider.notifier);
      if (identical(latest.items, cart.items)) {
        notifier.clearCart();
      } else {
        final purchased = List.of(cart.items);
        for (var index = latest.items.length - 1; index >= 0; index--) {
          final match = purchased.indexOf(latest.items[index]);
          if (match != -1) {
            purchased.removeAt(match);
            notifier.removeItem(index);
          }
        }
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OrderTrackingScreen(orderId: orderId),
        ),
      );
    } catch (_) {
      if (mounted) _notice('Không thể đặt hàng. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(checkoutUserIdProvider);
    final cart = ref.watch(cartProvider);
    final addresses = uid == null
        ? null
        : ref.watch(checkoutAddressesProvider(uid)).asData?.value;
    final address =
        addresses?.where((item) => item.id == _selectedAddressId).firstOrNull ??
        addresses?.where((item) => item.isDefault).firstOrNull;
    final discount = checkoutDiscount(_voucher, cart.subtotal, _shipping);
    final total = cart.subtotal + _shipping - discount;
    final canSubmit =
        uid != null &&
        cart.items.isNotEmpty &&
        (!_delivery || address != null) &&
        !_placingOrder &&
        !_checkingVoucher;

    return PopScope(
      canPop: !_placingOrder,
      child: Scaffold(
        appBar: AppBar(title: const Text('Xác nhận đặt hàng')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Giao tận nơi'),
                  icon: Icon(Icons.delivery_dining),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Lấy tại quán'),
                  icon: Icon(Icons.storefront),
                ),
              ],
              selected: {_delivery},
              onSelectionChanged: _placingOrder
                  ? null
                  : (value) => setState(() => _delivery = value.single),
            ),
            const SizedBox(height: 16),
            if (_delivery)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    address?.recipientName ?? 'Chọn địa chỉ giao hàng',
                  ),
                  subtitle: address == null
                      ? null
                      : Text(
                          '${address.recipientPhone}\n${address.fullAddress}',
                        ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _placingOrder || uid == null ? null : _chooseAddress,
                ),
              ),
            Card(
              child: ListTile(
                leading: Icon(_payment.icon),
                title: Text(_payment.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: _placingOrder ? null : _choosePayment,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherCode,
                    enabled: !_placingOrder && !_checkingVoucher,
                    decoration: InputDecoration(
                      labelText: 'Mã giảm giá',
                      suffixIcon: IconButton(
                        tooltip: 'Chọn từ Ví khuyến mãi',
                        onPressed: _placingOrder || _checkingVoucher
                            ? null
                            : _chooseVoucherFromWallet,
                        icon: const Icon(Icons.confirmation_number_outlined),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) {
                      if (_voucher != null) setState(() => _voucher = null);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _placingOrder || _checkingVoucher || uid == null
                      ? null
                      : _applyVoucher,
                  child: Text(_checkingVoucher ? 'Đang kiểm tra…' : 'Áp dụng'),
                ),
              ],
            ),
            if (_voucher != null)
              Text(
                discount > 0
                    ? _voucher!.title
                    : 'Mã giảm giá chưa đủ điều kiện cho đơn này.',
              ),
            const SizedBox(height: 16),
            for (final item in cart.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.productName),
                subtitle: Text('Size ${item.size} × ${item.quantity}'),
                trailing: Text(
                  AppFormatters.formatCurrency(item.price * item.quantity),
                ),
              ),
            _amount('Tiền hàng', cart.subtotal),
            _amount('Phí giao hàng', _shipping),
            _amount('Giảm giá', -discount),
            const Divider(),
            _amount('Tổng thanh toán', total),
            if (uid == null) const Text('Vui lòng đăng nhập để đặt hàng.'),
            if (cart.items.isEmpty) const Text('Giỏ hàng đang trống.'),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: canSubmit
                ? () => _placeOrder(uid, address, discount)
                : null,
            child: Text(_placingOrder ? 'Đang gửi đơn…' : 'Xác nhận đặt hàng'),
          ),
        ),
      ),
    );
  }

  Widget _amount(String label, double amount) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: Text(AppFormatters.formatCurrency(amount)),
  );
}
