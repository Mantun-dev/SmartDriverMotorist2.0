import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/Drivers/SharePreferences/services.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/constants.dart';
import 'Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'Drivers/SharePreferences/preferencias_usuario.dart';


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
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
  @override
  void initState() { 
    super.initState();
    
    PushNotificationServices.messageStream.listen((event) {
       if (event == 'PROCESS_TRIP') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[0]))
        );        
       }else if(event == 'PROCESS'){
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[1]))
        );  
       }
      print(event);    
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
      home: WelcomeScreen(),
    );
  }



}
