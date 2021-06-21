import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/agentInProgress.dart';
import 'package:flutter_auth/Drivers/models/messageDriver.dart';
import 'package:flutter_auth/Drivers/models/messageTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/registerTripAsCompleted.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:flutter_auth/constants.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:shop_app/screens/details/details_screen.dart';

//import '../../constants.dart';

void main() {
  runApp(MyConfirmAgent());
}

class MyConfirmAgent extends StatefulWidget {
  final PlantillaDriver plantillaDriver;
  final TripsList4 item;

  const MyConfirmAgent({Key key, this.plantillaDriver, this.item}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyConfirmAgent> {
  Future <TripsList4> item;
  bool traveled = false ;
  final tmpArray = [];
  bool traveled1 = true ;
  final prefs = new PreferenciasUsuario();

  
  TextEditingController check = new TextEditingController();
  List<TextEditingController> comment;

  Future<Message>fetchCheckAgentTrip(String agentId) async {
      int flag = (traveled)? 1: 0;
   
      Map datas = {
        'agentId' : agentId,
        'tripId' : prefs.tripId, 
        'traveled' : '${flag}'
      };
      print(datas);
    
      http.Response response = await http.post(Uri.encodeFull('http://$ip/apis/agentCheckIn'), body: datas);
      setState(() {
      final resp = Message.fromJson(json.decode(response.body));
      
      if (response.statusCode == 200 && resp.ok == true) {   
        //  print(response.body);    
        //    SweetAlert.show(context,
        //    title: 'Enviado',
        //    subtitle: resp.message,
        //    style: SweetAlertStyle.success
        //  );
       } 
       else if(response.statusCode == 500){
         SweetAlert.show(context,
             title: 'Opss...',
             subtitle: resp.message,
             style: SweetAlertStyle.error,
         );
       }
       });
        
       return Message.fromJson(json.decode(response.body));
  }

  Future<Driver2>fetchRegisterTripCompleted() async {

    http.Response responses = await http.get(Uri.encodeFull('http://$ip/apis/registerTripAsCompleted/${prefs.tripId}'));
    final si = Driver2.fromJson(json.decode(responses.body));

     print(responses.body);
     if (responses.statusCode == 200 && si.ok ) {         
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context)=>
      HomeDriverScreen()), (Route<dynamic> route) => false);
      SweetAlert.show(context,
       title: '${si.title}',
       subtitle: si.message,
       style: SweetAlertStyle.success
      );

      } else if (si.ok != true) {
        SweetAlert.show(context,
          title: si.title,
          subtitle: si.message,
          style: SweetAlertStyle.error,
        );
      }
    return Driver2.fromJson(json.decode(responses.body));
      //throw Exception('Failed to load Data');
  }

  Future<Driver>fetchRegisterCommentAgent(String agentId, String tripId, String comment) async {
    Map datas = {
      'agentId': agentId,
      'tripId' : tripId
    };
    Map datas2 = {
      'agentId': agentId,
      'tripId' : tripId,
      'commentDriver': comment
    };
    http.Response responses = await http.post(Uri.encodeFull('http://$ip/apis/getDriverComment'), body: datas);
    final si = Driver.fromJson(json.decode(responses.body));
    http.Response response = await http.post(Uri.encodeFull('http://$ip/apis/agentTripSetComment'), body: datas2);
     print(responses.body);
     print(response.body);
     if (responses.statusCode == 200 && si.ok == true && responses.statusCode == 200) {         
       SweetAlert.show(context,
        title: 'Enviado',
        subtitle: si.message,
        style: SweetAlertStyle.success
      );
      } else if (si.ok != true) {
        SweetAlert.show(context,
          title: si.title,
          subtitle: si.message,
          style: SweetAlertStyle.error,
        );
      }
    return Driver.fromJson(json.decode(responses.body));
      //throw Exception('Failed to load Data');
  }  

  Future<Driver>fetchRegisterAgentDidntGetOut(String agentId, String tripId,) async {
    Map datas = {
      'agentId': agentId,
      'tripId' : tripId
    };
    http.Response responses = await http.post(Uri.encodeFull('http://$ip/apis/agentDidntGetOut'), body: datas);
    final si = Driver.fromJson(json.decode(responses.body));

     print(responses.body);
     if (responses.statusCode == 200 && si.ok ) {         
       SweetAlert.show(context,
        title: si.title,
        subtitle: si.message,
        style: SweetAlertStyle.success
      );
      } else if (si.ok != true) {
        SweetAlert.show(context,
          title: si.title,
          subtitle: si.message,
          style: SweetAlertStyle.error,
        );
      }
    return Driver.fromJson(json.decode(responses.body));
      //throw Exception('Failed to load Data');
  }

  @override
  void initState() { 
    super.initState();
    item = fetchAgentsTripInProgress();
    comment = new List<TextEditingController>();
    check = new TextEditingController();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: DriverMenuLateral(),
          appBar: AppBar(
            title: Text('Información de viaje'),
            backgroundColor: kColorDriverAppBar,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DetailsDriverScreen(
                      plantillaDriver: plantillaDriver[1],
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
                child: Text('Viaje en proceso',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
            SizedBox(height: 10.0),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              width: 300,
              height: 60,
              child: Column(
                children: [
                  Center(
                      child: Text(
                          'Nota: Debe marcar el abordaje al momento en que el agente ingrese a la unidad, en caso de no abordar, solo debe llenar la observación.',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.normal,
                              fontSize: 15.0))),
                ],
              ),
            ),
            _agentToConfirm(),
            SizedBox(height: 20.0),
            _buttonsAgents(),
            SizedBox(height: 30.0),
          ])),
    );
  }


  Widget _agentToConfirm() {
           
          return FutureBuilder<TripsList4>(
          future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              if (abc.data.trips[0].tripAgent.length == 0) {
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
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.trips[0].tripAgent.length,
                      itemBuilder: (context, index){                      
                        return Container(
                          width: 500.0,
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                              Checkbox(                                                                                             
                                                value: (abc.data.trips[0].tripAgent[index].traveled == 0) ? false : 
                                                (abc.data.trips[0].tripAgent[index].traveled == 1)? true: 
                                                (abc.data.trips[0].tripAgent[index].traveled == null)?abc.data.trips[0].tripAgent[index].traveled??false:
                                                (abc.data.trips[0].tripAgent[index].traveled == true)?abc.data.trips[0].tripAgent[index].traveled??false:false,                                          
                                                onChanged: (value) {                                        
                                                  setState(() {
                                                    traveled = value;
                                                  });                                                                                                   
                                                  abc.data.trips[0].tripAgent[index].traveled  = traveled;   
                                                  if (value == true ) {
                                                    print('subio');
                                                    //print(abc.data.trips[0].tripAgent[index].agentId);
                                                    //tmpArray.add(abc.data.trips[0].tripAgent[index].traveled);                                                   
                                                    fetchCheckAgentTrip(abc.data.trips[0].tripAgent[index].agentId.toString());
                                                                                                                                                       
                                                    print('////////');
                                                  }else if(value == false){                                                       
                                                    print('bajo');
                                                    //print(abc.data.trips[0].tripAgent[index].agentId);
                                                    //tmpArray.replaceRange(index, index + 1, [abc.data.trips[0].tripAgent[index].traveled]);
                                                    fetchCheckAgentTrip(abc.data.trips[0].tripAgent[index].agentId.toString());
                                                    print('////////');
                                                  }                                                    
                                                }),                                                                           
                                              Text('Abordó '),                                                                                                                                       
                                                  
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
                                                    '${abc.data.trips[0].tripAgent[index].companyName}',
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
                                                      child:Text('${abc.data.trips[0].tripAgent[index].agentFullname}', style: TextStyle(color: kTextColor)),                                                                                                        
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
                                              margin: EdgeInsets.only(right: 15),
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
                                                          onPressed: () => launch('tel://${abc.data.trips[0].tripAgent[index].agentPhone}'),
                                                          child:  Text('${abc.data.trips[0].tripAgent[index].agentPhone}',style: TextStyle(color: Colors.blue[500],fontSize: 14))),                                                    
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
                                                      Text('${abc.data.trips[0].tripAgent[index].hourIn}'),
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
                                                    Text('${abc.data.trips[0].tripAgent[index].agentReferencePoint} \n ${abc.data.trips[0].tripAgent[index].neighborhoodName} \n ${abc.data.trips[0].tripAgent[index].districtName}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 20.0),
                                          Text('${abc.data.trips[0].tripAgent[index].hourForTrip}',style:TextStyle(color: Colors.red, fontSize: 17)),
                                          SizedBox(height: 20.0),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  TextButton (
                                                  style: TextButton.styleFrom(
                                                    primary: Colors.white, // foreground
                                                    backgroundColor: Color(0xFFFF7043),
                                                    shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: Color(0xFFFF7043),
                                                            width: 2,
                                                            style: BorderStyle.solid),
                                                        borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                    onPressed: () {
                                                      fetchRegisterAgentDidntGetOut(abc.data.trips[0].tripAgent[index].agentId.toString(), prefs.tripId );
                                                    },
                                                    
                                                    child: Text('Se pasó por él y no salió',
                                                        style: TextStyle(color: Colors.white)),
                                                    
                                                    
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
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
                                                                    child: Text('¿Razón por la cual no ingresó a la unidad?')),
                                                                content: TextField(
                                                                  controller: check,
                                                                  decoration: InputDecoration(labelText: 'Aquí escriba'),
                                                                ),
                                                                actions: [
                                                                  Text('Observación...', textAlign: TextAlign.center),
                                                                  Row(
                                                                    children: [
                                                                      SizedBox(width: 60.0),
                                                                      TextButton (
                                                                        style: TextButton.styleFrom(
                                                                          primary: Colors.white, // foreground
                                                                          backgroundColor: Colors.green
                                                                        ),
                                                                        onPressed: () => {
                                                                          fetchRegisterCommentAgent(abc.data.trips[0].tripAgent[index].agentId.toString(), prefs.tripId , check.text),
                                                                          Navigator.pop(context),
                                                                        },
                                                                        child: Text('Guardar'),                                                                        
                                                                      ),
                                                                      SizedBox(width: 10.0),
                                                                      TextButton (
                                                                        style: TextButton.styleFrom(
                                                                          primary: Colors.white, // foreground
                                                                          backgroundColor: Colors.red
                                                                        ),
                                                                        onPressed: () => {
                                                                          Navigator.pop(context),
                                                                        },
                                                                        child: Text('Cerrar'),                                                                        
                                                                      ),
                                                                    ],
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
                                                          return null;
                                                        });
                                                    },
                                                    
                                                    child: Text('Observaciones',
                                                        style: TextStyle(color: Colors.white)),
                                                                                                        
                                                  ),
                                          
                           
                                                ],
                                              ),
                                              
                                            ],
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
                    
              }
            } else {
              
              return ColorLoader3();
            }
          },
        ); 

        
  
  }
  


  Widget _buttonsAgents() {

       return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.green,
               shape: RoundedRectangleBorder(                
                borderRadius: BorderRadius.circular(15.0),
              )),
              child: Text("Completar Viaje"),
              onPressed: () {
                                                                
                fetchRegisterTripCompleted();
              },

            ),
            SizedBox(width: 5),
            ElevatedButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(                
                borderRadius: BorderRadius.circular(15.0),
              )),
              child: Text("Marcar como cancelado"),
              onPressed: () {
                
              },
              
            ),
          ],
        ),
      );
  }

}