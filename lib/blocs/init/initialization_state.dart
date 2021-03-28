part of 'initialization_bloc.dart';

@immutable
abstract class InitializationState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialState extends InitializationState {
  @override
  List<Object> get props => [];
}

class BeginInitState extends InitializationState {
  @override
  List<Object> get props => [];
}

class ReadyState extends InitializationState {
  @override
  List<Object> get props => [];
}

class ErrorState extends InitializationState {
  final String error;
  ErrorState({this.error});
  @override
  List<Object> get props => [error];
}
