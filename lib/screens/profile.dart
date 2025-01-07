import 'package:appdev_flutter_project/Profile/profile_bloc.dart';
import 'package:appdev_flutter_project/Profile/profile_event.dart';
import 'package:appdev_flutter_project/Profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/user.dart';
import 'NavigationWrapper.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  final String token;

  const ProfileScreen({Key? key, required this.userId, required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(token: token)..add(FetchProfileEvent(userId)),
      child: ProfileScreenView(userId: userId, token: token),
    );
  }
}

class ProfileScreenView extends StatelessWidget {
  final String userId;
  final String token;

  const ProfileScreenView({Key? key, required this.userId, required this.token})
      : super(key: key);

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
                builder: (context) =>
                    NavigationWrapper(userId: userId, token: token),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Color(0xFF000000)),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          } else if (state is ProfileLoadedState) {
            final user = state.user;
            return _buildProfileView(user);
          } else if (state is ProfileErrorState) {
            return const Center(
              child: Text(
                'Unable to load user data.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProfileView(User user) {
    return Center(
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
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildField('Name', user.name),
              _buildField('Email Account', user.email),
              _buildField('Mobile Number', user.phone),
              _buildField('Branch ID', user.branchId),
              _buildField('User Type', user.userType),
            ],
          ),
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
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
