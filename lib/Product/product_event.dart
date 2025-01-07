import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {}

class AddProductEvent extends ProductEvent {
  final Map<String, dynamic> product;

  AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;

  DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SearchProductEvent extends ProductEvent {
  final String query;

  SearchProductEvent(this.query);

  @override
  List<Object?> get props => [query];
}
