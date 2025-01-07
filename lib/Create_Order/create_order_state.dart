import 'package:equatable/equatable.dart';

abstract class CreateOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateOrderInitialState extends CreateOrderState {}

class CreateOrderLoadingState extends CreateOrderState {}

class CreateOrderLoadedState extends CreateOrderState {
  final List<Map<String, dynamic>> products;
  final Map<String, int> selectedProducts;

  CreateOrderLoadedState({required this.products, required this.selectedProducts});

  @override
  List<Object?> get props => [products, selectedProducts];
}

class CreateOrderSubmittingState extends CreateOrderState {}

class CreateOrderSuccessState extends CreateOrderState {}

class CreateOrderErrorState extends CreateOrderState {
  final String error;

  CreateOrderErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
