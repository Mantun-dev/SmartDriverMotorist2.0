// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_auth/providers/webrtc_service.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

// class CallScreen extends StatefulWidget {
//   final WebRTCService webrtcService;
//   final bool isOffer;  
//   final String? remoteSdp;
//   final Function(String sdp, String type)? onAnswerGenerated;

//   CallScreen({required this.webrtcService, required this.isOffer, this.onAnswerGenerated, this.remoteSdp});

//   @override
//   _CallScreenState createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   MediaStream? _remoteStream;

//   @override
//   void initState() {
//     super.initState();
//     _initializeRenderers();
//     _startWebRTC();
//   }

//   Future<void> _initializeRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

// Future<void> _startWebRTC() async {
//   final Map<String, dynamic> config = {
//     "iceServers": [
//       {"urls": "stun:stun.l.google.com:19302"},
//     ]
//   };

//   final Map<String, dynamic> constraints = {
//     "mandatory": {},
//     "optional": [],
//   };

//   // 🔁 Limpieza previa para evitar reutilización de peerConnection antigua
//   if (widget.webrtcService.peerConnection != null) {
//     await widget.webrtcService.peerConnection!.close();
//     widget.webrtcService.peerConnection = null;
//   }

//   _peerConnection = await createPeerConnection(config, constraints);
//   widget.webrtcService.peerConnection = _peerConnection;

//   await Helper.selectAudioOutput('speaker');

//   // 🧊 ICE candidate listener
//   _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//     if (candidate != null) {
//       print('Nuevo ICE Candidate receptor: ${candidate.candidate}');
//       final message = {
//         'type': 'webrtc',
//         'action': 'iceCandidate',
//         'candidate': candidate.candidate,
//         'sdpMid': candidate.sdpMid,
//         'sdpMLineIndex': candidate.sdpMLineIndex,
//         'from': "TP1A.220624.014",
//         'to': "HONORALI-N23",
//       };
//       widget.webrtcService.sendWebRTCSignal(jsonEncode(message));
//     }
//   };

//   // 🎯 Listener moderno para pistas entrantes
//   _peerConnection?.onTrack = (RTCTrackEvent event) async {
//     print("📡 Track recibido: ${event.track.kind}, enabled=${event.track.enabled}");

//     MediaStream remoteStream;

//     if (event.streams.isNotEmpty) {
//       remoteStream = event.streams.first;
//     } else {
//       remoteStream = await createLocalMediaStream('remote');
//       remoteStream.addTrack(event.track);
//     }

//     if (_remoteRenderer.srcObject == null) {
//       setState(() {
//         _remoteRenderer.srcObject = remoteStream;
//       });
//     }

//     if (event.track.kind == 'audio') {
//       print("🎧 Audio recibido");
//       await Helper.setSpeakerphoneOn(true);
//     }
//   };

//   // 🔄 Compatibilidad con versiones más antiguas
//   _peerConnection?.onAddStream = (MediaStream stream) {
//     print("📦 Stream agregado (legacy): ${stream.id}");
//     if (_remoteRenderer.srcObject == null) {
//       setState(() {
//         _remoteRenderer.srcObject = stream;
//       });
//     }
//   };

//   // 🎙️ Obtener audio y video local
//   _localStream = await navigator.mediaDevices.getUserMedia({
//     "audio": true,
//     "video": true,
//   });

//   widget.webrtcService.localStream = _localStream;

//   // ➕ Agregar pistas locales al peer connection
//   _localStream!.getTracks().forEach((track) {
//     _peerConnection!.addTrack(track, _localStream!);
//   });

//   print("🎙️ Local stream creado");
//   print("🔊 Pistas de audio: ${_localStream?.getAudioTracks().length}");
//   _localStream?.getAudioTracks().forEach((track) {
//     print("➡️ Local audio track: enabled=${track.enabled}, muted=${track.muted}");
//   });

//   // 🎥 Mostrar video local
//   _localRenderer.srcObject = _localStream;

//   // 📡 Si no somos el que envió la oferta, respondemos
//   if (!widget.isOffer) {
//     final remoteDesc = RTCSessionDescription(widget.remoteSdp, 'offer');
//     await _peerConnection!.setRemoteDescription(remoteDesc);

//     RTCSessionDescription answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);
//     widget.onAnswerGenerated?.call(answer.sdp!, answer.type!);
//   }
// }


//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     _peerConnection?.close();
//     _localStream?.dispose();
//     _remoteStream?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Center(
//             child: RTCVideoView(_remoteRenderer),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             child: SizedBox(
//               width: 120,
//               height: 160,
//               child: RTCVideoView(_localRenderer, mirror: true),
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 FloatingActionButton(
//                   onPressed: () {
//                     _peerConnection?.close();
//                     Navigator.pop(context);
//                   },
//                   backgroundColor: Colors.red,
//                   child: Icon(Icons.call_end),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
