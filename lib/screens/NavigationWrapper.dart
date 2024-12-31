import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Add this dependency in pubspec.yaml
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
  int _currentIndex = 2; // Set Home (center item) as the default selected tab

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens, passing userId and token where required
    _screens = [
      Center(child: Text('Users Screen')), // Placeholder for Users
      ProfileScreen(userId: widget.userId, token: widget.token),
      DashboardScreen(userId: widget.userId, token: widget.token),
      Center(child: Text('Create Order Screen')), // Placeholder for Create Order
      Center(child: Text('Manage Products Screen')), // Placeholder for Manage Products
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the current screen
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        backgroundColor: Colors.white,
        color: const Color(0xFF9278F9), // Purple theme color
        buttonBackgroundColor: Colors.white,
       
    
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        items: [
          Icon(
            Icons.group,
            size: 30,
            color: _currentIndex == 0 ? const Color(0xFF9278F9) : Colors.white,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: _currentIndex == 1 ? const Color(0xFF9278F9) : Colors.white,
          ),
          Icon(
            Icons.home,
            size: 30,
            color: _currentIndex == 2 ? const Color(0xFF9278F9) : Colors.white,
          ),
          Icon(
            Icons.add_shopping_cart,
            size: 30,
            color: _currentIndex == 3 ? const Color(0xFF9278F9) : Colors.white,
          ),
          Icon(
            Icons.inventory,
            size: 30,
            color: _currentIndex == 4 ? const Color(0xFF9278F9) : Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
