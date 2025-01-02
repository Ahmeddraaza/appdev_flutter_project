import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateOrderScreen extends StatefulWidget {
  final String token;

  const CreateOrderScreen({Key? key, required this.token}) : super(key: key);

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  Map<String, int> _selectedProducts = {}; // Use String for prod_id as key
  bool _isLoadingProducts = false;
  bool _isSubmittingOrder = false;

  final String baseUrl = 'http://10.0.2.2:3001/order';
  final String baseUrl1 = 'http://10.0.2.2:3001/products';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl1/findproducts'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _products = List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        });
      } else {
        _showSnackBar('Failed to fetch products', Colors.red);
      }
    } catch (error) {
      _showSnackBar('An error occurred: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _submitOrder() async {
    final customerName = _customerNameController.text.trim();

    if (customerName.isEmpty || _selectedProducts.isEmpty) {
      _showSnackBar("Please fill all fields and add products.", Colors.red);
      return;
    }

    final List<Map<String, dynamic>> products = _selectedProducts.entries
    .map((entry) => {
          "id": entry.key, // Key is the product ID
          "quantity": entry.value,
        })
    .toList();

final orderBody = {
  "customerName": customerName,
  "products": products,
};

print(orderBody); // Debugging log to check the payload


    setState(() {
      _isSubmittingOrder = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addOrder'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderBody),
      );

      if (response.statusCode == 201) {
        _showSnackBar("Order created successfully!", Colors.green);
        setState(() {
          _selectedProducts = {};
          _customerNameController.clear();
        });
      } else {
        _showSnackBar("Failed to create order.", Colors.red);
      }
    } catch (error) {
      _showSnackBar('An error occurred: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isSubmittingOrder = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8FC),
        elevation: 1,
        title: const Text(
          'Create Order',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Name Input
                    const Text(
                      "Customer Name",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        hintText: "Enter customer name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product List
                    const Text(
                      "Select Products",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          color: Colors.white,
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['Product_name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("\$${product['price']}"),
                                  ],
                                ),
                              Row(
  children: [
    IconButton(
      onPressed: () {
        setState(() {
          final productId = product['prod_id'].toString(); // Convert to String
          if (_selectedProducts.containsKey(productId)) {
            if (_selectedProducts[productId]! > 1) {
              _selectedProducts[productId] = _selectedProducts[productId]! - 1;
            } else {
              _selectedProducts.remove(productId);
            }
          }
        });
      },
      icon: const Icon(Icons.remove_circle, color: Colors.red),
    ),
    Text(
      _selectedProducts[product['prod_id'].toString()]?.toString() ?? "0", // Convert to String
      style: const TextStyle(fontSize: 16),
    ),
    IconButton(
      onPressed: () {
        setState(() {
          final productId = product['prod_id'].toString(); // Convert to String
          _selectedProducts[productId] = (_selectedProducts[productId] ?? 0) + 1;
        });
      },
      icon: const Icon(Icons.add_circle, color: Colors.green),
    ),
  ],
),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmittingOrder ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9278F9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmittingOrder
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Create Order",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
