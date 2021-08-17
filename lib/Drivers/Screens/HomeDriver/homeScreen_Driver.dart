import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/DriverProfile/driverProfile.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/bodyDriver.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/countNotify.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sweetalert/sweetalert.dart';
import '../../../constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:async';
//import 'package:showcaseview/showcaseview.dart';

class HomeDriverScreen extends StatefulWidget {
  final CountNotifications item;

  const HomeDriverScreen({Key key, this.item}) : super(key: key);
  @override
  _HomeDriverScreenState createState() => _HomeDriverScreenState();
}

class _HomeDriverScreenState extends State<HomeDriverScreen> with AutomaticKeepAliveClientMixin<HomeDriverScreen>{
  Future <List<CountNotifications>> item;
  //GlobalKey _one = GlobalKey();
  @override
  void initState() { 
    super.initState();
    item = fetchCountNotify();

      SchedulerBinding.instance.addPostFrameCallback((_){
      if (mounted) {
        
      setState(() {        
       this.closeSession();
      });
      }
    });
    
    // WidgetsBinding.instance.addPostFrameCallback((_) =>
    //     ShowCaseWidget.of(context).startShowCase( [_one]));
  }

  closeSession()async{
    http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data1 = DriverData.fromJson(json.decode(response.body));  

    if (data1.driverStatus == 0 || data1.driverStatus == false) {
      fetchDeleteSession();  
      prefs.remove(); 
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context)=>
      WelcomeScreen()), (Route<dynamic> route) => false);
      SweetAlert.show(context,
        title: "Lo sentimos",
        subtitle:"Este usuario está fuera de servicio, \nfavor comunicarse con el cordinador",
        style: SweetAlertStyle.error
      );
    }
  }
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(),
      drawer: DriverMenuLateral(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kColorDriverAppBar,
      elevation: 10,
      iconTheme: IconThemeData(color: Colors.white),
      actions: <Widget>[
        //aquí está el icono de las notificaciones
        FutureBuilder<List<CountNotifications>>(
        future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              return IconButton(          
                onPressed: ()=> _simpleDialog(context),
                icon:  Stack(
                  children: <Widget>[
                    Icon(Icons.notifications),
                    Positioned(  // draw a red marble
                      top: 0.0,
                      right: 0.0,
                      child: Container(                
                        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                        child: Text('${abc.data[0].total}', style: TextStyle(color: Colors.white, fontSize: 13)
                        )
                      ),
                    )
                  ]
                ),
              );
            }else{
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
        ),        //SizedBox(width: kDefaultPadding / 2)
      ],
    );
  }

Future<void> _simpleDialog(BuildContext context) async{  
    await showDialog(
      barrierDismissible: true,    
        context: context,
        builder: (context) =>
        FutureBuilder<List<CountNotifications>>(
        future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                margin: EdgeInsets.only(bottom : 420.0),
                height: 60,
                child:
                AlertDialog(
                    title: Center(child: Text('Pendientes')),
                    content: Column(children: [
                      // ignore: deprecated_member_use
                      FlatButton(
                        onPressed: () => {                          
                          Navigator.pop(context),
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return DetailsDriverScreen(plantillaDriver: plantillaDriver[0]);
                          })),
                        },
                        color: Colors.white,
                        child: Column( // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Stack(
                                    children: <Widget>[
                                      new Icon(Icons.car_rental),
                                      new Positioned(  // draw a red marble
                                        top: 0.0,
                                        right: 0.0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                          child: Text('${abc.data[0].tripsCreated}', style: TextStyle(color: Colors.white, fontSize: 13)
                                          )
                                        ),
                                      )
                                    ]
                                  ),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Column(
                                  children: [
                                    Text("Viajes creados")
                                  ],
                                ),
                              ],
                            ),
                            
                          ],
                        ),
                      ),
                      // ignore: deprecated_member_use
                      FlatButton(
                        onPressed: () => {                          
                          Navigator.pop(context),
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return DetailsDriverScreen(plantillaDriver: plantillaDriver[1]);
                          })),
                        },
                        color: Colors.white,
                        child: Column( // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Stack(
                                    children: <Widget>[
                                      new Icon(Icons.check),
                                      new Positioned(  // draw a red marble
                                        top: 0.0,
                                        right: 0.0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                          child: Text('${abc.data[0].tripsInProgress}', style: TextStyle(color: Colors.white, fontSize: 13)
                                          )
                                        ),
                                      )
                                    ]
                                  ),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Column(
                                  children: [
                                    Text("Viajes en proceso")
                                  ],
                                ),
            
                              ],
                            ),
                            
                          ],
                        ),
                      ),
                    ],),
              
                )
            );
  
            }else{
              return ColorLoader3();
            }
          },
        ),
        
    ); 
  }

  @override
  bool get wantKeepAlive => true;

}
