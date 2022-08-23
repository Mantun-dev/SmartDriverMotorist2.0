//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';

import '../../../../constants.dart';
 
void main() => runApp(Trips());
 
class Trips extends StatefulWidget {
  final TripsPending2 item;

  const Trips({Key key, this.item}): super(key: key);
  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  Future <List< TripsPending2>>item;
  TextEditingController tripId = new TextEditingController();
  final prefs = new PreferenciasUsuario();
    
  @override
  void initState(){
    super.initState();
    item = fetchTripsPending();
    tripId = new TextEditingController(text: prefs.tripId);
   // BackButtonInterceptor.add(myInterceptor);
  }



  fetchAgentsInTravel2(String tripId)async{
      prefs.tripId = tripId;   
    if (tripId == tripId) {  
      Navigator.push(context,MaterialPageRoute(builder: (context) => MyAgent(),));       
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      title: 'Viajes',
      debugShowCheckedModeBanner: false,
      home: Scaffold(   
        appBar: AppBar(
          backgroundColor: Colors.lightGreen[400],
          title: Center(child: Text('Viajes disponibles')),
          actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {      
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailsDriverScreen(plantillaDriver: plantillaDriver[0],)),
                  );
                },
              ),
              SizedBox(width: kDefaultPadding / 2)
            ],
        ),
        drawer: DriverMenuLateral(),     
        body: SingleChildScrollView(
          child: Container(
              width: size.width,
              child: Column(
                children: [
                  FutureBuilder<List< TripsPending2>>(
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
                                  title: Text('Agentes', style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 26.0)),
                                  subtitle: Text('No hay viajes pendientes', style: TextStyle(color: Colors.red,fontWeight: FontWeight.normal,fontSize: 18.0)),
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
                            margin: EdgeInsets.all(15),
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
                                        Column(
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
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Icon(Icons.kitchen, color: Colors.green[500], size: 35),
                                          Text(' Empresa: ',
                                              style: TextStyle(
                                                  color: Colors.green[500], fontSize: 17)),
                                          Text('${abc.data[index].empresa}'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Icon(Icons.timer, color: Colors.green[500], size: 35),
                                          Text('Hora:',
                                              style: TextStyle(
                                                  color: Colors.green[500], fontSize: 17)),
                                          Text('${abc.data[index].hora}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Icon(Icons.supervised_user_circle,
                                              color: Colors.green[500], size: 35),
                                          Text('Agentes: ',
                                              style: TextStyle(
                                                  color: Colors.green[500], fontSize: 17)),
                                          Text('${abc.data[index].agentes}'),
                                        ],
                                      ),
                                      Flexible(
                                        child: Column(
                                          children: [
                                            Icon(Icons.drive_eta_sharp,
                                                color: Colors.green[500], size: 35),
                                            Text('Conductor: ',
                                                style: TextStyle(
                                                    color: Colors.green[500], fontSize: 17)),
                                            Text('${abc.data[index].conductor}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.0),
                                  // Usamos una fila para ordenar los botones del card
                                  // ignore: deprecated_member_use
                                  FlatButton(
                                    
                                    onPressed: () {
                                    
                                      fetchAgentsInTravel2(abc.data[index].tripId.toString());
        
                                    },
                                    splashColor: kPrimaryDriverColor,
                                    color: kCardColorDriver2,
                                    child: Text('Ver viaje',
                                        style: TextStyle(color: Colors.white, fontSize: 20)),
                                    textColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: kPrimaryLightDriverColor,
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