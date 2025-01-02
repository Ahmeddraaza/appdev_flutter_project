import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserScreen extends StatefulWidget {
  final String token;

  const UserScreen({Key? key, required this.token}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();

  Map<String, dynamic>? userInfo;
  bool _isLoading = false;
  bool _isCreatingUser = false;

  final String baseUrl = 'http://10.0.2.2:3001';

  // Fetch user details
  Future<void> _fetchUser() async {
    final userId = _userIdController.text.trim();

    if (userId.isEmpty) {
      _showSnackBar('User ID is required', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getUser/$userId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          userInfo = json.decode(response.body);
        });
      } else {
        _showSnackBar('User not found', Colors.red);
        setState(() {
          userInfo = null;
        });
      }
    } catch (error) {
      _showSnackBar('Error: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Create a new user
  Future<void> _createUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final userType = _userTypeController.text.trim();
    final userId = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID

    if ([name, email, phone, password, userType].any((field) => field.isEmpty)) {
      _showSnackBar('All fields are required', Colors.red);
      return;
    }

    final body = {
      "userType": userType,
      "userId": userId,
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
    };

    setState(() {
      _isCreatingUser = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signUp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['msg'] == 'USER EXISTS') {
          _showSnackBar('User already exists', Colors.red);
        } else if (responseData['msg'] == 'CREATED') {
          _showSnackBar('User created successfully!', Colors.green);
          _clearFields();
        }
      } else {
        _showSnackBar('Failed to create user', Colors.red);
      }
    } catch (error) {
      _showSnackBar('Error: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isCreatingUser = false;
      });
    }
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _userTypeController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Screen'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fetch User Section
              const Text(
                'Fetch User Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Fetch User'),
              ),
              const SizedBox(height: 20),

              // User Info Display
              if (userInfo != null)
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${userInfo!['name']}'),
                        Text('Email: ${userInfo!['email']}'),
                        Text('Phone: ${userInfo!['phone']}'),
                        Text('User Type: ${userInfo!['userType']}'),
                        Text('User ID: ${userInfo!['userId']}'),
                      ],
                    ),
                  ),
                ),

              const Divider(thickness: 2, height: 40),

              // Create User Section
              const Text(
                'Create User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _userTypeController,
                decoration: InputDecoration(
                  labelText: 'User Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isCreatingUser ? null : _createUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: _isCreatingUser
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
