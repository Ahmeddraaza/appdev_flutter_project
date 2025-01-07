import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUsersEvent extends UserEvent {}

class CreateUserEvent extends UserEvent {
  final Map<String, dynamic> userData;

  CreateUserEvent(this.userData);

  @override
  List<Object?> get props => [userData];
}
