import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {}

class DashboardLoadingState extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  final String fullName;
  final String userType;
  final int totalOrders;
  final double revenue;
  final List<double> dailySales;
  final Map<String, double> monthlySales;
  final List<Map<String, dynamic>> orderData;
  final List<Map<String, dynamic>> bestSellingProducts;

  DashboardLoadedState({
    required this.fullName,
    required this.userType,
    required this.totalOrders,
    required this.revenue,
    required this.dailySales,
    required this.monthlySales,
    required this.orderData,
    required this.bestSellingProducts,
  });

  @override
  List<Object?> get props => [
        fullName,
        userType,
        totalOrders,
        revenue,
        dailySales,
        monthlySales,
        orderData,
        bestSellingProducts,
      ];
}

class DashboardErrorState extends DashboardState {
  final String error;

  DashboardErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
