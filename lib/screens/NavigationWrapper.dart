import 'package:flutter/material.dart';
import 'dashboardscreen.dart';
import 'profile.dart';

class NavigationWrapper extends StatefulWidget {
  final String userId; // Pass userId from login
  final String token; // Pass token from login

  const NavigationWrapper({Key? key, required this.userId, required this.token})
      : super(key: key);

  @override
  _NavigationWrapperState createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0; // Track the current tab index

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens, passing userId and token where required
    _screens = [
      DashboardScreen(userId: widget.userId, token: widget.token),
      Center(child: Text('Users Screen')), // Placeholder for Users
      Center(
          child: Text('Notifications Screen')), // Placeholder for Notifications
      ProfileScreen(userId: widget.userId, token: widget.token),
      Center(
          child: Text('Create Order Screen')), // Placeholder for Create Order
      Center(
          child: Text(
              'Manage Products Screen')), // Placeholder for Manage Products
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the selected tab index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the current screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped, // Handle tab changes
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart), label: 'Create Order'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'Manage Products'),
        ],
      ),
    );
  }
}
