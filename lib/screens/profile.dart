import 'package:appdev_flutter_project/model/user.dart';
import 'package:appdev_flutter_project/screens/NavigationWrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String userId; // User ID passed from the login response
  final String token;  // Token passed from the login response

  const ProfileScreen({Key? key, required this.userId, required this.token})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? userData; // User data object
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen is initialized
  }

  Future<void> fetchUserData() async {
    final url = 'http://10.0.2.2:3001/user/getUser/${widget.userId}'; // API endpoint

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Pass the token in the headers
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          userData = User.fromJson(responseData); // Parse response into User model
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC), // Match the dashboard theme
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8FC), // Adjusted color to match theme
        elevation: 1,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
   onPressed: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationWrapper(
            userId: widget.userId,
            token: widget.token,
          ),
        ),
        (route) => false, // Remove all previous routes
      );
   }, 
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
  
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            )
          : userData != null
              ? Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 552,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(52),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Details Header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.grey[200],
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userData!.email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Fields
                          _buildField('Name', userData!.name),
                          _buildField('Email Account', userData!.email),
                          _buildField('Mobile Number', userData!.phone),
                          _buildField('Branch ID', userData!.branchId),
                          _buildField('User Type', userData!.userType),
                          const SizedBox(height: 48),

                          
                        ],
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text(
                    'Unable to load user data.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
