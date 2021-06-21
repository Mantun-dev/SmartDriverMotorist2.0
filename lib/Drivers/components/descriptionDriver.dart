import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
//import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_auth/Drivers/Screens/Details/components/asignar_Horas.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/confirm_trips.dart';
//import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/history_TripDriver.dart';
//import 'package:flutter_auth/Drivers/Screens/Details/components/process_LeftAgent.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/process_Trip.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/company.dart';
import 'package:flutter_auth/Drivers/models/leftTrip.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
//import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_auth/Drivers/models/search.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
//import 'package:flutter/scheduler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:sweetalert/sweetalert.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' show json;
class DriverDescription extends StatefulWidget {
  
  final Company2 item;
  final DriverData itemx;
  final TripsDrivers driverx;
  DriverDescription({Key key, @required this.plantillaDriver,  this.item, this.itemx, this.driverx}) : super(key: key);

  final PlantillaDriver plantillaDriver;

  @override
  _DriverDescriptionState createState() => _DriverDescriptionState();
}

class _DriverDescriptionState extends State<DriverDescription> {
  Future <List< Company2>>item;
  Future<DriverData> itemx;
  Future <List< TripsDrivers>>driverx;

  String ip = "192.168.0.113:4000";
  String barcodeScan = "";
  String companyId;
  int driver;
  List data = [];
  final prefs = new PreferenciasUsuario();
  final tempArr = [];
  bool radioShowAndHide = false;
  final dri = [];
  
  Map<String, String> selectedValueMap = Map();
  List driverId = [];

 //asingment agent an one array 
  final List<String> names = <String>[];
  final List<String> noemp = <String>[];
  final List<String> hourout = <String>[];
  final List<String> direction = <String>[];

 
  final dataKey = new GlobalKey();
  
  final format = DateFormat("HH:mm");

  TextEditingController nameController = TextEditingController();
  TextEditingController agentEmployeeId = new TextEditingController();
  TextEditingController vehicule = new TextEditingController();
  TextEditingController hourOut = TextEditingController();
  @override
  void initState() { 
    super.initState();
    this.fetchCompanys();
    itemx = fetchRefres();
    driverx = fetchDriversDriver();      
  }
  


  
 Future<List>fetchDriversDrivers()async{
   http.Response response = await http.get(Uri.encodeFull('http://$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
   final data = DriverData.fromJson(json.decode(response.body));
   http.Response responses = await http.get(Uri.encodeFull('http://$ip/apis/asigmentDriverToCoord/${data.driverId}',));
    var jsonData = json.decode(responses.body); 
    if (responses.statusCode == 200) {
      print(responses.body);
      List<dynamic> responseBody = json.decode(responses.body);
      List<String> countries = [];
      for(int i=0; i < responseBody.length; i++) {
        countries.add(responseBody[i]['driverFullname']);           
      }
      driverId = jsonData;
      return countries;
    }
    else {
      print("error from server : $response");
      throw Exception('Failed to load post');
    }

 }

//prueba
Future<List< TripsDrivers>>fetchDriversDriver()async{
  http.Response response = await http.get(Uri.encodeFull('http://$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('http://$ip/apis/asigmentDriverToCoord/${data.driverId}'));

  var jsonData = json.decode(responses.body);

  List<TripsDrivers> trips = [];

  for (var u in jsonData) {
    TripsDrivers trip = TripsDrivers(u["driverId"], u["driverDni"],u["driverPhone"], u["driverFullname"],u["driverType"], u["driverStatus"],u["driverPassword"]);
    trips.add(trip);

  }
    setState(() {
    
      driverId = jsonData;
    });
  print(trips.length);
  return trips;

}


Future< Salida>fetchAgentsLeftPastToProgres(String hourOut, String nameController)async{
    http.Response responses = await http.get(Uri.encodeFull('http://$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final si = DriverData.fromJson(json.decode(responses.body));
    if (tempArr.length == 0) {
      SweetAlert.show(context,
        title: '¡Viaje vacío!',
        subtitle: ' No puede guardar este viaje sin\n agregar agentes',
        style: SweetAlertStyle.error,
      );
    }else{
      if (hourOut != "") {
        if (si.driverCoord == true) {
          Map datas = {
            'companyId' : prefs.companyId,
            'tripHour' : hourOut,
            'driverId' : radioShowAndHide==false?si.driverId.toString():prefs.driverIdx,
            'tripVehicle': nameController,    
          };
          print(datas);
          http.Response response1 = await http.post(Uri.encodeFull('http://$ip/apis/registerDeparture'), body: datas);
          final send = Salida.fromJson(json.decode(response1.body));
          prefs.tripId = send.tripId.toString();
          print(response1.body);
          for (var i = 0; i < tempArr.length; i++) {
            Map datas2 = {
              "agentId": tempArr[i].toString(),
              "tripId" : send.tripId.toString(),
              "tripHour" : hourOut
            };
            print(datas2);
            
            http.Response response3 = await http.post(Uri.encodeFull('http://$ip/apis/registerAgentForOutTrip'), body: datas2);
            
            print(response3.body);
          }
          if (response1.statusCode == 200) {             
            http.Response response2 = await http.get(Uri.encodeFull('http://$ip/apis/agentsInTravel/${prefs.tripId}'));
            
            Navigator.push(context,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));
            print(response2.body);
            SweetAlert.show(context,
              title: send.title,
              subtitle: send.message,
              style: SweetAlertStyle.success,
            );
          } else {
            throw Exception('Failed to load Data');
          }
        } else {
          Map datas = {
          'companyId' : prefs.companyId,
          'tripHour' : hourOut,
          'driverId' : si.driverId.toString(),
          'tripVehicle': nameController,    
          };
          print(datas);
          http.Response response1 = await http.post(Uri.encodeFull('http://$ip/apis/registerDeparture'), body: datas);
          final send = Salida.fromJson(json.decode(response1.body));
          prefs.tripId = send.tripId.toString();
          print(response1.body);
          for (var i = 0; i < tempArr.length; i++) {
            Map datas2 = {
              "agentId": tempArr[i].toString(),
              "tripId" : send.tripId.toString(),
              "tripHour" : hourOut
            };
            print(datas2);
            
            http.Response response3 = await http.post(Uri.encodeFull('http://$ip/apis/registerAgentForOutTrip'), body: datas2);
            
            print(response3.body);
          }

          if (response1.statusCode == 200) { 
            
            http.Response response2 = await http.get(Uri.encodeFull('http://$ip/apis/agentsInTravel/${prefs.tripId}'));
            
            Navigator.push(context,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));
            print(response2.body);
            SweetAlert.show(context,
              title: send.title,
              subtitle: send.message,
              style: SweetAlertStyle.success,
            );
          } else {
            throw Exception('Failed to load Data');
          }
        }                
      }else{
         SweetAlert.show(context,
          title: '¡Error!',
          subtitle: 'No ha asignado una hora a este viaje',
          style: SweetAlertStyle.error,
        );
      }
    }
    
}

Future scanBarcodeNormal() async {
  
  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.DEFAULT);
  setState(() {
    barcodeScan = barcodeScanRes;
  });
  Map data = {
    "companyId" : prefs.companyId ,
    "agentEmployeeId" : barcodeScan
  };
  http.Response responsed = await http.post(Uri.encodeFull('http://$ip/apis/searchAgent'), body: data);
  final data1 = Search.fromJson(json.decode(responsed.body));  

  if (responsed.statusCode == 200 && data1.ok == true && data1.agent.msg != null) {
    SweetAlert.show(context,
        title: '¡No encontrado!',
        subtitle: data1.agent.msg,
        style: SweetAlertStyle.error,
      );
  }else if(responsed.statusCode == 200 && data1.ok == true){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            width: 450,
            height: 490,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Text(
                    '¿Agregar agente al viaje?',
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 15),
                  ListTile(
                        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        title: Text('No empleado: '),
                        subtitle: Text('${data1.agent.agentEmployeeId}'),
                        leading: Icon(Icons.card_travel , color: kColorAppBar),
                  ),
                  ListTile(
                        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        title: Text('Nombre: '),
                        subtitle: Text('${data1.agent.agentFullname}'),
                        leading: Icon(Icons.contact_page_outlined , color: kColorAppBar),
                  ),
                  ListTile(
                        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        title: Text('Hora salida: '),
                        subtitle: Text('${data1.agent.hourOut}'),
                        leading: Icon(Icons.timer , color: kColorAppBar),
                  ),
                  ListTile(
                        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        title: Text('Dirección: '),
                        subtitle: Text('${data1.agent.departmentName} ${data1.agent.neighborhoodName}\n${data1.agent.agentReferencePoint} '),
                        leading: Icon(Icons.directions , color: kColorAppBar),
                  ),
                  SizedBox(height: 60),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      ElevatedButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,                        
                          backgroundColor: Colors.green
                        ), 
                        onPressed: () => {
                            
                          setState(() {
                            if (noemp.length <= 13) {                              
                              if (!(noemp.contains(data1.agent.agentEmployeeId)) && !(names.contains(data1.agent.agentEmployeeId)) && 
                                  !(hourout.contains(data1.agent.agentEmployeeId)) && !(direction.contains(data1.agent.agentEmployeeId))) {
                                  noemp.insert(0, '${data1.agent.agentEmployeeId}');
                                  names.insert(0,'${data1.agent.agentFullname}');
                                  hourout.insert(0, '${data1.agent.hourOut}');
                                  direction.insert(0, '${data1.agent.departmentName} ${data1.agent.neighborhoodName}\n${data1.agent.agentReferencePoint}');
                                  tempArr.add(data1.agent.agentId);
                                  
                              }else{
                                print('yasta we');
                                Navigator.pop(context);               
                                return SweetAlert.show(context,
                                  title: "¡Advertencia!",
                                  subtitle: " El agente con número de empleado \n '${data1.agent.agentEmployeeId}' ya está agregado al viaje",
                                  style: SweetAlertStyle.error
                                ); 
                              }
                            }else if(noemp.length > 13){
                              print('yasta we');
                              Navigator.pop(context); 
                              return SweetAlert.show(context,
                                  title: "¡Advertencia!",
                                  subtitle: " El limite de agentes son 14, favor \n comunicarse con su cordinador",
                                  style: SweetAlertStyle.error
                                ); 
                            }

                            Navigator.pop(context);
                          }),
                            
                        },
                        child: Text('Agregar'),                        
                      ), 
                      SizedBox(width: 20),
                      TextButton (
                        style: TextButton.styleFrom(
                          primary: Colors.red, // foreground
                          backgroundColor: Colors.orange
                        ),
                        onPressed: () => {
                            setState((){                          
                              Navigator.pop(context);                                                  
                            }),
                        },
                        child: Text('Cancelar', style: TextStyle(color: Colors.white),),
                    
                      ), 
                    ],
                  ),                    
                ],
              ),
            ),
          ),
        )
      );
    
  }

  print(barcodeScan);
}

Future<List<Company2>>fetchCompanys()async{
  http.Response response = await http.get(Uri.encodeFull('http://$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final si = DriverData.fromJson(json.decode(response.body));
  http.Response responsed = await http.get(Uri.encodeFull('http://$ip/apis/newdeparture/${si.departmentId}'));
    var jsonData = json.decode(responsed.body); 
    List< Company2> trips = [];
    for (var u in jsonData) {
      Company2 trip = Company2(u["companyId"], u["companyName"]);
      trips.add(trip);
    }
    setState(() {
        data = jsonData;
      });
    print(trips.length);
  return trips;
}


Future< Search>fetchSearchAgents2(String agentEmployeeId)async{
  Map data = {
    "companyId" : prefs.companyId ,
    "agentEmployeeId" : agentEmployeeId
  };
  http.Response responsed = await http.post(Uri.encodeFull('http://$ip/apis/searchAgent'), body: data);
  final data1 = Search.fromJson(json.decode(responsed.body));  
    if (responsed.statusCode == 200 && data1.ok == true && data1.agent.msg != null) {  
      SweetAlert.show(context,
        title: '¡No encontrado!',
        subtitle: data1.agent.msg,
        style: SweetAlertStyle.error,
      );
    }else if(responsed.statusCode == 200 && data1.ok == true){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            width: 450,
            height: 490,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Text(
                    '¿Agregar agente al viaje?',
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 15),
                  ListTile(
                        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        title: Text('No empleado: '),
                        subtitle: Text('${data1.agent.agentEmployeeId}'),
                        leading: Icon(Icons.card_travel , color: kColorAppBar),
                  ),
                  ListTile(
                        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        title: Text('Nombre: '),
                        subtitle: Text('${data1.agent.agentFullname}'),
                        leading: Icon(Icons.contact_page_outlined , color: kColorAppBar),
                  ),
                  ListTile(
                        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        title: Text('Hora salida: '),
                        subtitle: Text('${data1.agent.hourOut}'),
                        leading: Icon(Icons.timer , color: kColorAppBar),
                  ),
                  ListTile(
                        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        title: Text('Dirección: '),
                        subtitle: Text('${data1.agent.departmentName} ${data1.agent.neighborhoodName}\n${data1.agent.agentReferencePoint} '),
                        leading: Icon(Icons.directions , color: kColorAppBar),
                  ),
                  SizedBox(height: 60),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => {                        
                          setState(() {
                            if (noemp.length <= 13) {                              
                              if (!(noemp.contains(data1.agent.agentEmployeeId)) && !(names.contains(data1.agent.agentEmployeeId)) && 
                                  !(hourout.contains(data1.agent.agentEmployeeId)) && !(direction.contains(data1.agent.agentEmployeeId))) {
                                  noemp.insert(0, '${data1.agent.agentEmployeeId}');
                                  names.insert(0,'${data1.agent.agentFullname}');
                                  hourout.insert(0, '${data1.agent.hourOut}');
                                  direction.insert(0, '${data1.agent.departmentName} ${data1.agent.neighborhoodName}\n${data1.agent.agentReferencePoint}');
                                  tempArr.add(data1.agent.agentId);
                                  print(data1.agent.agentId);
                              }else{
                                print('yasta we');
                                Navigator.pop(context);               
                                return SweetAlert.show(context,
                                  title: "¡Advertencia!",
                                  subtitle: " El agente con número de empleado \n '${data1.agent.agentEmployeeId}' ya está agregado al viaje",
                                  style: SweetAlertStyle.error
                                ); 
                              }
                            }else if(noemp.length > 13){
                              print('yasta we');
                              Navigator.pop(context); 
                              return SweetAlert.show(context,
                                  title: "¡Advertencia!",
                                  subtitle: " El limite de agentes son 14, favor \n comunicarse con su cordinador",
                                  style: SweetAlertStyle.error
                                ); 
                            }

                            Navigator.pop(context);
                          }),
                            // },
                        },
                        child: Text('Agregar'),                        
                      ), 
                      SizedBox(width: 20),
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () => {
                            setState((){                          
                              Navigator.pop(context);                                                  
                            }),
                        },
                        child: Text('Cancelar'),
                      ), 
                    ],
                  ),                    
                ],
              ),
            ),
          ),
        )
      );
    
    } 
  return Search.fromJson(json.decode(responsed.body));      
}


  @override
  Widget build(BuildContext context) {
    //variable

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      //aquí voy a meter la información
      child: Column(
        children: [
          //aquí llamo el procedimiento que contiene el orden las demás páginas
          _processCards(context),          
        ],
      ),
    );
  }



  Widget _processCards(BuildContext context) {
    return Column(
      children: [
        if (widget.plantillaDriver.id == 1) ...[
          _mostrarPrimerventana(),
          SizedBox(height: 20.0),
        ] else if (widget.plantillaDriver.id == 2) ...[
          _mostrarSegundaVentana(),
          SizedBox(height: 20.0),
        ] else if (widget.plantillaDriver.id == 3) ...[
          _mostrarTerceraVentana(context),
          SizedBox(height: 25.0),
        ] else if (widget.plantillaDriver.id == 4) ...[
          _mostrarCuartaVentana(),
          SizedBox(height: 20.0),
        ]
      ],
    );
  }

  Widget _mostrarPrimerventana() {
    return AsignarHoras();
  }

  Widget _mostrarSegundaVentana() {
    return ProcessTrip();
  }

  Widget _mostrarTerceraVentana(BuildContext context) {
    
    return SingleChildScrollView( 
      key: dataKey,     
      child: Container(
        child: Column(
          children: [
            Text('Compañia',
                style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.normal,
                    fontSize: 20.0)),
            SizedBox(height: 20.0),
            _crearDropdown(context),
            FutureBuilder<DriverData>(
              future: itemx,            
              builder: (BuildContext context, abc) {
                switch (abc.connectionState) {
                case ConnectionState.waiting: return Text('Cargando....');
                default:
                  if (abc.hasError){
                    return Text('Error: ${abc.error}');
                  }else{
                    return Column(
                      children: [
                        if (abc.data.driverCoord == true) showAndHide()
                      ],
                    );
                  }
                }
              }
            ),
            SizedBox(height: 20.0),            
            Text('Hora',style: TextStyle(color: Colors.grey[700],fontWeight: FontWeight.normal,fontSize: 20.0)),
            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
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
                    controller: hourOut,
                    onShowPicker: (contexts, currentValue) async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.convert(time);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: nameController,
                decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: "Vehiculo",
            )),
            SizedBox(height: 20.0),
            Row(
              children: [
              SizedBox(width: 70.0),
              ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[400]
                ), 
              child: Icon(Icons.restore_from_trash),
              onPressed: (){
                setState(() {
                  names.removeRange(0, names.length);
                  noemp.removeRange(0, noemp.length); 
                  hourout.removeRange(0, hourout.length);
                  direction.removeRange(0, direction.length);
                  tempArr.removeRange(0, tempArr.length);
                });                          
              }),
              SizedBox(width: 5.0),
              ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[400]
                ), 
              child: Icon(Icons.search),            
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
                            title: Center(child: Text('Buscar Agente')),
                            content: TextField(
                              controller: agentEmployeeId,
                              decoration: InputDecoration(labelText: 'Escriba aqui'),
                            ),
                              actions: [
                                Row(
                                  children: [
                                    SizedBox(width: 60.0),                                  
                                    TextButton(                                    
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.blueAccent,
                                    ), 
                                      onPressed: () => {                                      
                                        fetchSearchAgents2( agentEmployeeId.text),                                      
                                        Navigator.pop(context)
                                      },
                                      child: Text('Buscar'),                                    
                                    ),
                                    SizedBox(width: 10.0),
                                    TextButton(                                    
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.red,
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
                }
                ,
              ),
              SizedBox(width: 5.0),
              ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green[400]
                ), 
                child: Icon(Icons.camera_alt_rounded),
                onPressed: scanBarcodeNormal
              )
           
            ],
            ),
            SizedBox(height: 6.0),
            Text("Total de agentes: ${names.length}", style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 16.0)),
            SizedBox(height: 6.0),
           if (names.length == 0)... {  
              Card(
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
                       subtitle: Text('No hay agentes en el viaje', style: TextStyle(
                               color: Colors.red,
                               fontWeight: FontWeight.normal,
                               fontSize: 18.0)),
                     ),                      
                   ],
                 ),
              ),
             
           },
            Container(
            height: 380,
              child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: names.length,
                    itemBuilder: (BuildContext context, int index) {                                 
                        return Card(
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(4.0),
                            elevation: 2,
                            child: Column(
                              children: <Widget>[                               
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.confirmation_number,
                                              color: Colors.green[500],
                                              size: 35,
                                            ),
                                            Text('# No empleado: ',
                                                style: TextStyle(
                                                    color: Colors.green[500],
                                                    fontSize: 17)),
                                            Text('${noemp[index]} '),
                                          ],
                                        ),
                                        Flexible(
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.account_box_sharp,
                                                color: Colors.green[500],
                                                size: 35,
                                              ),
                                              Text('Nombre:',
                                                  style: TextStyle(
                                                      color: Colors.green[500],
                                                      fontSize: 17)),
                                              Text('${names[index]}'),
                                            ],
                                          ),
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
                                              Icons.access_alarms ,
                                              color: Colors.green[500],
                                              size: 35,
                                            ),
                                            Text('Hora salida: ',
                                                style: TextStyle(
                                                    color: Colors.green[500],
                                                    fontSize: 17)),
                                            Text('${hourout[index]}'),
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
                                            Text('${direction[index]}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                ),
                               SizedBox(height: 20.0),
                               TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.red,
                                            width: 2,
                                            style: BorderStyle.solid),
                                        borderRadius: BorderRadius.circular(10)),
                                ), 
                                    onPressed: () {
                                      setState(() {
                                        
                                        noemp.remove(noemp[index]);
                                        names.remove(names[index]);
                                        hourout.remove(hourout[index]);
                                        direction.remove(direction[index]);
                                      });
                                      
                                       tempArr.remove(tempArr[index]);
                                    
                                    },
                                    
                                    child: Text('Quitar',
                                        style: TextStyle(color: Colors.white)),                                                                    
                                  ),
                                  SizedBox(height: 10.0),
                              ],
                            ),
                        );
                    
                      }
                    
                  )
                  
            ),
            Row(
              children: [
                SizedBox(width: 110),
                Column(
                  children: [
                    ElevatedButton(            
                      style: TextButton.styleFrom(                
                        backgroundColor: Colors.green[400],
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40)
                      ),              
                      child: Icon(Icons.save),
                      onPressed: (){
                        fetchAgentsLeftPastToProgres( hourOut.text, vehicule.text);
                      }
                    ), 
                  ],
                ),
                SizedBox(width: 40),
                Column(
                  children: [
                    FloatingActionButton(
                        onPressed: () => Scrollable.ensureVisible(dataKey.currentContext, duration: Duration(seconds: 1)),
                        child: Icon(Icons.arrow_upward),
                    ),   
                  ],
                )
              ],
            ),                                                  
          ],
        ),
      ),
    );
  }

  Widget showAndHide(){
    return Container(
      child: Column(
        children: [
          SizedBox(height: 20.0),
          ElevatedButton(
            child: Text(radioShowAndHide== false?'Presione aquí para asignar conductor':'Presione aquí si usted realizará el viaje'),
              onPressed: (){
                if (radioShowAndHide) {
                  setState(() {
                    radioShowAndHide = false;
                  });
                } else {
                  setState(() {
                    radioShowAndHide = true;
                  });
                }
            }),

            Visibility(
              maintainSize: true, 
              maintainAnimation: true,
              maintainState: true,
              visible: radioShowAndHide, 
              child: getSearchableDropdown(context)
            ),                  
        ],
      ),
    );
  }

  Widget getSearchableDropdown(BuildContext context) {

    return SearchableDropdown(      
              items: driverId.map((item) {
                return new DropdownMenuItem(
                    child: Text(item['driverFullname']), value: item['driverId']);
              }).toList(),
              isExpanded: true,
              value: driver,
              searchFn: (String keyword, items) {
                List<int> ret = [];
                if (items != null && keyword.isNotEmpty) {
                  keyword.split(" ").forEach((k) {
                    int i = 0;
                    driverId.forEach((item) {
                      if (k.isNotEmpty &&
                          (item['driverFullname']
                              .toString()
                              .toLowerCase()
                              .contains(k.toLowerCase()))) {
                        ret.add(i);
                      }
                      i++;
                    });
                  });
                }
                if (keyword.isEmpty) {
                  ret = Iterable<int>.generate(items.length).toList();
                }
                return (ret);
              },              
              isCaseSensitiveSearch: true,              
              searchHint: new Text(
                'Seleccione ',
                style: new TextStyle(fontSize: 20),
              ),
              onChanged: (value) {
                setState(() {
                  driver = value;
                  prefs.driverIdx = driver.toString();
                  print(prefs.driverIdx);
                });
                
              },
              
    );
  }


  Widget _crearDropdown(BuildContext context) {
        //List<DropdownMenuItem<String>> lista = new List();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        children: [
          Icon(Icons.location_city),
          SizedBox(width: 20.0),
          Expanded(child:  new DropdownButton(
            items: data.map((e) {
              return new DropdownMenuItem(
                child: Text(e['companyName']),
                value: e['companyId'].toString(),
              );
          }).toList(),
          onChanged: (val){
            setState(() {
              companyId = val;
              
              prefs.companyId = companyId;
            });
            print(val);
          },
          value: companyId,
          )
          ),
         
        ],
      ),
    );
  }


  Widget _mostrarCuartaVentana() {
    return HistoryTripDriver();
  }

  // Widget _hoursTime() {
  //   final format = DateFormat("HH:mm");
  //   return Container(
  //     decoration: BoxDecoration(
  //         border: Border.all(width: 1, color: Colors.grey),
  //         borderRadius: BorderRadius.all(Radius.circular(4)),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.1),
  //             spreadRadius: 5,
  //             blurRadius: 7,
  //             offset: Offset(0, 3), // changes position of shadow
  //           )
  //         ]),
  //     margin: EdgeInsets.symmetric(horizontal: 40.0),
  //     child: Column(
  //       children: [
  //         DateTimeField(
  //           format: format,
  //           controller: hourOut,
  //           onShowPicker: (context, currentValue) async {
  //             final time = await showTimePicker(
  //               context: context,
  //               initialTime:
  //                   TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
  //             );
  //             return DateTimeField.convert(time);
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  
  // }
  
}


  
