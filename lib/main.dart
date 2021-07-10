import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/Drivers/SharePreferences/services.dart';
import 'package:flutter_auth/constants.dart';
import 'package:sweetalert/sweetalert.dart';
import 'Drivers/SharePreferences/preferencias_usuario.dart';

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
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
      prefs.tripId = event.toString(); 
        if (event == event) {   
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) =>MyAgent())
          );        
        }
      //print(event);    
  });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Smart Driver',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      //home: WelcomeScreen(),
      initialRoute:prefs.nombreUsuario ==null || prefs.nombreUsuario == ""? 'login' :'home',
      routes: {
        'login' : (BuildContext context) => WelcomeScreen(),
        'home' : (BuildContext context) => HomeDriverScreen()
      },
    );
  }

}

void showMyDialog() {
  return SweetAlert.show(navigatorKey.currentContext,
    title: "¡Advertencia!",
    subtitle: "El agente seleccionado ya está agregado al viaje",
    style: SweetAlertStyle.error
  ); 
}
