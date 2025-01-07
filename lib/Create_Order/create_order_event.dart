import 'package:equatable/equatable.dart';

abstract class CreateOrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends CreateOrderEvent {}

class SubmitOrderEvent extends CreateOrderEvent {
  final String customerName;
  final Map<String, int> selectedProducts;

  SubmitOrderEvent(this.customerName, this.selectedProducts);

  @override
  List<Object?> get props => [customerName, selectedProducts];
}

class UpdateSelectedProductEvent extends CreateOrderEvent {
  final String productId;
  final int quantityChange;

  UpdateSelectedProductEvent(this.productId, this.quantityChange);

  @override
  List<Object?> get props => [productId, quantityChange];
}
