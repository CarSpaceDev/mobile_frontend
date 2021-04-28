part of 'mqtt_bloc.dart';

abstract class MqttState extends Equatable {
  const MqttState();
}

class MqttInitial extends MqttState {
  @override
  List<Object> get props => [];
}

class MqttReady extends MqttState {
  @override
  List<Object> get props => [];
}

class MqttMessageReceived extends MqttState {
  final String topic;
  final dynamic message;
  MqttMessageReceived({@required this.message, @required this.topic});
  @override
  List<Object> get props => [topic,message];
}