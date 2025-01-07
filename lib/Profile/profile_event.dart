import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {
  final String userId;

  FetchProfileEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
