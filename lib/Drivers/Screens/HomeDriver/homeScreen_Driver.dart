import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/detailsDriver_assignHour.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/details_TripProgress.dart';
//import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/DriverProfile/driverProfile.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/bodyDriver.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/countNotify.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/components/backgroundH.dart';
import 'package:flutter_auth/main.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quickalert/quickalert.dart';
import '../../../components/AppBarPosterior.dart';
import '../../../components/AppBarSuperior.dart';
import '../../../constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
//import 'package:app_settings/app_settings.dart';
//import 'package:showcaseview/showcaseview.dart';

class HomeDriverScreen extends StatefulWidget {
  final CountNotifications? item;

  const HomeDriverScreen({Key? key, this.item}) : super(key: key);
  @override
  _HomeDriverScreenState createState() => _HomeDriverScreenState();
}

class _HomeDriverScreenState extends State<HomeDriverScreen>
    with AutomaticKeepAliveClientMixin<HomeDriverScreen> {
  Future<List<CountNotifications>>? item;
  //GlobalKey _one = GlobalKey();
  @override
  void initState() {
    setPantallaP(1);
    super.initState();
    item = fetchCountNotify();
    checkLocationPermission();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          this.closeSession();
        });
      }
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) =>
    //     ShowCaseWidget.of(context).startShowCase( [_one]));
  }

  closeSession() async {
    http.Response response = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data1 = DriverData.fromJson(json.decode(response.body));

    if (data1.driverStatus == 0 || data1.driverStatus == false) {
      fetchDeleteSession();
      prefs.remove();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
          (Route<dynamic> route) => false);
          QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Lo sentimos",
          text: "Este usuario está fuera de servicio, \nfavor comunicarse con el cordinador",
          );
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    return BackgroundHome(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: AppBarSuperior(item: 0,)
                  ),
          body: Column(
            children: [
              Expanded(child: Body()),
              SafeArea(child: AppBarPosterior(item:0)),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      shadowColor: Colors.black87,
      elevation: 10,
      iconTheme: IconThemeData(color: secondColor, size: 32),
      actions: <Widget>[
        //aquí está el icono de las notificaciones
        FutureBuilder<List<CountNotifications>>(
          future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              return IconButton(
                onPressed: () => _simpleDialog(context),
                icon: Stack(children: <Widget>[
                  Icon(Icons.notifications),
                  Positioned(
                    // draw a red marble
                    top: 0.0,
                    right: 0.0,
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.red),
                        child: Text('${abc.data![0].total}',
                            style:
                                TextStyle(color: Colors.white, fontSize: 13))),
                  )
                ]),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/userDriver.svg",
            width: 100,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return DriverProfilePage();
            }));
          },
        ), //SizedBox(width: kDefaultPadding / 2)
      ],
    );
  }

  Future<void> _simpleDialog(BuildContext context) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => FutureBuilder<List<CountNotifications>>(
        future: item,
        builder: (BuildContext context, abc) {
          if (abc.connectionState == ConnectionState.done) {
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                margin: EdgeInsets.only(bottom: 420.0),
                height: 60,
                child: AlertDialog(
                  backgroundColor: backgroundColor,
                  title: Center(child: Text('Pendientes',style: TextStyle(color: Colors.white))),
                  content: Column(
                    children: [
                      // ignore: deprecated_member_use
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: backgroundColor,
                        ),
                        onPressed: () => {
                          Navigator.pop(context),
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DetailsDriverHour(
                                plantillaDriver: plantillaDriver[0]);
                          })),
                        },
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Stack(children: <Widget>[
                                      new Icon(Icons.car_rental),
                                      new Positioned(top: 0.0,right: 0.0,
                                        child: Container(padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.red),
                                          child: Text('${abc.data![0].tripsCreated}',style: TextStyle(color: Colors.white,fontSize: 13))),
                                      )
                                    ]),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Text("Viajes creados",style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // ignore: deprecated_member_use
                      TextButton(style: TextButton.styleFrom(backgroundColor: backgroundColor,),
                        onPressed: () => {
                          Navigator.pop(context),
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) {return DetailsDriverTripInProgress(plantillaDriver: plantillaDriver[1]);})),
                        },
                        child: Column(
                          // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Stack(children: <Widget>[
                                      new Icon(Icons.check),
                                      new Positioned(top: 0.0,right: 0.0,
                                        child: Container(padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                          decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.red),
                                            child: Text('${abc.data![0].tripsInProgress}',style: TextStyle( color: Colors.white,fontSize: 13))),
                                      )
                                    ]),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Text("Viajes en proceso",style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          
          } else {
            return ColorLoader3();
          }
        },
      ),
    );
  }
  
  void checkLocationPermission() async {
    // Verificar si se tiene el permiso de grabación de audio
    var status = await Permission.location.status;

    if (status.isGranted) {
      // Permiso concedido
    } else {
      // No se ha solicitado el permiso, solicitarlo al usuario
      await Permission.location.request();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
