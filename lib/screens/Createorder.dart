import 'package:appdev_flutter_project/Create_Order/create_order_bloc.dart';
import 'package:appdev_flutter_project/Create_Order/create_order_event.dart';
import 'package:appdev_flutter_project/Create_Order/create_order_state.dart';
import 'package:appdev_flutter_project/screens/NavigationWrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateOrderScreen extends StatelessWidget {
  final String token;
  final String userId;

  const CreateOrderScreen({Key? key, required this.token, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateOrderBloc(token: token)..add(FetchProductsEvent()),
      child: CreateOrderView(token: token, userId: userId),
    );
  }
}

class CreateOrderView extends StatelessWidget {
  final String token;
  final String userId;

  const CreateOrderView({Key? key, required this.token, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customerNameController = TextEditingController();

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
        title: const Text(
          'Create Order',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      body: BlocConsumer<CreateOrderBloc, CreateOrderState>(
        listener: (context, state) {
          if (state is CreateOrderSuccessState) {
            // Show success message
            _showSnackBar(context, "Order created successfully!", Colors.green);

            // Clear selected products and customer name
            customerNameController.clear();
            BlocProvider.of<CreateOrderBloc>(context).add(FetchProductsEvent());
          } else if (state is CreateOrderErrorState) {
            _showSnackBar(context, state.error, Colors.red);
            customerNameController.clear();
            BlocProvider.of<CreateOrderBloc>(context).add(FetchProductsEvent());
          }
        },
        builder: (context, state) {
          if (state is CreateOrderLoadingState) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          } else if (state is CreateOrderLoadedState) {
            return SingleChildScrollView(
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
                      controller: customerNameController,
                      decoration: InputDecoration(
                        hintText: "Enter customer name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Create Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (customerNameController.text.trim().isEmpty || state.selectedProducts.isEmpty) {
                            _showSnackBar(context, "Please fill all fields and add products.", Colors.red);
                            return;
                          }
                          BlocProvider.of<CreateOrderBloc>(context).add(
                            SubmitOrderEvent(
                              customerNameController.text.trim(),
                              state.selectedProducts,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9278F9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Create Order",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
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
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        final productId = product['prod_id'];
                        final quantity = state.selectedProducts[productId] ?? 0;

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
                                        BlocProvider.of<CreateOrderBloc>(context).add(
                                          UpdateSelectedProductEvent(productId, -1),
                                        );
                                      },
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    ),
                                    Text(
                                      quantity.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        BlocProvider.of<CreateOrderBloc>(context).add(
                                          UpdateSelectedProductEvent(productId, 1),
                                        );
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
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
