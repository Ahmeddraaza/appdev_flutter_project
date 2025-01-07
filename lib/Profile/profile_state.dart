import 'package:equatable/equatable.dart';
import '../model/user.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final User user;

  ProfileLoadedState(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileErrorState extends ProfileState {
  final String error;

  ProfileErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
