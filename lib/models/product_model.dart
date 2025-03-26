import 'dart:convert'; // Import for handling JSON data

class Product {
  final int id;
  final String name;
  final double price;
  final String thumbnail; // Image URL field
  final double discountPercentage;
  final double finalPrice; // Price after discount
  final String brand; // Added brand field

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.thumbnail, // Include image URL
    required this.discountPercentage,
    required this.finalPrice,
    required this.brand, // New field
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double originalPrice = (json['price'] as num).toDouble();
    double discount = (json['discountPercentage'] as num).toDouble();
    double discountedPrice = originalPrice - (originalPrice * discount / 100);

    return Product(
      id: json['id'],
      name: json['title'],
      price: originalPrice,
      thumbnail: json['thumbnail'], // Fetch image from API
      discountPercentage: discount,
      finalPrice: discountedPrice,
      brand: json['brand'] ?? "Unknown", // Handle missing brand field
    );
  }

  // Convert Product to JSON (if needed for saving data)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'price': price,
      'thumbnail': thumbnail,
      'discountPercentage': discountPercentage,
      'finalPrice': finalPrice,
      'brand': brand, // Include brand
    };
  }
}
