import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Product/product_bloc.dart';
import '../Product/product_event.dart';
import '../Product/product_state.dart';
import 'NavigationWrapper.dart';

class ProductScreen extends StatelessWidget {
  final String token;
  final String userId;

  const ProductScreen({Key? key, required this.token, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(token: token)..add(FetchProductsEvent()),
      child: ProductScreenView(token: token, userId: userId),
    );
  }
}

class ProductScreenView extends StatelessWidget {
  final String token;
  final String userId;

  const ProductScreenView({Key? key, required this.token, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8FC),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationWrapper(userId: userId, token: token),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text('Products', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.purple),
                  );
                } else if (state is ProductLoadedState) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return _buildProductTile(context, product);
                    },
                  );
                } else if (state is ProductErrorState) {
                  return Center(
                    child: Text(state.error, style: const TextStyle(color: Colors.red)),
                  );
                }
                return const Center(child: Text('No products available'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
  final TextEditingController searchController = TextEditingController();

  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: 'Search Product',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                // Fetch all products when search is cleared
                BlocProvider.of<ProductBloc>(context).add(FetchProductsEvent());
              } else {
                // Perform the search
                BlocProvider.of<ProductBloc>(context).add(SearchProductEvent(value));
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => _showAddProductDialog(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A5AF8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildProductTile(BuildContext context, Map<String, dynamic> product) {
    final isInStock = (product['quantity'] ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey, size: 24),
              onPressed: () {
                BlocProvider.of<ProductBloc>(context).add(DeleteProductEvent(product['prod_id']));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
  final TextEditingController prodIdController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController QuantityController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Add Product'),
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: prodIdController,
              decoration: const InputDecoration(labelText: 'Product ID'),
            ),
            TextField(
              controller: productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: QuantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Use the original context where BlocProvider is accessible
            BlocProvider.of<ProductBloc>(context).add(
              AddProductEvent({
                'prod_id': prodIdController.text.trim(),
                'Product_name': productNameController.text.trim(),
                'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                'quantity': double.tryParse(QuantityController.text.trim()) ?? 0.0,
                'image': imageController.text.trim(),
              }),
            );
            Navigator.pop(dialogContext);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
}