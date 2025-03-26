import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import '../bloc/cart_bloc.dart';
import '../models/product_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  int currentPage = 1;
  final int limit = 10;
  int totalProducts = 0;
  int totalPages = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);

    final response = await http.get(Uri.parse(
        'https://dummyjson.com/products?limit=$limit&skip=${(currentPage - 1) * limit}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Product> newProducts =
      (data['products'] as List).map((e) => Product.fromJson(e)).toList();

      setState(() {
        products = newProducts;
        totalProducts = data['total'];
        totalPages = (totalProducts / limit).ceil();
      });
    }
    setState(() => isLoading = false);
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() => currentPage = page);
      fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catalogue'),
        backgroundColor: Colors.pink[100],
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              int itemCount =
              state.cartItems.fold(0, (sum, item) => sum + item.quantity);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart, size: 28),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: badges.Badge(
                        badgeContent: Text(
                          itemCount.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.red,
                          padding: EdgeInsets.all(6),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 products per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7, // Adjust height ratio
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: Image.network(
                            product.thumbnail,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(product.brand,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "₹${product.finalPrice.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "${product.discountPercentage.toStringAsFixed(1)}% OFF",
                                      style: TextStyle(
                                          color: Colors.pink,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                  ),
                                  onPressed: () {
                                    BlocProvider.of<CartBloc>(context,
                                        listen: false)
                                        .add(AddToCart(product));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "${product.name} added to cart"),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Text('Add',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          buildPagination(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildPagination() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enable scrolling for large page numbers
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Page Button
          IconButton(
            onPressed: currentPage > 1 ? () => goToPage(currentPage - 1) : null,
            icon: Icon(Icons.chevron_left),
          ),

          // Page Number Buttons with Limit
          for (int i = 1; i <= totalPages; i++)
            if (i == 1 ||
                i == totalPages ||
                (i >= currentPage - 2 && i <= currentPage + 2))
              GestureDetector(
                onTap: () => goToPage(i),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentPage == i ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    i.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: currentPage == i ? Colors.white : Colors.blue,
                    ),
                  ),
                ),
              )
            else if (i == currentPage - 3 || i == currentPage + 3)
              Text("..."), // Add ellipsis for skipped numbers

          // Next Page Button
          IconButton(
            onPressed:
            currentPage < totalPages ? () => goToPage(currentPage + 1) : null,
            icon: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
