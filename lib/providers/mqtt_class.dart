// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:battery_plus/battery_plus.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// //import 'package:flutter/material.dart';
// import 'package:flutter_auth/helpers/loggers.dart';
// import 'package:flutter_auth/main.dart';
// import 'package:flutter_auth/providers/calls.dart';
// import 'package:flutter_auth/providers/providerWebRtc.dart';
// import 'package:flutter_auth/providers/provider_mqtt.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// //import 'package:flutter_auth/providers/calls.dart';
// //import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:provider/provider.dart';


// class MQTTManager {
//   MqttServerClient? client;
//   String deviceId;
//   //RTCPeerConnection? _peerConnection;

//   MQTTManager(this.deviceId) {
//     client = MqttServerClient('mqtt.smtdriver.com', 'Mqtt_$deviceId');
//     client?.port = 1883;
//     client?.logging(on: true);
//     client?.keepAlivePeriod = 120;
//     client?.onDisconnected = _onDisconnected;
//     client?.onConnected = _onConnected;
//     client?.onSubscribed = _onSubscribed;
     
//     final connMessage = MqttConnectMessage() 
//       .withWillTopic('willtopic')
//       .withWillMessage('willMessage')
//       .startClean()
//       .withWillQos(MqttQos.atLeastOnce)
//       .withClientIdentifier('Mqtt_$deviceId');

//     client?.connectionMessage = connMessage;
//   }

//   Future<bool> connect() async {
//     try {
//       var status = await client?.connect();
//       if (status?.state != MqttConnectionState.connected) {
//         logger.e('Error al conectar: ${status?.state}', error: '${status?.state}');  
//         client?.disconnect();
//         return false;
//       } else {
//         // logger.d('Conexión establecida');  
//         return true;
//       }
//     } catch (e) {
//       logger.e('Error al conectar: $e', error: '$e'); 
//       client?.disconnect();
//       return false;
//     }
//   }
//   void _onConnected() {
//     // logger.d('Conectado al servidor Aedes MQTT');
//     subscribeToTopic();
//   }

//   void subscribeToTopic() {
//     client?.subscribe('notificaciones/$deviceId', MqttQos.atLeastOnce);
//     client?.subscribe('webrtc/signal', MqttQos.atLeastOnce); // Escuchar señales WebRTC
//     // logger.d('Suscrito al tema notificaciones/$deviceId'); 
//   }

//   void _onSubscribed(String topic) {
//     logger.d('Suscrito al tema: $topic');  
//   }

//   int _baseRetryInterval = 30;
//   int _maxRetryInterval = 300;
//   int _currentRetryInterval = 30;
//   int _reconnectAttempts = 0;


//   void _onDisconnected() {
//     loggerNoStack.w('Desconectado del servidor MQTT');

//     _reconnectAttempts++;

//     _currentRetryInterval = min(_baseRetryInterval * pow(1.5, _reconnectAttempts).toInt(), _maxRetryInterval);

//     final jitter = Random().nextInt(_currentRetryInterval  ~/ 4);
//     final delayWithJitter = _currentRetryInterval + jitter;

//     Future.delayed(Duration(seconds: delayWithJitter), () async {
//       // Verificar el estado de la red antes de intentar
//       var connectivityResult = await Connectivity().checkConnectivity();
//       if (connectivityResult == ConnectivityResult.none) {
//         loggerNoStack.i('Sin conexión a internet, posponiendo reconexión');
//         return;
//       }

//       loggerNoStack.i('Intentando reconectar...');
//       bool connected = await connect();
//       if (connected) {
//         logger.d('Reconexión exitosa');
//         _reconnectAttempts = 0;
//         _currentRetryInterval = _baseRetryInterval;
//       } else {
//         loggerNoStack.w('Fallo al reconectar, próximo intento en $_currentRetryInterval segundos');
//       }
//     });
//   }

//   void listenForMessages(void Function(Map<dynamic, dynamic>) callback) {
//     client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
//       for (var message in messages) {
//         final payload = message.payload as MqttPublishMessage;
//         final messageBytes = payload.payload.message;

//         // Decodifica el mensaje como UTF-8
//         final messageText = utf8.decode(messageBytes);

//         // Decodifica el JSON
//         try {
//           final jsonData = jsonDecode(messageText);
//           //logger.d("Mensaje recibido: $jsonData");
//           // Verifica si la acción es 'iceCandidate'
//           if (jsonData.containsKey('action') && jsonData['action'] == 'iceCandidate') {
//             // Verifica si existen las claves 'candidate', 'sdpMid' y 'sdpMLineIndex' en jsonData
//             if (jsonData.containsKey('candidate') &&
//                 jsonData.containsKey('sdpMid') &&
//                 jsonData.containsKey('sdpMLineIndex')) {
//               // Crea un nuevo mapa con la información adicional
//               final updatedJsonData = {
//                 ...jsonData, // Incluye los datos existentes
//                 'candidate': jsonData['candidate'],
//                 'sdpMid': jsonData['sdpMid'],
//                 'sdpMLineIndex': jsonData['sdpMLineIndex'],
//               };
//               callback(updatedJsonData);
//             } else {
//               // Si la acción es 'iceCandidate' pero faltan los campos, pasa el jsonData original
//               callback(jsonData);
//               print('Advertencia: Mensaje iceCandidate sin candidate, sdpMid o sdpMLineIndex');
//             }
//           } else {
//             // Si la acción no es 'iceCandidate', simplemente pasa el jsonData original
//             callback(jsonData);
//           }
//           logger.e('Vamos da: $jsonData', error: 'Error conexión');   
//           if (jsonData.containsKey("type") && jsonData["type"] == "webrtc") {
//             handleWebRTCSignal(jsonData);
//           }
        
          
//         } catch (e) {
//           print('Error al decodificar JSON: $e');
//         }
//       }
//     });
//   }
//     void handleWebRTCSignal(Map<String, dynamic> signal)async {
//     logger.d("Señal WebRTC recibida: $signal");
    
//     // if (signal.containsKey("sdp")) {
//     //   String sdp = signal["sdp"];
//     //   bool isOffer = signal["sdpType"] == "offer"; // Determina si es una oferta

//     //   if (navigatorKey.currentContext != null) {
//     //     showCallUI(navigatorKey.currentContext!, sdp, isOffer);
//     //   }
//     // } else {
//     //   loggerNoStack.w("No se encontró SDP en la señal WebRTC");
//     // }
//   }

//     void showCallUI(BuildContext context, String sdp, bool isOffer)async {
//     final mqttManagerProvider = Provider.of<MQTTManagerProvider>(context, listen: false);
                                

//                                 if (mqttManagerProvider.mqttManager == null) {
//                                   await mqttManagerProvider.initializeMQTT(deviceId);
//                                 }

//                                 bool isConnected = await mqttManagerProvider.mqttManager!.ensureConnection();
//                                 if (!isConnected) {
//                                   print("No se pudo conectar al MQTT");
//                                   return;
//                                 }

//     final webrtcProvider = Provider.of<WebRTCProvider>(context, listen: false);
//                                 final webRTCService = webrtcProvider.init(mqttManagerProvider.mqttManager!);

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CallScreen(
//                                       webrtcService: webRTCService,
//                                       isOffer: true,
//                                     ),),
//     );
//   }

//   void disconnect() {
//      print("MQTT DISCONNECT LLAMADO");
//     client?.disconnect();
//   }

  
//   // Verifica si el cliente está conectado antes de realizar alguna acción
//   Future<bool> ensureConnection() async {
//     if (client?.connectionStatus?.state == MqttConnectionState.connected) {
          
//     return true;
//     }

//     final battery = Battery();
//     final level = await battery.batteryLevel;
//     if (level < 20) {
//       loggerNoStack.w('Batería baja ($level%), retrasando reconexión');
//       return false;
//     }    

//     // Intenta reconectar
//     bool connected = await connect();
//     if (!connected) {
//       loggerNoStack.w('No se pudo reconectar al servidor MQTT');
//       return false;
//     }
    
//     return await connect();
//   }
// }