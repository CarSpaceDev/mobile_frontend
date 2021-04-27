import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  String clientIdentifier = "zdg_${DateTime.now().millisecondsSinceEpoch}";
  MqttServerClient client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> mqttStream;
  MqttBloc() : super(MqttInitial());

  @override
  Stream<MqttState> mapEventToState(
    MqttEvent event,
  ) async* {
    if (event is InitializeMqtt) {
      client = MqttServerClient('mqtt.zdgph.tech', clientIdentifier);
      client.logging(on: false);
      client.port = 1883;
      client.keepAlivePeriod = 60;
      client.onDisconnected = () {
        print('EXAMPLE::OnDisconnected client callback - Client disconnection');
        if (client.connectionStatus.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
          print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
        }
      };
      client.onConnected = () {
        print('Client connection was successful');
      };
      client.onSubscribed = (String topic) {
        print('Subscription confirmed for topic $topic');
      };
      client.onAutoReconnect = () {
        print("reconnecting");
      };
      client.onAutoReconnected = () {
        print("Auto reconnected");
      };
      client.pongCallback = () {
        print('Ping mqtt.zdgph.tech successful');
      };
      client.autoReconnect = true;
      client.connectionMessage = MqttConnectMessage()
          .authenticateAs('zdgdev', 'zdgcs21!')
          .withClientIdentifier(clientIdentifier)
          .startClean() // Non persistent session for testing
          .withWillQos(MqttQos.atLeastOnce);
      try {
        await client.connect();
        if (client.connectionStatus.state == MqttConnectionState.connected) {
          print('Mosquitto client connected');
          // client.
          yield MqttReady();
        } else {
          print('Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
          client.disconnect();
        }
      } on NoConnectionException catch (e) {
        print('MQTT Exception: - $e');
        client.disconnect();
      } on SocketException catch (e) {
        print('MQTT Socket exception - $e');
        client.disconnect();
      }
    }
    if(event is MqttDispose){
      client.disconnect();
      client = null;
      mqttStream.cancel();
    }
  }

}
