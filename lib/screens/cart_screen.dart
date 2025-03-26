import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.cartItems.isEmpty) {
            return Center(child: Text('Your cart is empty!'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = state.cartItems[index];
                    return ListTile(
                      leading: Image.network(item.product.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item.product.name),
                      subtitle: Text(
                        "Quantity: ${item.quantity} | Total: ₹${(item.product.finalPrice * item.quantity).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              BlocProvider.of<CartBloc>(context).add(RemoveFromCart(item.product));
                            },
                          ),
                          Text('${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () {
                              BlocProvider.of<CartBloc>(context).add(AddToCart(item.product));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Checkout Section
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Text("Amount Price", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("₹${state.totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Proceeding to checkout!'),
                          duration: Duration(seconds: 2),
                        ));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Check Out', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 5),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 12,
                            child: Text(
                              state.cartItems.length.toString(),
                              style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

