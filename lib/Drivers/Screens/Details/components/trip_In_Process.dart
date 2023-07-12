import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/confirm_trips.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/details_TripProgress.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_auth/main.dart';
import 'package:quickalert/quickalert.dart';

import '../../../../constants.dart';
import '../../../models/plantillaDriver.dart';

void main() => runApp(Process());

class Process extends StatefulWidget {
  final TripsInProgress? item;
  const Process({Key? key, this.item}) : super(key: key);
  @override
  _ProcessState createState() => _ProcessState();
}

class _ProcessState extends State<Process> {
  Future<List<TripsInProgress>>? item;
  TextEditingController tripId = new TextEditingController();
  final prefs = new PreferenciasUsuario();

  @override
  void initState() {
    super.initState();
    item = fetchTripsInProgress();
    tripId = new TextEditingController(text: prefs.tripId);
  }

  fetchAgentsAsigmentChekc(String tripId) async {
    prefs.tripId = tripId;
    if (tripId == tripId) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyConfirmAgent(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 10,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_circle_left),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DetailsDriverTripInProgress(
                          plantillaDriver: plantillaDriver[1]);
                    },
                  ),
                );
              },
            ),
            SizedBox(width: kDefaultPadding / 2)
          ],
        ),
        drawer: DriverMenuLateral(),
        body: Container(
          color: backgroundColor,
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<List<TripsInProgress>>(
                  future: item,
                  builder: (BuildContext context, abc) {
                    if (abc.connectionState == ConnectionState.done) {
                      if (abc.data!.length < 1) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.bus_alert),
                                title: Text('Agentes',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26.0)),
                                subtitle: Text('No hay viajes pendientes',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18.0)),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: abc.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      blurStyle: BlurStyle.normal,
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: -10,
                                      offset: Offset(-15, -6)),
                                  BoxShadow(
                                      blurStyle: BlurStyle.normal,
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 30,
                                      spreadRadius: -15,
                                      offset: Offset(18, 5)),
                                ]),
                                child: Card(
                                  color: Color(0xFF303440),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: EdgeInsets.all(14),
                                  elevation: 10,
                                  child: Column(
                                    children: <Widget>[
                                    Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Theme(                                      
                                      data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        initiallyExpanded: true ,
                                        collapsedIconColor: Colors.white,
                                        backgroundColor: backgroundColor,
                                        title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(14,0,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.tag,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(
                                                  child: Text('Viaje: ${abc.data![index].tripId}',style: TextStyle(color: Colors.white,fontSize: 18.0)),
                                                ),
                                              ],
                                            ),
                                          ),                       
                                        ],
                                        ),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 32),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.calendar_today,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Text('Fecha: ${abc.data![index].fecha}',style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                  ],
                                              ),
                                            ), 
                                            SizedBox(height: 13),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 32),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.location_city_rounded,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Text('Empresa: ${abc.data![index].empresa}',style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                  ],
                                              ),
                                            ),
                                            SizedBox(height: 13),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 32),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.access_time,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Text('Hora: ${abc.data![index].hora}',style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                  ],
                                              ),
                                            ),
                                            SizedBox(height: 13),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 32),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.supervised_user_circle,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Text('Agentes: ${abc.data![index].agentes}',style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                  ],
                                              ),
                                            ),
                                            SizedBox(height: 13),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 32),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.timer_outlined,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Text('Tipo: ${abc.data![index].tipo}',style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                                  ],
                                              ),
                                            ),
                                            SizedBox(height: 13),
                                          ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                                blurStyle: BlurStyle.normal,
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                blurRadius: 10,
                                                spreadRadius: -8,
                                                offset: Offset(-15, -6)),
                                            BoxShadow(
                                                blurStyle: BlurStyle.normal,
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                blurRadius: 10,
                                                spreadRadius: -15,
                                                offset: Offset(18, 5)),
                                          ]),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              fixedSize: Size(200, 50),
                                              elevation: 10,
                                              backgroundColor: backgroundColor,
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            child: Text('Ver viaje',
                                                style: TextStyle(
                                                    color: firstColor,
                                                    fontSize: 20)),
                                            onPressed: () {
                                              
                                              fetchAgentsAsigmentChekc(abc
                                                .data![index].tripId
                                                .toString());
                                                
                                                QuickAlert.show(
                                                context: navigatorKey.currentContext!,
                                                title: "Nota",
                                                text: "Debe marcar el abordaje al momento en que el agente ingrese a la unidad, en caso de no abordar, solo debe llenar la observación.",
                                                type: QuickAlertType.warning,
                                              );                                             },
                                          ),
                                        ),                                  
                                        SizedBox(height: 10.0),                                                                   
                                    ],
                                  ),
                                ),
                              );
                            });
                      }
                    } else {
                      return ColorLoader3();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
