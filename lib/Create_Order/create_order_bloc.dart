import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_order_event.dart';
import 'create_order_state.dart';

class CreateOrderBloc extends Bloc<CreateOrderEvent, CreateOrderState> {
  final String token;
  final String productUrl = 'http://10.0.2.2:3001/products/findproducts';
  final String orderUrl = 'http://10.0.2.2:3001/order/addOrder';

  CreateOrderBloc({required this.token}) : super(CreateOrderInitialState()) {
    on<FetchProductsEvent>(_fetchProducts);
    on<SubmitOrderEvent>(_submitOrder);
    on<UpdateSelectedProductEvent>(_updateSelectedProduct);
  }

  Future<void> _fetchProducts(FetchProductsEvent event, Emitter<CreateOrderState> emit) async {
    emit(CreateOrderLoadingState());
    try {
      final response = await http.get(
        Uri.parse(productUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body)['data'] ?? [];
        emit(CreateOrderLoadedState(
          products: List<Map<String, dynamic>>.from(responseData),
          selectedProducts: {},
        ));
      } else {
        emit(CreateOrderErrorState('Failed to fetch products.'));
      }
    } catch (e) {
      emit(CreateOrderErrorState('An error occurred: $e'));
    }
  }

  Future<void> _submitOrder(SubmitOrderEvent event, Emitter<CreateOrderState> emit) async {
    emit(CreateOrderSubmittingState());
    try {
      final orderBody = {
        "customerName": event.customerName,
        "products": event.selectedProducts.entries
            .map((entry) => {"id": entry.key, "quantity": entry.value})
            .toList(),
      };

      final response = await http.post(
        Uri.parse(orderUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderBody),
      );

      if (response.statusCode == 201) {
        emit(CreateOrderSuccessState());
      } else {
        emit(CreateOrderErrorState('Failed to create order.'));
      }
    } catch (e) {
      emit(CreateOrderErrorState('An error occurred: $e'));
    }
  }

  void _updateSelectedProduct(UpdateSelectedProductEvent event, Emitter<CreateOrderState> emit) {
    if (state is CreateOrderLoadedState) {
      final currentState = state as CreateOrderLoadedState;
      final updatedProducts = Map<String, int>.from(currentState.selectedProducts);

      if (updatedProducts.containsKey(event.productId)) {
        updatedProducts[event.productId] = updatedProducts[event.productId]! + event.quantityChange;

        if (updatedProducts[event.productId]! <= 0) {
          updatedProducts.remove(event.productId);
        }
      } else if (event.quantityChange > 0) {
        updatedProducts[event.productId] = event.quantityChange;
      }

      emit(CreateOrderLoadedState(
        products: currentState.products,
        selectedProducts: updatedProducts,
      ));
    }
  }
}
