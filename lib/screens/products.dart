import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductScreen extends StatefulWidget {
  final String token;

  const ProductScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _prodIdController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;

  final String baseUrl = 'http://10.0.2.2:3001/products';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/findproducts'),
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
        _isLoading = false;
      });
    }
  }

  Future<void> _addProduct() async {
    final body = {
      'prod_id': _prodIdController.text.trim(),
      'Product_name': _productNameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'image': _imageController.text.trim(),
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addproducts'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Product added successfully!', Colors.green);
        _fetchProducts();
        _clearFields();
      } else {
        _showSnackBar('Failed to add product', Colors.red);
      }
    } catch (error) {
      _showSnackBar('An error occurred: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(String prodId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$prodId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        _showSnackBar('Product deleted successfully', Colors.green);
        _fetchProducts();
      } else {
        _showSnackBar('Failed to delete product', Colors.red);
      }
    } catch (error) {
      _showSnackBar('An error occurred: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    _prodIdController.clear();
    _productNameController.clear();
    _priceController.clear();
    _imageController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _findProductById() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _fetchProducts();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/findproduct/$query'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _products = [responseData['data']];
        });
      } else {
        _showSnackBar('Product not found', Colors.red);
      }
    } catch (error) {
      _showSnackBar('An error occurred: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8FC),
        elevation: 1,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.purple))
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductTile(product);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search Product',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                _findProductById();
              },
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A5AF8
            ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildProductTile(Map<String, dynamic> product) {
  final isInStock = (product['quantity'] ?? 0) > 0;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 255, 255, 255),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 5,
        ),
      ],
    ),
    child: Stack(
      children: [
        // Center content: image, name, and price
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              product['image'] ?? '',
              width: 400,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error,
                size: 50,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product['Product_name'] ?? 'Unknown',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),

        // Stock label
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isInStock ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              isInStock ? 'In Stock' : 'Out of Stock',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Trash icon
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey, size: 24),
            onPressed: () => _confirmDelete(product['prod_id']),
          ),
        ),
      ],
    ),
  );
}

void _confirmDelete(String prodId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteProduct(prodId);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

  Future<void> _showAddProductDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _prodIdController,
                decoration: const InputDecoration(labelText: 'Product ID'),
              ),
              TextField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _categoryNameController,
                decoration: const InputDecoration(labelText: 'Category'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addProduct();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
