import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/finished_trips.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/models/AgentTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

class HistoryTripDriver extends StatefulWidget {
  final TripsHistory? item;
  const HistoryTripDriver({Key? key, this.item}) : super(key: key);

  @override
  _HistoryTripDriverState createState() => _HistoryTripDriverState();
}

class _HistoryTripDriverState extends State<HistoryTripDriver> {
  Future<List<TripsHistory>>? item;
  final prefs = new PreferenciasUsuario();
  TextEditingController tripId = new TextEditingController();
  String ip = "https://driver.smtdriver.com";
  @override
  void initState() {
    super.initState();
    item = fetchTripsHistory();
    tripId = new TextEditingController(text: prefs.tripId);
  }

  Future<TripsList3> fetchAgentsCompleted(String tripId) async {
    Map datas = {
      'tripId': tripId,
    };
    prefs.tripId = tripId;

    http.Response responsed =
        await http.get(Uri.parse('$ip/apis/agentsInTravel/${datas['tripId']}'));

    if (responsed.statusCode == 200) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyFinishedTrips(),
          ));
      return TripsList3.fromJson(json.decode(responsed.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500.0,
      child: Column(
        children: [
          FutureBuilder<List<TripsHistory>>(
            future: item,
            builder: (BuildContext context, abc) {
              if (abc.connectionState == ConnectionState.done) {
                if (abc.data!.length < 1) {
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 26.0)),
                            subtitle: Text('No hay viajes registrados',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18.0)),
                          ),
                        ],
                      ),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 35.0, vertical: 5.0),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                blurStyle: BlurStyle.normal,
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 25,
                                spreadRadius: -50,
                                offset: Offset(-10, -16)),
                            BoxShadow(
                                blurStyle: BlurStyle.normal,
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 25,
                                spreadRadius: -50,
                                offset: Offset(18, 15)),
                          ]),
                          child: Card(
                            color: backgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(15),
                            elevation: 10,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 20.0),
                                Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 5, 10, 0),
                                        title: Text('Viaje : ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${abc.data![index].tripId}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white60,
                                                fontWeight: FontWeight.normal)),
                                        leading: Icon(
                                          Icons.tag,
                                          color: thirdColor,
                                          size: 35,
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 5, 10, 0),
                                        title: Text('Fecha: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${abc.data![index].fecha}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white60,
                                                fontWeight: FontWeight.normal)),
                                        leading: Icon(Icons.date_range,
                                            color: thirdColor, size: 35),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 5, 10, 0),
                                        title: Text('Conductor: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${abc.data![index].conductor}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white60,
                                                fontWeight: FontWeight.normal)),
                                        leading: Icon(Icons.drive_eta_sharp,
                                            color: thirdColor, size: 35),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 5, 10, 0),
                                        title: Text('Empresa: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${abc.data![index].empresa}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white60,
                                                fontWeight: FontWeight.normal)),
                                        leading: Icon(
                                            Icons.location_city_rounded,
                                            color: thirdColor,
                                            size: 35),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 5, 10, 0),
                                        title: Text('Hora:',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${abc.data![index].hora}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white60,
                                                fontWeight: FontWeight.normal)),
                                        leading: Icon(Icons.access_time,
                                            color: thirdColor, size: 35),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 5, 10, 0),
                                        title: Text('Agentes: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${abc.data![index].agentes}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white60,
                                                fontWeight: FontWeight.normal)),
                                        leading: Icon(
                                            Icons.supervised_user_circle,
                                            color: thirdColor,
                                            size: 35),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 5, 10, 0),
                                        title: Text('Tipo:',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${abc.data![index].tipo}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white60,
                                                fontWeight: FontWeight.normal)),
                                        leading: Icon(Icons.timer_outlined,
                                            color: thirdColor, size: 35),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20.0),
                                // Usamos una fila para ordenar los botones del card
                                // ignore: deprecated_member_use
                                Container(
                                  width: 150,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      textStyle: TextStyle(
                                        color: backgroundColor,
                                      ),
                                      backgroundColor: firstColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text('Ver viaje',
                                        style: TextStyle(
                                            color: backgroundColor,
                                            fontSize: 17)),
                                    onPressed: () {
                                      fetchAgentsCompleted(
                                          abc.data![index].tripId.toString());
                                    },
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
    );
  }
}
