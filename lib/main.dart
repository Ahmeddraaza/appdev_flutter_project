import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AppDevFlutterProject());
}

class AppDevFlutterProject extends StatelessWidget {
  const AppDevFlutterProject({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AppDev Flutter Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
