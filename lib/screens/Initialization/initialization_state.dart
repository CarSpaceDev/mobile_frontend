import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class InitializationState extends Equatable {
  InitializationState();
}

class InitialState extends InitializationState {
  @override
  List<Object> get props => [];
}

class ReadyState extends InitializationState {
  @override
  List<Object> get props => [];
}

class ErrorState extends InitializationState {
  @override
  List<Object> get props => [];
}
