import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/confirm_trips.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/details_TripProgress.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';

import '../../../../constants.dart';
import '../../../models/plantillaDriver.dart';

void main() => runApp(Process());

class Process extends StatefulWidget {
  final TripsInProgress item;
  const Process({Key key, this.item}) : super(key: key);
  @override
  _ProcessState createState() => _ProcessState();
}

class _ProcessState extends State<Process> {
  Future<List<TripsInProgress>> item;
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
                Navigator.pop(
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
                      if (abc.data.length < 1) {
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
                            itemCount: abc.data.length,
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
                                      SizedBox(height: 20.0),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Icon(
                                                  Icons.directions_car,
                                                  color: thirdColor,
                                                  size: 40,
                                                ),
                                                Text('No. de viaje : ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Gradiant2,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                  '${abc.data[index].tripId}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color: thirdColor,
                                                  size: 40,
                                                ),
                                                Text('Fecha: ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Gradiant2,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text('${abc.data[index].fecha}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceEvenly, //Center Row contents horizontally,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Icon(Icons.location_city,
                                                    color: thirdColor,
                                                    size: 40),
                                                Text(' Empresa: ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Gradiant2,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                  '${abc.data[index].empresa}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceEvenly, //Center Row contents horizontally,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.access_time,
                                                    color: thirdColor,
                                                    size: 40),
                                                Text('Hora:',
                                                    style: TextStyle(
                                                        color: Gradiant2,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text('${abc.data[index].hora}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .supervised_user_circle,
                                                    color: thirdColor,
                                                    size: 40),
                                                Text('Agentes: ',
                                                    style: TextStyle(
                                                        color: Gradiant2,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    '${abc.data[index].agentes}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceEvenly, //Center Row contents horizontally,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons
                                                        .arrow_circle_down_rounded,
                                                    color: thirdColor,
                                                    size: 40),
                                                Text('Tipo: ',
                                                    style: TextStyle(
                                                        color: Gradiant2,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text('${abc.data[index].tipo}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  color: thirdColor,
                                                  size: 40,
                                                ),
                                                Text('Conductor: ',
                                                    style: TextStyle(
                                                        color: Gradiant2,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    '${abc.data[index].conductor}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20.0),

                                      // Usamos una fila para ordenar los botones del card
                                      // ignore: deprecated_member_use
                                      Container(
                                        decoration: BoxDecoration(boxShadow: [
                                          BoxShadow(
                                              blurStyle: BlurStyle.normal,
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              blurRadius: 30,
                                              spreadRadius: -8,
                                              offset: Offset(-15, -6)),
                                          BoxShadow(
                                              blurStyle: BlurStyle.normal,
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              blurRadius: 30,
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
                                                // side: BorderSide(
                                                //     color: kCardColorDriver2,
                                                //     width: 2,
                                                //     style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            fetchAgentsAsigmentChekc(abc
                                                .data[index].tripId
                                                .toString());
                                          },
                                          child: Text('Ver viaje',
                                              style: TextStyle(
                                                  color: firstColor,
                                                  fontSize: 20)),
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
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
