import 'package:appdev_flutter_project/User_management/user_bloc.dart';
import 'package:appdev_flutter_project/User_management/user_event.dart';
import 'package:appdev_flutter_project/User_management/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/NavigationWrapper.dart';

class UserScreen extends StatelessWidget {
  final String token;
  final String userId;

  const UserScreen({Key? key, required this.token, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc(token: token)..add(FetchUsersEvent()),
      child: UserScreenView(token: token, userId: userId),
    );
  }
}

class UserScreenView extends StatelessWidget {
  final String token;
  final String userId;

  const UserScreenView({Key? key, required this.token, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8FC),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationWrapper(userId: userId, token: token),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text('User Management', style: TextStyle(color: Colors.black)),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserCreatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is UserErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
  if (state is UserLoadingState) {
    return const Center(child: CircularProgressIndicator());
  } else if (state is UserLoadedState || state is UserCreatedState || state is UserErrorState) {
    final employees = state.employees;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildCreateUserCard(context),
            const SizedBox(height: 20),
            employees.isNotEmpty
                ? _buildEmployeeList(employees)
                : const Center(child: Text("No employees found.")),
          ],
        ),
      ),
    );
  }
  return const Center(child: Text("Unexpected error occurred."));
}

      ),
    );
  }

  Widget _buildCreateUserCard(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final branchIdController = TextEditingController();
    String selectedUserType = 'admin';

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextField('Name', nameController),
            const SizedBox(height: 10),
            _buildTextField('Email', emailController),
            const SizedBox(height: 10),
            _buildTextField('Phone', phoneController),
            const SizedBox(height: 10),
            _buildTextField('Branch ID', branchIdController),
            const SizedBox(height: 10),
            _buildTextField('Password', passwordController, obscureText: true),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedUserType,
              items: ['admin', 'superadmin', 'cashier', 'operational manager'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                selectedUserType = value!;
              },
              decoration: const InputDecoration(labelText: 'User Type', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final userId = DateTime.now().millisecondsSinceEpoch.toString(); // Generate a unique ID
                  final userData = {
                    "name": nameController.text.trim(),
                    "userId": userId,
                    "email": emailController.text.trim(),
                    "phone": phoneController.text.trim(),
                    "password": passwordController.text.trim(),
                    "branchId": branchIdController.text.trim(),
                    "userType": selectedUserType,
                  };
                  BlocProvider.of<UserBloc>(context).add(CreateUserEvent(userData));
                },
                child: const Text('Create User', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A5AF8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList(List<dynamic> employees) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Employee List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SingleChildScrollView(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
