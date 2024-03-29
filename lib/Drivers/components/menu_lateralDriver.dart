import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/details_HoursOut.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/details_TripProgress.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/details_history.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/DriverProfile/driverProfile.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/profile.dart';
import 'package:flutter_auth/constants.dart';
import 'package:quickalert/quickalert.dart';

import '../Screens/Details/components/detailsDriver_assignHour.dart';

class DriverMenuLateral extends StatefulWidget {
  final Profile? item;
  final DriverData? itemx;
  const DriverMenuLateral({Key? key, this.item, this.itemx}) : super(key: key);

  @override
  _DriverMenuLateralState createState() => _DriverMenuLateralState();
}

class _DriverMenuLateralState extends State<DriverMenuLateral> {
  Future<Profile>? item;
  Future<DriverData>? itemx;
  final prefs = new PreferenciasUsuario();
  @override
  void initState() {
    super.initState();
    itemx = fetchRefres();
    item = fetchRefresProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('${prefs.nombreUsuarioFull}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            accountEmail: Text('${prefs.phone}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: ExactAssetImage('assets/fondos.jpg'),
                    fit: BoxFit.cover)),
          ),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DriverProfilePage())).then((_) => HomeDriverScreen());
            },
            child: Column(crossAxisAlignment:CrossAxisAlignment.end,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.white),
                    SizedBox(width: 15,),
                    Flexible(child: Text('Mi perfil',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                  ],
                  ),
                ),                       
              ],
            ),
          ),
          Divider(
            color: Colors.white,
          ),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverHour(plantillaDriver: plantillaDriver[0]))).then((_) =>DetailsDriverHour(plantillaDriver: plantillaDriver[1]));
            },
            child: Column(crossAxisAlignment:CrossAxisAlignment.end,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                child: Row(
                  children: [
                    Icon(Icons.airport_shuttle, color: Colors.white),
                    SizedBox(width: 15,),
                    Flexible(child: Text('Horas de encuentro',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                  ],
                  ),
                ),                       
              ],
            ),
          ),          
          Divider(
            color: Colors.white,
          ),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DetailsDriverTripInProgress(plantillaDriver: plantillaDriver[1]))).then((_) =>DetailsDriverScreen(plantillaDriver: plantillaDriver[3]));
            },
            child: Column(crossAxisAlignment:CrossAxisAlignment.end,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                child: Row(
                  children: [
                    Icon(Icons.outbox, color: Colors.white),
                    SizedBox(width: 15,),
                    Flexible(child: Text('Viajes en proceso',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                  ],
                  ),
                ),                       
              ],
            ),
          ), 
          Divider(
            color: Colors.white,
          ),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverHistory(plantillaDriver: plantillaDriver[3]))).then((_) =>DetailsDriverHoursOut(plantillaDriver: plantillaDriver[2]));
            },
            child: Column(crossAxisAlignment:CrossAxisAlignment.end,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.white),
                    SizedBox(width: 15,),
                    Flexible(child: Text('Historial de Viajes ',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                  ],
                  ),
                ),                       
              ],
            ),
          ),
          Divider(
            color: Colors.white,
          ),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverHistory(plantillaDriver: plantillaDriver[3]))).then((_) =>DetailsDriverHoursOut(plantillaDriver: plantillaDriver[2]));
            },
            child: Column(crossAxisAlignment:CrossAxisAlignment.end,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                child: Row(
                  children: [
                    Icon(Icons.qr_code, color: Colors.white),
                    SizedBox(width: 15,),
                    Flexible(child: Text('Registrar Salidas',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                  ],
                  ),
                ),                       
              ],
            ),
          ),
          Divider(
            color: Colors.white,
          ),
          InkWell(
            onTap: (){
              //Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverHistory(plantillaDriver: plantillaDriver[3]))).then((_) =>DetailsDriverHoursOut(plantillaDriver: plantillaDriver[2]));
              _noDisponible(context);
            },
            child: Column(crossAxisAlignment:CrossAxisAlignment.end,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                child: Row(
                  children: [
                    Icon(Icons.supervised_user_circle, color: Colors.white),
                    SizedBox(width: 15,),
                    Flexible(child: Text('Viajes ejecutivos',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                  ],
                  ),
                ),                       
              ],
            ),
          ),
          Divider(
            color: Colors.white,
          ),
          FutureBuilder<DriverData>(
            future: itemx,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.departmentId == 2) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => DetailsDriverScreen(plantillaDriver: plantillaDriver[5]))).then((_) => DetailsDriverScreen());
                        },
                        child: Column(crossAxisAlignment:CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                            child: Row(
                              children: [
                                Icon(Icons.emoji_people_rounded, color: Colors.white),
                                SizedBox(width: 15,),
                                Flexible(child: Text('Registrar viaje sólido',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                              ],
                              ),
                            ),                       
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                      ),
                    ],
                  );
                }
                return Container();
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          InkWell(
            onTap: (){
              QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  title: "Salir",
                  text: "¿Está seguro que desea salir?",
                  confirmBtnText: 'Confirmar',
                  cancelBtnText: 'Cancelar',
                  showCancelBtn: true,  
                  confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                  cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),
                  onConfirmBtnTap: () {
                    fetchDeleteSession();
                    prefs.remove();
                    QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    text: "¡Gracias por usar Smart Driver!",
                    );
                    new Future.delayed(new Duration(seconds: 2), () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) => WelcomeScreen()),
                        (Route<dynamic> route) => false);
                  });
                  },
                  onCancelBtnTap: () {
                    Navigator.pop(context);
                    // QuickAlert.show(
                    // context: context,
                    // type: QuickAlertType.success,
                    // text: "¡Cancelado!",                    
                    // );
                  },
                );
            },
            child: Column(crossAxisAlignment:CrossAxisAlignment.end,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 15,),
                    Flexible(child: Text('Cerrar sesión',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                  ],
                  ),
                ),                       
              ],
            ),
          ),
          Divider(
            color: Colors.white,
          ),
          //Divider(),
        ],
      ),
    );
  }

  _noDisponible(BuildContext context) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Center(
                    child: Text('Página disponible \n\t\t\t\tpróximamente')),
                actions: [
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => {
                        Navigator.pop(context),
                      },
                      child: Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Text('');
        });
  }
}
