import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';

import 'package:flutter_auth/Drivers/SharePreferences/services.dart';
import 'package:flutter_auth/components/splashView.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/providers/chat.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'Drivers/SharePreferences/preferencias_usuario.dart';

class MyHttpoverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
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
    PushNotificationServices.messageStream.listen((event) {

      if (event != "MESSAGE_NOTIFICATION") {
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
          'login': (BuildContext context) => SplashView(),
          'home': (BuildContext context) => HomeDriverScreen()
        },
      ),
    );
  }
}

Future<dynamic> showMyDialog() {
  return QuickAlert.show(
   context: navigatorKey.currentContext!,
   type: QuickAlertType.error,
   title: "??Advertencia!",
   text: "El agente seleccionado ya est?? agregado al viaje",
  );
}
