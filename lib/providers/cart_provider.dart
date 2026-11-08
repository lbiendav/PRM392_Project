import 'package:flutter_riverpod/legacy.dart';
import '../models/order_model.dart';

class CartState {
  final List<OrderItemModel> items;

  const CartState({this.items = const []});

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  CartState copyWith({List<OrderItemModel>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(OrderItemModel item) {
    final items = [...state.items];
    final index = items.indexWhere(
      (current) => current.configurationKey == item.configurationKey,
    );
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + item.quantity,
      );
    }
    state = state.copyWith(items: items);
  }

  void removeItem(int index) {
    final list = [...state.items];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      state = state.copyWith(items: list);
    }
  }

  void clearCart() {
    state = const CartState(items: []);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
