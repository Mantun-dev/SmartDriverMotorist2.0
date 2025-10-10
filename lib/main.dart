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

  final callType = message.data['callType'];
  if (callType == 'Incoming') {
    // Al recibir la notificación de llamada en segundo plano o cerrado,
    // disparamos la Notificación Local con fullScreenIntent: true.
    await PushNotificationServices.showIncomingCallNotification(
      callerName: message.data['userName'],
      payload: jsonEncode(message.data),  // Pasar el payload completo para re-navegación
    );
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  final payload = response.payload;
  if (payload != null) {
    try {
      final data = jsonDecode(payload);
      PushNotificationServices.handleNotificationNavigation(data);
    } catch (e) {
      print('Error al decodificar payload en background: $e');
    }
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

  // Paso 1: Inicializar flutter_local_notifications.
  await PushNotificationServices.init(
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

  // Registra el handler de mensajes en segundo plano de FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Inicializar servicios, pasando el GlobalKey
  await PushNotificationServices.initializeApp(navigatorKey); 

  // Paso 2: Obtener el mensaje inicial de FCM
  RemoteMessage? initialFCMMessage = await FirebaseMessaging.instance.getInitialMessage();
  Map<String, dynamic>? initialCallData;

  if (initialFCMMessage != null && initialFCMMessage.data['callType'] == 'Incoming') {
    initialCallData = initialFCMMessage.data;
  }
  runApp(MyApp(initialCallData: initialCallData, navigatorKey: navigatorKey));
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, dynamic>? initialCallData;

  const MyApp({
    super.key,
    required this.navigatorKey, // Ahora requiere la clave
    this.initialCallData, // Recibe la data de la llamada inicial
  }); 
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final prefs = new PreferenciasUsuario();
  @override
  void initState() {
    super.initState(); 
    checkAudioPermission();
    // Asignación de la clave al servicio (Aunque ya se hace en main, se mantiene por si acaso)
    PushNotificationServices.initializeApp(widget.navigatorKey); 
    
    // 💡 LÓGICA DE NAVEGACIÓN INICIAL (Cubre FCM getInitialMessage Y FSI array fallback)
    if (widget.initialCallData != null || PushNotificationServices.array != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Prioriza la data del constructor (FCM) o usa la data estática (FSI fallback)
        final dataToNavigate = widget.initialCallData ?? PushNotificationServices.array;
        
        if (dataToNavigate != null) {
          print("Intentando navegar (Inicial/Fallback) con data: $dataToNavigate");
          PushNotificationServices.handleNotificationNavigation(dataToNavigate);
          // Limpia la data estática después de usarla para evitar re-navegación
          PushNotificationServices.array = null; 
        }
      });
    }

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
        navigatorKey: widget.navigatorKey,
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