part of 'mqtt_bloc.dart';

abstract class MqttEvent extends Equatable {
  const MqttEvent();
}

class InitializeMqtt extends MqttEvent {
  InitializeMqtt();
  @override
  List<Object> get props => [];
}

class SubscribeToTopic extends MqttEvent {
  final String topic;
  SubscribeToTopic({@required this.topic});
  @override
  List<Object> get props => [topic];
}

class MessageReceivedEvent extends MqttEvent {
  final String topic;
  final dynamic message;
  MessageReceivedEvent({@required this.message, @required this.topic});
  @override
  List<Object> get props => [message];
}

class UnsubscribeTopic extends MqttEvent {
  final String topic;
  UnsubscribeTopic({@required this.topic});
  @override
  List<Object> get props => [topic];
}

class SendMessageToTopic extends MqttEvent {
  final String topic;
  final String message;
  SendMessageToTopic({@required this.topic, @required this.message});
  @override
  List<Object> get props => [topic, message];
}

class DisposeMqtt extends MqttEvent {
  @override
  List<Object> get props => [];
}