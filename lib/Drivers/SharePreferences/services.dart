import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatscreen.dart';
// import 'package:flutter_auth/providers/IncomingCallScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import '../../providers/JitsiCallPage.dart';

class PushNotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static final StreamController<dynamic> _messageStreamController = StreamController.broadcast();
  static Stream<dynamic> get messageStream => _messageStreamController.stream;

  static GlobalKey<NavigatorState>? navigatorKey;
  static dynamic array;
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  // Método para mostrar notificaciones
  static Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    var details = await _notificationDetails();
    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Detalles de la notificación para Android e iOS
  static Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.high,
        // Estas propiedades son específicas de Android y se ignoran en iOS.
        // Las mantengo para la compatibilidad cruzada, pero no tienen efecto en iOS.
      ),
      // Configuración específica para iOS
      iOS: DarwinNotificationDetails(
        // Puedes personalizar aquí si necesitas opciones específicas como
        // presentAlert, presentBadge, presentSound.
        // Por defecto, se mostrarán las alertas, el sonido y la insignia si están habilitados en los permisos.
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // Inicialización de la notificación y Firebase
  static Future<void> init({bool initScheduled = false}) async {
    // Para iOS, no necesitamos crear un "canal" explícitamente como en Android.
    // La configuración de permisos se maneja de forma diferente.

    // Android Initialization Settings
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS Initialization Settings (DarwinInitializationSettings for modern Flutter Local Notifications)
    // Nota: El sonido para iOS se maneja de manera diferente. Firebase Cloud Messaging (FCM)
    // envía el sonido directamente en el payload de la notificación APNs.
    // Para notificaciones locales en iOS con sonido personalizado, necesitas que el archivo de sonido
    // esté en el Runner/Resources de tu proyecto Xcode.
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: (id, title, body, payload) async {
      //   // Solo para iOS < 10.0 cuando la app está en primer plano
      //   // Puedes mostrar una alerta o manejar la notificación aquí.
      // },
    );

    const settings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Este callback reemplaza onSelectNotification para versiones más nuevas.
        final payload = response.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload);
            final callType = data['callType'];

            if (callType == 'Incoming') {
              final callerName = data['userName'] ?? 'Desconocido';
              final roomId = data['roomId'];
              navigatorKey!.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => JitsiCallPage(roomId: roomId, name: callerName),
                ),
              );
            } else {
              onNotifications.add(payload);
            }
          } catch (e) {
            print('Error al decodificar payload: $e');
          }
        }
      },
    );
  }

    // --- NUEVO MÉTODO PARA MANEJAR LA NAVEGACIÓN ---
  static void handleNotificationNavigation(Map<String, dynamic> data) {
    print('Intentando navegar con data: $data');
    final callType = data['callType'];

    if (callType == 'Incoming') {
      final callerName = data['userName'] ?? 'Desconocido';
      final roomId = data['roomId'];
      // Asegurarse de que navigatorKey esté disponible antes de intentar navegar
      if (navigatorKey?.currentState != null) {
        navigatorKey!.currentState?.push(
          MaterialPageRoute(
            builder: (_) => JitsiCallPage(roomId: roomId, name: callerName),
          ),
        );
        print('Navegando a JitsiCallPage');
      } else {
        print('Error: navigatorKey no está disponible para navegar a JitsiCallPage.');
        // Opcional: Podrías guardar el `data` en SharedPreferences aquí
        // para navegar una vez que la app esté completamente inicializada
        array = data; // Guarda el data si no se pudo navegar inmediatamente
      }
    } else if (data['type'] == "MESSAGE_NOTIFICATION") {
      if (navigatorKey?.currentState != null) {
        navigatorKey!.currentState?.push(MaterialPageRoute(
            builder: (_) => ChatScreen(
                  idAgent: data['agentId'].toString(),
                  nombreAgent: data['agentFullname'],
                  nombre: data['driverFullname'],
                  id: data['driverId'],
                  rol: "MOTORISTA",
                  tipoViaje: data['tripType'],
                  idV: data['tripId'],
                  pantalla: true,
                )));
        print('Navegando a ChatScreen');
      } else {
        print('Error: navigatorKey no está disponible para navegar al ChatScreen.');
      }
    } else {
      // Para otros tipos de notificaciones, simplemente emitir el payload
      onNotifications.add(jsonEncode(data));
    }
  }

  static Future _backgroundHandelr(RemoteMessage message) async {
    _messageStreamController.add(message.data);
    array = message.data;
    final data = message.data;
    final callType = data['callType'];
    print(data);
    if (callType == 'Incoming') {
      await showIncomingCallNotification(
        callerName: data['userName'],
        payload: jsonEncode(data),
      );
    } else {
      showNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        payload: data.toString(),
      );
    }
  }

  static Future _onMessageHandelr(RemoteMessage message) async {
    _messageStreamController.add(message.data);
    array = message.data;
    final data = message.data;
    final callType = data['callType'];
    print(data);
    if (callType == 'Incoming') {
      await showIncomingCallNotification(
        callerName: data['userName'],
        payload: jsonEncode(data),
      );
    } else {
      showNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        payload: data.toString(),
      );
    }
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    _messageStreamController.add(message.data);
    array = message.data;
    showNotification(
      title: message.notification!.title,
      body: '${message.notification!.body}',
    );
  }

  static Future<void> showIncomingCallNotification({
    required String? callerName,
    required String payload,
  }) async {
    // Para Android, mantenemos la configuración de canal específica para llamadas
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'call_channel', // ID de canal único
      'Llamadas',
      channelDescription: 'Notificaciones de llamadas entrantes',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // Propiedad específica de Android
      visibility: NotificationVisibility.public, // Propiedad específica de Android
      ticker: 'ticker', // Propiedad específica de Android
      sound: UriAndroidNotificationSound("assets/tunes/llamada.mp3"), // Sonido personalizado para Android
      playSound: true,
    );

    // Para iOS (Darwin), la configuración de sonido para llamadas entrantes
    // DEBE ser manejada a nivel de payload de FCM (APNs) en tu backend.
    // FlutterLocalNotificationsPlugin no puede reproducir sonidos de llamada
    // que se comporten como "ringtone" directamente desde el cliente iOS
    // si el sonido no está especificado en el payload APNs o si la app
    // no está en primer plano y el sonido no está configurado como crítico.
    // El archivo `llamada.mp3` debería ser agregado a Runner/Resources en Xcode
    // para que un payload de FCM lo pueda referenciar.
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Si el sonido 'llamada.mp3' está en tu bundle de recursos de iOS,
      // y quieres que se reproduzca para notificaciones locales, puedes
      // especificarlo aquí. Sin embargo, para llamadas entrantes tipo VoIP,
      // la lógica de sonido más avanzada (como un ringtone prolongado)
      // se maneja mejor a través de PushKit y CallKit en iOS, que están
      // fuera del alcance directo de Flutter Local Notifications y requieren
      // código nativo o plugins específicos de Jitsi/llamadas.
      // En un escenario real de llamada, el servidor enviaría una notificación APNs
      // con el campo `sound` apuntando al archivo de sonido en el bundle de la app.
      sound: 'llamada.mp3', // Asegúrate de que 'llamada.mp3' esté en Runner/Resources en Xcode.
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics, // Incluye la configuración iOS
    );

    await _notifications.show(
      12345, // ID único
      'Llamada entrante',
      '$callerName te está llamando',
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future initializeApp(GlobalKey<NavigatorState> navigatorKey) async {
    PushNotificationServices.navigatorKey = navigatorKey;
    await Firebase.initializeApp();
    await init();
    token = await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      token = newToken;
      print("Nuevo token de registro: $token");
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundHandelr);
    FirebaseMessaging.onMessage.listen(_onMessageHandelr);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

    print(token);
  }

  static void navigateToScreen(Map<String, dynamic> data) {
    if (data['type'] != "AGENT_TRANSFERED") {
      // prefs.tripId = data.toString();
      // navigatorKey?.currentState
      //     ?.push(MaterialPageRoute(builder: (_) => MyAgent()));
    }

    if (data['type'] == "MESSAGE_NOTIFICATION") {
      navigatorKey?.currentState?.push(MaterialPageRoute(
          builder: (_) => ChatScreen(
                idAgent: data['agentId'].toString(),
                nombreAgent: data['agentFullname'],
                nombre: data['driverFullname'],
                id: data['driverId'],
                rol: "MOTORISTA",
                tipoViaje: data['tripType'],
                idV: data['tripId'],
                pantalla: true,
              )));
    }
  }

  static closeStreams() {
    _messageStreamController.close();
  }
}
// //9B:DA:1E:1E:81:DE:47:80:AC:AD:B5:66:F8:1D:B8:88:64:41:12:EC

// import 'dart:async';
// import 'dart:convert';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_auth/Drivers/Screens/Chat/chatscreen.dart';
// import 'package:flutter_auth/providers/IncomingCallScreen.dart';
// //import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:rxdart/rxdart.dart';

// import '../../providers/JitsiCallPage.dart';
// //import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';

// class PushNotificationServices{


//   static FirebaseMessaging messaging = FirebaseMessaging.instance;
//   static String? token;
//   static StreamController<dynamic> _messageStreamController = new StreamController.broadcast();
//   static Stream<dynamic> get messageStream => _messageStreamController.stream;
//   //final prefs = new PreferenciasUsuario();

//   static GlobalKey<NavigatorState>? navigatorKey;
//   static dynamic array;
//   static final _notifications = FlutterLocalNotificationsPlugin();
//   static final onNotifications = BehaviorSubject<String?>();
//    // Método para mostrar notificaciones
//   static Future<void> showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//     String? payload,
//   }) async {
//     var details = await _notificationDetails();

//     // Muestra la notificación
//     await _notifications.show(id, title, body, details, payload: payload);

//     // Imprimir para confirmar que se ejecuta la notificación
//     //print("Notificación mostrada: $title - $body");
//   }

//   // Detalles de la notificación para Android e iOS
//   static Future<NotificationDetails> _notificationDetails() async {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'channel id',
//         'channel name',
//         channelDescription: 'channel description',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//       iOS: IOSNotificationDetails(),
//     );
//   }

//   // Crear el canal de notificación en Android
//   static Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'channel id', // ID del canal
//       'channel name', // Nombre del canal
//       description: 'channel description', // Descripción del canal
//       importance: Importance.max,
//       // priority: Priority.high,
//     );
//     // Registra el canal en el sistema
//     await _notifications.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   // Inicialización de la notificación y Firebase
//   static Future<void> init({bool initScheduled = false}) async {
//     await _createNotificationChannel(); // Crea el canal de notificación

//     const android = AndroidInitializationSettings('@mipmap/launcher_icon');
//     const iOS = IOSInitializationSettings();
//     const settings = InitializationSettings(android: android, iOS: iOS);

//     await _notifications.initialize(
//       settings,
//       onSelectNotification: (payload) async {
//         if (payload != null) {
//           try {
//             final data = jsonDecode(payload);
//             final callType = data['callType'];

//             if (callType == 'Incoming') {
//               final callerName = data['userName'] ?? 'Desconocido'; 
//               final roomId = data['roomId'];               
//               navigatorKey!.currentState?.push(
//                   MaterialPageRoute(
//                     builder: (_) => JitsiCallPage(roomId: roomId, name: callerName),
//                   ),
//                 );
//               } else {
//                 // Otras notificaciones
//                 onNotifications.add(payload);
//               }
//           } catch (e) {
//             print('Error al decodificar payload: $e');
//           }
//         }
//       },
//     );
//   }


//   static Future _backgroundHandelr(RemoteMessage message)async{
//     //print('onBackground handelr ${message.messageId}'); 
//     // print('aquí 1');
//     // print(message.data);
//     _messageStreamController.add(message.data);
//     array = message.data;     
//     final data = message.data;
//     final callType = data['callType'];
//     print(data);
//     if (callType == 'Incoming') {
//       await showIncomingCallNotification(
//         callerName: data['userName'],
//         payload: jsonEncode(data),
//       );
//     } else {
//       // Notificación normal
//       showNotification(
//         title: message.notification?.title,
//         body: message.notification?.body,
//         payload: data.toString(),
//       );
//     }
//     //navigateToScreen(message.data);          
//   }

//   static Future _onMessageHandelr(RemoteMessage message)async{
//     //print('onMessage handelr ${message.messageId}');
//     // print('aquí 2');
//     _messageStreamController.add(message.data);
//     array = message.data; 
//     final data = message.data;
//     final callType = data['callType'];
//     print(data);
//     if (callType == 'Incoming') {
//       await showIncomingCallNotification(
//         callerName: data['userName'],
//         payload: jsonEncode(data),
//       );
//     } else {
//       // Notificación normal
//       showNotification(
//         title: message.notification?.title,
//         body: message.notification?.body,
//         payload: data.toString(),
//       );
//     }
//   }
//   static Future _onMessageOpenApp(RemoteMessage message)async{
//     //print('onBackground handelr ${message.messageId}');
//     // print('aquí 3');
//     // print(message.data);
//     _messageStreamController.add(message.data); 
//     array = message.data; 
//     showNotification(
//       title: message.notification!.title,
//       body: '${message.notification!.body}',
//     );
//   }

//   static Future<void> showIncomingCallNotification({
//       required String? callerName,
//       required String payload,
//     }) async {
//       const AndroidNotificationDetails androidPlatformChannelSpecifics =
//           AndroidNotificationDetails(
//         'call_channel', // Unique channel ID
//         'Llamadas',
//         channelDescription: 'Notificaciones de llamadas entrantes',
//         importance: Importance.max,
//         priority: Priority.high,
//         fullScreenIntent: true,
//         visibility: NotificationVisibility.public,
//         ticker: 'ticker',
//         sound: const UriAndroidNotificationSound("assets/tunes/llamada.mp3"),
//         playSound: true,
//       );

//       const NotificationDetails platformChannelSpecifics =
//           NotificationDetails(android: androidPlatformChannelSpecifics);

//       await _notifications.show(
//         12345, // ID único
//         'Llamada entrante',
//         '$callerName te está llamando',
//         platformChannelSpecifics,
//         payload: payload,      
//       );
//     }


//     static Future initializeApp(GlobalKey<NavigatorState> navigatorKey)async{   
//     //push notifications
//     PushNotificationServices.navigatorKey = navigatorKey;
//     //final prefs = new PreferenciasUsuario();
//     await Firebase.initializeApp();
//     await init();
//     token = await FirebaseMessaging.instance.getToken();
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//     // Manejar la actualización del token de registro
//     token = newToken;
//       print("Nuevo token de registro: $token");
//       // Aquí puedes enviar el nuevo token al servidor de backend para actualizarlo
//     });
//     //llamado
//     FirebaseMessaging.onBackgroundMessage(_backgroundHandelr);
//     FirebaseMessaging.onMessage.listen(_onMessageHandelr);
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);


//     //token = prefs.tokenIdMobile;
//     print(token);
//   }

//   static void navigateToScreen(Map<String, dynamic> data) {
//     if (data['type'] != "AGENT_TRANSFERED") {
//       //prefs.tripId = data.toString();
//       // navigatorKey?.currentState
//       //     ?.push(MaterialPageRoute(builder: (_) => MyAgent()));
//     }

//     if (data['type'] == "MESSAGE_NOTIFICATION") {  
//       navigatorKey?.currentState
//           ?.push(MaterialPageRoute(builder: (_) => ChatScreen(
//               idAgent: data['agentId'].toString(),
//               nombreAgent: data['agentFullname'],
//               nombre: data['driverFullname'],
//               id: data['driverId'],
//               rol: "MOTORISTA",
//               tipoViaje: data['tripType'],
//               idV: data['tripId'],
//               pantalla: true,
//             )));
      
//     }
//   }

//   //static listenNotifications()=> onNotifications.stream.listen(event);
//   //static event(String? payload)=>Get.to(()=>const MyHomePage());   

//   static closeStreams(){
//     _messageStreamController.close();
//   }

// }