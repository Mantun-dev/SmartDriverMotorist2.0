//import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
//import 'dart:developer';

import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/asignar_Horas.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/confirm_trips.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/databases.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/history_TripDriver.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/process_Trip.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/progress_indicator.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/company.dart';
import 'package:flutter_auth/Drivers/models/findAgentSolid.dart';
import 'package:flutter_auth/Drivers/models/leftTrip.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/search.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/tripToSolid.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_auth/main.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:localstorage/localstorage.dart';
//import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quickalert/quickalert.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

class DriverDescription extends StatefulWidget {
final Company2? item;
  final DriverData? itemx;
  final TripsDrivers? driverx;
  DriverDescription(
      {Key? key,
      required this.plantillaDriver,  this.item,  this.itemx, this.driverx,
})
      : super(key: key);
  final PlantillaDriver plantillaDriver;

  @override
  _DriverDescriptionState createState() => _DriverDescriptionState();
}

class _DriverDescriptionState extends State<DriverDescription>
    with AutomaticKeepAliveClientMixin<DriverDescription> {
  Future<List<Company2>>? item;
  Future<DriverData>? itemx;
  Future<List<TripsDrivers>>? driverx;
  DatabaseHandler? handler;
  String handleerrror = "";
  String ip = "https://driver.smtdriver.com";
  String barcodeScan = "";

  String? destinationId;
  String? destinationPrueba;
  dynamic driver = '';
  List data = [];
  List data2 = [];
  final prefs = new PreferenciasUsuario();

  bool seleccionarCompany = false;
  bool seleccionarMotorista = false;

  //arreglo para el agentId
  final tempArr = [];

  bool radioShowAndHide = false;
  final dri = [];

  Map<String, String> selectedValueMap = Map();
  List<TripsDrivers> driverId = [];

  //asingment agent an one array
  final List<String> names = <String>[];
  final List<String> noemp = <String>[];
  final List<String> hourout = <String>[];
  final List<String> direction = <String>[];

  final dataKey = new GlobalKey();
  final format = DateFormat("HH:mm");

  TextEditingController nameController = TextEditingController();
  TextEditingController agentEmployeeId = new TextEditingController();
  TextEditingController vehicleController = new TextEditingController();
  TextEditingController vehicule = new TextEditingController();
  TextEditingController hourOut = TextEditingController();

  bool vehFlag = false;

  @override
  void initState() {
    super.initState();
    this.fetchCompanys();
    this.fetchDestinations();
    itemx = fetchRefres();
    itemx!.then((value) => print(value.driverCoord) );
    fetchDriversDriver();
    vehicule = new TextEditingController(text: prefs.vehiculo);
    vehicleController.text=prefs.vehiculo;
    //print(prefs.vehiculo);
    // print(prefs.companyId);
    this.handler = DatabaseHandler();
    this.handler!.initializeDB().whenComplete(() async {
      //this.handler.deleteAgent("");
      // await this.fetchSearchAgents2(agentEmployeeId.text);
      // await this.fetchSearchAgentsSolid(agentEmployeeId.text);
      //await this.scanBarcodeNormal();
      setState(() {});
    });
  }

  void clearText() {
    agentEmployeeId.clear();
  }

  Future<List> fetchDriversDrivers() async {
    http.Response response = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(response.body));
    http.Response responses = await http.get(Uri.parse(
      '$ip/apis/asigmentDriverToCoord/${data.driverId}',
    ));
    var jsonData = json.decode(responses.body);
    if (responses.statusCode == 200) {
      print(responses.body);
      List<dynamic> responseBody = json.decode(responses.body);
      List<String> countries = [];
      for (int i = 0; i < responseBody.length; i++) {
        countries.add(responseBody[i]['driverFullname']);
      }
      driverId = jsonData;
      setState(() {});
      return countries;
    } else {
      print("error from server : $response");
      setState(() {});
      throw Exception('Failed to load post');
    }
  }

//prueba
  void fetchDriversDriver() async {
    http.Response response = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(response.body));
    http.Response responses = await http
        .get(Uri.parse('$ip/apis/asigmentDriverToCoord/${data.driverId}'));

    var jsonData = json.decode(responses.body);    
    for (var u in jsonData) {
      driverId.add(TripsDrivers(
          driverId:u["driverId"],
          driverDNI:u["driverDNI"],
          driverPhone:u["driverPhone"],
          driverFullname:u["driverFullname"],
          driverType:u["driverType"],
          driverStatus:u["driverStatus"],
          driverPassword:u["driverPassword"],
      ));      
    }   
    setState(() {});        
  }

  fetchAgentsLeftPastToProgres( String hourOut, String nameVehicle) async {
    
    http.Response responses = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(responses.body));
    int? statusCodex;
    final Database db = await handler!.initializeDB();
    final tables = await db.rawQuery('SELECT * FROM userX ;');
    if (tables.length == 0) {
      Navigator.pop(context);      
      QuickAlert.show(context: context,title: "¡Alerta",text: "No hay agentes agregados",type: QuickAlertType.warning,); 
    } 

    if(prefs.vehiculo == ""){
      QuickAlert.show(context: context,title: "¡Alerta!",text: "Necesita agregar el vehículo",type: QuickAlertType.warning,
        onConfirmBtnTap:() { 
          Scrollable.ensureVisible(dataKey.currentContext!);
          setState(() {                
            vehFlag = true;
          });
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    }
    if(prefs.vehiculo.isNotEmpty && tables.length != 0){
      if (data.driverCoord == true) {                
        Map datas = {
          'companyId': prefs.companyId,
          'driverId': radioShowAndHide == false? data.driverId.toString(): prefs.driverIdx,
          'tripVehicle': prefs.vehiculo,
          'vehicleId': prefs.vehiculoId,
        };
        print(datas);
        http.Response response1 = await http.post(Uri.parse('https://driver.smtdriver.com/apis/registerDeparture/test'), body: datas);
        final send = Salida.fromJson(json.decode(response1.body));
        prefs.tripId = send.tripId!.tripId.toString();

        var agente = [];
        
        for (var i = 0; i < tables.length; i++) {
          Map datas2 = {
            "agentId": tables[i]['idsend'].toString(),
            "tripId": send.tripId!.tripId.toString(),
            "tripHour": send.tripId!.tripHour,
            "driverId":radioShowAndHide == false? data.driverId.toString(): prefs.driverIdx
          };
          
          agente.add({
            "agenteN": tables[i]['nameuser'].toString(),
            "agenteId": tables[i]['idsend'].toString(),
          });

          var dataResp = await http.post(Uri.parse('$ip/apis/test/registerAgentForOutTrip'),body: datas2);
          setState(() {            
            statusCodex = dataResp.statusCode;
          });
        }
        DateTime fechaActual = DateTime.now();
        String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaActual);

      
        Map datas3 = {
          "id": send.tripId!.tripId,
          "NombreM": prefs.nombreUsuarioFull.toString(),
          "idM": data.driverId,
          "Company": int.parse(prefs.companyId),
          "Fecha": fechaFormateada.toString(),
          "Agentes": agente
        };
        String sendData2 = json.encode(datas3);

        await http.post(Uri.parse('https://apichat.smtdriver.com/api/salas'),body: sendData2, headers: {"Content-Type": "application/json"});
        
        validationLastToPassProgres(statusCodex, prefs.tripId, send.title, send.message);        
      } else {
        Map datas = {'companyId': prefs.companyId,'driverId': data.driverId.toString(),'tripVehicle': prefs.vehiculo,'vehicleId': prefs.vehiculoId,};
        print(datas);
        http.Response response1 = await http.post(Uri.parse('https://driver.smtdriver.com/apis/registerDeparture/test'), body: datas);
        final send = Salida.fromJson(json.decode(response1.body));
        prefs.tripId = send.tripId!.tripId.toString();
        for (var i = 0; i < tables.length; i++) {
          Map datas2 = {
            "agentId": tables[i]['idsend'].toString(),
            "tripId": send.tripId!.tripId.toString(),
            "tripHour": send.tripId!.tripHour,
            "driverId":data.driverId.toString()
          };
          var dataResp = await http.post(Uri.parse('$ip/apis/test/registerAgentForOutTrip'),body: datas2);          
          setState(() {            
            statusCodex = dataResp.statusCode;
          });
        }
        validationLastToPassProgres(statusCodex, prefs.tripId, send.title, send.message,);
      }
    }
  }

  void validationLastToPassProgres(statusCode, tripId, title, message)async{
    if (statusCode == 200) {
      await http.get(Uri.parse('$ip/apis/agentsInTravel/$tripId'));    
      Navigator.pop(context);
      Navigator.push(context,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));
      prefs.removeIdCompanyAndVehicle();
      QuickAlert.show(context: context,title: title,text: message,type: QuickAlertType.success,confirmBtnText: 'Ok'); 
      this.handler!.cleanTable();
    } else {
        throw Exception('Failed to load Data');
    } 
  }

  Future scanBarcodeNormal() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      barcodeScan = barcodeScanRes;
    });
    Map data = {"companyId": prefs.companyId, "agentEmployeeId": barcodeScan};

    http.Response responsed =
        await http.post(Uri.parse('$ip/apis/searchAgent'), body: data);
    final data1 = Search.fromJson(json.decode(responsed.body));
    final Database db = await handler!.initializeDB();
    final tables = await db.rawQuery('SELECT * FROM userX ;');
    final tables2 = await db.rawQuery(
        "SELECT noempid FROM userX WHERE noempid = '${prefs.nameSalida}'");
    if (responsed.statusCode == 200 && data1.ok == true && data1.agent!.msg != null) {
      if (barcodeScan == '${-1}') {
        print('');
      } else {
        QuickAlert.show(
          context: context,
          title: '¡No encontrado!',
          text: data1.agent!.msg,
          type: QuickAlertType.error,
        ); 
      }
      print(data1.agent!.msg);
    } else if (responsed.statusCode == 200 && data1.ok == true) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: backgroundColor,
                content: Container(
                  width: 450,
                  height: 490,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 15),
                        Center(
                          child: Text('¿Agregar agente al viaje?',textAlign: TextAlign.center,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: GradiantV_2),),
                        ),
                        SizedBox(height: 15),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('No empleado: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.agentEmployeeId}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.card_travel,
                            color: thirdColor,
                            size: 35,),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Nombre: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.agentFullname}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.contact_page_outlined,
                            color: thirdColor,
                            size: 35,),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Hora salida: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.hourOut}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.access_time,
                            color: thirdColor,
                            size: 35,),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Dirección: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text(
                              '${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint} ',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.directions,
                            color: thirdColor,
                            size: 35,),
                        ),
                        SizedBox(height: 40),
                        Row(
                          children: [
                            SizedBox(width: 40),
                            ElevatedButton(
                              style: TextButton.styleFrom(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.green),
                              onPressed: () => {
                                setState(() {
                                  if (tables.length <= 13) {
                                    if (prefs.nameSalida != tables2.toString()) {
                                      noemp.insert(0, '${data1.agent!.agentEmployeeId}');
                                      names.insert(0, '${data1.agent!.agentFullname}');
                                      hourout.insert(0, '${data1.agent!.hourOut}');
                                      direction.insert(0,'${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}');
                                      tempArr.add(data1.agent!.agentId);prefs.companyIdAgent =data1.agent!.companyId.toString();
                                      prefs.nameSalida = data1.agent!.agentEmployeeId.toString();
                                      User firstUser = User(noempid: '${data1.agent!.agentEmployeeId}',nameuser:'${data1.agent!.agentFullname}',hourout: '${data1.agent!.hourOut}',direction:'${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}',idsend: data1.agent!.agentId);
                                      List<User> listOfUsers = [firstUser];
                                      this.handler!.insertUser(listOfUsers);
                                    } else {
                                      print('yasta we');
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                        context: context,
                                        title: "¡Advertencia!",
                                        text: " El agente con número de empleado \n '${data1.agent!.agentEmployeeId}' ya está agregado al viaje",
                                        type: QuickAlertType.error,
                                      );                                    
                                    }
                                  } else if (tables.length > 13) {
                                    print('yasta we');
                                    Navigator.pop(context);
                                    QuickAlert.show(
                                        context: context,
                                        title: "¡Advertencia!",
                                        text: " El limite de agentes son 14, favor \n comunicarse con su cordinador",
                                        type: QuickAlertType.error,
                                      );
                                  }
                                  Navigator.pop(context);
                                }),
                              },
                              child: Text('Agregar'),
                            ),
                            SizedBox(width: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: TextStyle(
                                    color: Colors.red,
                                  ),
                                  backgroundColor: Colors.orange),
                              onPressed: () => {
                                setState(() {
                                  Navigator.pop(context);
                                }),
                              },
                              child: Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ));
    }

    print(barcodeScan);
  }

  Future scanBarcodeNormalSolid() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      barcodeScan = barcodeScanRes;
    });
    Map data = {
      "companyId": prefs.companyId,
      "agentEmployeeId": barcodeScan,
      "destinationId": prefs.destinationId,
    };
    final Database db = await handler!.initializeDB();

    final tables = await db.rawQuery('SELECT * FROM agentInsertSolid ;');
    final tables2 = await db.rawQuery(
        "SELECT noempid FROM agentInsertSolid WHERE noempid = '${prefs.nameSalida}'");
    http.Response responsed =
        await http.post(Uri.parse('$ip/apis/getAgentForEntryTrip'), body: data);
    final data1 = FindAgentSolid.fromJson(json.decode(responsed.body));
    print(responsed.body);
    if (responsed.statusCode == 200) {
      if (barcodeScan == '${-1}') {
        print('');
      }
      if (data1.type == "error") {
        QuickAlert.show(
          context: context,
          title: '¡No encontrado!',
          text: 'No se encontró el agente con número de empleado \n $agentEmployeeId',
          type: QuickAlertType.error,
        );
      } else if (data1.type == "success") { 
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  backgroundColor: backgroundColor,
                  content: Container(
                    color: backgroundColor,
                    width: 450,
                    height: 490,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 15),
                          Text(
                            '¿Agregar agente al viaje?',textAlign: TextAlign.center,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: GradiantV_2),
                          ),
                          SizedBox(height: 15),
                          ListTile(
                            contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            title: Text('No empleado: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.agentEmployeeId}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.card_travel,
                            color: thirdColor,
                            size: 35,),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            title: Text('Nombre: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.agentFullname}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.contact_page_outlined,
                            color: thirdColor,
                            size: 35,),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            title: Text('Hora: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.hourAgent}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.access_time,
                            color: thirdColor,
                            size: 35,),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            title: Text('Dirección: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text(
                              '${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint} ',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.directions,
                            color: thirdColor,
                            size: 35,),
                          ),
                          SizedBox(height: 40),
                          Row(
                            children: [
                              SizedBox(width: 40),
                              TextButton(
                                style: TextButton.styleFrom(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () => {
                                  setState(() {
                                    if (tables.length <= 13) {
                                      if (prefs.nameSalida != tables2.toString()) {
                                        noemp.insert(0,
                                            '${data1.agent!.agentEmployeeId}');
                                        names.insert(
                                            0, '${data1.agent!.agentFullname}');
                                        hourout.insert(
                                            0, '${data1.agent!.hourAgent}');
                                        direction.insert(0,
                                            '${data1.agent!.agentReferencePoint} ${data1.agent!.neighborhoodName}\n${data1.agent!.departmentName}');
                                        tempArr.add(data1.agent!.agentId);
                                        prefs.destinationIdAgent =
                                            data1.agent!.companyId.toString();
                                        prefs.nameSalida = data1
                                            .agent!.agentEmployeeId
                                            .toString();
                                        User firstUser = User(
                                            noempid:
                                                '${data1.agent!.agentEmployeeId}',
                                            nameuser:
                                                '${data1.agent!.agentFullname}',
                                            hourout: '${data1.agent!.hourAgent}',
                                            direction:
                                                '${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}',
                                            idsend: data1.agent!.agentId);
                                        print(firstUser);
                                        List<User> listOfUsers = [firstUser];
                                        this.handler!.insertAgentSolid(listOfUsers);
                                        clearText();
                                        //guardar();

                                      } else {
                                        print('yasta we');
                                        Navigator.pop(context);
                                        QuickAlert.show(
                                          context: context,
                                          title: "¡Advertencia!",
                                          text: " El agente con número de empleado \n '${data1.agent!.agentEmployeeId}' ya está agregado al viaje",
                                          type: QuickAlertType.error,
                                        );
                                      }
                                    } else if (tables.length > 13) {
                                      print('yasta we');
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                        context: context,
                                        title: "¡Advertencia!",
                                        text: " El limite de agentes son 14, favor \n comunicarse con su cordinador",
                                        type: QuickAlertType.error,
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
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                                onPressed: () => {
                                  setState(() {
                                    Navigator.pop(context);
                                  }),
                                },
                                child: Text('Cancelar'),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ));
      }
    }

    print(barcodeScan);
  }

  Future<List<Company2>> fetchCompanys() async {
    http.Response response = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final si = DriverData.fromJson(json.decode(response.body));
    http.Response responsed =
        await http.get(Uri.parse('$ip/apis/newdeparture/${si.departmentId}'));
    var jsonData = json.decode(responsed.body);
    List<Company2> trips = [];
    for (var u in jsonData) {
      Company2 trip = Company2(u["companyId"], u["companyName"]);
      trips.add(trip);
    }
    if (mounted) {
      setState(() {
        data = jsonData;
      });
    }
    return trips;
  }

  Future<List<Destinationations>> fetchDestinations() async {
    http.Response response = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final si = DriverData.fromJson(json.decode(response.body));
    http.Response responsed = await http
        .get(Uri.parse('$ip/apis/getDestinationsForEntryTrip/${si.driverId}'));
    var jsonData = json.decode(responsed.body);
    List<Destinationations> trips = [];
    for (var u in jsonData['destinations']) {
      Destinationations trip =
          Destinationations(u["destinationId"], u["destinationName"]);
      trips.add(trip);
    }
    if (mounted) {
      setState(() {
        data2 = jsonData['destinations'];
      });
    }
    print(trips.length);
    return trips;
  }

  Future<Search> fetchSearchAgents2(String agentEmployeeId) async {
    Navigator.pop(context);
    LoadingIndicatorDialog().show(context);
    Map data = {
      "companyId": prefs.companyId,
      "agentEmployeeId": agentEmployeeId
    };
    final Database db = await handler!.initializeDB();
    final tables = await db.rawQuery('SELECT * FROM userX ;');
    final tables2 = await db.rawQuery(
        "SELECT noempid FROM userX WHERE noempid = '${prefs.nameSalida}'");
    http.Response responsed =
        await http.post(Uri.parse('$ip/apis/searchAgent'), body: data);
    final data1 = Search.fromJson(json.decode(responsed.body));

    LoadingIndicatorDialog().dismiss();
    if (responsed.statusCode == 200 && data1.ok == true && data1.agent!.msg != null) {
      //print(data1.agent!.msg);
      //print('Este es el agentId' + data1.agent!.agentId.toString());
      // if (data1.agent!.agentId != null) {
      // }
        QuickAlert.show(
          context: context,
          title: '¡No encontrado!',
          text: data1.agent!.msg,
          type: QuickAlertType.error,
        );
    } else if (responsed.statusCode == 200 && data1.ok == true) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: backgroundColor,
                content: Container(
                  width: 450,
                  height: 490,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 15),
                        Center(
                          child: Text(
                            '¿Agregar agente al viaje?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: GradiantV_2),
                          ),
                        ),
                        SizedBox(height: 15),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('No empleado:',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.agentEmployeeId}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(
                            Icons.card_travel,
                            color: thirdColor,
                            size: 35,
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Nombre: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.agentFullname}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading:
                              Icon(Icons.person, color: thirdColor, size: 35),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Hora salida: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.hourOut}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.access_time,
                              color: thirdColor, size: 35),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Dirección: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text(
                              '${data1.agent!.neighborhoodName} ${data1.agent!.agentReferencePoint}\n${data1.agent!.departmentName}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.directions,
                              color: thirdColor, size: 35),
                        ),
                        SizedBox(height: 40),
                        Row(
                         // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  textStyle: TextStyle(
                                    color: backgroundColor,
                                  ),
                                  backgroundColor: firstColor,
                                ),
                                onPressed: () => {
                                  setState(() {
                                    if (tables.length <= 13) {
                                      if (prefs.nameSalida != tables2.toString()) {
                                        noemp.insert(0,'${data1.agent!.agentEmployeeId}');
                                        names.insert(0, '${data1.agent!.agentFullname}');
                                        hourout.insert(0, '${data1.agent!.hourOut}');
                                        direction.insert(0,'${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}');
                                        tempArr.add(data1.agent!.agentId);
                                        prefs.companyIdAgent = data1.agent!.companyId.toString();
                                        prefs.nameSalida = data1.agent!.agentEmployeeId.toString();
                                        User firstUser = User(
                                            noempid: '${data1.agent!.agentEmployeeId}',
                                            nameuser: '${data1.agent!.agentFullname}',
                                            hourout: '${data1.agent!.hourOut}',
                                            direction:'${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}',
                                            idsend: data1.agent!.agentId);
                                        List<User> listOfUsers = [firstUser];
                                        this.handler!.insertUser(listOfUsers);
                                        clearText();
                                        //guardar();

                                      } else {
                                        print('yasta we');
                                        Navigator.pop(context);
                                        QuickAlert.show(
                                          context: context,
                                          title: "¡Advertencia!",
                                          text: " El agente con número de empleado \n '${data1.agent!.agentEmployeeId}' ya está agregado al viaje",
                                          type: QuickAlertType.error,
                                        );
                                      }
                                    } else if (tables.length > 13) {
                                      print('yasta we');
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                        context: context,
                                        title: "¡Advertencia!",
                                        text: " El limite de agentes son 14, favor \n comunicarse con su cordinador",
                                        type: QuickAlertType.error,
                                      );
                                    }

                                    Navigator.pop(context);
                                  }),
                                  // },
                                },
                                child: Text('Agregar',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: backgroundColor)),
                              ),
                            ),                            
                            Container(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => {
                                  setState(() {
                                    Navigator.pop(context);
                                  }),
                                },
                                child: Text('Cancelar',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
    
    }
    return Search.fromJson(json.decode(responsed.body));
  }

  // ignore: missing_return
  fetchSearchAgentsSolid(String agentEmployeeId) async {
    Map data = {
      "companyId": prefs.companyId,
      "agentEmployeeId": agentEmployeeId,
      "destinationId": prefs.destinationId,
    };
    if (agentEmployeeId != "") {
      final Database db = await handler!.initializeDB();

      final tables = await db.rawQuery('SELECT * FROM agentInsertSolid ;');
      final tables2 = await db.rawQuery("SELECT noempid FROM agentInsertSolid WHERE noempid = '${prefs.nameSalida}'");
      http.Response responsed = await http.post(Uri.parse('$ip/apis/getAgentForEntryTrip'), body: data);

      final data1 = FindAgentSolid.fromJson(json.decode(responsed.body));
      if (responsed.statusCode == 200) {
        if (data1.type == "error") {
          QuickAlert.show(
            context: context,
            title: '¡No encontrado!',
            text: 'No se encontró el agente con número de empleado \n $agentEmployeeId',
            type: QuickAlertType.error,
          );    
        } else if (data1.type == "success") { 
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    backgroundColor: backgroundColor,
                    content: Container(
                      width: 450,
                      height: 490,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 15),
                            Text(
                              '¿Agregar agente al viaje?',
                              textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: GradiantV_2),
                            ),
                             SizedBox(height: 15),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('No empleado:',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.agentEmployeeId}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(
                            Icons.card_travel,
                            color: thirdColor,
                            size: 35,
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Nombre: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.agentFullname}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading:
                              Icon(Icons.person, color: thirdColor, size: 35),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Hora salida: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text('${data1.agent!.hourAgent}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.access_time,
                              color: thirdColor, size: 35),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          title: Text('Dirección: ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text(
                              '${data1.agent!.neighborhoodName} ${data1.agent!.agentReferencePoint}\n${data1.agent!.departmentName}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          leading: Icon(Icons.directions,
                              color: thirdColor, size: 35),
                        ),
                        SizedBox(height: 40),
                            Row(
                              children: [
                                SizedBox(width: 40),
                                Container(
                                  width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  textStyle: TextStyle(
                                    color: backgroundColor,
                                  ),
                                  backgroundColor: firstColor,
                                ),
                                    onPressed: () => {
                                      setState(() {
                                        if (tables.length <= 13) {
                                          if (prefs.nameSalida != tables2.toString()) {
                                            noemp.insert(0,
                                                '${data1.agent!.agentEmployeeId}');
                                            names.insert(0,
                                                '${data1.agent!.agentFullname}');
                                            hourout.insert(
                                                0, '${data1.agent!.hourAgent}');
                                            direction.insert(0,
                                                '${data1.agent!.agentReferencePoint} ${data1.agent!.neighborhoodName}\n${data1.agent!.departmentName}');
                                            tempArr.add(data1.agent!.agentId);
                                            prefs.destinationIdAgent =
                                                data1.agent!.companyId.toString();
                                            prefs.nameSalida = data1
                                                .agent!.agentEmployeeId
                                                .toString();
                                            User firstUser = User(
                                                noempid:
                                                    '${data1.agent!.agentEmployeeId}',
                                                nameuser:
                                                    '${data1.agent!.agentFullname}',
                                                hourout:
                                                    '${data1.agent!.hourAgent}',
                                                direction:
                                                    '${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}',
                                                idsend: data1.agent!.agentId);
                                            print(firstUser);
                                            List<User> listOfUsers = [firstUser];
                                            this.handler!.insertAgentSolid(listOfUsers);
                                            clearText();
                                            //guardar();

                                          } else {
                                            print('yasta we');
                                            Navigator.pop(context);
                                            QuickAlert.show(
                                              context: context,
                                              title: "¡Advertencia!",
                                              text: " El agente con número de empleado \n '${data1.agent!.agentEmployeeId}' ya está agregado al viaje",
                                              type: QuickAlertType.error,
                                            ); 
                                          }
                                        } else if (tables.length > 13) {
                                          print('yasta we');
                                          Navigator.pop(context);
                                          QuickAlert.show(
                                            context: context,
                                            title: "¡Advertencia!",
                                            text: " El limite de agentes son 14, favor \n comunicarse con su cordinador",
                                            type: QuickAlertType.error,
                                          ); 
                                        }
                                        Navigator.pop(context);
                                      }),
                                      // },
                                    },
                                    child: Text('Agregar'),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Container(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => {
                                  setState(() {
                                    Navigator.pop(context);
                                  }),
                                },
                                child: Text('Cancelar',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white)),
                              ),
                            ),
                              ],
                            ),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ));
        
        }
      }
      return FindAgentSolid.fromJson(json.decode(responsed.body));
    }
  }

  // ignore: missing_return
  fetchAgentsLeftPastToProgresToSolid() async {
    http.Response responses2 = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(responses2.body));

    http.Response responses = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final si = DriverData.fromJson(json.decode(responses.body));
    final Database db = await handler!.initializeDB();
    final tables = await db.rawQuery('SELECT * FROM agentInsertSolid ;');
    if (tables.length == 0) {
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        title: "Alerta",
        text: "No hay agentes agregados",
        type: QuickAlertType.error,
      ); 
    } else {
      if (si.driverCoord == true) {
        Map datas = {
          'companyId': prefs.companyId,
          'driverId': radioShowAndHide == false
              ? si.driverId.toString()
              : prefs.driverIdx,
          'destinationId': prefs.destinationId,
          'tripVehicle': prefs.vehiculoSolid,
        };
        http.Response response1 = await http.post(Uri.parse('$ip/apis/registerTripEntryByDriver'), body: datas);
        final send = TripsToSolid.fromJson(json.decode(response1.body));
        prefs.tripId = send.trip!.tripId.toString();

        var agente = [];
        if (response1.statusCode == 200) {

            for (var i = 0; i < tables.length; i++) {
            Map datas2 = {
              "agentId": tables[i]['idsend'].toString(),
              "tripId": send.trip!.tripId.toString(),
              "tripHour": send.trip!.tripHour.toString(),
              "driverId":data.driverId.toString()
            };
            agente.add({
              "agenteN": tables[i]['nameuser'].toString(),
              "agenteId": tables[i]['idsend'].toString(),
            });
            final sendDatas = await http.post(Uri.parse('$ip/apis/registerAgentForOutTrip'),body: datas2);
            
            print(sendDatas.body);
            Navigator.pop(context);
            Navigator.push(context,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));
            prefs.removeIdCompanyAndVehicle();
            QuickAlert.show(
              context: context,
              title: '¡Éxito!',
              text: 'El viaje se ha registrado correctamente',
              type: QuickAlertType.success,
            );  
            this.handler!.cleanTableAgent();
          }

          DateTime fechaActual = DateTime.now();
          String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaActual);

        
          Map datas3 = {
            "id": send.trip!.tripId,
            "NombreM": prefs.nombreUsuarioFull,
            "idM": si.driverId,
            "Company": int.parse(prefs.companyId),
            "Fecha": fechaFormateada.toString(),
            "Agentes": agente
          };
          String sendData2 = json.encode(datas3);

          await http.post(Uri.parse('https://apichat.smtdriver.com/api/salas'),body: sendData2, headers: {"Content-Type": "application/json"});
        } else {
          throw Exception('Failed to load Data');
        }

      } else {
        Map datas = {
          'companyId': prefs.companyId,
          'driverId': si.driverId.toString(),
          'destinationId': prefs.destinationId,
          'tripVehicle': prefs.vehiculoSolid,
        };
        //print(datas);
        http.Response response1 = await http.post(Uri.parse('$ip/apis/registerTripEntryByDriver'), body: datas);
        //print(response1.body);
        final send = TripsToSolid.fromJson(json.decode(response1.body));
        prefs.tripId = send.trip!.tripId.toString();
        if (response1.statusCode == 200) {
          for (var i = 0; i < tables.length; i++) {
            Map datas2 = {
              "agentId": tables[i]['idsend'].toString(),
              "tripId": send.trip!.tripId.toString(),
              "tripHour": send.trip!.tripHour.toString()
            };

            await http.post(Uri.parse('$ip/apis/registerAgentTripEntryByDriver'),body: datas2);
            Navigator.pop(context);
            Navigator.push(context,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));
            prefs.removeIdCompanyAndVehicle();
            QuickAlert.show(
              context: context,
              title: '¡Éxito!',
              text: 'El viaje se ha registrado correctamente',
              type: QuickAlertType.success,
            ); 
            this.handler!.cleanTableAgent();
          }
        } else {
          throw Exception('Failed to load Data');
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    //variable
    super.build(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
          SizedBox(height: 35.0),
        ] else if (widget.plantillaDriver.id == 4) ...[
          _mostrarCuartaVentana(),
          SizedBox(height: 20.0),
        ] else if (widget.plantillaDriver.id == 5) ...[
          //_noDisponible(context),
        ] else if (widget.plantillaDriver.id == 6) ...[
          _mostrarQuintaVentana(context),
          SizedBox(height: 120.0),
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            _crearDropdown(context),
            SizedBox(height: 20.0),
            FutureBuilder<DriverData>(
              future: itemx,
              builder: (BuildContext context, abc) {
                if (abc.connectionState == ConnectionState.done) {
                  DriverData? driverData = abc.data;
                  return Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      if(driverData?.driverType=='Motorista')
                        Text('Escanee el codigo qr del vehículo', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)),
                      if(driverData?.driverType=='Motorista')
                        SizedBox(height: 5,),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1
                              ) // Radio de la esquina
                            ),
                              child: Padding(
                                padding: const EdgeInsets.only(left:20.0, right: 10),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(  
                                      "assets/icons/vehiculo.svg",
                                      color: Theme.of(context).primaryIconTheme.color,
                                      width: 15,
                                      height: 15,
                                    ),
                                    SizedBox(width: 6),
                                    Flexible(
                                      child: TextField(
                                        enabled: driverData?.driverType=='Motorista'?false:true,
                                                    style: TextStyle(
                                                      color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                                                    ),
                                                    controller: vehicleController,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: 'Vehículo',
                                                      hintStyle: TextStyle(
                                                        color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                                                      )
                                                    ),
                                                    onChanged: (value) => {
                                                      prefs.vehiculo=value,
                                                      prefs.vehiculoId='',
                                                    },
                                                  ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Theme.of(context).primaryColorDark,
                                width: 1
                              )
                            ),
                            child: IconButton(
                              icon: SvgPicture.asset(  
                                    "assets/icons/QR.svg",
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                              onPressed: () async{
                                String codigoQR = await FlutterBarcodeScanner.scanBarcode("#9580FF", "Cancelar", true, ScanMode.QR);
                        
                                  if (codigoQR == "-1") {
                                    return;
                                  } else {
      
                                    LoadingIndicatorDialog().show(context);
                                    http.Response responseSala = await http.get(Uri.parse('https://app.mantungps.com/3rd/vehicles/$codigoQR'),headers: {"Content-Type": "application/json", "x-api-key": 'a10xhq0p21h3fb9y86hh1oxp66c03f'});
                                    final resp = json.decode(responseSala.body);
                                    LoadingIndicatorDialog().dismiss();
                                    if(resp['type']=='success'){
                                      print(responseSala.body);
                                      
                                      if(mounted){
                                        showDialog(
                                                context: context,
                                                builder: (context) => vehiculoE(resp, context, codigoQR),);
                                      }
                                    }else{
                                      if(mounted){
                                        QuickAlert.show(context: context,title: "Alerta",text: "Vehículo no valido",type: QuickAlertType.error,); 
                                      }
                                    }
                                  }
                              }
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return ColorLoader3();
                }
              },
            ),
            FutureBuilder<DriverData?>(
              future: itemx!,
              builder: (BuildContext context, abc) {
                switch (abc.connectionState) {
                  case ConnectionState.waiting:
                    return Text('Cargando....');
                  default:
                    if (abc.hasError) {
                      return Text('Error: ${abc.error}');
                    } else {
                      return abc.data?.driverCoord == true? 
                      Column(
                        children: [
                          SizedBox(height: 20),
                          getSearchableDropdown(context),
                        ],
                      ) : Text('');
                    }
                }
              }),
            SizedBox(height: 20.0),
            Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 75,
                  child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: GradiantV_2,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),),
                      child: Icon(Icons.delete,color: backgroundColor, size: 25.0),
                      onPressed: () {
                        QuickAlert.show(context: context,title: "...",
                        text: "¿Desea eliminar a los agentes?",
                        confirmBtnText: "Si",cancelBtnText: "Cancelar",showCancelBtn: true,  confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
                          onConfirmBtnTap: () {
                            Navigator.pop(context);
                            QuickAlert.show(
                              context: context,
                              title: "Eliminando...",
                              type: QuickAlertType.success,
                            );
                            setState(() {
                              this.handler!.cleanTable();
                            });
                            },
                            onCancelBtnTap: () {
                              Navigator.pop(context);
                              QuickAlert.show(
                                context: context,
                                title: "Cancelado",
                                type: QuickAlertType.success,                                                  
                              );                                                
                            },                                              
                            type: QuickAlertType.warning,
                          );
                        
                      }),
                ),
                SizedBox(width: 8.0),
                Container(
                  width: 75,
                  child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: GradiantV2,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),),
                    child: Icon(Icons.search, color: backgroundColor, size: 25.0),
                    onPressed: () {
                      showGeneralDialog(
                          barrierColor: Colors.black.withOpacity(0.5),
                          transitionBuilder: (context, a1, a2, widget) {
                            return Transform.scale(scale: a1.value,
                              child: Opacity(opacity: a1.value,
                                child: AlertDialog(
                                  backgroundColor: backgroundColor,
                                  shape: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(16.0)),
                                  title: Center(child: Text('Buscar Agente',style: TextStyle(color: GradiantV_2, fontSize: 20.0),)),
                                  content: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:BorderRadius.all(Radius.circular(15)),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.2),spreadRadius: 0,blurStyle: BlurStyle.solid,blurRadius: 10,offset: Offset(0,0), ),
                                        BoxShadow(color: Colors.white.withOpacity(0.1),spreadRadius: 0,blurRadius: 5,blurStyle: BlurStyle.inner,offset: Offset(0,0),                                 ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: TextField(style: TextStyle(color: Colors.white),
                                        controller: agentEmployeeId,
                                        decoration: InputDecoration(border: InputBorder.none,labelText: 'Escriba aqui',labelStyle: TextStyle(color: Colors.white.withOpacity(0.5),fontSize: 15.0)),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(width: 100,
                                          child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0),),textStyle: TextStyle(color: backgroundColor,),backgroundColor: Gradiant2,),
                                            onPressed: () => {
                                              fetchSearchAgents2(
                                                  agentEmployeeId.text),
                                              
                                            },
                                            child: Text('Buscar',style: TextStyle(color: backgroundColor,fontSize: 15.0)),
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Container(width: 100,
                                          child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0),),textStyle: TextStyle(color: Colors.white,),backgroundColor: Colors.red,),
                                            onPressed: () => {
                                              Navigator.pop(context),
                                            },
                                            child: Text('Cerrar',style: TextStyle(color: Colors.white,fontSize: 15.0)),
                                          ),
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
                            return Text('');
                          });
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                Container(width: 75,
                  child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),backgroundColor: firstColor),child: Icon(Icons.qr_code,color: backgroundColor, size: 25.0),onPressed: scanBarcodeNormal),
                )
              ],
            ),
            SizedBox(height: 6.0),
            FutureBuilder(
              future: this.handler!.retrieveUsers(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<User?>> snapshot) {
                if (snapshot.hasData) {
                  noemp.add("${snapshot.data?.length}");
                  return Text("Total de agentes: ${snapshot.data?.length}",style: TextStyle(color: Colors.white,fontSize: 15.0,fontWeight: FontWeight.bold));
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 6.0),
            FutureBuilder(
                future: this.handler!.retrieveUsers(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<User?>> snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        child: Column(
                          children: [
                            for (var i = 0; i < snapshot.data!.length; i++) ...{
                              Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(blurStyle: BlurStyle.normal,color: Colors.white.withOpacity(0.2),blurRadius: 15,spreadRadius: -30,offset: Offset(-25, -25)),
                                  BoxShadow(blurStyle: BlurStyle.normal,color: Colors.black.withOpacity(0.6),blurRadius: 30,spreadRadius: -45,offset: Offset(20, -15)),
                                ]),
                                child: Card(elevation: 20,color: backgroundColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),margin: EdgeInsets.all(4.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(margin: EdgeInsets.only(left: 15),
                                        child: Column(
                                          children: [
                                            Column(crossAxisAlignment:CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.confirmation_number,color: thirdColor),
                                                    SizedBox(width: 15,),
                                                    Flexible(child: Text('# No empleado: ${snapshot.data![i]!.noempid}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                  ],
                                                  ),
                                                ),                       
                                              ],
                                            ),
                                            Column(crossAxisAlignment:CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.account_box_sharp,color: thirdColor),
                                                    SizedBox(width: 15,),
                                                    Flexible(child: Text('Nombre: ${snapshot.data![i]!.nameuser}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                  ],
                                                  ),
                                                ),                       
                                              ],
                                            ),
                                            Column(crossAxisAlignment:CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.access_alarms,color: thirdColor),
                                                    SizedBox(width: 15,),
                                                    Flexible(child: Text('Hora salida: ${snapshot.data![i]!.hourout}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                  ],
                                                  ),
                                                ),                       
                                              ],
                                            ),
                                            Column(crossAxisAlignment:CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                                                child: Row(
                                                  children: [
                                                    Padding(padding: const EdgeInsets.only(bottom: 18),child: Icon(Icons.location_pin,color: thirdColor)),
                                                    SizedBox(width: 15,),
                                                    Flexible(child: Text('Dirección: ${snapshot.data![i]!.direction}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                  ],
                                                  ),
                                                ),                       
                                              ],
                                            ),          
                                          ],
                                        ),
                                      ),
                                      Container(width: 150,
                                        decoration: BoxDecoration(boxShadow: [
                                          BoxShadow(blurStyle: BlurStyle.normal,color:Colors.white.withOpacity(0.2),blurRadius: 10,spreadRadius: -8,offset: Offset(-10, -6)),
                                          BoxShadow(blurStyle: BlurStyle.normal,color:Colors.black.withOpacity(0.6),blurRadius: 10,spreadRadius: -15,offset: Offset(18, 5)),
                                        ]),                                    
                                        child: ElevatedButton(style: ElevatedButton.styleFrom(textStyle: TextStyle(color: Colors.white,),backgroundColor: backgroundColor,shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0)),),
                                          onPressed: () async {
                                            final Database db = await handler!.initializeDB();
                                            await this.handler!.deleteUser(snapshot.data![i]!.idsend!);
                                            await db.rawQuery("DELETE FROM userX WHERE nameuser = '${snapshot.data![i]!.nameuser}'");
                                            QuickAlert.show(context: context,title: "¿Desea eliminar el Agente?",confirmBtnText: "Si",cancelBtnText: "Cancelar",showCancelBtn: true,  confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
                                              onConfirmBtnTap: () {
                                                Navigator.pop(context);
                                                QuickAlert.show(
                                                  context: context,
                                                  title: "Eliminado",
                                                  type: QuickAlertType.success,
                                                );
                                                setState(() {
                                                  snapshot.data!.remove(snapshot.data![i]);
                                                });
                                              },
                                              onCancelBtnTap: () {
                                                Navigator.pop(context);
                                                QuickAlert.show(
                                                  context: context,
                                                  title: "Cancelado",
                                                  type: QuickAlertType.error,                                                  
                                                );                                                
                                              },                                              
                                              type: QuickAlertType.success,
                                            ); 
                                          },
                                          child: Text('Quitar',style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                    ],
                                  ),
                                ),
                              )
                            },
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 20.0),
                                  Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(blurStyle: BlurStyle.normal,color: Colors.white.withOpacity(0.2),blurRadius: 15,spreadRadius: -30,offset: Offset(-25, -25)),
                                      BoxShadow(blurStyle: BlurStyle.normal,color: Colors.black.withOpacity(0.6),blurRadius: 30,spreadRadius: -45,offset: Offset(20, -15)),
                                    ]),
                                    child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10.0)),backgroundColor: thirdColor,padding: EdgeInsets.symmetric(vertical: 5, horizontal: 22)),
                                        child: Icon(Icons.save,color: backgroundColor, size: 25.0),
                                        onPressed: () async {                                      
                                          showGeneralDialog(
                                            context: context,transitionBuilder:(context, a1, a2, widget) {
                                              return Center( child: ColorLoader3());
                                            },
                                            transitionDuration:Duration(milliseconds: 200),
                                            barrierDismissible: false,
                                            barrierLabel: '',
                                            pageBuilder: (context, animation1,animation2) {
                                              return Text('');
                                            }
                                          );
                                          await fetchAgentsLeftPastToProgres(hourOut.text, vehicule.text);
                                          if(prefs.vehiculo != "" || nameController.text != ""){
                                            setState(() {
                                              this.handler!.cleanTable();
                                            });
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 60,)
                          ],
                        ),
                      ),
                    );
                  } else if (names.length == 0) {
                    return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),margin: EdgeInsets.symmetric(vertical: 25),
                      child: Container(color: backgroundColor,
                        child: Column(mainAxisSize: MainAxisSize.max,crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.bus_alert,color: thirdColor,),
                              title: Text('Agentes',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal,fontSize: 26.0)),
                              subtitle: Text('No hay agentes en el viaje',style: TextStyle(color: Colors.red,fontWeight: FontWeight.normal,fontSize: 18.0)),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })
          
          ],
        ),
      ),
    );
  }

  AlertDialog vehiculoE(resp, BuildContext context, codigoQR) {

    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Center(
          child: Text(
        'Vehículo Encontrado',
        style: TextStyle(color: GradiantV_2, fontSize: 20.0),
      )),
      content: Container(
        height: 130,
        child: Column(
          children: [
                const SizedBox(height: 8.0),
                Text('Descripcion:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 5,
                ),
                Text(resp['vehicle']['name'],
                    style: TextStyle(color: Colors.white, fontSize: 18.0)),
                SizedBox(
                  height: 15,
                ),
                Text('Placa:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 10,
                ),
                Text(resp['vehicle']['registrationNumber'],
                    style: TextStyle(color: Colors.white, fontSize: 18.0)),
              ],
        ),
      ),
      actions: [
                                                              Row(mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Container(width: 100,
                                                                    child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0),),textStyle: TextStyle(color: backgroundColor,),backgroundColor: Gradiant2,),
                                                                      onPressed: () {
                                                                        setState(() { 
                                                                          prefs.vehiculo = "${resp['vehicle']['name']} [${resp['vehicle']['registrationNumber']}]";
                                                                          prefs.vehiculoId=codigoQR;
                                                                          vehicleController.text=prefs.vehiculo;

                                                                          print(prefs.vehiculoId);
                                                                          print(prefs.vehiculo);
                                                                        });
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text('Agregar',style: TextStyle(color: backgroundColor,fontSize: 15.0)),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10.0),
                                                                  Container(width: 100,
                                                                    child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0),),textStyle: TextStyle(color: Colors.white,),backgroundColor: Colors.red,),
                                                                      onPressed: () => {
                                                                        Navigator.pop(context),
                                                                      },
                                                                      child: Text('Cancelar',style: TextStyle(color: Colors.white,fontSize: 15.0)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
    );
  }

  Widget showAndHide() {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 30.0),
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(blurStyle: BlurStyle.normal,color: Colors.white.withOpacity(0.2),blurRadius: 30,spreadRadius: -8,offset: Offset(-15, -6)),
              BoxShadow(blurStyle: BlurStyle.normal,color: Colors.black.withOpacity(0.6),blurRadius: 30,spreadRadius: -15,offset: Offset(18, 5)),
            ]),
            child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),backgroundColor: Gradiant2,padding:EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
              child: Text(radioShowAndHide == false? 'Presione aquí para asignar conductor': 'Presione aquí si usted realizará el viaje', style: TextStyle(color: backgroundColor)),
              onPressed: () {
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
          ),
          Visibility(maintainSize: true,maintainAnimation: true,maintainState: true,visible: radioShowAndHide,child: getSearchableDropdown(context)),
        ],
      ),
    );
  }

  Widget getSearchableDropdown(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        if(seleccionarMotorista==true)
         Padding(
          padding: const EdgeInsets.only(top:40.0),
          child: menuConductor(size),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              seleccionarMotorista = !seleccionarMotorista;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1
              )
            ),
            child: Padding(
              padding: const EdgeInsets.only(left:20.0, right: 10),
              child: Row(
                children: [
                  SvgPicture.asset(  
                    "assets/icons/compania.svg",
                    color: Theme.of(context).primaryIconTheme.color,
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 5),
                  if(radioShowAndHide)...{
                    Expanded(
                      child: Text(
                        driver,
                        style:  Theme.of(navigatorKey.currentContext!).textTheme.titleMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                      ),
                    ),
                  }else...{
                    Expanded(
                      child: Text(
                        'Asignar un conductor (Opcional)',
                        style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                        ),
                      ),
                    ),
                  },
        
                  SvgPicture.asset(  
                    "assets/icons/flecha_hacia_abajo.svg",
                    color: Theme.of(context).primaryIconTheme.color,
                    width: 50,
                    height: 50,
                  ),
                ],
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget menuConductor(Size size) {
    List<TripsDrivers> driversList = driverId;

    bool ningunoPresent = driversList.any((driver) => driver.driverFullname == "Ninguno");

    if (!ningunoPresent) {
      driversList.insert(0, TripsDrivers(driverFullname: "Ninguno", driverId: -1));
    }

    return Container(
      width: size.width,
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 12, left: 12),
            child: TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Theme.of(navigatorKey.currentContext!).hintColor, 
                  fontSize: 15, 
                  fontFamily: 'Roboto'
                ),
              ),
              onChanged: (value) {
                print(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: driversList.length,
              padding: const EdgeInsets.only(top: 10, right: 12, left: 12, bottom: 10),
              itemBuilder: (context, index) {
                TripsDrivers ventana = driversList[index];
                String nameConductor = ventana.driverFullname!;
                int idConductor = ventana.driverId!;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (nameConductor != 'Ninguno') {
                        driver = nameConductor;
                        prefs.driverIdx = idConductor.toString();
                        radioShowAndHide = true;
                        seleccionarMotorista = false;
                      } else {
                        radioShowAndHide = false;
                        seleccionarMotorista = false;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      nameConductor,
                      textAlign: TextAlign.start,
                      style: Theme.of(navigatorKey.currentContext!)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearDropdown(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        if(seleccionarCompany==true)
         Padding(
          padding: const EdgeInsets.only(top:40.0),
          child: menuCompany(context, size),
        ),
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1
              )
            ),
            child: Padding(
              padding: const EdgeInsets.only(left:20.0, right: 10),
              child: Row(
                children: [
                  SvgPicture.asset(  
                    "assets/icons/compania.svg",
                    color: Theme.of(context).primaryIconTheme.color,
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 5),
                  if(prefs.companyPrueba!='')...{
                    Expanded(
                      child: Text(
                        prefs.companyPrueba,
                        style:  Theme.of(navigatorKey.currentContext!).textTheme.titleMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                      ),
                    ),
                  }else...{
                    Expanded(
                      child: Text(
                        'Seleccione una compañía',
                        style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                        ),
                      ),
                    ),
                  },
        
                  SvgPicture.asset(  
                    "assets/icons/flecha_hacia_abajo.svg",
                    color: Theme.of(context).primaryIconTheme.color,
                    width: 50,
                    height: 50,
                  ),
                ],
              )
            ),
          ),
          onTap: () {
            setState(() {
              seleccionarCompany = !seleccionarCompany;
            });
          },
        ),
      ],
    );
  }

  Widget menuCompany(contextP, size) {

    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.asMap().entries.map((entry) {
                dynamic ventana = entry.value;
                String nameCompany = ventana['companyName'];
                int idCompany = ventana['companyId'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      seleccionarCompany = false;
                      prefs.companyId = idCompany.toString();
                      prefs.companyPrueba = nameCompany;

                      if (prefs.companyId != prefs.companyIdAgent) {
                        if (handleerrror == 'khe') {
                          this.handler!.cleanTable();
                          this.handler!.cleanTableAgent();
                        }
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      nameCompany,
                      textAlign: TextAlign.start,
                      style: Theme.of(navigatorKey.currentContext!)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _crearDropdownToDestination(BuildContext context) {
    final String destination1 = "Gasolinera";
    final String destination2 = "Emisoras";

    return Container(margin: EdgeInsets.symmetric(horizontal: 40.0),
    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2),spreadRadius: 0,blurStyle: BlurStyle.solid,blurRadius: 10,offset: Offset(0, 0),),
          BoxShadow(color: Colors.white.withOpacity(0.1),spreadRadius: 0,blurRadius: 5,blurStyle: BlurStyle.inner,offset: Offset(0, 0), ),
        ],
      
      ),
      child: Row(
        
        children: [
          Padding(padding: const EdgeInsets.all(8.0),child: Icon(Icons.location_city,color: thirdColor,size: 30.0,),),  
          SizedBox(width: 20.0),
          Expanded(
            child: new DropdownButton(underline: SizedBox(),style: TextStyle(color: Colors.white),dropdownColor: backgroundColor2,elevation: 20,
              hint: Text(prefs.destinationPrueba,style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal,fontSize: 15.0)),
            items: data2.map((e) {
              return new DropdownMenuItem(
                child: Text(
                    e['destinationName'] == null || e['destinationName'] == ""
                        ? prefs.destinationPrueba
                        : e['destinationName']),
                value: e['destinationId'].toString(),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                destinationId = val;
                prefs.destinationId = destinationId!;
                if (prefs.destinationId == "9") {
                  prefs.destinationPrueba = destination1;
                } else if (prefs.destinationId == "10") {
                  prefs.destinationPrueba = destination2;
                }
                if (prefs.destinationId != prefs.destinationIdAgent) {
                  this.handler!.cleanTableAgent();
                }
              });
            },
            value: destinationId,
          )),
        
        ],
      ),
    );
  }

  Widget _mostrarCuartaVentana() {
    return HistoryTripDriver();
  }

  Widget _mostrarQuintaVentana(BuildContext context) {
    return Column(
      children: [
        Text('Compañía',style: TextStyle(color: GradiantV_2,fontWeight: FontWeight.normal,fontSize: 35.0)),
        SizedBox(height: 20.0),
        _crearDropdown(context),
        SizedBox(height: 10.0),
        Text('Destino',style: TextStyle(color: GradiantV_2,fontWeight: FontWeight.normal,fontSize: 35.0)),
        SizedBox(height: 5.0),
        _crearDropdownToDestination(context),
        FutureBuilder<DriverData?>(
            future: itemx!,
            builder: (BuildContext context, abc) {
              switch (abc.connectionState) {
                case ConnectionState.waiting:
                  return Text('Cargando....');
                default:
                  if (abc.hasError) {
                    return Text('Error: ${abc.error}');
                  } else {
                    return Column(
                      children: [
                        if (abc.data?.driverCoord == true) showAndHide()
                      ],
                    );
                  }
              }
            }),
        Container(width: 320,
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2),spreadRadius: 0,blurStyle: BlurStyle.solid,blurRadius: 10,offset: Offset(0, 0), ),
              BoxShadow(color: Colors.white.withOpacity(0.1),spreadRadius: 0,blurRadius: 5,blurStyle: BlurStyle.inner,offset: Offset(0, 0), ),
            ],
          ),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(cursorColor: firstColor,style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {                    
                  prefs.vehiculo = value;
                });
              },
              controller: nameController,
              decoration: InputDecoration(icon: Icon(Icons.directions_bus,color: thirdColor, size: 30.0),border: InputBorder.none,                  
              hintText: prefs.vehiculoSolid == ""? "Vehículo": prefs.vehiculoSolid,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15.0)
              )),
          ),
        ),
        SizedBox(height: 20.0),
        Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 75,
              child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: GradiantV_2,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),),
                child: Icon(Icons.delete,color: backgroundColor, size: 25.0),
                onPressed: () {
                  setState(() {
                    this.handler!.cleanTableAgentSolid();
                  });
                }),
            ),
            SizedBox(width: 5.0),
            Container(width: 75,
              child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: GradiantV2,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),),
                child:Icon(Icons.search, color: backgroundColor, size: 25.0),
                  onPressed: () {
                      showGeneralDialog(
                          barrierColor: Colors.black.withOpacity(0.5),
                          transitionBuilder: (context, a1, a2, widget) {
                            return Transform.scale(scale: a1.value,
                              child: Opacity(opacity: a1.value,
                                child: AlertDialog(backgroundColor: backgroundColor,shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                                  title: Center(
                                    child: Text('Buscar Agente',style: TextStyle(color: GradiantV_2, fontSize: 20.0),)),
                                    content: Container(decoration: BoxDecoration(borderRadius:BorderRadius.all(Radius.circular(15)),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.2),spreadRadius: 0,blurStyle: BlurStyle.solid,blurRadius: 10,offset: Offset(0,0),),
                                        BoxShadow(color: Colors.white.withOpacity(0.1),spreadRadius: 0,blurRadius: 5,blurStyle: BlurStyle.inner,offset: Offset(0,0), ),
                                      ],
                                    ),
                                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: TextField(style: TextStyle(color: Colors.white),controller: agentEmployeeId,
                                        decoration: InputDecoration(border: InputBorder.none,labelText: 'Escriba aqui',labelStyle: TextStyle(color: Colors.white.withOpacity(0.5),fontSize: 15.0)),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Row(mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(width: 100,
                                          child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0),),textStyle: TextStyle(color: backgroundColor,),backgroundColor: Gradiant2,),
                                            onPressed: () => {
                                              fetchSearchAgentsSolid(agentEmployeeId.text),
                                              Navigator.pop(context)
                                            },
                                            child: Text('Buscar',style: TextStyle(color: backgroundColor,fontSize: 15.0)),
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Container(width: 100,
                                          child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0),),textStyle: TextStyle(color: Colors.white,),backgroundColor: Colors.red,),
                                            onPressed: () => {
                                              Navigator.pop(context),
                                            },
                                            child: Text('Cerrar',style: TextStyle(color: Colors.white,fontSize: 15.0)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        transitionDuration: Duration(milliseconds: 200),barrierDismissible: true,barrierLabel: '',context: context,pageBuilder: (context, animation1, animation2) {return Text('');});
                    },
                  ),
                ),
            SizedBox(width: 8.0),
            Container(width: 75,
              child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),backgroundColor: firstColor),
                child: Icon(Icons.qr_code,color: backgroundColor, size: 25.0),onPressed: scanBarcodeNormalSolid),
            ) 
          ],
        ),
        SizedBox(height: 6.0),
        FutureBuilder(
          future: this.handler!.retrieveAgentSolid(),
          builder: (BuildContext context, AsyncSnapshot<List<User?>> snapshot) {
            if (snapshot.hasData) {
              noemp.add("${snapshot.data?.length}");
              return Text("Total de agentes: ${snapshot.data?.length}",style: TextStyle(color: Colors.white,fontSize: 15.0,fontWeight: FontWeight.bold));
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        SizedBox(height: 6.0),
        FutureBuilder(
            future: this.handler!.retrieveAgentSolid(),
            builder: (BuildContext context, AsyncSnapshot<List<User?>> snapshot) {
              if (snapshot.hasData) {
                return Padding(padding: const EdgeInsets.all(15.0),
                  child: Container(
                    child: Column(
                      children: [
                        for (var i = 0; i < snapshot.data!.length; i++) ...{
                          Container(decoration: BoxDecoration(boxShadow: [
                            BoxShadow(blurStyle: BlurStyle.normal,color: Colors.white.withOpacity(0.2),blurRadius: 15,spreadRadius: -30,offset: Offset(-25, -25)),
                            BoxShadow(blurStyle: BlurStyle.normal,color: Colors.black.withOpacity(0.6),blurRadius: 30,spreadRadius: -45,offset: Offset(20, -15)),
                            ]),                            
                            child: Card(elevation: 20,color: backgroundColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),margin: EdgeInsets.all(4.0),
                              child: Column(
                                children: <Widget>[
                                  Container(margin: EdgeInsets.only(left: 15),
                                    child: Column(
                                      children: [
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.confirmation_number,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(child: Text('# No empleado: ${snapshot.data![i]!.noempid}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                ],
                                                ),
                                              ),                       
                                            ],
                                          ),
                                          Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.account_box_sharp,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(child: Text('Nombre: ${snapshot.data![i]!.nameuser}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                ],
                                                ),
                                              ),                       
                                            ],
                                          ),
                                          Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.access_alarms,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(child: Text('Hora salida: ${snapshot.data![i]!.hourout}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                ],
                                                ),
                                              ),                       
                                            ],
                                          ),
                                          Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(14,20,20,0),
                                              child: Row(
                                                children: [
                                                  Padding(padding: const EdgeInsets.only(bottom: 18),child: Icon(Icons.location_pin,color: thirdColor)),
                                                  SizedBox(width: 15,),
                                                  Flexible(child: Text('Dirección: ${snapshot.data![i]!.direction}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                ],
                                                ),
                                              ),                       
                                            ],
                                          ),  
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(boxShadow: [
                                          BoxShadow(blurStyle: BlurStyle.normal,color:Colors.white.withOpacity(0.2),blurRadius: 10,spreadRadius: -8,offset: Offset(-10, -6)),
                                          BoxShadow(blurStyle: BlurStyle.normal,color:Colors.black.withOpacity(0.6),blurRadius: 10,spreadRadius: -15,offset: Offset(18, 5)),
                                        ]),
                                      width: 150,
                                      child: ElevatedButton(style: ElevatedButton.styleFrom(textStyle: TextStyle(color: Colors.white,),backgroundColor: backgroundColor,shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0)),),
                                      onPressed: () async {
                                        final Database db = await handler!.initializeDB();
                                          await this.handler!.deleteAgentSolid(snapshot.data![i]!.idsend);
                                          await db.rawQuery("DELETE FROM agentInsertSolid WHERE nameuser = '${snapshot.data![i]!.nameuser}'");
                                            setState(() {
                                              snapshot.data!.remove(snapshot.data![i]);
                                            });
                                          },
                                          child: Text('Quitar',style: TextStyle(color: Colors.white)),),
                                    ),
                                    SizedBox(height: 10.0),
                                ],
                              ),
                            ),
                          ),
                        },
                        Center(
                          child: Column(
                            children: [                             
                              Container(decoration: BoxDecoration(boxShadow: [
                                BoxShadow(blurStyle: BlurStyle.normal,color: Colors.white.withOpacity(0.2),blurRadius: 15,spreadRadius: -30,offset: Offset(-25, -25)),
                                BoxShadow(blurStyle: BlurStyle.normal,color: Colors.black.withOpacity(0.6),blurRadius: 30,spreadRadius: -45,offset: Offset(20, -15)),
                                ]),
                              child: ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10.0)),
                                backgroundColor: thirdColor,padding: EdgeInsets.symmetric(vertical: 5, horizontal: 22)),
                                  child: Icon(Icons.save),
                                    onPressed: () async {
                                      showGeneralDialog(context: context,
                                        transitionBuilder: (context, a1, a2, widget) {
                                          return Center(child: ColorLoader3());
                                        },
                                        transitionDuration:Duration(milliseconds: 200),
                                        barrierDismissible: false,
                                        barrierLabel: '',
                                        pageBuilder: (context, animation1, animation2) {
                                          return Text('');
                                        });      
                                        await fetchAgentsLeftPastToProgresToSolid();
                                        setState(() {
                                          this.handler!.cleanTableAgentSolid();
                                        });
                                }),
                              ),                              
                            ],
                          ),
                        ),                        
                      ],
                    ),
                  ),
                );
              } else if (names.length == 0) {
                return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),margin: EdgeInsets.symmetric(vertical: 25),
                  child: Container(color: backgroundColor,
                    child: Column(mainAxisSize: MainAxisSize.max,crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ListTile(leading: Icon(Icons.bus_alert,color: thirdColor,),
                          title: Text('Agentes',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal,fontSize: 26.0)),
                          subtitle: Text('No hay agentes en el viaje',style: TextStyle(color: Colors.red,fontWeight: FontWeight.normal,fontSize: 18.0)),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            })
      ],
    );
  }
}

class User {  
  final String? noempid;
  final String? nameuser;
  final String? hourout;
  final String? direction;
  final int? idsend;
  User({this.noempid,this.nameuser,this.hourout,this.direction,this.idsend,});
  User.fromMap(Map<String, dynamic> res):noempid = res["noempid"],nameuser = res["nameuser"],hourout = res["hourout"],direction = res["direction"],idsend = res["idsend"];
  Map<String, Object> toMap() {return {'noempid': noempid!, 'nameuser': nameuser!, 'hourout': hourout!,'direction': direction!, 'idsend': idsend!,};}
}
