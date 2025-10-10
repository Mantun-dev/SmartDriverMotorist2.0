import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatscreen.dart';
import 'package:flutter_auth/providers/IncomingCallScreen.dart';
// import 'package:flutter_auth/providers/IncomingCallScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import '../../providers/JitsiCallPage.dart';


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

class PushNotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<String> _messageStreamController =
      StreamController.broadcast();
  static Stream<dynamic> get messageStream => _messageStreamController.stream;
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static dynamic array;
  static GlobalKey<NavigatorState>? navigatorKey;

  // --- CONFIGURACIÓN DE CANAL PARA LLAMADAS (Android) ---
  // Nota: Esto debe estar configurado también a nivel nativo en AndroidManifest.xml
  static const String _callChannelId = 'call_channel';
  static const AndroidNotificationChannel _callChannel = AndroidNotificationChannel(
    _callChannelId, 
    'Llamadas Entrantes',
    description: 'Canal de alta prioridad para mostrar llamadas en pantalla completa.',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('llamada'), // 'llamada' debe ser el nombre del archivo sin extensión en android/app/src/main/res/raw
  );

  // Método para mostrar notificaciones (Mantenido)
  static Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    // Uso de un canal genérico o el canal por defecto si no es una llamada
    var details = await _notificationDetails(); 
    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Detalles de la notificación (Mantenido, pero ahora usamos un canal específico en showIncomingCallNotification)
  static Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.defaultImportance, // Baja la importancia para el canal por defecto
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // Creación del canal de alta prioridad (Debe llamarse durante la inicialización)
  static Future<void> _createNotificationChannel() async {
     await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_callChannel);
  }

  // Inicialización de la notificación y Firebase
  static Future<void> init({bool initScheduled = false,
    void Function(NotificationResponse)? onDidReceiveBackgroundNotificationResponse,
  }) async {
    await _createNotificationChannel(); 

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload); 
            handleNotificationNavigation(data); 
          } catch (e) {
            print('Error al decodificar payload: $e');
          }
        }
      },
      // Usa el callback opcional pasado desde main
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse, 
    );
  }

  // Solicitar permisos de notificación (Mantenido)
  static void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Permisos de notificación concedidos");
    } else {
      print("Permisos de notificación no concedidos");
    }
  }

  // Manejar la notificación en segundo plano
  // 💡 Acción 1: Llama a showIncomingCallNotification que tiene fullScreenIntent
  static Future<void> _backgroundHandelr(RemoteMessage message) async {
    print('onBackground handelr ${message.messageId}');
    final data = message.data;
    final callType = data['callType'];
    print(data);
    
    // El payload debe contener la información necesaria para navegar
    final String payload = jsonEncode(data);

    if (callType == 'Incoming') {
      await showIncomingCallNotification(
        callerName: data['userName'],
        payload: payload,
      );
    } else {
      // Notificación normal
      showNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        payload: payload,
      );
    }
    _messageStreamController.add(message.data['type'] ?? 'no data');
  }

  // Manejar la notificación en primer plano (Mantenido, navega directamente sin notificación local)
  static Future<void> _onMessageHandelr(RemoteMessage message) async {
    print('onMessage handler ${message.messageId}');

    final data = message.data;
    final callType = data['callType'];
    print(data);

    if (callType == 'Incoming') {
      final callerName = data['userName'] ?? 'Desconocido';
      final roomId = data['roomId'];

      if (navigatorKey?.currentState != null) {
        navigatorKey!.currentState!.push(
          MaterialPageRoute(
            builder: (context) => IncomingCallAlert(
              callerName: callerName,
              roomId: roomId,
            ),
          ),
        );
        print('Navegando a IncomingCallAlert desde _onMessageHandelr (App en primer plano)');
      } else {
        // En caso de fallo de navegación (raro en primer plano), mostrar notificación
        await showIncomingCallNotification(
          callerName: data['userName'],
          payload: jsonEncode(data),
        );
        print('navigatorKey no disponible, mostrando notificación de llamada como fallback.');
      }
    } else {
      showNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        payload: jsonEncode(data),
      );
    }
    _messageStreamController.add(data['type'] ?? 'no data');
  }

  // Manejar la notificación al abrir la app (FCM) - Se usa para el caso de cuando la notificación original no fue local.
  static Future<void> _onMessageOpenApp(RemoteMessage message) async {
    print('onMessageOpenApp ${message.messageId}');
    _messageStreamController.add(message.data['type'] ?? 'no data');
    // 💡 Acción 2: Llamada a la navegación centralizada
    handleNotificationNavigation(message.data);
  }

  // --- FUNCIÓN CLAVE PARA LA PANTALLA DE LLAMADA ---
  static Future<void> showIncomingCallNotification({
    required String? callerName,
    required String payload,
  }) async {
    // 💡 Acción 1: Usar fullScreenIntent
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _callChannelId, // Usar el ID del canal de alta prioridad
      'Llamadas Entrantes',
      channelDescription: 'Notificaciones de llamadas entrantes',
      importance: Importance.max,
      priority: Priority.max, // Usar máxima prioridad
      fullScreenIntent: true, // ESTO ES CLAVE para Android
      visibility: NotificationVisibility.public,
      ticker: 'Llamada entrante',
      // Usa el sonido del canal: UriAndroidNotificationSound("assets/tunes/llamada.mp3"),
      // Si usas RawResourceAndroidNotificationSound('llamada') el archivo debe estar en /res/raw
      // y configurado en _callChannel
      playSound: true, 
    );

    // Para iOS, la implementación de CallKit es necesaria para la experiencia nativa.
    // Con FLoating solo se logra un banner de alta prioridad.
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'llamada.mp3', // Asegúrate de que está en Runner/Resources
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.show(
      // Usar un ID de notificación único para la llamada
      12345, 
      'Llamada entrante',
      '$callerName te está llamando',
      platformChannelSpecifics,
      payload: payload, // El payload es CRUCIAL para la navegación
    );
  }

  // --- NUEVO MÉTODO PARA MANEJAR LA NAVEGACIÓN (Centralizada) ---
  // 💡 Acción 2: Se usa al presionar la notificación (onDidReceiveNotificationResponse) 
  // y al abrir la app desde FCM (onMessageOpenedApp)
  static void handleNotificationNavigation(Map<String, dynamic> data) {
    print('Intentando navegar con data: $data');
    final callType = data['callType'];

    if (callType == 'Incoming') {
      final callerName = data['userName'] ?? 'Desconocido';
      final roomId = data['roomId'];
      
      // La navegación solo es posible si el `navigatorKey` está disponible
      if (navigatorKey?.currentState != null && navigatorKey!.currentState!.mounted) {
        navigatorKey!.currentState?.push(
          MaterialPageRoute(
            builder: (_) => IncomingCallAlert(
              callerName: callerName,
              roomId: roomId
            ),
          ),
        );
        print('Navegando a IncomingCallAlert por toque de notificación/apertura de app.');
      } else {
        print('Error: navigatorKey no disponible. Guardando data para manejo en main.');
        // Si no podemos navegar, guardamos los datos para que sean manejados en la función `main`
        array = data; 
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

  // Inicialización de la aplicación (Mantenido)
  static Future<void> initializeApp(GlobalKey<NavigatorState> navigatorKey) async {
    PushNotificationServices.navigatorKey = navigatorKey;
    
    // Ya no es necesario llamar a init() aquí, se llama en main()
    // await init(); // <-- ELIMINAR O COMENTAR

    await Firebase.initializeApp(); 
    
    // Quitar la lógica de getInitialMessage() aquí, se maneja en main.dart
    // RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    // if (initialMessage != null && initialMessage.data['callType'] == 'Incoming') {
    //   handleNotificationNavigation(initialMessage.data);
    // }
    
    token = await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      token = newToken;
      print("Nuevo token de registro: $token");
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundHandelr);
    FirebaseMessaging.onMessage.listen(_onMessageHandelr);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

    print('FCM Token: $token');
  }

  // Cerrar los streams (Mantenido)
  static void closeStreams() {
    _messageStreamController.close();
  }
}

// //9B:DA:1E:1E:81:DE:47:80:AC:AD:B5:66:F8:1D:B8:88:64:41:12:EC
