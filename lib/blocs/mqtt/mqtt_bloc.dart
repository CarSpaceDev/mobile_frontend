import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  String clientIdentifier;
  MqttServerClient client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> mqttStream;
  MqttBloc() : super(MqttInitial());

  @override
  Stream<MqttState> mapEventToState(
    MqttEvent event,
  ) async* {
    if (event is InitializeMqtt) {
      print("Initializing MQTT");
      clientIdentifier = "zdg_${DateTime.now().millisecondsSinceEpoch}";
      print("MQTT ID: $clientIdentifier");
      client = MqttServerClient(StringConstants.kMqttUrl, clientIdentifier);
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
          .authenticateAs(StringConstants.kMqttUser, StringConstants.kMqttPass)
          .withClientIdentifier(clientIdentifier)
          .startClean() // Non persistent session for testing
          .withWillQos(MqttQos.atLeastOnce);
      try {
        await client.connect();
        if (client.connectionStatus.state == MqttConnectionState.connected) {
          print('Mosquitto client connected');
          client.subscribe("debug", MqttQos.atMostOnce);
          mqttStream = client.updates.listen(handleMessage);
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
    if (event is MessageReceivedEvent) {
      print("MQTT Message received from [${event.topic}] : ${event.message}");
      yield MqttMessageReceived(topic: event.topic, message: event.message);
    }
    if (event is SubscribeToTopic) {
      print("SUBSCRIBING TO ${event.topic}");
      client.subscribe(event.topic, MqttQos.atMostOnce);
    }
    if (event is UnsubscribeTopic) {
      print("UNSUBSCRIBING FROM ${event.topic}");
      client.unsubscribe(event.topic);
    }
    if (event is SendMessageToTopic) {
      print("SENDING TO ${event.topic} : ${event.message}");
      final builder = MqttClientPayloadBuilder();
      builder.addString(event.message);
      client.publishMessage(event.topic, MqttQos.atLeastOnce, builder.payload);
    }
    if (event is DisposeMqtt) {
      print("MQTTBlocCalledDispose");
      client.disconnect();
      client = null;
      mqttStream.cancel();
    }
  }

  handleMessage(List<MqttReceivedMessage<MqttMessage>> v) {
    MqttPublishMessage recMess = v.first.payload;
    String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    var payload = jsonDecode(pt);
    locator<NavigationService>()
        .navigatorKey
        .currentContext
        .read<MqttBloc>()
        .add(MessageReceivedEvent(topic: v.first.topic, message: payload));
  }
}
