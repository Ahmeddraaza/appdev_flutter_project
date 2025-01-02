import 'package:appdev_flutter_project/screens/bestsellingproduct.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'DashboardSummary.dart';
import 'OrderInformationCard.dart';
import 'dailysalesgraph.dart';
import 'monthlysales.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  final String token;

  const DashboardScreen({Key? key, required this.userId, required this.token})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String fullName = "";
  String userType = "User Type";
  int totalOrders = 0;
  double revenue = 0;
  List<double> dailySales = [];
  Map<String, double> monthlySales = {};
  List<Map<String, dynamic>> orderData = [];
  List<Map<String, dynamic>> bestSellingProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      await fetchUserFullName();
      await fetchRevenueAndOrders();
      await fetchDailySales();
      await fetchMonthlySales();
      await fetchOrderInformation();
      await fetchBestSellingProducts();

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching dashboard data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserFullName() async {
    final url = Uri.parse('http://10.0.2.2:3001/user/getUser/${widget.userId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          fullName = responseData['name'] ?? "Full Name";
          userType = responseData['userType'] ?? "User Type";
        });
      } else {
        print("Failed to fetch user full name: ${response.body}");
      }
    } catch (error) {
      print("Error fetching user full name: $error");
    }
  }

  Future<void> fetchRevenueAndOrders() async {
    final url = Uri.parse('http://10.0.2.2:3001/auth/count');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalOrders = data['count'];
          revenue = data['revenue'].toDouble() ?? 0.0;
        });
        print("Revenue and Orders Data: $data");

      }
    } catch (error) {
      print("Error fetching revenue and orders: $error");
    }
  }

  Future<void> fetchDailySales() async {
    final url = Uri.parse('http://10.0.2.2:3001/auth/dailysaleslatestweek');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });
      if (response.statusCode == 200) {
        setState(() {
          dailySales = (jsonDecode(response.body) as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList();
        });
      }
    } catch (error) {
      print("Error fetching daily sales: $error");
    }
  }

  Future<void> fetchMonthlySales() async {
    final url = Uri.parse('http://10.0.2.2:3001/auth/revenuebymonth');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          monthlySales = (data as Map<String, dynamic>).map<String, double>(
              (key, value) => MapEntry(key, (value as num).toDouble()));
        });
      }
    } catch (error) {
      print("Error fetching monthly sales: $error");
    }
  }

  Future<void> fetchOrderInformation() async {
    final url = Uri.parse('http://10.0.2.2:3001/auth/getorders');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          orderData = data.map<Map<String, dynamic>>((order) {
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
        });
      }
    } catch (error) {
      print("Error fetching order information: $error");
    }
  }

  Future<void> fetchBestSellingProducts() async {
    try {
      final productMap = <String, int>{};
      for (var order in orderData) {
        for (var product in (order["products"] as List<dynamic>)) {
          final productName = product["productname"] ?? "Unknown Product";
          final quantity = (product["quantity"] ?? 0) as int;

          productMap[productName] = (productMap[productName] ?? 0) + quantity;
        }
      }
      setState(() {
        bestSellingProducts = productMap.entries
            .map<Map<String, dynamic>>((entry) => {
                  "productName": entry.key,
                  "quantity": entry.value,
                })
            .toList()
          ..sort((a, b) => (b["quantity"] as int).compareTo(a["quantity"] as int));
      });
    } catch (error) {
      print("Error fetching best-selling products: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header
                  _buildHeader(),

                  const SizedBox(height: 20),

                  // Dashboard Summary
                  DashboardSummary(
                    revenue: revenue,
                    totalOrders: totalOrders,
                    revenueChange: '3.4%',
                    ordersChange: '10%',
                  ),

                  const SizedBox(height: 20),

                  // Daily Sales Graph
                  DailySalesGraphCard(
                    title: "Daily Sales (Last Week)",
                    data: dailySales,
                    labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                    previousWeekTotal: 30000,
                  ),

                  const SizedBox(height: 20),

                  // Monthly Sales Graph
                  MonthlySalesGraphCard(
                    title: "Monthly Sales",
                    data: monthlySales.values.toList(),
                    labels: monthlySales.keys.map((key) {
                      return _getMonthName(int.parse(key));
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Order Information
                  OrderInformationCard(orderData: orderData),

                  const SizedBox(height: 20),

                  BestSellingProducts(bestSellingProducts: bestSellingProducts)

                ],
              ),
            ),
    );   
    
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF6E61FF),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                userType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E61FF),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF6E61FF)),
            onPressed: () {
              // Handle notification tap
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(int monthNumber) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[monthNumber - 1];
  }
}
