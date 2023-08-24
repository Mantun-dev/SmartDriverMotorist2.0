//9B:DA:1E:1E:81:DE:47:80:AC:AD:B5:66:F8:1D:B8:88:64:41:12:EC

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';


class PushNotificationServices{


  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<String> _messageStreamController = new StreamController.broadcast();
  static Stream<String> get messageStream => _messageStreamController.stream;
  //final prefs = new PreferenciasUsuario();

  static Future _backgroundHandelr(RemoteMessage message)async{
    //print('onBackground handelr ${message.messageId}'); 
    print(message.data['type']);
    _messageStreamController.add(message.data['type']??'no data');          
  }

  static Future _onMessageHandelr(RemoteMessage message)async{
    //print('onMessage handelr ${message.messageId}');
    print(message.data['type']);
    _messageStreamController.add(message.data['type']??'no data');  
        
  }
  static Future _onMessageOpenApp(RemoteMessage message)async{
    //print('onBackground handelr ${message.messageId}');
    print(message.data['type']);
    _messageStreamController.add(message.data['type']??'no data');  
  }

    static Future initializeApp()async{
    //push notifications
    //final prefs = new PreferenciasUsuario();
    await Firebase.initializeApp();
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

  static closeStreams(){
    _messageStreamController.close();
  }

}