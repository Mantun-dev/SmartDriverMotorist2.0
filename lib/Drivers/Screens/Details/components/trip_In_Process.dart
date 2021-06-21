import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/confirm_trips.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';

import '../../../../constants.dart';
 
void main() => runApp(Process());
 
class Process extends StatefulWidget {
  final TripsInProgress item;
  const Process({Key key, this.item}) : super(key: key);
  @override
  _ProcessState createState() => _ProcessState();
}

class _ProcessState extends State<Process> {
  Future <List< TripsInProgress>>item;
  TextEditingController tripId = new TextEditingController();
  final prefs = new PreferenciasUsuario();

  @override
    void initState() { 
      super.initState();
      item = fetchTripsInProgress();
      tripId = new TextEditingController( text: prefs.tripId );
    }

  fetchAgentsAsigmentChekc(String tripId)async{
      prefs.tripId = tripId;   
     if (tripId == tripId) {  
       Navigator.push(context,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));       
     }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,      
      home: Scaffold(        
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          title: Center(child: Text('Viajes en proceso')),
        ),
        body: SingleChildScrollView(
          child: Container(
          width: 500.0,
            child: Column(
              children: [
                      FutureBuilder<List< TripsInProgress>>(
                      future: item,
                      builder: (BuildContext context, abc) {
                        if (abc.connectionState == ConnectionState.done) {
                          if (abc.data.length < 1) {
                            return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.symmetric(vertical: 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.bus_alert),
                                      title: Text('Agentes', style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 26.0)),
                                      subtitle: Text('No hay viajes pendientes', style: TextStyle(
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
                            itemBuilder: (context, index){                        
                                return Card(
                                shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(14),
                                elevation: 10,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 20.0),
                                    Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.tag,
                                                color: Colors.green[500],
                                                size: 35,
                                              ),
                                              Text(' Viaje : ',
                                                  style: TextStyle(
                                                      color: Colors.green[500], fontSize: 17)),
                                              Text('${abc.data[index].tripId}'),
                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color: Colors.green[500],
                                                  size: 35,
                                                ),
                                                Text('Fecha: ',
                                                    style: TextStyle(
                                                        color: Colors.green[500], fontSize: 17)),
                                                Text('${abc.data[index].fecha}'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.kitchen,
                                              color: Colors.green[500],
                                              size: 35,
                                            ),
                                            Text(' Empresa: ',
                                                style: TextStyle(
                                                    color: Colors.green[500], fontSize: 17)),
                                            Text(
                                              '${abc.data[index].empresa}',
                                              style: TextStyle(color: kTextColor),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 5),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.timer,
                                                color: Colors.green[500],
                                                size: 35,
                                              ),
                                              Text('Hora:',
                                                  style: TextStyle(
                                                      color: Colors.green[500], fontSize: 17)),
                                              Text('${abc.data[index].hora}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.supervised_user_circle,
                                              color: Colors.green[500],
                                              size: 35,
                                            ),
                                            Text('Agentes: ',
                                                style: TextStyle(
                                                    color: Colors.green[500], fontSize: 17)),
                                            Text('${abc.data[index].agentes}'),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.arrow_circle_down_rounded,
                                              color: Colors.green[500],
                                              size: 35,
                                            ),
                                            Text('Tipo: ',
                                                style: TextStyle(
                                                    color: Colors.green[500], fontSize: 17)),
                                            Text('${abc.data[index].tipo}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
        
                                    // Usamos una fila para ordenar los botones del card
                                    // ignore: deprecated_member_use
                                    FlatButton(
                                      onPressed: () {
                                        fetchAgentsAsigmentChekc(abc.data[index].tripId.toString());
                                      },
                                      splashColor: kPrimaryDriverColor,
                                      color: kCardColorDriver2,
                                      child: Text('Ver viaje',
                                          style: TextStyle(color: Colors.white, fontSize: 17)),
                                      textColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: kCardColorDriver2,
                                              width: 2,
                                              style: BorderStyle.solid),
                                          borderRadius: BorderRadius.circular(10)),
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
          ),
        ),
      ),
    );
  }
}