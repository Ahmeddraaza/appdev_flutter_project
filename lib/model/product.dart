class Product {
  final String prodId;
  final String productName;
  final String? productBrand; // Optional field
  final int quantity;
  final double price;
  final DateTime createdAt;

  Product({
    required this.prodId,
    required this.productName,
    this.productBrand,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  // Factory method to create a Product object from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      prodId: json['prod_id'] ?? '',
      productName: json['Product_name'] ?? '',
      productBrand: json['Product_Brand'], // Optional field
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(), // Ensure price is a double
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Method to convert a Product object to JSON
  Map<String, dynamic> toJson() {
    return {
      'prod_id': prodId,
      'Product_name': productName,
      'Product_Brand': productBrand,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
