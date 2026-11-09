import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    state = state.copyWith(items: [...state.items, item]);
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= state.items.length) return;

    if (quantity <= 0) {
      removeItem(index);
      return;
    }

    final list = [...state.items];
    list[index] = list[index].copyWith(quantity: quantity);
    state = state.copyWith(items: list);
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
