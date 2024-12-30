import 'package:appdev_flutter_project/screens/onboardingscreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7A5AF8), Colors.white],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/logo.png',
            width: 400, // Adjust width as needed
            height: 400, // Adjust height as needed
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
