import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/AgentTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:intl/intl.dart';
import '../../../../constants.dart';

void main() {
  runApp(MyFinishedTrips());
}

class MyFinishedTrips extends StatefulWidget {
  final PlantillaDriver plantillaDriver;

  const MyFinishedTrips({Key key, this.plantillaDriver}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyFinishedTrips> {
  bool checkBoxValue = false;
  final format = DateFormat("HH:mm");
  Future <TripsList3> item;
  @override
  void initState() { 
    super.initState();
    item = fetchAgentsCompleted();

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: DriverMenuLateral(),
          appBar: AppBar(
            title: Text('Detalle de Viaje'),
            backgroundColor: kColorDriverAppBar,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DetailsDriverScreen(
                      plantillaDriver: plantillaDriver[3],
                    );
                  }));
                },
              ),
              SizedBox(width: kDefaultPadding / 2)
            ],
          ),
          body: ListView(children: <Widget>[
            SizedBox(height: 40.0),
            Center(
                child: Text('Agentes con hora asignada',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
            SizedBox(height: 10.0),
            _agentToConfirm(),
            SizedBox(height: 20.0),
            Center(
                child: Text('Agentes cancelados',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
            SizedBox(height: 10.0),
            _agentToCancel(),
            SizedBox(height: 20.0),
          ])),
    );
  }

  Widget _agentToConfirm() {
      return FutureBuilder<TripsList3>(
          future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              if (abc.data.trips[0].inTrip.length == 0) {
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
                                        fontSize: 20.0)),
                                subtitle: Text('No hay agentes confirmados para este viaje', style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15.0)),
                              ),                      
                            ],
                          ),
                        );
              } else {                
                return FutureBuilder<TripsList3>(
                  future: item,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.trips[0].inTrip.length,
                      itemBuilder: (context, index){
                        return Container(
                          width: 500.0,
                          child: Column(
                            children: [
                              Card(
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(15.0),
                                elevation: 2,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ExpansionTile(
                                        backgroundColor: Colors.white,
                                        title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              if (abc.data.trips[0].inTrip[index].traveled == 1)...{                                                
                                                Text('✅'),
                                                Text('Abordó')
                                              } else ...{
                                                Text('x',style: TextStyle(color: Colors.red[500], fontSize: 25)),
                                                Text(' no abordó')
                                              }
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(width: 25.0),
                                              Column(
                                                children: [
                                                  Icon(
                                                    Icons.kitchen,
                                                    color: Colors.green[500],
                                                    size: 35,
                                                  ),
                                                  Text(' Empresa: ',
                                                      style: TextStyle(color: Colors.green[500], fontSize: 17)),
                                                  Text(
                                                    '${abc.data.trips[0].inTrip[index].companyName}',
                                                    style: TextStyle(color: kTextColor),
                                                  ),
                                                ],
                                              ),
                                              Flexible(
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.supervised_user_circle_rounded,
                                                      color: Colors.green[500],
                                                      size: 35,
                                                    ),
                                                    Text('Nombre: ',
                                                        style: TextStyle(color: Colors.green[500], fontSize: 17)),
                                                    Text('${abc.data.trips[0].inTrip[index].agentFullname}', style: TextStyle(color: kTextColor)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                        trailing: SizedBox(),
                                        children: [
                                          //aqui lo demás
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(Icons.phone,
                                                        color: Colors.green[500], size: 35),
                                                    Text('Teléfono: ',
                                                        style: TextStyle(
                                                            color: Colors.green[500],
                                                            fontSize: 17)),
                                                    Text('${abc.data.trips[0].inTrip[index].agentPhone}'),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      color: Colors.green[500],
                                                      size: 35,
                                                    ),
                                                    Text('Entrada:',
                                                        style: TextStyle(
                                                            color: Colors.green[500],
                                                            fontSize: 17)),
                                                    Text('${abc.data.trips[0].inTrip[index].hourIn}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(
                                                      Icons.location_pin,
                                                      color: Colors.green[500],
                                                      size: 35,
                                                    ),
                                                    Text('Dirección: ',
                                                        style: TextStyle(
                                                            color: Colors.green[500],
                                                            fontSize: 17)),
                                                    Text('${abc.data.trips[0].inTrip[index].agentReferencePoint} \n ${abc.data.trips[0].inTrip[index].neighborhoodName} \n ${abc.data.trips[0].inTrip[index].districtName}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 20.0),

                                          TextButton (
                                            style: TextButton.styleFrom(
                                              primary: Colors.white, // foreground
                                              backgroundColor: kCardColorDriver2,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: kCardColorDriver1,
                                                    width: 2,
                                                    style: BorderStyle.solid),
                                                borderRadius: BorderRadius.circular(10)),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Container(
                                                    width: 400,
                                                    height: 200,
                                                    child: Column(
                                                      children: <Widget>[                                                      
                                                        SizedBox(height: 15),
                                                        if (abc.data.trips[0].inTrip[index].commentDriver == null)...{
                                                          Center(child: Text(
                                                            'Observación',
                                                            style: TextStyle(
                                                              fontSize: 22, fontWeight: FontWeight.bold
                                                            ),)
                                                          
                                                          ),
                                                          Text('')
                                                        } else...{
                                                          Center(child: Text(
                                                            'Observación',
                                                            style: TextStyle(
                                                              fontSize: 22, fontWeight: FontWeight.bold
                                                            ),),),
                                                          SizedBox(height: 15),
                                                          Center(
                                                            child: Text(
                                                              '${abc.data.trips[0].inTrip[index].commentDriver}',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        },
                                                        SizedBox(height: 21),
                                                        TextButton (
                                                          style: TextButton.styleFrom(
                                                            primary: Colors.white, // foreground
                                                            backgroundColor: Colors.green
                                                          ),
                                                          onPressed: () => {
                                                              setState((){
                                                                Navigator.pop(context);                                                  
                                                              }),
                                                          },
                                                          child: Text('Entendido'),                                                         
                                                        ), 
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              );
                                            },
                                            
                                            child: Text('Observaciones',
                                                style: TextStyle(color: Colors.white)),
                                            
                                            
                                          ),
                                          
                                          SizedBox(height: 20.0),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                          ),
                        ); 

                      } 
                    ) ;
                  },
                );          
              }
            } else {
              return ColorLoader3();
            }
          },
        ); 
  
  }

  Widget _agentToCancel() {
      return FutureBuilder<TripsList3>(
          future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              if (abc.data.trips[1].cancelAgent.length == 0) {
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
                                        fontSize: 20.0)),
                                subtitle: Text('No hay agentes cancelados para este viaje', style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15.0)),
                              ),                      
                            ],
                          ),
                        );
              } else {                
                return FutureBuilder<TripsList3>(
                  future: item,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.trips[1].cancelAgent.length,
                      itemBuilder: (context, index){
                        return Container(
                          width: 500.0,
                          child: Column(
                            children: [
                              Card(
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(15.0),
                                elevation: 2,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ExpansionTile(
                                        backgroundColor: Colors.white,
                                        title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              if (abc.data.trips[1].cancelAgent[index].traveled == 1)...{                                                
                                                Text('✅'),
                                                Text('Abordó')
                                              } else ...{
                                                Text('x',style: TextStyle(color: Colors.red[500], fontSize: 25)),
                                                Text(' no abordó')
                                              }
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(width: 25.0),
                                              Column(
                                                children: [
                                                  Icon(
                                                    Icons.kitchen,
                                                    color: Colors.green[500],
                                                    size: 35,
                                                  ),
                                                  Text(' Empresa: ',
                                                      style: TextStyle(color: Colors.green[500], fontSize: 17)),
                                                  Text(
                                                    '${abc.data.trips[1].cancelAgent[index].companyName}',
                                                    style: TextStyle(color: kTextColor),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Icon(
                                                    Icons.supervised_user_circle_rounded,
                                                    color: Colors.green[500],
                                                    size: 35,
                                                  ),
                                                  Text('Nombre: ',
                                                      style: TextStyle(color: Colors.green[500], fontSize: 17)),
                                                  Text('${abc.data.trips[1].cancelAgent[index].agentFullname}', style: TextStyle(color: kTextColor)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                        trailing: SizedBox(),
                                        children: [
                                          //aqui lo demás
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(Icons.phone,
                                                        color: Colors.green[500], size: 35),
                                                    Text('Teléfono: ',
                                                        style: TextStyle(
                                                            color: Colors.green[500],
                                                            fontSize: 17)),
                                                    Text('${abc.data.trips[1].cancelAgent[index].agentPhone}'),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      color: Colors.green[500],
                                                      size: 35,
                                                    ),
                                                    Text('Entrada:',
                                                        style: TextStyle(
                                                            color: Colors.green[500],
                                                            fontSize: 17)),
                                                    Text('${abc.data.trips[1].cancelAgent[index].hourIn}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(
                                                      Icons.location_pin,
                                                      color: Colors.green[500],
                                                      size: 35,
                                                    ),
                                                    Text('Dirección: ',
                                                        style: TextStyle(
                                                            color: Colors.green[500],
                                                            fontSize: 17)),
                                                    Text('${abc.data.trips[1].cancelAgent[index].agentReferencePoint} \n ${abc.data.trips[1].cancelAgent[index].neighborhoodName} \n ${abc.data.trips[1].cancelAgent[index].districtName}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 20.0),

                                         TextButton (
                                            style: TextButton.styleFrom(
                                              primary: Colors.white, // foreground
                                              backgroundColor: kCardColorDriver2,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: kCardColorDriver1,
                                                    width: 2,
                                                    style: BorderStyle.solid),
                                                borderRadius: BorderRadius.circular(10))
                                            ),                                         
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Container(
                                                    width: 400,
                                                    height: 200,
                                                    child: Column(
                                                      children: <Widget>[                                                      
                                                        SizedBox(height: 15),
                                                        if (abc.data.trips[0].inTrip[index].commentDriver == null)...{
                                                          Center(child: Text(
                                                            'Observación',
                                                            style: TextStyle(
                                                              fontSize: 22, fontWeight: FontWeight.bold
                                                            ),)
                                                          
                                                          ),
                                                          Text('')
                                                        } else...{
                                                          Center(child: Text(
                                                            'Observación',
                                                            style: TextStyle(
                                                              fontSize: 22, fontWeight: FontWeight.bold
                                                            ),),),
                                                          SizedBox(height: 15),
                                                          Center(
                                                            child: Text(
                                                              '${abc.data.trips[1].cancelAgent[index].commentDriver}',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        },
                                                        SizedBox(height: 21),
                                                        TextButton (
                                                          style: TextButton.styleFrom(
                                                            primary: Colors.white, // foreground
                                                            backgroundColor: Colors.green
                                                          ),
                                                          onPressed: () => {
                                                              setState((){
                                                                Navigator.pop(context);                                                  
                                                              }),
                                                          },
                                                          child: Text('Entendido'),                                                          
                                                        ), 
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              );
                                            },
                                            
                                            child: Text('Observaciones',
                                                style: TextStyle(color: Colors.white)),
                                            
                                            
                                        ),
                                          
                                          SizedBox(height: 20.0),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                          ),
                        ); 

                      } 
                    ) ;
                  },
                );          
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ); 
  
  }

}
