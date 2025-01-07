import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final String token;

  UserBloc({required this.token}) : super(UserLoadingState()) {
    on<FetchUsersEvent>(_fetchUsers);
    on<CreateUserEvent>(_createUser);
  }

  Future<void> _fetchUsers(FetchUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3001/auth/getemployees'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final employees = json.decode(response.body);
        emit(UserLoadedState(employees));
      } else {
        emit(UserErrorState("Failed to load employees.", state.employees));
      }
    } catch (error) {
      emit(UserErrorState("Error fetching employees: $error", state.employees));
    }
  }

  Future<void> _createUser(CreateUserEvent event, Emitter<UserState> emit) async {
    final userData = event.userData;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/auth/signUp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UserCreatedState("User created successfully!", state.employees));
        add(FetchUsersEvent()); // Refresh employees after user creation
      } else {
        emit(UserErrorState("Failed to create user.", state.employees));
      }
    } catch (error) {
      emit(UserErrorState("Error creating user: $error", state.employees));
    }
  }
}
