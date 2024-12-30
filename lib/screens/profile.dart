import 'package:appdev_flutter_project/model/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import the User model


class ProfileScreen extends StatefulWidget {
  final String userId; // User ID passed from the login response
  final String token;  // Token passed from the login response

  const ProfileScreen({Key? key, required this.userId, required this.token}) : super(key: key);

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
    final url = 'http://localhost:3001/user/getUser/${widget.userId}'; // API endpoint

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
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Color(0xFF7A5AF8), // Adjust color as per your theme
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show a loading spinner while fetching data
          : userData != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Profile Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ProfileField(
                                label: 'Full Name',
                                value: userData!.name,
                              ),
                              ProfileField(
                                label: 'Mobile',
                                value: userData!.phone,
                              ),
                              ProfileField(
                                label: 'Email',
                                value: userData!.email,
                              ),
                              ProfileField(
                                label: 'Branch ID',
                                value: userData!.branchId,
                              ),
                              ProfileField(
                                label: 'User Type',
                                value: userData!.userType,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Additional content (if needed)
                      Text(
                        'Other Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Additional content goes here.'),
                        ),
                      ),
                    ],
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
}

// A reusable widget for displaying profile fields
class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
