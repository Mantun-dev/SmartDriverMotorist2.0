//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';

import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';

import '../../../../constants.dart';
import '../../../models/plantillaDriver.dart';
import 'detailsDriver_assignHour.dart';

void main() => runApp(Trips());

class Trips extends StatefulWidget {
  final TripsPending2 item;

  const Trips({Key key, this.item}) : super(key: key);
  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  Future<List<TripsPending2>> item;
  TextEditingController tripId = new TextEditingController();
  final prefs = new PreferenciasUsuario();

  @override
  void initState() {
    super.initState();
    item = fetchTripsPending();
    tripId = new TextEditingController(text: prefs.tripId);
    // BackButtonInterceptor.add(myInterceptor);
  }

  fetchAgentsInTravel2(String tripId) async {
    prefs.tripId = tripId;
    if (tripId == tripId) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyAgent(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 10,
          backgroundColor: backgroundColor,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_circle_left),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DetailsDriverHour(
                          plantillaDriver: plantillaDriver[0]);
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
          width: size.width,
          height: size.height,
          color: backgroundColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<List<TripsPending2>>(
                  future: item,
                  builder: (BuildContext context, abc) {
                    if (abc.connectionState == ConnectionState.done) {
                      if (abc.data.length < 1) {
                        return Card(
                          color: backgroundColor,
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
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
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
                                      blurRadius: 30,
                                      spreadRadius: -8,
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
                                  margin: EdgeInsets.all(15),
                                  elevation: 10,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 15),
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
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Gradiant2,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                    '${abc.data[index].fecha}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
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
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center, //Center Row contents vertically,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceEvenly, //Center Row contents horizontally,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center, //
                                                children: [
                                                  Icon(Icons.location_city,
                                                      color: thirdColor,
                                                      size: 40),
                                                  Text('Empresa:',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Gradiant2,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      '${abc.data[index].empresa}',
                                                      textAlign:
                                                          TextAlign.center,
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
                                                    CrossAxisAlignment
                                                        .center, //
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
                                                  Text(
                                                      '${abc.data[index].hora}',
                                                      textAlign:
                                                          TextAlign.center,
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
                                          margin: EdgeInsets.only(left: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly, //Center Row contents horizontally,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center, //
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceEvenly, //Center Row contents horizontally,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center, //
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
                                                  Icon(Icons.person,
                                                      color: thirdColor,
                                                      size: 40),
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
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20.0),
                                        // Usamos una fila para ordenar los botones del card
                                        // ignore: deprecated_member_use
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
                                                    .withOpacity(0.6),
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
                                              fetchAgentsInTravel2(abc
                                                  .data[index].tripId
                                                  .toString());
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20.0),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                    } else {
                      return Center(child: ColorLoader3());
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
