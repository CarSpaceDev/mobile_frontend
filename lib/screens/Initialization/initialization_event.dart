import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class InitializationEvent extends Equatable {
  InitializationEvent();
}

class ReadyEvent extends InitializationEvent {
  @override
  List<Object> get props => [];
}

class ErrorEvent extends InitializationEvent {
  @override
  List<Object> get props => [];
}
