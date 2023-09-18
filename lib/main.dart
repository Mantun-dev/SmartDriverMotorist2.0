import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';

import 'package:flutter_auth/Drivers/SharePreferences/services.dart';
import 'package:flutter_auth/components/splashView.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/providers/chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:upgrader/upgrader.dart';
import 'Drivers/SharePreferences/preferencias_usuario.dart';

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

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpoverrides();
  final prefs = new PreferenciasUsuario();
  await PushNotificationServices.initializeApp();
  await prefs.initPrefs();
  runApp(MyApp());
}

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
    PushNotificationServices.messageStream.listen((event) {

      if (event != "MESSAGE_NOTIFICATION" && pantallaP  ==1) {
        prefs.tripId = event.toString();
        //print(event);
        navigatorKey.currentState
            ?.push(MaterialPageRoute(builder: (_) => MyAgent()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ChatProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Smart Driver',
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
        ),
        //home: WelcomeScreen(),
        initialRoute: prefs.nombreUsuario == null || prefs.nombreUsuario == ""
            ? 'login'
            : 'home',
        routes: {
          'login': (BuildContext context) =>  UpgradeAlert(upgrader: Upgrader(dialogStyle: Platform.isIOS? UpgradeDialogStyle.cupertino: UpgradeDialogStyle.material),child: SplashView()),
          'home': (BuildContext context) => UpgradeAlert(upgrader: Upgrader(dialogStyle: Platform.isIOS? UpgradeDialogStyle.cupertino: UpgradeDialogStyle.material),child: HomeDriverScreen())
        },
      ),
    );
  }
}

Future<dynamic> showMyDialog() {
  return QuickAlert.show(
    context: navigatorKey.currentContext!,
    type: QuickAlertType.error,
    title: "¡Advertencia!",
    text: "El agente seleccionado ya está agregado al viaje",
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