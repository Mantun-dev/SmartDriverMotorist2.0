// import 'dart:convert';

// import 'package:flutter_auth/helpers/loggers.dart';
// import 'package:flutter_auth/providers/mqtt_class.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:mqtt_client/mqtt_client.dart';

// class WebRTCService {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   MQTTManager? mqttManager;
//   String? localSdp;
//   String? remoteSdp;
//   RTCPeerConnection? get peerConnection => _peerConnection;
//    set peerConnection(RTCPeerConnection? connection) => _peerConnection = connection;
//   MediaStream? get localStream => _localStream;
//   set localStream(MediaStream? stream) => _localStream = stream;

//   WebRTCService(this.mqttManager);
//   final Map<String, dynamic> _config = {
//     'iceServers': [
//       {'urls': 'stun:stun.l.google.com:19302'}, // Servidor STUN gratuito
//     ]
//   };


//   Future<void> initialize() async {      
//     _peerConnection = await createPeerConnection(_config);
    
//     // Agregar stream de audio (voz)
//     _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});
//     print("🟢 Stream local creado: $_localStream");
//     print("🔊 Pistas de audio: ${_localStream?.getAudioTracks()}");
//     _localStream?.getTracks().forEach((track) {
//       print("📡 Añadiendo pista: ${track.kind}");
//       _peerConnection?.addTrack(track, _localStream!);
//     });

//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       print('Nuevo ICE Candidate local: ${candidate.candidate}');
//       // ignore: unnecessary_null_comparison
//       if (candidate != null) {
//         final message = {
//           'type': 'webrtc',
//           'action': 'iceCandidate',
//           'candidate': candidate.candidate,
//           'sdpMid': candidate.sdpMid,
//           'sdpMLineIndex': candidate.sdpMLineIndex,
//           'from': "TP1A.220624.014", // Asegúrate de tener el deviceId disponible aquí
//           'to': "QP1A.190711.020", // Asegúrate de tener el targetDeviceId disponible aquí
//         };
//         sendWebRTCSignal(jsonEncode(message));
//       }
//     };

//     _peerConnection?.onTrack = (RTCTrackEvent event) {
//       print('Nueva pista recibida: ${event.streams[0]}');
//     };
//   }

  
//     Future<void> createOffer(String targetDeviceId, String deviceId) async {      
//       if (_peerConnection == null) {
//         _peerConnection = await createPeerConnection({
//           'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]
//         });
//       }
      
//       RTCSessionDescription offer = await _peerConnection!.createOffer();
//       localSdp = offer.sdp;
//       logger.e("localSdp deberia funkar ********************************************.");
//       logger.e(localSdp);

//       await _peerConnection!.setLocalDescription(offer);

//       final message = {
//         'type': 'webrtc',
//         'action': 'offer',
//         'sdp': offer.sdp,
//         'sdpType': offer.type,
//         'from': deviceId,
//         'to': targetDeviceId,
//       };
//       print(message);
//       sendWebRTCSignal(jsonEncode(message));
//     }



//   /// **Envío de señales WebRTC**
//   void sendWebRTCSignal(String message) {
    
//     final builder = MqttClientPayloadBuilder();
//     builder.addString(message);
//     mqttManager?.client?.publishMessage("webrtc/signal", MqttQos.atLeastOnce, builder.payload!);
//     logger.d("Señal WebRTC enviada: $message");
//   }

//   // Future<void> createOffer() async {
//   //   RTCSessionDescription offer = await _peerConnection!.createOffer();
//   //   await _peerConnection!.setLocalDescription(offer);
//   //   print('Oferta SDP creada: ${offer.sdp}');
//   // }

//   Future<void> createAnswer() async {
//     RTCSessionDescription answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);
//     print('Respuesta SDP creada: ${answer.sdp}');
//   }

//   Future<void> setRemoteDescription(String sdp, String type) async {
//     RTCSessionDescription desc = RTCSessionDescription(sdp, type);
//     await _peerConnection!.setRemoteDescription(desc);
//   }

//   void closeConnection() {
//     _localStream?.dispose();
//     _peerConnection?.close();
//     _peerConnection = null;
//   }
// }
