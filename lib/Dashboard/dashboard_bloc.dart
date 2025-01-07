import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final String userId;
  final String token;

  DashboardBloc({required this.userId, required this.token})
      : super(DashboardInitialState()) {
    on<FetchDashboardDataEvent>(_fetchDashboardData);
  }

  Future<void> _fetchDashboardData(
      FetchDashboardDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoadingState());

    try {
      // Fetch all required data in parallel
      final results = await Future.wait([
        _fetchUserFullName(),
        _fetchRevenueAndOrders(),
        _fetchDailySales(),
        _fetchMonthlySales(),
        _fetchOrderInformation(),
        _fetchBestSellingProducts(),
      ]);

      // Parse results
      final fullName = results[0] as Map<String, dynamic>;
      final revenueAndOrders = results[1] as Map<String, dynamic>;
      final dailySales = results[2] as List<double>;
      final monthlySales = results[3] as Map<String, double>;
      final orderData = results[4] as List<Map<String, dynamic>>;
      final bestSellingProducts = results[5] as List<Map<String, dynamic>>;

      // Emit loaded state
      emit(DashboardLoadedState(
        fullName: fullName['name'] ?? 'Full Name',
        userType: fullName['userType'] ?? 'User Type',
        totalOrders: revenueAndOrders['count'] ?? 0,
        revenue: (revenueAndOrders['revenue'] as num?)?.toDouble() ?? 0.0,
        dailySales: dailySales,
        monthlySales: monthlySales,
        orderData: orderData,
        bestSellingProducts: bestSellingProducts,
      ));
    } catch (error) {
      emit(DashboardErrorState('Error fetching dashboard data: $error'));
    }
  }

  Future<Map<String, dynamic>> _fetchUserFullName() async {
    final url = Uri.parse('http://localhost:3001/user/getUser/$userId');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user full name: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _fetchRevenueAndOrders() async {
    final url = Uri.parse('http://localhost:3001/auth/count');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch revenue and orders: ${response.body}');
    }
  }

  Future<List<double>> _fetchDailySales() async {
    final url = Uri.parse('http://localhost:3001/auth/dailysaleslatestweek');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();
    } else {
      throw Exception('Failed to fetch daily sales: ${response.body}');
    }
  }

  Future<Map<String, double>> _fetchMonthlySales() async {
    final url = Uri.parse('http://localhost:3001/auth/revenuebymonth');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    } else {
      throw Exception('Failed to fetch monthly sales: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrderInformation() async {
    final url = Uri.parse('http://localhost:3001/auth/getorders');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).map((order) {
        final orderDate = DateTime.parse(order["createdAt"] ?? DateTime.now().toIso8601String())
            .toLocal()
            .toString()
            .split(' ')[0];
        final customerName = order["customerName"] ?? "Unknown";
        final quantity = (order["products"] as List<dynamic>).fold<int>(
          0,
          (sum, product) => sum + ((product["quantity"] ?? 0) as int),
        );
        final totalAmount = (order["total_amount"] ?? 0).toDouble();

        return {
          "orderDate": orderDate,
          "customerName": customerName,
          "quantity": quantity,
          "totalAmount": totalAmount,
          "products": order["products"],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch order information: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchBestSellingProducts() async {
    final url = Uri.parse('http://localhost:3001/auth/bestsellingproducts');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).map((product) {
        return {
          "productName": product["Product_name"] ?? "Unknown Product",
          "quantity": product["quantity"] ?? 0,
          "price": product["price"] ?? 0.0,
          "image": product["image"] ?? "",
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch best-selling products: ${response.body}');
    }
  }
}
