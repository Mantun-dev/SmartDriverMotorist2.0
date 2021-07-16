import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/DriverProfile/driverProfile.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/profile.dart';
import 'package:sweetalert/sweetalert.dart';

class DriverMenuLateral extends StatefulWidget {
  final Profile item;
  const DriverMenuLateral({Key key, this.item}) : super(key: key);

  @override
  _DriverMenuLateralState createState() => _DriverMenuLateralState();
}

class _DriverMenuLateralState extends State<DriverMenuLateral> {
  Future<Profile> item;
  final prefs = new PreferenciasUsuario();
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
            accountName: Text('${prefs.nombreUsuarioFull}'),             
            accountEmail: Text('${prefs.phone}'),  
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: ExactAssetImage('assets/fondos.jpg'),
                    fit: BoxFit.cover)),
          ),
          ListTile(
            title: Text('Mi perfil'),
            leading: Icon(Icons.account_circle),
            onTap: () {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DriverProfilePage()))
              .then((_) => HomeDriverScreen());                
            },
          ),
          Divider(),
          ListTile(
            title: Text('Asignar horas de viaje'),
            leading: Icon(Icons.airport_shuttle),
            onTap: () {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[0])))
              .then((_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[1]));                 
            },
          ),
          Divider(),
          ListTile(
            title: Text('Viajes en proceso'),
            leading: Icon(Icons.outbox),
            onTap: () {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[1])))
              .then((_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[3]));   
            },
          ),
          Divider(),
          ListTile(
            title: Text('Historial de Viajes '),
            leading: Icon(Icons.history),
            onTap: () {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[3])))
              .then((_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[2]));   
            },
          ),
          Divider(),
          ListTile(
            title: Text('Registrar Salidas'),
            leading: Icon(Icons.qr_code),
            onTap: () {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[2])))
              .then((_) => HomeDriverScreen());  
            },
          ),
          Divider(),
          ListTile(
            title: Text('Cerrar sesión'),
            leading: Icon(Icons.logout),
            onTap: () {
              SweetAlert.show(context,
                subtitle: "Está seguro que desea salir?",
                style: SweetAlertStyle.confirm,
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar",
                showCancelButton: true, onPress: (bool isConfirm) {
                if(isConfirm){                
                  fetchDeleteSession();  
                  prefs.remove();                   
                  SweetAlert.show(context,subtitle: "¡Gracias por usar Smart Driver!", style: SweetAlertStyle.success);
                  new Future.delayed(new Duration(seconds: 2),(){
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context)=>
                  WelcomeScreen()), (Route<dynamic> route) => false);
                  });                  
                }else{
                  SweetAlert.show(context,subtitle: "¡Cancelado!", style: SweetAlertStyle.success);
                }
                // return false to keep dialog
                return false;
               });             
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
