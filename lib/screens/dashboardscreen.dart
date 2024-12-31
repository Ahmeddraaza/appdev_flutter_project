import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final String userId; // Pass the user ID from login
  final String token; // Pass the token from login

  const DashboardScreen({Key? key, required this.userId, required this.token})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> orderData = [];
  List<Map<String, dynamic>> bestSellingProducts = [];
  String fullName = ""; // Store the user's full name
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    fetchUserFullName(); // Fetch the user's full name
  }

  // Fetch the user's full name
  Future<void> fetchUserFullName() async {
    final url =
        Uri.parse('http://localhost:3001/user/getUser/${widget.userId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Pass token in headers
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          fullName = responseData['name'] ?? "Unknown User";
        });
      } else {
        print("Failed to fetch user full name: ${response.body}");
      }
    } catch (error) {
      print("Error fetching user full name: $error");
    }
  }

  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
    try {
      final url = Uri.parse('http://localhost:3001/auth/getorders');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;

        // Extract order data
        final orders = responseData.map<Map<String, dynamic>>((order) {
          final orderDate = DateTime.parse(
                  order["createdAt"] ?? DateTime.now().toIso8601String())
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
          };
        }).toList();

        // Calculate best-selling products
        final Map<String, int> productMap = {};
        for (var order in responseData) {
          for (var product in (order["products"] as List<dynamic>)) {
            final productName = product["productname"] ?? "Unknown Product";
            final quantity = (product["quantity"] ?? 0) as int;

            productMap[productName] = (productMap[productName] ?? 0) + quantity;
          }
        }

        final bestSellers = productMap.entries
            .map<Map<String, dynamic>>((entry) => {
                  "productName": entry.key,
                  "quantity": entry.value,
                })
            .toList()
          ..sort(
              (a, b) => (b["quantity"] as int).compareTo(a["quantity"] as int));

        setState(() {
          orderData = orders;
          bestSellingProducts = bestSellers.take(5).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch order data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching dashboard data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name and Dashboard Overview
                      Text(
                        fullName, // Display the user's full name
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Admin Dashboard',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Monthly Sales and Today's Orders (Dummy Data for Now)
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: const [
                                    Text(
                                      '\$393.00',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('Revenue'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: const [
                                    Text(
                                      '1,000',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Today's Orders"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Order Information Table
                      const Text(
                        'Order Information',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Order Date')),
                            DataColumn(label: Text('Customer Name')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Total Amount')),
                          ],
                          rows: orderData
                              .map(
                                (order) => DataRow(cells: [
                                  DataCell(Text(order["orderDate"])),
                                  DataCell(Text(order["customerName"])),
                                  DataCell(Text(order["quantity"].toString())),
                                  DataCell(Text('\$${order["totalAmount"]}')),
                                ]),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Best Selling Products
                      const Text(
                        'Best Selling Products',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bestSellingProducts.length,
                        itemBuilder: (context, index) {
                          final product = bestSellingProducts[index];
                          return Card(
                            child: ListTile(
                              title: Text(product["productName"]),
                              trailing:
                                  Text('Quantity: ${product["quantity"]}'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
