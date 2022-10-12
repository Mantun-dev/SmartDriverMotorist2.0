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
  final TripsHistory item;
  const HistoryTripDriver({Key key, this.item}) : super(key: key);

  @override
  _HistoryTripDriverState createState() => _HistoryTripDriverState();
}

class _HistoryTripDriverState extends State<HistoryTripDriver> {
  Future<List<TripsHistory>> item;
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
                                  color: Colors.black,
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
                  );
                } else {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.length,
                      itemBuilder: (context, index) {
                        return Card(
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
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text('Viaje : ',
                                          style: TextStyle(fontSize: 15)),
                                      subtitle:
                                          Text('${abc.data[index].tripId}'),
                                      leading: Icon(Icons.tag,
                                          color: Colors.green[500]),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text('Fecha: ',
                                          style: TextStyle(fontSize: 15)),
                                      subtitle:
                                          Text('${abc.data[index].fecha}'),
                                      leading: Icon(Icons.date_range,
                                          color: Colors.green[500]),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text('Conductor: ',
                                          style: TextStyle(fontSize: 15)),
                                      subtitle:
                                          Text('${abc.data[index].conductor}'),
                                      leading: Icon(Icons.drive_eta_sharp,
                                          color: Colors.green[500]),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text(' Empresa: ',
                                          style: TextStyle(fontSize: 15)),
                                      subtitle:
                                          Text('${abc.data[index].empresa}'),
                                      leading: Icon(Icons.kitchen,
                                          color: Colors.green[500]),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text('Hora:',
                                          style: TextStyle(fontSize: 15)),
                                      subtitle: Text('${abc.data[index].hora}'),
                                      leading: Icon(Icons.timer,
                                          color: Colors.green[500]),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text('Agentes: ',
                                          style: TextStyle(fontSize: 15)),
                                      subtitle:
                                          Text('${abc.data[index].agentes}'),
                                      leading: Icon(
                                          Icons.supervised_user_circle,
                                          color: Colors.green[500]),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text('Tipo: ',
                                          style: TextStyle(fontSize: 15)),
                                      subtitle: Text('${abc.data[index].tipo}'),
                                      leading: Icon(Icons.add_alarm_rounded,
                                          color: Colors.green[500]),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20.0),
                              // Usamos una fila para ordenar los botones del card
                              // ignore: deprecated_member_use
                              TextButton(
                                style: TextButton.styleFrom(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  backgroundColor: kCardColorDriver2,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: kCardColorDriver2,
                                          width: 2,
                                          style: BorderStyle.solid),
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text('Ver viaje',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17)),
                                onPressed: () {
                                  fetchAgentsCompleted(
                                      abc.data[index].tripId.toString());
                                },
                              ),
                              SizedBox(height: 20.0),
                            ],
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
