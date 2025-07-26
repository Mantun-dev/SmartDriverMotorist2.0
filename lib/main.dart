import 'dart:async';
import 'dart:convert';

import 'dart:io';

// import 'package:battery_plus/battery_plus.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/confirm_trips.dart';
//import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';

import 'package:flutter_auth/Drivers/SharePreferences/services.dart';
//import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/components/splashView.dart';
import 'package:flutter_auth/providers/JitsiCallPage.dart';
// import 'package:flutter_auth/helpers/loggers.dart';
// import 'package:flutter_auth/providers/calls.dart';
//import 'package:flutter_auth/helpers/base_client.dart';
//import 'package:flutter_auth/helpers/res_apis.dart';
import 'package:flutter_auth/providers/chat.dart';
// import 'package:flutter_auth/providers/device_info.dart';
// import 'package:flutter_auth/providers/mqtt_class.dart';
// import 'package:flutter_auth/providers/providerWebRtc.dart';
// import 'package:flutter_auth/providers/provider_mqtt.dart';
// import 'package:flutter_auth/providers/webrtc_service.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:mqtt_client/mqtt_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'Drivers/SharePreferences/preferencias_usuario.dart';
import 'components/Tema.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;

class MyHttpoverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

int pantallaP = 0;

void setPantallaP(int numero){
  pantallaP = numero;
}

int ub = 0;

void setUb(int numero){
  ub = numero;
}

int getUb(){
  return ub;
}

// Función top-level para manejar mensajes en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // Aquí puedes manejar la notificación local como ya lo haces
  final data = message.data;
  if (data['callType'] == 'Incoming') {
    await PushNotificationServices.showIncomingCallNotification(
      callerName: data['userName'],
      payload: jsonEncode(data),
    );
  } else {
    PushNotificationServices.showNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      payload: jsonEncode(data), // Es mejor siempre enviar el payload como JSON
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey();
// En un archivo global, por ejemplo, global_stream.dart


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   // Inicializar canal antes de ejecutar la app  
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //   FlutterLocalNotificationsPlugin();

// await flutterLocalNotificationsPlugin
//     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//     ?.requestPermission();

  HttpOverrides.global = new MyHttpoverrides();
  final prefs = new PreferenciasUsuario(); 
  await prefs.initPrefs();  
  await Firebase.initializeApp(); // ✅ Luego, inicializar Firebase

  // Registra el handler de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
   final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
  await PushNotificationServices.initializeApp(globalNavigatorKey);
   // Esperar un poco antes de registrar el canal
  // Manejar notificaciones que abrieron la aplicación (app terminada)
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // Retrasar la navegación para asegurar que el navigatorKey esté listo
    Future.delayed(Duration(milliseconds: 500), () {
      PushNotificationServices.handleNotificationNavigation(initialMessage.data);
    });
  }
  // Inicializar el canal de WebRTC
  // const MethodChannel channel = MethodChannel('webrtc_channel');
  
  // initializeService();
  // FlutterBackgroundService().on('webrtc_event').listen((event) {
  //   print("🔹 Evento recibido desde background: $event");
  //   final Map<String, dynamic> signal = Map<String, dynamic>.from(event!);
  //   channel.invokeMethod("new_webrtc_event", signal);
  //   handleWebRTCSignal(navigatorKey.currentContext, signal);
  // });

  // // Verificar si el canal está disponible
  // await checkWebRTCChannel(channel);
 
  runApp(MyApp());
}


 void handleWebRTCSignal(BuildContext? context, Map<String, dynamic>? signal)async {
      // if (signal == null || !signal.containsKey("action")) return;
      // final action = signal['action'];
      // final fromDeviceId = signal['from'];
      // String? deviceId = await getDeviceId();
      // logger.e('Aja a ver que conexion hay: $action ', error: 'Keh');       

      // if (action == 'offer') {
      //   if (!signal.containsKey("sdp")) return;
      //   String sdp = signal["sdp"];
      //   final mqttManagerProvider = Provider.of<MQTTManagerProvider>(context!, listen: false);                                

      //   if (mqttManagerProvider.mqttManager == null) {
      //     await mqttManagerProvider.initializeMQTT(deviceId!);
      //   }

      //   bool isConnected = await mqttManagerProvider.mqttManager!.ensureConnection();
      //   if (!isConnected) {
      //     print("No se pudo conectar al MQTT");
      //     return;
      //   }
        
      //   final webrtcProvider = Provider.of<WebRTCProvider>(context, listen: false);
      //   final webRTCService = webrtcProvider.init(mqttManagerProvider.mqttManager!);
      //   await webRTCService.initialize();

      //   webRTCService.remoteSdp = sdp; 
      //   final remoteDesc = RTCSessionDescription(sdp, 'offer');
      //   await webRTCService.peerConnection!.setRemoteDescription(remoteDesc);

      //   RTCSessionDescription answer = await webRTCService.peerConnection!.createAnswer();
      //   await webRTCService.peerConnection!.setLocalDescription(answer);

      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => CallScreen(
      //         remoteSdp: sdp,
      //         webrtcService: webRTCService,
      //         isOffer: false,
      //         onAnswerGenerated: (answerSdp, answerType)async {
      //           final answerMessage = {
      //             'type': 'webrtc',
      //             'action': 'answer',
      //             'sdp': answerSdp,
      //             'sdpType': answerType,
      //             'from': deviceId, // mi dispositivo
      //             'to': fromDeviceId,   // quien hizo la oferta
      //           };
      //           final builder = MqttClientPayloadBuilder();
      //           builder.addString(jsonEncode(answerMessage));
      //           final mqttManager = MQTTManager(deviceId!);                
                
      //           // Connect and handle connection status
      //           try {
      //             isConnected = await mqttManager.connect();
      //             // logger.d('MQTT connection attempt result: $isConnected');    
      //           } catch (e) {
      //             logger.e('MQTT connection error: $e', error: 'Error conexión');    
      //             isConnected = false;
      //           }

      //           mqttManager.client?.publishMessage(
      //             "webrtc/signal",
      //             MqttQos.atLeastOnce,
      //             builder.payload!,
      //           );

      //           print("📤 Enviando respuesta (answer) a $fromDeviceId");
      //         },
      //       ),
      //     ),
      //   );
      // } else if (action == 'answer') {
      //   if (!signal.containsKey("sdp")) return;
      //   String sdp = signal["sdp"];
      //   final webrtcProvider = Provider.of<WebRTCProvider>(context!, listen: false);
      //   final webRTCService = webrtcProvider.webrtcService;

      //   if (webRTCService != null) {
      //     await webRTCService.setRemoteDescription(sdp, 'answer');
      //   } else {
      //     print("⚠️ No se encontró la instancia de WebRTCService.");
      //   }
      // }else if (action == 'iceCandidate') {
      //   if (!signal.containsKey('candidate') || signal['candidate'] == null) return;
      //   print('Recibiendo ICE Candidate remoto: ${signal['candidate']}');
      //   final candidate = RTCIceCandidate(
      //     signal['candidate'],
      //     signal['sdpMid'],
      //     signal['sdpMLineIndex'],
      //   );
      //   print("➡️ Agregando ICE candidate: $candidate");
      //   try {
      //   final webrtcProvider = Provider.of<WebRTCProvider>(context!, listen: false);
      //   print('Intentando agregar ICE Candidate al peerConnection del emisor...');
      //     await webrtcProvider.webrtcService?.peerConnection?.addCandidate(candidate);
      //     print('ICE Candidate agregado exitosamente (o eso parece).');
      //   } catch (e) {
      //     print('⚠️ Error al agregar ICE Candidate del receptor en el emisor: $e');
      //   }
      // }
  }

  // void showCallUI(BuildContext? context, String sdp, bool isOffer) {
  //   Navigator.push(
  //     context!,
  //     MaterialPageRoute(builder: (context) => CallScreen(sdp: sdp, isOffer: isOffer)),
  //   );
  // }

Future<void> checkWebRTCChannel(channel) async {
  await Future.delayed(Duration(seconds: 2)); // Espera para inicializar
  try {
    final bool? exists = await channel.invokeMethod("ping");
    print("✅ WebRTC channel disponible: $exists");
  } on PlatformException catch (e) {
    print("❌ Error de PlatformException: ${e.message}");
  } catch (e) {
    print("⚠️ Error desconocido al verificar WebRTC: $e");
  }
}


// @pragma('vm:entry-point')
// void initializeService()async {
//   final service = FlutterBackgroundService();
//   final battery = Battery();

//   service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: true, // Mantiene el servicio activo
//       autoStartOnBoot: true, // Reinicia el servicio si el dispositivo se reinicia
//       autoStart: true, // Inicia automáticamente cuando se abre la app
//       notificationChannelId: 'mqtt_service', // ID del canal de notificación
//       initialNotificationTitle: 'Servicio MQTT',
//       initialNotificationContent: 'Conectando...',
//       foregroundServiceNotificationId: 1, // ID de la notificación
//     ),
//     iosConfiguration: IosConfiguration(),
//   );
//   battery.onBatteryStateChanged.listen((BatteryState state) { 
//     if(state == BatteryState.charging){
//       service.invoke('increaseSyncRate');
//     }else{
//       service.invoke('reduceSyncRate');
//     }
//   });

//   await service.startService();
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Debug log for tracking service start
//   print("Background service starting...");
//   // final MethodChannel channel = MethodChannel('webrtc_channel');
  
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) { 
//       service.setAsForegroundService();
//     });

//     service.on('setAsBackground').listen((event) { 
//       service.setAsBackgroundService();
//     });
    
//     // Set as foreground service immediately to avoid getting stuck
//     service.setAsForegroundService();
//   }

  
//   // Get device ID
//   String? deviceId = await getDeviceId();
//   if (deviceId == null) {    
//     loggerNoStack.w('Failed to get device ID');
//     if (service is AndroidServiceInstance) {
//       service.setForegroundNotificationInfo(
//         title: 'Servicio Smart Driver', 
//         content: 'Error: No se pudo obtener el ID del dispositivo'
//       );
//     }
//     return;
//   }
  
//   // Create and connect MQTT manager
//   final mqttManager = MQTTManager(deviceId);
//   bool isConnected = false;
  
//   // Connect and handle connection status
//   try {
//     isConnected = await mqttManager.connect();
//     // logger.d('MQTT connection attempt result: $isConnected');    
//   } catch (e) {
//     logger.e('MQTT connection error: $e', error: 'Error conexión');    
//     isConnected = false;
//   }
  
//   // Update notification based on connection status
//   if (service is AndroidServiceInstance) {
//     service.setForegroundNotificationInfo(
//       title: 'Servicio Smart Driver', 
//       content: isConnected ? 'Conectado al servicio de Smart Driver' : 'Intentando conectar...'
//     );
//   }

//   // Setup message listener if connected
//   if (isConnected) {
//     mqttManager.listenForMessages((jsonData,){
//       final title = jsonData['title'];
//       final body = jsonData['body'];
//       // logger.d('Escuchando');
//       if (jsonData.containsKey("type") && jsonData["type"] == "webrtc") {  
//         try {
//           final Map<String, dynamic> webrtcEvent = Map<String, dynamic>.from(jsonData);
//           service.invoke('webrtc_event', webrtcEvent);                   
//         } catch (e) {
//           logger.e("⚠️ Error al verificar el canal WebRTC: $e");
//         }    
//       }
//       PushNotificationServices.showNotification(title: title, body: body);      
//       // logger.d('Message received: $jsonData'); 
//     });
//   }

//   // Variables para controlar la frecuencia
//   int normalSyncInterval = 5; // 5 minutos
//   int batterySavingInterval = 15; // 15 minutos
//   int currentInterval = normalSyncInterval;
//   Timer? periodicTimer;

//   // Función para realizar la verificación de conexión
//   Future<void> checkConnection() async {
//     var connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult == ConnectivityResult.none) {
//       // Sin conexión, no intentes reconectar aún
//       logger.d('Sin conexión a internet, esperando próxima verificación');
//       return;
//     }

//     try {
//       bool connectionStatus = await mqttManager.ensureConnection();
            
//       if (service is AndroidServiceInstance) {
//         if (await service.isForegroundService()) {
//           service.setForegroundNotificationInfo(
//             title: 'Servicio Smart Driver', 
//             content: connectionStatus 
//               ? 'Conectado al servicio de Smart Driver' 
//               : 'Reconectando...'
//           );
//         }
//       }
      
//       // Log current status for debugging
//       // logger.d('Connection status: $connectionStatus');       
//     } catch (e) {
//       logger.e('Error checking connection: $e', error: 'Error');      
//     }
//   }

//   // Función para iniciar el timer con el intervalo actual
//   void startPeriodicTimer() {
//     periodicTimer?.cancel();
//     periodicTimer = Timer.periodic(Duration(minutes: currentInterval), (timer) async {
//       await checkConnection();
//     });
//     // logger.d('Timer configurado con intervalo de $currentInterval minutos');
//   }

//   // Escuchar eventos para cambiar el intervalo
//   service.on('increaseSyncRate').listen((event) {
//     currentInterval = normalSyncInterval;
//     startPeriodicTimer();
//     // logger.d('Aumentando frecuencia de sincronización a $currentInterval minutos');
//   });

//   service.on('reduceSyncRate').listen((event) {
//     currentInterval = batterySavingInterval;
//     startPeriodicTimer();
//     // logger.d('Reduciendo frecuencia de sincronización a $currentInterval minutos');
//   });

//   // Iniciar con el intervalo normal
//   startPeriodicTimer();

//   // Verificar estado de la batería inicialmente
//   try {
//     final battery = Battery();
//     final batteryLevel = await battery.batteryLevel;
//     final batteryState = await battery.batteryState;
    
//     // Si la batería está baja, reducir la frecuencia desde el inicio
//     if (batteryLevel < 30 && batteryState == BatteryState.discharging) {
//       service.invoke('reduceSyncRate');
//     }
    
//     // Configurar listener para cambios en la batería
//     battery.onBatteryStateChanged.listen((BatteryState state) {
//       if (state == BatteryState.charging) {
//         service.invoke('increaseSyncRate');
//       } else if (state == BatteryState.discharging && batteryLevel < 30) {
//         service.invoke('reduceSyncRate');
//       }
//     });
//   } catch (e) {
//     logger.e('Error al configurar monitoreo de batería: $e');
//   }
  
//   // Realizar una verificación inicial de conexión
//   await checkConnection();

//   // Handle stop request
//   service.on('stop').listen((event) {
//     //print("Service stop requested");
//     mqttManager.disconnect();
//     periodicTimer?.cancel();
//     service.stopSelf();
//   });
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final prefs = new PreferenciasUsuario();
  @override
  void initState() {
    super.initState(); 
    checkAudioPermission();
    PushNotificationServices.initializeApp(navigatorKey);
    PushNotificationServices.messageStream.listen((event) {       
      if (event['type'] == "AGENT_TRANSFERED") {
        prefs.tripId = event['tripId'].toString();        
        navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => MyConfirmAgent())).then((_) => MyConfirmAgent());
      }

    });

    eventBus.on<ThemeChangeEvent>().listen((event) {
      // Actualizar el estado o realizar acciones según el evento recibido
      setState(() { 
        prefs.tema = !prefs.tema;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ChatProvider()),
        // ChangeNotifierProvider(create: (_) => MQTTManagerProvider()),  
        // ChangeNotifierProvider(create: (_) => WebRTCProvider()),        
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Smart Driver',
        // home: Stack(children: [
        //   WebRTCListener(),
        // ]),
        theme: prefs.tema!=true? appThemeDataLight : appThemeDataDark,
        //home: WelcomeScreen(),
        initialRoute: prefs.nombreUsuario == ""
            ? 'login'
            : 'home',
        routes: {
          'login': (BuildContext context) =>  UpgradeAlert(upgrader: Upgrader(dialogStyle: Platform.isIOS? UpgradeDialogStyle.cupertino: UpgradeDialogStyle.material),child: SplashView()),
          'home': (BuildContext context) => UpgradeAlert(upgrader: Upgrader(dialogStyle: Platform.isIOS? UpgradeDialogStyle.cupertino: UpgradeDialogStyle.material),child: HomeDriverScreen()),
          '/jitsi_call_page': (context) => JitsiCallPage(
              roomId: PushNotificationServices.array?['roomId'] ?? '',
              name: PushNotificationServices.array?['userName'] ?? 'Desconocido',
            ),
        },
      ),
    );
  }

  void checkAudioPermission() async {
    // Verificar si se tiene el permiso de grabación de audio
    var status = await Permission.microphone.status;
    
    if (status.isGranted) {
      // Permiso concedido

    } else {
      // No se ha solicitado el permiso, solicitarlo al usuario
      await Permission.microphone.request();
    }
  }
  
}

// class WebRTCListener extends StatefulWidget {
//   @override
//   _WebRTCListenerState createState() => _WebRTCListenerState();
// }

// class _WebRTCListenerState extends State<WebRTCListener> {
//   StreamSubscription? _subscription;

//   @override
//   void initState() {
//     super.initState();
//     _subscription = webrtcSignalStreamController.stream.listen((data) {
//       logger.d("Evento recibido en WebRTCListener: $data");
//     });
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<Map<String, dynamic>>(
//       stream: webrtcSignalStreamController.stream,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           logger.d("StreamBuilder recibió una señal: ${snapshot.data}");
//           final signal = snapshot.data!;
//           handleWebRTCSignal(context, signal);
//         } else if (snapshot.hasError) {
//           logger.e("Error en el StreamBuilder: ${snapshot.error}");
//         } else {
//           logger.d("StreamBuilder esperando datos...");
//         }
//         return Container(); 
//       },
//     );
//   }

//   void handleWebRTCSignal(BuildContext context, Map<String, dynamic> signal) {
//     if (signal.containsKey("sdp")) {
//       String sdp = signal["sdp"];
//       bool isOffer = signal["sdpType"] == "offer";
//       logger.d("sdp: $sdp");
//       logger.d("isOffer: $isOffer");
//       showCallUI(context, sdp, isOffer);
//     }
//   }

//   void showCallUI(BuildContext context, String sdp, bool isOffer) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CallScreen(sdp: sdp, isOffer: isOffer)),
//     );
//   }
// }


EventBus eventBus = EventBus();

class ThemeChangeEvent {
  final bool newTheme;

  ThemeChangeEvent(this.newTheme);
}