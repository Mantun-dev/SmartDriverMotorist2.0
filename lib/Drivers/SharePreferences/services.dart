//9B:DA:1E:1E:81:DE:47:80:AC:AD:B5:66:F8:1D:B8:88:64:41:12:EC

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatscreen.dart';
//import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
//import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';

class PushNotificationServices{


  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<dynamic> _messageStreamController = new StreamController.broadcast();
  static Stream<dynamic> get messageStream => _messageStreamController.stream;
  //final prefs = new PreferenciasUsuario();

  static GlobalKey<NavigatorState>? navigatorKey;
  static dynamic array;
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  })async=> _notifications.show(id, title, body, await _notificationDetails(), payload: payload);

  static Future _notificationDetails()async  {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        //priority: Priority.high,  
        //sound:RawResourceAndroidNotificationSound('notification'),
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false})async{
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iOS = IOSInitializationSettings();
    const settings = InitializationSettings(android:android ,iOS: iOS);
    await _notifications.initialize(
      settings,
      onSelectNotification: (payload)async{
        onNotifications.add(payload);
        navigateToScreen(array); 
        print('onSelectNotification called with payload: $payload');

      },
    );
  }

  static Future _backgroundHandelr(RemoteMessage message)async{
    //print('onBackground handelr ${message.messageId}'); 
    print('aquí 1');
    print(message.data);
    _messageStreamController.add(message.data);
    array = message.data;     
    showNotification(
      title: message.notification!.title,
      body: '${message.notification!.body}',
    );
    //navigateToScreen(message.data);          
  }

  static Future _onMessageHandelr(RemoteMessage message)async{
    //print('onMessage handelr ${message.messageId}');
    print('aquí 2');
    _messageStreamController.add(message.data);
    array = message.data; 
    showNotification(
      title: message.notification!.title,
      body: '${message.notification!.body}',
    );
  }
  static Future _onMessageOpenApp(RemoteMessage message)async{
    //print('onBackground handelr ${message.messageId}');
    print('aquí 3');
    print(message.data);
    _messageStreamController.add(message.data); 
    array = message.data; 
    showNotification(
      title: message.notification!.title,
      body: '${message.notification!.body}',
    );
  }

    static Future initializeApp(GlobalKey<NavigatorState> navigatorKey)async{
    //push notifications
    PushNotificationServices.navigatorKey = navigatorKey;
    //final prefs = new PreferenciasUsuario();
    await Firebase.initializeApp();
    await init();
    token = await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    // Manejar la actualización del token de registro
    token = newToken;
      print("Nuevo token de registro: $token");
      // Aquí puedes enviar el nuevo token al servidor de backend para actualizarlo
    });
    //llamado
    FirebaseMessaging.onBackgroundMessage(_backgroundHandelr);
    FirebaseMessaging.onMessage.listen(_onMessageHandelr);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);


    //token = prefs.tokenIdMobile;
    print(token);
  }

  static void navigateToScreen(Map<String, dynamic> data) {
    if (data['type'] != "MESSAGE_NOTIFICATION") {
      //prefs.tripId = data.toString();
      // navigatorKey?.currentState
      //     ?.push(MaterialPageRoute(builder: (_) => MyAgent()));
    }

    if (data['type'] == "MESSAGE_NOTIFICATION") {  
      navigatorKey?.currentState
          ?.push(MaterialPageRoute(builder: (_) => ChatScreen(
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

  //static listenNotifications()=> onNotifications.stream.listen(event);
  //static event(String? payload)=>Get.to(()=>const MyHomePage());   

  static closeStreams(){
    _messageStreamController.close();
  }

}