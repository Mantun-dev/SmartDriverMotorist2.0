// // WebRTCCallPage.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_auth/helpers/base_client.dart';
// import 'package:flutter_auth/providers/MqttSignalingService.dart';
// import 'package:flutter_auth/providers/WebRTCController.dart';
// import 'package:flutter_auth/providers/device_info.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

// class WebRTCCallPage extends StatefulWidget {
//   final String selfId;
//   final String targetId;
//   final bool isCaller;
//   final String? roomId;
//   final String? tripId;

//   WebRTCCallPage({
//     super.key,
//     required this.selfId,
//     required this.targetId,
//     required this.isCaller,
//     this.roomId,
//     this.tripId,
//   });

//   @override
//   State<WebRTCCallPage> createState() => _WebRTCCallPageState();
// }

// class _WebRTCCallPageState extends State<WebRTCCallPage> {
//   late MqttSignalingService _signalingService;
//   WebRTCController? _webrtcController;

//   bool _isConnected = false;
//   bool _isLoading = true;
//   bool _showVideo = false; // NEW: Control visibility of video streams
//   bool _isLocalCameraOn = false; // NEW: Track local camera state

//   @override
//   void initState() {
//     super.initState();
//     _startCallAutomatically();
//   }

//   Future<void> _startCallAutomatically() async {
//     setState(() {
//       _isLoading = true;
//     });

//     String? currentDeviceId = await getDeviceId();
//     if (currentDeviceId == null || currentDeviceId != widget.selfId) {
//       print("Error: Device ID mismatch or not found. Cannot proceed with call.");
//       setState(() { _isLoading = false; });
//       return;
//     }

//     _signalingService = MqttSignalingService(
//       broker: 'callmqtt.smtdriver.com',
//       clientId: currentDeviceId,
//       userId: widget.selfId,
//       onSignalReceived: (message) {
//         print('❓ WebRTCCallPage: Placeholder onSignalReceived received message: $message');
//       },
//     );

//     try {
//       await _signalingService.connect();
//     } catch (e) {
//       print("Error connecting to MQTT: $e");
//       setState(() { _isLoading = false; });
//       return;
//     }
//     print('Initializing WebRTCController with selfId: ${widget.selfId}, targetId: ${widget.targetId}');

//     _webrtcController = WebRTCController(
//       isCaller: widget.isCaller, // Pass isCaller here
//       selfId: widget.selfId,
//       targetId: widget.targetId,
//       signalingService: _signalingService,
//       onRemoteStream: (stream) {
//         print("🌐 Remote stream received on WebRTCCallPage");
//         // No setState(_showVideo = true) here, as video is now controlled by button
//         setState(() {}); // Trigger rebuild to update renderers
//       },
//       onControllerReady: (selfId) {
//         print("🎉 WebRTCController reports ready for device: $selfId");

//         if (!widget.isCaller) {
//           print("🚀 Receiver (${selfId}) is sending 'ready' signal to ${widget.targetId}");
//           _signalingService.sendSignal(widget.targetId, {
//             'type': 'ready',
//             'from': selfId,
//             'to': widget.targetId,
//           });
//         }
//       },
//     );

//     try {
//       await _webrtcController!.initialize(isCaller: widget.isCaller); // Pass isCaller to initialize method
//       print("WebRTCController initialized for ${widget.selfId}. isCaller: ${widget.isCaller}");
//       setState(() {
//         _isConnected = true;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print("Error initializing WebRTC Controller: $e");
//       setState(() { _isLoading = false; });
//       return;
//     }
//   }

//   void _hangUp() {
//     _webrtcController?.dispose();
//     _webrtcController = null;
//     _signalingService.disconnect();
//     setState(() {
//       _isConnected = false;
//     });
//     print('colgóoo la llamada************');
//     print(widget.roomId);
//     validateTripCall(widget.roomId, 'ended');
//     Navigator.of(context).pop();
//   }

//   validateTripCall(roomId, callStatus) async {
//     await BaseClient().get('https://admin.smtdriver.com/updateCallerToTrip/$roomId/$callStatus',{"Content-Type": "application/json"});     
//   }


//   // NEW: Toggle video visibility and camera state
//   Future<void> _toggleVideo() async {
//     if (_webrtcController != null) {
//       await _webrtcController!.toggleCamera();
//       setState(() {
//         _showVideo = !_showVideo;
//         _isLocalCameraOn = _webrtcController!.isCameraEnabled; // Update local state
//       });
//       print('Video visibility toggled to: $_showVideo, Local camera state: $_isLocalCameraOn');
//     }
//   }

//   @override
//   void dispose() {
//     _webrtcController?.dispose();
//     _signalingService.disconnect();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Llamada WebRTC')),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Text('Tu ID: ${widget.selfId}', style: const TextStyle(fontWeight: FontWeight.bold)),
//             Text('ID Destino: ${widget.targetId}', style: const TextStyle(fontWeight: FontWeight.bold)),
//             Text('Rol: ${widget.isCaller ? "Emisor" : "Receptor"}', style: const TextStyle(fontWeight: FontWeight.bold)),
//             if (widget.roomId != null) Text('Room ID: ${widget.roomId}', style: const TextStyle(fontWeight: FontWeight.bold)),
//             if (widget.tripId != null) Text('Trip ID: ${widget.tripId}', style: const TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             if (_isLoading)
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(height: 16),
//                       Text('Estableciendo conexión...', style: TextStyle(fontSize: 16)),
//                     ],
//                   ),
//                 ),
//               )
//             else if (_isConnected) ...[
//               // --- Video View Layout ---
//               Expanded(
//                 child: Stack( // Use Stack for picture-in-picture
//                   children: [
//                     // Main Remote Video
//                     Positioned.fill(
//                       child: _showVideo && _webrtcController!.remoteRenderer.srcObject != null
//                           ? RTCVideoView(_webrtcController!.remoteRenderer)
//                           : Container(color: Colors.black, child: Center(child: Icon(Icons.person, size: 100, color: Colors.white))),
//                     ),
//                     // Local Video (small, top-right corner)
//                     Positioned(
//                       right: 16.0,
//                       top: 16.0,
//                       child: SizedBox(
//                         width: 120.0,
//                         height: 160.0,
//                         child: _showVideo && _webrtcController!.localRenderer.srcObject != null
//                             ? RTCVideoView(_webrtcController!.localRenderer, mirror: true)
//                             : Container(color: Colors.grey[800], child: Center(child: Icon(Icons.person_outline, color: Colors.white, size: 60))),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // --- Control Buttons ---
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _toggleVideo,
//                     icon: Icon(_showVideo ? Icons.videocam_off : Icons.videocam),
//                     label: Text(_showVideo ? 'Apagar Video' : 'Encender Video'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _showVideo ? Colors.orange : Colors.blue,
//                     ),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _hangUp,
//                     icon: const Icon(Icons.call_end),
//                     label: const Text('Finalizar Llamada'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   ),
//                 ],
//               ),
//             ] else // If not loading and not connected (implies error or failed connection)
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'No se pudo conectar a la llamada. Por favor, intente de nuevo.',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.red, fontSize: 16),
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('Volver'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }