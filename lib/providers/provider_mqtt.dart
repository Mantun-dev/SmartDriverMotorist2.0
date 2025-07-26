// // En MQTTManagerProvider.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter_auth/providers/mqtt_class.dart';

// class MQTTManagerProvider with ChangeNotifier {
//   MQTTManager? _mqttManager;

//   MQTTManager? get mqttManager => _mqttManager;

//   Future<void> initializeMQTT(String deviceId) async {
//     _mqttManager = MQTTManager(deviceId);
//     await _mqttManager!.connect();
//     notifyListeners();
//   }
// }