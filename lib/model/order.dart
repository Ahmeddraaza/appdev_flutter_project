import 'package:appdev_flutter_project/model/product.dart';

class Order {
  final String customerName;
  final List<Product> products;
  final double totalAmount;
  final DateTime createdAt;

  Order({
    required this.customerName,
    required this.products,
    required this.totalAmount,
    required this.createdAt,
  });

  // Factory method to create an Order object from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      customerName: json['customerName'] ?? '',
      products: (json['products'] as List)
          .map((product) => Product.fromJson(product))
          .toList(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Method to convert an Order object to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'products': products.map((product) => product.toJson()).toList(),
      'total_amount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
