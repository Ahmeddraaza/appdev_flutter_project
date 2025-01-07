import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final String token;
  final String baseUrl = 'http://10.0.2.2:3001/products';

  ProductBloc({required this.token}) : super(ProductInitialState()) {
    on<FetchProductsEvent>(_fetchProducts);
    on<AddProductEvent>(_addProduct);
    on<DeleteProductEvent>(_deleteProduct);
    on<SearchProductEvent>(_searchProduct);
  }

  Future<void> _fetchProducts(
      FetchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/findproducts'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        emit(ProductLoadedState(
          List<Map<String, dynamic>>.from(responseData['data'] ?? []),
        ));
      } else {
        emit(ProductErrorState('Failed to fetch products'));
      }
    } catch (error) {
      emit(ProductErrorState('An error occurred: ${error.toString()}'));
    }
  }

  Future<void> _addProduct(
      AddProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addproducts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(event.product),
      );

      if (response.statusCode == 200) {
        add(FetchProductsEvent());
      } else {
        emit(ProductErrorState('Failed to add product'));
      }
    } catch (error) {
      emit(ProductErrorState('An error occurred: ${error.toString()}'));
    }
  }

  Future<void> _deleteProduct(
      DeleteProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/${event.productId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        add(FetchProductsEvent());
      } else {
        emit(ProductErrorState('Failed to delete product'));
      }
    } catch (error) {
      emit(ProductErrorState('An error occurred: ${error.toString()}'));
    }
  }

  Future<void> _searchProduct(
      SearchProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/findproduct/${event.query}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        emit(ProductLoadedState([responseData['data']]));
      } else {
        emit(ProductErrorState('Product not found'));
      }
    } catch (error) {
      emit(ProductErrorState('An error occurred: ${error.toString()}'));
    }
  }
}
