import 'package:appdev_flutter_project/screens/NavigationWrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserScreen extends StatefulWidget {
  final String token;
  final String userId;

  const UserScreen({Key? key, required this.token, required this.userId}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<dynamic> employees = [];
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController branchIdController = TextEditingController();

  String selectedUserType = 'admin';
  final List<String> userTypes = ['admin', 'superadmin', 'cashier', 'operational manager'];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/auth/getemployees'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          employees = json.decode(response.body);
        });
      } else {
        throw Exception("Failed to load employees");
      }
    } catch (error) {
      print("Error fetching employees: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching employees: $error"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final branchId = branchIdController.text.trim();
    final userType = selectedUserType;

    if ([name, email, phone, password, branchId].any((field) => field.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required"), backgroundColor: Colors.red),
      );
      return;
    }

    final body = {
      "userType": userType,
      "userId": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "branchId": branchId,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3001/auth/signUp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User created successfully!"), backgroundColor: Colors.green),
        );
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();
        branchIdController.clear();
        setState(() {
          selectedUserType = 'admin';
        });
        fetchEmployees();
      } else {
        print("Error Response: ${response.body}");
        throw Exception("Failed to create user");
      }
    } catch (error) {
      print("Error creating user: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      appBar: AppBar(
      backgroundColor: const Color(0xFFF3F8FC), // Adjusted color to match theme
        elevation: 1,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
   onPressed: () {
      Navigator.pushAndRemoveUntil(context,
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
        title: const Text('User Management')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Create User Card
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create User',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: branchIdController,
                        decoration: InputDecoration(
                          labelText: 'Branch ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedUserType,
                        items: userTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserType = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'User Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: createUser,
                          child: const Text('Create User', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A5AF8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // User Information Card
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Employee List',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : employees.isNotEmpty
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text("Name")),
                                      DataColumn(label: Text("Email")),
                                      DataColumn(label: Text("Phone")),
                                      DataColumn(label: Text("Branch ID")),
                                      DataColumn(label: Text("Type")),
                                    ],
                                    rows: employees.map((employee) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(employee['name'] ?? '')),
                                          DataCell(Text(employee['email'] ?? '')),
                                          DataCell(Text(employee['phone'] ?? '')),
                                          DataCell(Text(employee['branchId'] ?? '')),
                                          DataCell(Text(employee['userType'] ?? '')),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                )
                              : const Text("No employees found."),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
