import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/validators.dart';
import '../../models/address_model.dart';
import 'checkout_data.dart';

class AddressManagementScreen extends ConsumerStatefulWidget {
  const AddressManagementScreen({super.key, this.isSelectMode = false});
  final bool isSelectMode;

  @override
  ConsumerState<AddressManagementScreen> createState() =>
      _AddressManagementState();
}

class _AddressManagementState extends ConsumerState<AddressManagementScreen> {
  bool _saving = false;

  Future<void> _save(
    String uid, {
    AddressModel? address,
    String? removeId,
    String? defaultId,
  }) async {
    if (_saving || ref.read(checkoutUserIdProvider) != uid) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(checkoutDataProvider)
          .updateAddress(
            uid,
            address: address,
            removeId: removeId,
            defaultId: defaultId,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu địa chỉ. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit(String uid, [AddressModel? existing]) async {
    final id = existing?.id ?? ref.read(checkoutDataProvider).newAddressId(uid);
    final result = await showDialog<AddressModel>(
      context: context,
      builder: (_) => _AddressForm(uid: uid, id: id, existing: existing),
    );
    if (mounted && result != null) await _save(uid, address: result);
  }

  Future<void> _delete(String uid, AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa địa chỉ?'),
        content: Text(address.fullAddress),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (mounted && confirmed == true) await _save(uid, removeId: address.id);
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(checkoutUserIdProvider);
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để quản lý địa chỉ.')),
      );
    }
    final addresses = ref.watch(checkoutAddressesProvider(uid));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelectMode ? 'Chọn địa chỉ' : 'Sổ địa chỉ'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _edit(uid),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Thêm địa chỉ'),
      ),
      body: addresses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(checkoutAddressesProvider(uid)),
            child: const Text('Không tải được địa chỉ. Thử lại'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Chưa có địa chỉ nhận hàng.'))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                children: [
                  if (_saving) const LinearProgressIndicator(),
                  for (final item in items)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          item.isDefault
                              ? Icons.star
                              : Icons.location_on_outlined,
                        ),
                        title: Text(
                          item.label + (item.isDefault ? ' · Mặc định' : ''),
                        ),
                        subtitle: Text(
                          [
                            item.recipientName,
                            item.recipientPhone,
                            item.fullAddress,
                          ].join('\n'),
                        ),
                        onTap: widget.isSelectMode && !_saving
                            ? () => Navigator.pop(context, item)
                            : null,
                        trailing: PopupMenuButton<String>(
                          enabled: !_saving,
                          onSelected: (action) async {
                            switch (action) {
                              case 'edit':
                                await _edit(uid, item);
                              case 'delete':
                                await _delete(uid, item);
                              case 'default':
                                await _save(uid, defaultId: item.id);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa'),
                            ),
                            if (!item.isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Đặt làm mặc định'),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  const _AddressForm({required this.uid, required this.id, this.existing});
  final String uid;
  final String id;
  final AddressModel? existing;

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _form = GlobalKey<FormState>();
  late final _label = TextEditingController(
    text: widget.existing?.label ?? 'Nhà riêng',
  );
  late final _name = TextEditingController(
    text: widget.existing?.recipientName,
  );
  late final _phone = TextEditingController(
    text: widget.existing?.recipientPhone,
  );
  late final _address = TextEditingController(
    text: widget.existing?.fullAddress,
  );

  @override
  void dispose() {
    _label.dispose();
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Vui lòng nhập thông tin' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Thêm địa chỉ' : 'Sửa địa chỉ'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _label,
                decoration: const InputDecoration(labelText: 'Tên gợi nhớ'),
                validator: _required,
              ),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Tên người nhận'),
                validator: AppValidators.validateFullName,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: AppValidators.validatePhoneNumber,
              ),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ chi tiết',
                ),
                maxLines: 2,
                validator: _required,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(
              context,
              AddressModel(
                id: widget.id,
                userId: widget.uid,
                label: _label.text.trim(),
                fullAddress: _address.text.trim(),
                recipientName: _name.text.trim(),
                recipientPhone: _phone.text.replaceAll(' ', ''),
              ),
            );
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
