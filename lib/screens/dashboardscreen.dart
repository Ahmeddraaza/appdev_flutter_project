import 'package:appdev_flutter_project/Dashboard/dashboard_bloc.dart';
import 'package:appdev_flutter_project/Dashboard/dashboard_event.dart';
import 'package:appdev_flutter_project/Dashboard/dashboard_state.dart';
import 'package:appdev_flutter_project/screens/DashboardSummary.dart';
import 'package:appdev_flutter_project/screens/OrderInformationCard.dart';
import 'package:appdev_flutter_project/screens/bestsellingproduct.dart';
import 'package:appdev_flutter_project/screens/dailysalesgraph.dart';
import 'package:appdev_flutter_project/screens/monthlysales.dart';
import 'package:appdev_flutter_project/screens/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;
  final String token;

  const DashboardScreen({Key? key, required this.userId, required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(userId: userId, token: token)
        ..add(FetchDashboardDataEvent()), // Trigger data fetching
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F8FC),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoadingState) {
              // Show a loading indicator while fetching data
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoadedState) {
              // Render the dashboard when data is loaded
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 60),
                    // Header
                    _buildHeader(context, state.fullName, state.userType),


                    const SizedBox(height: 20),

                    // Dashboard Summary
                    DashboardSummary(
                      revenue: state.revenue,
                      totalOrders: state.totalOrders,
                      revenueChange: "3.4%", // Add dynamic calculations if needed
                      ordersChange: "10%",  // Add dynamic calculations if needed
                    ),

                    const SizedBox(height: 20),

                    // Daily Sales Graph
                    DailySalesGraphCard(
                      title: "Daily Sales (Last Week)",
                      data: state.dailySales,
                      labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                      previousWeekTotal: 30000.0, // Example value
                    ),

                    const SizedBox(height: 20),

                    // Monthly Sales Graph
                    MonthlySalesGraphCard(
                      title: "Monthly Sales",
                      data: state.monthlySales.values.toList(),
                      labels: state.monthlySales.keys.map((key) {
                        return _getMonthName(int.parse(key));
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Order Information
                    OrderInformationCard(orderData: state.orderData),

                    const SizedBox(height: 20),

                    // Best Selling Products
                    BestSellingProducts(bestSellingProducts: state.bestSellingProducts),
                  ],
                ),
              );
            } else if (state is DashboardErrorState) {
              // Show an error message if data fetching fails
              return Center(
                child: Text(
                  state.error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context,String fullName, String userType) {
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
              // Navigate to Notification Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(token: token),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(int monthNumber) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec',
    ];
    return months[monthNumber - 1];
  }
}
