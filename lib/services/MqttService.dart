import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


class MqttService {
  final String identifier = "zdg_${DateTime.now().millisecondsSinceEpoch}";
  final String url = 'mqtt.zdgph.tech';
  final String username = 'zdgdev';
  final String password = 'zdgcs21!';
  final client = MqttServerClient('mqtt.zdgph.tech', '');
  bool readyStatus = false;

  MqttService() {
    connect();
  }

  Future connect() async {
    client.logging(on: false);
    client.port = 1883;
    client.keepAlivePeriod = 60;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onAutoReconnect = onAutoReconnect;
    client.onAutoReconnected = () {
      print("Auto reconnected");
    };
    client.pongCallback = pong;
    client.autoReconnect = true;
    final connMess = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier(DateTime.now().millisecondsSinceEpoch.toString())
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print('Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  subscribe(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  unSubscribe(String topic) {
    client.unsubscribe(topic);
  }

  send(String topic, message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void onAutoReconnect() {
    print("reconnecting");
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    // exit(-1);
  }

  /// The successful connect callback
  void onConnected() {
    print('Client connection was successful');
  }

  /// Pong callback
  void pong() {
    print('Pinging mqtt.zdgph.tech');
  }
}
