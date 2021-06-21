import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/DriverProfile/driverProfile.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/profile.dart';

class DriverMenuLateral extends StatefulWidget {
  final Profile item;
  const DriverMenuLateral({Key key, this.item}) : super(key: key);

  @override
  _DriverMenuLateralState createState() => _DriverMenuLateralState();
}

class _DriverMenuLateralState extends State<DriverMenuLateral> {
  Future<Profile> item;

    @override  
  void initState() {  
    super.initState();  
    item = fetchRefresProfile();
  } 

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: FutureBuilder<Profile> (
              future: item,              
              builder: (BuildContext context, abc) {
                if (abc.connectionState == ConnectionState.done) {
                  return Text('${abc.data.driver.driverFullname}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),             
            accountEmail: FutureBuilder<Profile> (
              future: item,              
              builder: (BuildContext context, abc) {
                if (abc.connectionState == ConnectionState.done) {
                  return Text('${abc.data.driver.driverPhone}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),  
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: ExactAssetImage('assets/fondos.jpg'),
                    fit: BoxFit.cover)),
          ),
          ListTile(
            title: Text('Mi perfil'),
            leading: Icon(Icons.account_circle),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DriverProfilePage();
              }));
            },
          ),
          Divider(),
          ListTile(
            title: Text('Asignar horas de viaje'),
            leading: Icon(Icons.airport_shuttle),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DetailsDriverScreen(plantillaDriver: plantillaDriver[0]);
              }));
            },
          ),
          Divider(),
          ListTile(
            title: Text('Viajes en proceso'),
            leading: Icon(Icons.history),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DetailsDriverScreen(plantillaDriver: plantillaDriver[1]);
              }));
            },
          ),
          Divider(),
          ListTile(
            title: Text('Historial de Viajes '),
            leading: Icon(Icons.outbox),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DetailsDriverScreen(plantillaDriver: plantillaDriver[3]);
              }));
            },
          ),
          Divider(),
          ListTile(
            title: Text('Registrar Salidas'),
            leading: Icon(Icons.qr_code),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DetailsDriverScreen(plantillaDriver: plantillaDriver[2]);
              }));
            },
          ),
          Divider(),
          ListTile(
            title: Text('Cerrar sesión'),
            leading: Icon(Icons.logout),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WelcomeScreen();
              }));
            },
          ),
          Divider(),
          // ListTile(
          //     title: Text('App Agent'),
          //     leading: Icon(Icons.logout),
          //     onTap: () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) {
          //         return HomeDriverScreen();
          //       }));
          //     })
        ],
      ),
    );
  }
}
