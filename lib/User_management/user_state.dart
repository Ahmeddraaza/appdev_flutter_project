import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  final List<dynamic> employees;

  const UserState({this.employees = const []});

  @override
  List<Object?> get props => [employees];
}

class UserLoadingState extends UserState {}

class UserLoadedState extends UserState {
  const UserLoadedState(List<dynamic> employees) : super(employees: employees);
}

class UserCreatedState extends UserState {
  final String message;

  const UserCreatedState(this.message, List<dynamic> employees) : super(employees: employees);

  @override
  List<Object?> get props => [message, employees];
}

class UserErrorState extends UserState {
  final String error;

  const UserErrorState(this.error, List<dynamic> employees) : super(employees: employees);

  @override
  List<Object?> get props => [error, employees];
}
