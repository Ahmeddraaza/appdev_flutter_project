import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'profile_event.dart';
import 'profile_state.dart';
import '../model/user.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final String token;

  ProfileBloc({required this.token}) : super(ProfileLoadingState()) {
    on<FetchProfileEvent>(_fetchProfile);
  }

  Future<void> _fetchProfile(
      FetchProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadingState());

    final url = 'http://10.0.2.2:3001/user/getUser/${event.userId}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = User.fromJson(responseData);
        emit(ProfileLoadedState(user));
      } else {
        emit(ProfileErrorState("Failed to load user data."));
      }
    } catch (error) {
      emit(ProfileErrorState("Error fetching user data: $error"));
    }
  }
}
