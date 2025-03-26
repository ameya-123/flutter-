import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_model.dart';

// Cart Events
abstract class CartEvent {}

class AddToCart extends CartEvent {
  final Product product;
  AddToCart(this.product);
}

class RemoveFromCart extends CartEvent {
  final Product product;
  RemoveFromCart(this.product);
}

// Cart Item Model
class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

// Cart State
class CartState {
  final List<CartItem> cartItems;
  final double totalPrice;

  CartState({required this.cartItems, required this.totalPrice});

  CartState copyWith({List<CartItem>? cartItems, double? totalPrice}) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

// Cart BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState(cartItems: [], totalPrice: 0.0)) {
    on<AddToCart>((event, emit) {
      List<CartItem> updatedCart = List.from(state.cartItems);
      int index = updatedCart.indexWhere((item) => item.product.id == event.product.id);

      if (index >= 0) {
        updatedCart[index].quantity++;
      } else {
        updatedCart.add(CartItem(product: event.product, quantity: 1));
      }

      double newTotalPrice = updatedCart.fold(0, (sum, item) => sum + (item.product.finalPrice * item.quantity));

      emit(state.copyWith(cartItems: updatedCart, totalPrice: newTotalPrice));
    });

    on<RemoveFromCart>((event, emit) {
      List<CartItem> updatedCart = List.from(state.cartItems);
      int index = updatedCart.indexWhere((item) => item.product.id == event.product.id);

      if (index >= 0) {
        if (updatedCart[index].quantity > 1) {
          updatedCart[index].quantity--;
        } else {
          updatedCart.removeAt(index);
        }
      }

      double newTotalPrice = updatedCart.fold(0, (sum, item) => sum + (item.product.finalPrice * item.quantity));

      emit(state.copyWith(cartItems: updatedCart, totalPrice: newTotalPrice));
    });
  }
}
