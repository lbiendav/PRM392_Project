import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CheckoutPayment {
  cash('cod', 'Tiền mặt khi nhận hàng (COD)', Icons.payments_outlined),
  momo('momo', 'Ví MoMo (giả lập)', Icons.account_balance_wallet_outlined),
  zaloPay('zalopay', 'Ví ZaloPay (giả lập)', Icons.phone_android),
  card('credit_card', 'Thẻ ATM / Visa (giả lập)', Icons.credit_card);

  const CheckoutPayment(this.code, this.label, this.icon);
  final String code;
  final String label;
  final IconData icon;
}

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key, this.initial = CheckoutPayment.cash});
  final CheckoutPayment initial;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethodScreen> {
  final _form = GlobalKey<FormState>();
  late CheckoutPayment _payment = widget.initial;

  String? _cardNumber(String? input) {
    final value = input?.replaceAll(' ', '') ?? '';
    if (value != '4111111111111111') {
      return 'Dùng số thẻ mẫu 4111 1111 1111 1111';
    }
    return null;
  }

  String? _expiry(String? input) {
    final match = RegExp(
      r'^(0[1-9]|1[0-2])/(\d{2})$',
    ).firstMatch(input?.trim() ?? '');
    if (match == null) return 'Nhập ngày hết hạn theo MM/YY';
    final expiry = DateTime(
      2000 + int.parse(match[2]!),
      int.parse(match[1]!) + 1,
    );
    return expiry.isAfter(DateTime.now()) ? null : 'Thẻ đã hết hạn';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phương thức thanh toán')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final method in CheckoutPayment.values)
              Card(
                child: ListTile(
                  leading: Icon(method.icon),
                  title: Text(method.label),
                  selected: method == _payment,
                  trailing: Icon(
                    method == _payment
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () => setState(() => _payment = method),
                ),
              ),
            if (_payment == CheckoutPayment.card) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Thanh toán mô phỏng. Dùng số thẻ mẫu 4111 1111 1111 1111.',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số thẻ mẫu'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                validator: _cardNumber,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên chủ thẻ mẫu'),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => (value?.trim().length ?? 0) < 2
                    ? 'Nhập tên chủ thẻ mẫu'
                    : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Ngày hết hạn (MM/YY)',
                ),
                keyboardType: TextInputType.datetime,
                validator: _expiry,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (_form.currentState!.validate()) {
                  Navigator.pop(context, _payment);
                }
              },
              child: const Text('Xác nhận phương thức'),
            ),
          ],
        ),
      ),
    );
  }
}
