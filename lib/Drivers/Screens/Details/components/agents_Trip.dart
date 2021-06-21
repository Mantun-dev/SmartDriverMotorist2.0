
import 'package:flutter/material.dart';

import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_auth/Drivers/models/registerTripAsCompleted.dart';
import 'package:intl/intl.dart';
import 'package:sweetalert/sweetalert.dart';
import '../../../../constants.dart';
import '../../../models/agentsInTravelModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyAgent());
}

class MyAgent extends StatefulWidget {
  final TripsList2 item;
  final PlantillaDriver plantillaDriver;

  const MyAgent({Key key, this.plantillaDriver, this.item}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyAgent> {

  
  Future <TripsList2> item;
  TextEditingController agentHours = new TextEditingController();
  final prefs = new PreferenciasUsuario();
  String ip = "192.168.0.113:4000";
  

  Future<Driver>fetchHours( String agentId, String agentTripHour,  String tripId ) async {
      Map data = {
        'agentId' : agentId,
        'agentTripHour'    : agentTripHour,
        'tripId'   : tripId
      };
    
      print(data);
    http.Response response = await http.post(Uri.encodeFull('http://$ip/apis/registerAgentTripTime'), body: data);

    final resp = Driver.fromJson(json.decode(response.body));
      

    if (response.statusCode == 200 && resp.ok == true && agentTripHour != "") {   
      print(response.body);    
        SweetAlert.show(context,
        title: resp.title,
        subtitle: resp.message,
        style: SweetAlertStyle.success
      );
    } 
    else if(response.statusCode == 200 && resp.ok != true ){
      SweetAlert.show(context,
          title: resp.title,
          subtitle: resp.message,
          style: SweetAlertStyle.error,
      );
    }

      return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver>fetchNoConfirm( String agentId,  String tripId ) async {
      Map data = {
        'agentId' : agentId,
        'tripId'   : tripId
      };
    
      print(data);
    http.Response response = await http.post(Uri.encodeFull('http://$ip/apis/markAgentAsNotConfirmed'), body: data);
if (mounted) {
    setState(() {
    final resp = Driver.fromJson(json.decode(response.body));
      

    if (response.statusCode == 200 && resp.ok == true) {   
      print(response.body);    
        SweetAlert.show(context,
        title: resp.title,
        subtitle: resp.message,
        style: SweetAlertStyle.success
      );
    } 
    else if(response.statusCode == 500){
      SweetAlert.show(context,
          title: resp.title,
          subtitle: resp.message,
          style: SweetAlertStyle.error,
      );
    }
    });
    }
      return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver>fetchPastInProgress( ) async {

    http.Response response = await http.get(Uri.encodeFull('http://$ip/apis/passTripToProgress/${prefs.tripId}'));
    final resp = Driver.fromJson(json.decode(response.body));
          if (response.statusCode == 200 && resp.ok == true) {   
              print(response.body);  
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context)=>
              HomeDriverScreen()), (Route<dynamic> route) => false); 
              SweetAlert.show(context,
              title: resp.title,
              subtitle: resp.message,
              style: SweetAlertStyle.success
            );
          } 
          else if(response.statusCode == 500){
            SweetAlert.show(context,
                title: resp.title,
                subtitle: resp.message,
                style: SweetAlertStyle.error,
            );
          }


    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver>fetchTripCancel() async {
      http.Response responses = await http.get(Uri.encodeFull('http://$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
      final data = DriverData.fromJson(json.decode(responses.body));
      http.Response response = await http.get(Uri.encodeFull('http://$ip/apis/driverCancelTrip/${prefs.tripId}/${data.driverId}'));

      final resp = Driver.fromJson(json.decode(response.body));

        if (response.statusCode == 200 && resp.ok == true) {   
            print(response.body); 
           
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context)=>
             HomeDriverScreen()), (Route<dynamic> route) => false);  
            SweetAlert.show(context,
            title: 'ok',
            subtitle: resp.message,
            style: SweetAlertStyle.success
            );
        } 
        else if(response.statusCode == 500){
          SweetAlert.show(context,
              title: 'ok',
              subtitle: resp.message,
              style: SweetAlertStyle.error,
          );
        }
 

      
      return Driver.fromJson(json.decode(response.body));
  }



  @override
  void initState() { 
    super.initState();
    item = fetchAgentsInTravel2();
    //agentHours = new TextEditingController( text: prefs.tripHours );

  }
  static DateTime _eventdDate = DateTime.now();
                                                        static var now =
  TimeOfDay.fromDateTime(DateTime.parse(_eventdDate.toString()));  
  final format = DateFormat('HH:mm');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: DriverMenuLateral(),
          appBar: AppBar(
            title: Text('Asignación de Horas'),
            backgroundColor: kColorDriverAppBar,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DetailsDriverScreen(
                      plantillaDriver: plantillaDriver[0],
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
                child: Text('Agentes confirmados',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
            _agentToConfirm(),
            SizedBox(height: 40.0),
            Center(
                child: Text('Agentes no confirmados',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
            _agentoNoConfirm(),
            SizedBox(height: 40.0),
            Center(
                child: Text('Agentes que han cancelado',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
            _agentToCancel(),
            SizedBox(height: 20.0),
            _buttonsAgents(),
            SizedBox(height: 30.0),
          ])),
    );
  }

//AgentToConfirm
  Widget _agentToConfirm(){

        return FutureBuilder<TripsList2> (
          future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              if (abc.data.trips[0].agentes.length == 0) {
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
                                subtitle: Text('No hay agentes no confirmados para este viaje', style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15.0)),
                              ),                      
                            ],
                          ),
                        );
              } else {
                return FutureBuilder<TripsList2>(
                  future: item,
                  builder: (BuildContext context,  abc) {
                    if (abc.connectionState == ConnectionState.done) {  
                       return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.trips[0].agentes.length,
                      itemBuilder: (context, index){
                        return Container(
                            width: 500.0,
                            child: Column(
                              children: [
                                InkWell(                                      
                                    child: Card(
                                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                                        '${abc.data.trips[0].agentes[index].companyName}',
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
                                                        Container(
                                                          padding: EdgeInsets.only(left: 20), 
                                                          child:Text('${abc.data.trips[0].agentes[index].agentFullname}', style: TextStyle(color: kTextColor)),
                                                        ),    
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
                                                child: Container(
                                                  margin: EdgeInsets.only(left: 20),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Icon(
                                                            Icons.phone,
                                                            color: Colors.green[500],
                                                            size: 35,
                                                          ),
                                                          Text('Teléfono: ',
                                                              style: TextStyle(
                                                                  color: Colors.green[500],
                                                                  fontSize: 17)),                                                        
                                                          TextButton(
                                                          onPressed: () => launch('tel://${abc.data.trips[0].agentes[index].agentPhone}'),
                                                          child:  Text('${abc.data.trips[0].agentes[index].agentPhone}',style: TextStyle(color: Colors.blue[500],fontSize: 14))),
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
                                                          Text('${abc.data.trips[0].agentes[index].hourIn}'),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
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
                                                        Text('${abc.data.trips[0].agentes[index].agentReferencePoint} \n ${abc.data.trips[0].agentes[index].neighborhoodName} \n ${abc.data.trips[0].agentes[index].districtName}'),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                             SizedBox(height: 30.0),
                                             if (abc.data.trips[0].agentes[index].hourForTrip == "00:00")... {
                                              Text('Hora de encuentro: '), 
                                             } else... {
                                               Row(
                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                 children: [
                                                   Column(
                                                    children: [
                                                      Text('Hora de encuentro: '),
                                                    ],
                                                   ),
                                                   Column(
                                                    children: [
                                                      Text('${abc.data.trips[0].agentes[index].hourForTrip}',style: TextStyle(color: Colors.blue[400],fontWeight: FontWeight.bold,fontSize: 19.0))
                                                    ],
                                                   ),
                                                 ],
                                               ),
                                             },
                                              SizedBox(height: 10.0),
                                              
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(width: 1, color: Colors.grey),
                                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.2),
                                                          spreadRadius: 5,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 3), // changes position of shadow
                                                        )
                                                      ]),
                                                  margin: EdgeInsets.symmetric(horizontal: 40.0),
                                                  child: Column(
                                                    children: [
                                                      DateTimeField(
                                                        format: format,
                                                        
                                                        onShowPicker: (context, currentValue) async {
                                                          final time = await showTimePicker(
                                                            context: context,
                                                            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                                          );
                                                          if (time != null && agentHours.text != 00.00) {
                                                            String _eventTime = now.toString().substring(10, 15);   
                                                            _eventTime = time.toString().substring(10, 15);   
                                                            print(_eventTime);
                                                            fetchHours(abc.data.trips[0].agentes[index].agentId.toString(), _eventTime, abc.data.trips[0].agentes[index].tripId.toString());
                                                            Navigator.pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      MyAgent()),
                                                                  (Route<dynamic> route) =>
                                                              false);
                                                          }
                                                          print(agentHours);
                                                          return DateTimeField.convert(time);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              
                                              SizedBox(height: 20.0),
                                           ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    // if (agentHours != 00.00) {                                        
                                    // }
                                    },
                                ),
                               
                              ],
                            ),
                          );   
                     
                      } 
                    );                      
                          
                     
                    } else {
                      return ColorLoader3();
                    }
                  },
                );                 
              }
            } else {
              return ColorLoader3();
            }
          },
        ); 

  }

//AgentNoConfirm
  Widget _agentoNoConfirm() {

        return FutureBuilder<TripsList2> (
          future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              if (abc.data.trips[1].noConfirmados.length == 0) {
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
                                subtitle: Text('No hay agentes no confirmados para este viaje', style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15.0)),
                              ),                      
                            ],
                          ),
                        );
              } else {                
                return FutureBuilder<TripsList2>(
                future: item,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.trips[1].noConfirmados.length,
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
                                                    '${abc.data.trips[1].noConfirmados[index].companyName}',
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
                                                    Container(
                                                      padding: EdgeInsets.only(left: 20), 
                                                      child:Text('${abc.data.trips[1].noConfirmados[index].agentFullname}', style: TextStyle(color: kTextColor)),
                                                    ),                                              
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
                                                    Icon(
                                                      Icons.phone,
                                                      color: Colors.green[500],
                                                      size: 35,
                                                    ),
                                                    Text('Teléfono: ',
                                                        style: TextStyle(
                                                            color: Colors.green[500],
                                                            fontSize: 17)),
                                                    TextButton(
                                                    onPressed: () => launch('tel://${abc.data.trips[1].noConfirmados[index].agentPhone}'),
                                                    child:  Text('${abc.data.trips[1].noConfirmados[index].agentPhone}',style: TextStyle(color: Colors.blue[500],fontSize: 14))),                                                                                                  
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
                                                    Text('${abc.data.trips[1].noConfirmados[index].hourIn}'),
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
                                                    Text('${abc.data.trips[1].noConfirmados[index].agentReferencePoint} \n ${abc.data.trips[1].noConfirmados[index].neighborhoodName} \n ${abc.data.trips[1].noConfirmados[index].districtName}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 30.0),
                                          Text('Hora de encuentro: '),
                                          SizedBox(height: 10.0),
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 1, color: Colors.grey),
                                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.2),
                                                    spreadRadius: 5,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3), // changes position of shadow
                                                  )
                                                ]),
                                            margin: EdgeInsets.symmetric(horizontal: 40.0),
                                            child: Column(
                                              children: [
                                                DateTimeField(
                                                  format: format,                                                  
                                                  onShowPicker: (context, currentValue) async {
                                                    final time = await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay.now(),
                                                    );
                                                    if (time != null) {
                                                      setState(() {                                                          
                                                        String _eventTime = now.toString().substring(10, 15);   
                                                        _eventTime = time.toString().substring(10, 15);   
                                                        print(_eventTime);
                                                        fetchHours(  abc.data.trips[1].noConfirmados[index].agentId.toString(), _eventTime,   abc.data.trips[1].noConfirmados[index].tripId.toString() );
                                                        Navigator.pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      MyAgent()),
                                                                  (Route<dynamic> route) =>
                                                              false);
                                                      });
                                                    }
                                                    return DateTimeField.convert(time);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 20.0),
                                          // Usamos una fila para ordenar los botones del card
                                          TextButton (
                                            style: TextButton.styleFrom(
                                              primary: Colors.white, // foreground
                                              backgroundColor: kCardColorDriver1,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: kCardColorDriver2,
                                                    width: 2,
                                                    style: BorderStyle.solid),
                                                borderRadius: BorderRadius.circular(10)),
                                            ),
                                            onPressed: () {
                                              fetchNoConfirm(abc.data.trips[1].noConfirmados[index].agentId.toString(), abc.data.trips[1].noConfirmados[index].tripId.toString());
                                            },                                                                                        
                                            child: Text('No confirmó',
                                                style:
                                                    TextStyle(color: Colors.white, fontSize: 17)),                                                                                        
                                          ),
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
                    );
                  },
                );
                              
              }
            } else {
              return ColorLoader3();
            }
          },
        ); 

  }


//AgentToCancel
  Widget _agentToCancel() {

      return FutureBuilder<TripsList2>(
          future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              if (abc.data.trips[2].cancelados.length == 0) {
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
                                subtitle: Text('No hay agentes que han cancelados', style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15.0)),
                              ),                      
                            ],
                          ),
                        );
              } else if(abc.data.trips[2].cancelados.length > 0){                
                return FutureBuilder<TripsList2>(
                  future: item,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.trips[2].cancelados.length,
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
                                                    '${abc.data.trips[2].cancelados[index].companyName}',
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
                                                    Container(
                                                      padding: EdgeInsets.only(left: 20), 
                                                      child: Text('${abc.data.trips[2].cancelados[index].agentFullname}', style: TextStyle(color: kTextColor)),
                                                    ),
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
                                                    TextButton(
                                                        onPressed: () => launch('tel://${abc.data.trips[2].cancelados[index].agentPhone}'),
                                                        child:  Text('${abc.data.trips[2].cancelados[index].agentPhone}',style: TextStyle(color: Colors.blue[500],fontSize: 14))),
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
                                                    Text('${abc.data.trips[2].cancelados[index].hourIn}'),
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
                                                    Text('${abc.data.trips[2].cancelados[index].agentReferencePoint} \n ${abc.data.trips[2].cancelados[index].neighborhoodName} \n ${abc.data.trips[2].cancelados[index].districtName}'),
                                                  ],
                                                ),
                                              ],
                                            ),
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
              return SizedBox();
            } else {
              return ColorLoader3();
            }
          },
        ); 
  
  }
  
  
//Buttons
  Widget _buttonsAgents() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(
            style: TextButton.styleFrom(
             primary: Colors.white, // foreground
             backgroundColor: Colors.green,
             shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            
            child: Text(" Pasar viaje en proceso"),
            onPressed: () {

              fetchPastInProgress();
  
            },
          ),
          SizedBox(width: 5),
          ElevatedButton(
            style: TextButton.styleFrom(
             primary: Colors.white, // foreground
             backgroundColor: Colors.red,
             shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Marcar como cancelado"),
            onPressed: () {
              fetchTripCancel();
            },
          ),
        ],
      ),
    );
  }
}
