import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_auth/Drivers/Screens/calls/WebRTCCallPage.dart';
import 'package:flutter_auth/helpers/base_client.dart';
import 'package:flutter_auth/providers/device_info.dart';

// ignore: must_be_immutable
class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  dynamic array = {};
  IncomingCallScreen({super.key, required this.callerName, required this.array});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _startRingtone();
  }

  void _startRingtone() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // await _audioPlayer.play(UrlSource('android.resource://com.smartdriver.devs/raw/call'));
  }

  void _stopRingtone() {
    _audioPlayer.stop();
  }

  void _onAccept() async{
    String? deviceId = await getDeviceId();
    final data = widget.array;
    final roomId = data['roomId'];
    final tripId = data['tripId'];
    final callType = data['callType'];
    final callerDeviceId = data['callerDeviceId'];
    validateTripCall(roomId, 'answered');
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => WebRTCCallPage(
    //       selfId: '$deviceId',
    //       targetId: '$callerDeviceId',
    //       isCaller: callType=="Incoming"? false: true,
    //       roomId: '$roomId',
    //       tripId: '$tripId',
    //     ),
    //   ),
    // );

    //Navigator.pop(context);
  }

  validateTripCall(roomId, callStatus) async {
    await BaseClient().get('https://admin.smtdriver.com/updateCallerToTrip/$roomId/$callStatus',{"Content-Type": "application/json"});     
  }

  void _onReject() {
    _stopRingtone();
    final data = widget.array;
    final roomId = data['roomId'];
    // lógica para rechazar la llamada
    validateTripCall(roomId, 'ended');
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.callerName,
                style: const TextStyle(color: Colors.white, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "reject",
                    onPressed: _onReject,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end),
                  ),
                  FloatingActionButton(
                    heroTag: "accept",
                    onPressed: _onAccept,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.call),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
