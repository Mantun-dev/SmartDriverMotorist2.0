// // MqttSignalingService.dart
// import 'dart:convert';
// import 'package:mqtt_client/mqtt_client.dart'; // Ensure correct import
// import 'package:mqtt_client/mqtt_server_client.dart'; // Ensure correct import

// class MqttSignalingService {
//   final String broker;
//   final String clientId;
//   late final String userId;
//   Function(Map<String, dynamic> message) onSignalReceived;

//   late MqttServerClient _client;
//   bool _isConnected = false;

//   MqttSignalingService({
//     required this.broker,
//     required this.clientId,
//     required this.userId,
//     required this.onSignalReceived,
//   });

//   Future<void> connect() async {
//     _client = MqttServerClient(broker, clientId);
//     _client.port = 8884;
//     _client.secure = true;
//     _client.keepAlivePeriod = 120;
//     _client.onDisconnected = _onDisconnected;
//     _client.onConnected = _onConnected;
//     _client.onSubscribed = (topic) => print("📡 Subscrito a: $topic"); // This is already good

//     _client.logging(on: true);
//     _client.setProtocolV311();

//     final connMessage = MqttConnectMessage()
//         .withWillTopic('willtopic')
//         .withWillMessage('willMessage')
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce)
//         .withClientIdentifier(clientId); // Use clientId directly here, not 'Mqtt_$clientId' unless intentional.
//                                          // If your broker log shows 'Mqtt_TP1A...', then keep it.
//                                          // But if you're using 'TP1A...', remove the 'Mqtt_'.
//                                          // Let's assume you remove 'Mqtt_' for simplicity and consistency with clientId field.

//     _client.connectionMessage = connMessage;

//     try {
//       print('🔌 Conectando a MQTT con ClientId: $clientId...'); // More detailed print
//       await _client.connect();
//     } catch (e) {
//       print("❌ Error al conectar MQTT para $clientId: $e");
//       _client.disconnect();
//     }

//     if (_client.connectionStatus?.state == MqttConnectionState.connected) {
//       _isConnected = true;
//       print('✅ Conectado a MQTT con ClientId: $clientId');

//       final topic = 'webrtc/$userId';
//       _client.subscribe(topic, MqttQos.atLeastOnce);
//       print('📡 MQTT: Intentando subscribir a topic: $topic para userId: $userId'); // New print

//       _client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//         print('✅ MQTT Updates Listener Triggered!'); // New print
//         if (c == null || c.isEmpty) {
//           print('❗ MQTT Updates Listener: Received null or empty list.');
//           return;
//         }

//         final recMess = c[0].payload as MqttPublishMessage;
//         final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

//         print('📨 MQTT: Mensaje recibido en topic "${c[0].topic}" para $userId: $payload'); // More detailed print
//         try {
//           final message = jsonDecode(payload) as Map<String, dynamic>;
//           print('✅ MQTT: Mensaje JSON parseado exitosamente.'); // New print
//           onSignalReceived(message);
//         } catch (e) {
//           print("⚠️ Error al parsear mensaje MQTT en el listener: $e. Payload: $payload"); // More detailed error
//         }
//       }, onError: (e) {
//         print('❌ MQTT Updates Listener: Error en stream: $e'); // Add error listener for stream
//       }, onDone: () {
//         print('🚪 MQTT Updates Listener: Stream cerrado.'); // Add onDone listener
//       });
//     } else {
//       print('🚫 Conexión fallida para $clientId: ${_client.connectionStatus}');
//       _client.disconnect();
//     }
//   }

//   void sendSignal(String toUserId, Map<String, dynamic> message) async{
//     if (!_isConnected) {      
//       print("🚫 No conectado a MQTT, no se puede enviar señal.");
//       return;
//     }

//     final topic = 'webrtc/$toUserId';
//     final payload = jsonEncode(message);
//     final builder = MqttClientPayloadBuilder()..addString(payload);

//     _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
//     print("📤 MQTT: Señal enviada por $userId a $toUserId (topic: $topic): $payload"); // Enhanced print
//   }

//   void _onConnected() {
//     print('🔗 MQTT conectado (_onConnected callback).');
//   }

//   void _onDisconnected() {
//     print('❌ MQTT desconectado (_onDisconnected callback).');
//     _isConnected = false;
//   }

//   void disconnect() {
//     print('🔌 MQTT: Desconectando cliente...');
//     _client.disconnect();
//   }
// }