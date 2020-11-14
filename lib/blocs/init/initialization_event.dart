part of 'initialization_bloc.dart';

@immutable
abstract class InitializationEvent extends Equatable {
  const InitializationEvent();

  @override
  List<Object> get props => [];
}

class BeginInitEvent extends InitializationEvent {
  @override
  List<Object> get props => [];
}

class ReadyEvent extends InitializationEvent {
  @override
  List<Object> get props => [];
}

class ErrorEvent extends InitializationEvent {
  @override
  List<Object> get props => [];
}
