//import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
//import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/asignar_Horas.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/confirm_trips.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/databases.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/history_TripDriver.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/process_Trip.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/company.dart';
import 'package:flutter_auth/Drivers/models/findAgentSolid.dart';
import 'package:flutter_auth/Drivers/models/leftTrip.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/search.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/tripToSolid.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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
  String? companyId;
  String? destinationId;
  String? destinationPrueba;
  dynamic driver;
  List data = [];
  List data2 = [];
  final prefs = new PreferenciasUsuario();

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
  TextEditingController vehicule = new TextEditingController();
  TextEditingController hourOut = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.fetchCompanys();
    this.fetchDestinations();
    itemx = fetchRefres();
    itemx!.then((value) => print(value.driverCoord) );
    fetchDriversDriver();
    vehicule = new TextEditingController(text: prefs.vehiculo);
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
    http.Response response = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
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
      return countries;
    } else {
      print("error from server : $response");
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
  }

// ignore: missing_return
  Future<Salida?> fetchAgentsLeftPastToProgres( String hourOut, String nameController) async {
    http.Response responses = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final si = DriverData.fromJson(json.decode(responses.body));
    final Database db = await handler!.initializeDB();
    final tables = await db.rawQuery('SELECT * FROM userX ;');
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
          'tripHour': hourOut,
          'driverId': radioShowAndHide == false
              ? si.driverId.toString()
              : prefs.driverIdx,
          'tripVehicle': prefs.vehiculo,
        };
        http.Response response1 = await http
            .post(Uri.parse('$ip/apis/registerDeparture2'), body: datas);
        final send = Salida.fromJson(json.decode(response1.body));
        prefs.tripId = send.tripId!.tripId.toString();
        for (var i = 0; i < tables.length; i++) {
          Map datas2 = {
            "agentId": tables[i]['idsend'].toString(),
            "tripId": send.tripId!.tripId.toString(),
            "tripHour": send.tripId!.tripHour
          };

          await http.post(Uri.parse('$ip/apis/registerAgentForOutTrip'),
              body: datas2);
        }
        if (response1.statusCode == 200) {
          await http.get(Uri.parse('$ip/apis/agentsInTravel/${prefs.tripId}'));

          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyConfirmAgent(),
              ));
          prefs.removeIdCompanyAndVehicle();
          QuickAlert.show(
            context: context,
            title: send.title,
            text: send.message,
            type: QuickAlertType.success,
          ); 
          this.handler!.cleanTable();
        } else {
          throw Exception('Failed to load Data');
        }
      } else {
        Map datas = {
          'companyId': prefs.companyId,
          'driverId': si.driverId.toString(),
          'tripVehicle': nameController,
        };
        http.Response response1 = await http
            .post(Uri.parse('$ip/apis/registerDeparture2'), body: datas);
        final send = Salida.fromJson(json.decode(response1.body));
        prefs.tripId = send.tripId!.tripId.toString();

        for (var i = 0; i < tables.length; i++) {
          Map datas2 = {
            "agentId": tables[i]['idsend'].toString(),
            "tripId": send.tripId!.tripId.toString(),
            "tripHour": send.tripId!.tripHour
          };

          await http.post(Uri.parse('$ip/apis/registerAgentForOutTrip'),
              body: datas2);
        }

        if (response1.statusCode == 200) {
          await http.get(Uri.parse('$ip/apis/agentsInTravel/${prefs.tripId}'));

          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyConfirmAgent(),
              ));
          prefs.removeIdCompanyAndVehicle();
          QuickAlert.show(
            context: context,
            title: send.title,
            text: send.message,
            type: QuickAlertType.success,
          ); 

          this.handler!.cleanTable();
        } else {
          throw Exception('Failed to load Data');
        }
      }
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
    if (responsed.statusCode == 200 &&
        data1.ok == true &&
        data1.agent!.msg != null) {
      if (barcodeScan == '${-1}') {
        print('');
      } else {
        QuickAlert.show(
          context: context,
          title: '??No encontrado!',
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
                          child: Text(
                            '??Agregar agente al viaje?',
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
                          title: Text('Direcci??n: ',
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
                                    if (prefs.nameSalida != tables2) {
                                      noemp.insert(
                                          0, '${data1.agent!.agentEmployeeId}');
                                      names.insert(
                                          0, '${data1.agent!.agentFullname}');
                                      hourout.insert(
                                          0, '${data1.agent!.hourOut}');
                                      direction.insert(0,
                                          '${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}');
                                      tempArr.add(data1.agent!.agentId);
                                      prefs.companyIdAgent =
                                          data1.agent!.companyId.toString();
                                      prefs.nameSalida = data1
                                          .agent!.agentEmployeeId
                                          .toString();
                                      User firstUser = User(
                                          noempid:
                                              '${data1.agent!.agentEmployeeId}',
                                          nameuser:
                                              '${data1.agent!.agentFullname}',
                                          hourout: '${data1.agent!.hourOut}',
                                          direction:
                                              '${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}',
                                          idsend: data1.agent!.agentId);
                                      List<User> listOfUsers = [firstUser];
                                      this.handler!.insertUser(listOfUsers);

                                      //guardar();

                                    } else {
                                      print('yasta we');
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                        context: context,
                                        title: "??Advertencia!",
                                        text: " El agente con n??mero de empleado \n '${data1.agent!.agentEmployeeId}' ya est?? agregado al viaje",
                                        type: QuickAlertType.error,
                                      );                                    
                                    }
                                  } else if (tables.length > 13) {
                                    print('yasta we');
                                    Navigator.pop(context);
                                    QuickAlert.show(
                                        context: context,
                                        title: "??Advertencia!",
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

    final tables = await db.rawQuery('SELECT * FROM agentInsert ;');
    final tables2 = await db.rawQuery(
        "SELECT noempid FROM agentInsert WHERE noempid = '${prefs.nameSalida}'");
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
          title: '??No encontrado!',
          text: 'No se encontr?? el agente con n??mero de empleado \n $agentEmployeeId',
          type: QuickAlertType.error,
        );
      } else if (data1.type == "success") {
        print(data1.type);
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
                            '??Agregar agente al viaje?',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 15),
                          ListTile(
                            contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            title: Text('No empleado: '),
                            subtitle: Text('${data1.agent!.agentEmployeeId}'),
                            leading:
                                Icon(Icons.card_travel, color: kColorAppBar),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            title: Text('Nombre: '),
                            subtitle: Text('${data1.agent!.agentFullname}'),
                            leading: Icon(Icons.contact_page_outlined,
                                color: kColorAppBar),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            title: Text('Hora: '),
                            subtitle: Text('${data1.agent!.hourAgent}'),
                            leading:
                                Icon(Icons.access_time, color: kColorAppBar),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            title: Text('Direcci??n: '),
                            subtitle: Text(
                                '${data1.agent!.neighborhoodName} ${data1.agent!.agentReferencePoint}\n${data1.agent!.departmentName} '),
                            leading:
                                Icon(Icons.directions, color: kColorAppBar),
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
                                      if (prefs.nameSalida != tables2) {
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
                                        this.handler!.insertAgent(listOfUsers);
                                        clearText();
                                        //guardar();

                                      } else {
                                        print('yasta we');
                                        Navigator.pop(context);
                                        QuickAlert.show(
                                          context: context,
                                          title: "??Advertencia!",
                                          text: " El agente con n??mero de empleado \n '${data1.agent!.agentEmployeeId}' ya est?? agregado al viaje",
                                          type: QuickAlertType.error,
                                        );
                                      }
                                    } else if (tables.length > 13) {
                                      print('yasta we');
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                        context: context,
                                        title: "??Advertencia!",
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
    if (responsed.statusCode == 200 &&
        data1.ok == true &&
        data1.agent!.msg != null) {
      print(data1.agent!.msg);
      print('Este es el agentId' + data1.agent!.agentId.toString());
      if (data1.agent!.agentId != null) {
        QuickAlert.show(
          context: context,
          title: '??No encontrado!',
          text: data1.agent!.msg,
          type: QuickAlertType.error,
        );
      }
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
                            '??Agregar agente al viaje?',
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
                          title: Text('Direcci??n: ',
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
                                      if (prefs.nameSalida != tables2) {
                                        noemp.insert(0,
                                            '${data1.agent!.agentEmployeeId}');
                                        names.insert(
                                            0, '${data1.agent!.agentFullname}');
                                        hourout.insert(
                                            0, '${data1.agent!.hourOut}');
                                        direction.insert(0,
                                            '${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}');
                                        tempArr.add(data1.agent!.agentId);
                                        prefs.companyIdAgent =
                                            data1.agent!.companyId.toString();
                                        prefs.nameSalida = data1
                                            .agent!.agentEmployeeId
                                            .toString();
                                        User firstUser = User(
                                            noempid:
                                                '${data1.agent!.agentEmployeeId}',
                                            nameuser:
                                                '${data1.agent!.agentFullname}',
                                            hourout: '${data1.agent!.hourOut}',
                                            direction:
                                                '${data1.agent!.departmentName} ${data1.agent!.neighborhoodName}\n${data1.agent!.agentReferencePoint}',
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
                                          title: "??Advertencia!",
                                          text: " El agente con n??mero de empleado \n '${data1.agent!.agentEmployeeId}' ya est?? agregado al viaje",
                                          type: QuickAlertType.error,
                                        );
                                      }
                                    } else if (tables.length > 13) {
                                      print('yasta we');
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                        context: context,
                                        title: "??Advertencia!",
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
  Future<FindAgentSolid?> fetchSearchAgentsSolid(String agentEmployeeId) async {
    Map data = {
      "companyId": prefs.companyId,
      "agentEmployeeId": agentEmployeeId,
      "destinationId": prefs.destinationId,
    };
    if (agentEmployeeId != "" && prefs.destinationId != null) {
      final Database db = await handler!.initializeDB();

      final tables = await db.rawQuery('SELECT * FROM agentInsert ;');
      final tables2 = await db.rawQuery(
          "SELECT noempid FROM agentInsert WHERE noempid = '${prefs.nameSalida}'");
      http.Response responsed = await http
          .post(Uri.parse('$ip/apis/getAgentForEntryTrip'), body: data);

      final data1 = FindAgentSolid.fromJson(json.decode(responsed.body));
      if (responsed.statusCode == 200) {
        if (data1.type == "error") {
          QuickAlert.show(
            context: context,
            title: '??No encontrado!',
            text: 'No se encontr?? el agente con n??mero de empleado \n $agentEmployeeId',
            type: QuickAlertType.error,
          );    
        } else if (data1.type == "success") {
          print(data1);
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
                              '??Agregar agente al viaje?',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 15),
                            ListTile(
                              contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              title: Text('No empleado: '),
                              subtitle: Text('${data1.agent!.agentEmployeeId}'),
                              leading:
                                  Icon(Icons.card_travel, color: kColorAppBar),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              title: Text('Nombre: '),
                              subtitle: Text('${data1.agent!.agentFullname}'),
                              leading: Icon(Icons.contact_page_outlined,
                                  color: kColorAppBar),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              title: Text('Hora: '),
                              subtitle: Text('${data1.agent!.hourAgent}'),
                              leading:
                                  Icon(Icons.access_time, color: kColorAppBar),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                              title: Text('Direcci??n: '),
                              subtitle: Text(
                                  '${data1.agent!.neighborhoodName} ${data1.agent!.agentReferencePoint}\n${data1.agent!.departmentName} '),
                              leading:
                                  Icon(Icons.directions, color: kColorAppBar),
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
                                        if (prefs.nameSalida != tables2) {
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
                                          this.handler!.insertAgent(listOfUsers);
                                          clearText();
                                          //guardar();

                                        } else {
                                          print('yasta we');
                                          Navigator.pop(context);
                                          QuickAlert.show(
                                            context: context,
                                            title: "??Advertencia!",
                                            text: " El agente con n??mero de empleado \n '${data1.agent!.agentEmployeeId}' ya est?? agregado al viaje",
                                            type: QuickAlertType.error,
                                          ); 
                                        }
                                      } else if (tables.length > 13) {
                                        print('yasta we');
                                        Navigator.pop(context);
                                        QuickAlert.show(
                                          context: context,
                                          title: "??Advertencia!",
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
      return FindAgentSolid.fromJson(json.decode(responsed.body));
    }
  }

  // ignore: missing_return
  Future<TripsToSolid?> fetchAgentsLeftPastToProgresToSolid() async {
    http.Response responses = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final si = DriverData.fromJson(json.decode(responses.body));
    final Database db = await handler!.initializeDB();
    final tables = await db.rawQuery('SELECT * FROM agentInsert ;');
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
        http.Response response1 = await http
            .post(Uri.parse('$ip/apis/registerTripEntryByDriver'), body: datas);
        final send = TripsToSolid.fromJson(json.decode(response1.body));
        prefs.tripId = send.trip!.tripId.toString();
        for (var i = 0; i < tables.length; i++) {
          Map datas2 = {
            "agentId": tables[i]['idsend'].toString(),
            "tripId": send.trip!.tripId.toString(),
            "tripHour": send.trip!.tripHour
          };

          if (response1.statusCode == 200) {
            final sendDatas = await http.post(
                Uri.parse('$ip/apis/registerAgentTripEntryByDriver'),
                body: datas2);
            print(sendDatas.body);
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyConfirmAgent(),
                ));
            prefs.removeIdCompanyAndVehicle();
            QuickAlert.show(
              context: context,
              title: '????xito!',
              text: 'El viaje se ha registrado correctamente',
              type: QuickAlertType.success,
            );  
            this.handler!.cleanTableAgent();
          } else {
            throw Exception('Failed to load Data');
          }
        }
      } else {
        Map datas = {
          'companyId': prefs.companyId,
          'driverId': si.driverId.toString(),
          'destinationId': prefs.destinationId,
          'tripVehicle': prefs.vehiculoSolid,
        };
        print(datas);
        http.Response response1 = await http
            .post(Uri.parse('$ip/apis/registerTripEntryByDriver'), body: datas);
        print(response1.body);
        final send = TripsToSolid.fromJson(json.decode(response1.body));
        prefs.tripId = send.trip!.tripId.toString();
        if (response1.statusCode == 200) {
          for (var i = 0; i < tables.length; i++) {
            Map datas2 = {
              "agentId": tables[i]['idsend'].toString(),
              "tripId": send.trip!.tripId.toString(),
              "tripHour": send.trip!.tripHour.toString()
            };

            await http.post(
                Uri.parse('$ip/apis/registerAgentTripEntryByDriver'),
                body: datas2);
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyConfirmAgent(),
                ));
            prefs.removeIdCompanyAndVehicle();
            QuickAlert.show(
              context: context,
              title: '????xito!',
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
          //aqu?? llamo el procedimiento que contiene el orden las dem??s p??ginas
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
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Compa????a',
            style: TextStyle(
                color: GradiantV_2,
                fontWeight: FontWeight.normal,
                fontSize: 35.0)),
        SizedBox(height: 20.0),
        _crearDropdown(context),
        SizedBox(height: 20.0),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0,
                blurStyle: BlurStyle.solid,
                blurRadius: 10,
                offset: Offset(0, 0), // changes position of shadow
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 5,
                blurStyle: BlurStyle.inner,
                offset: Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          width: 320,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
                cursorColor: firstColor,
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  prefs.vehiculo = value;
                },
                controller: nameController,
                decoration: InputDecoration(
                  icon: Icon(Icons.directions_bus,
                      color: thirdColor, size: 30.0),
                  border: InputBorder.none,
                  hintText:
                      prefs.vehiculo == "" ? "Veh??culo" : prefs.vehiculo,
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 15.0),
                )),
          ),
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
                    return Column(
                      children: [
                        if (abc.data?.driverCoord == true) showAndHide()
                      ],
                    );
                  }
              }
            }),
        SizedBox(height: 20.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 75,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GradiantV_2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Icon(Icons.delete,
                      color: backgroundColor, size: 25.0),
                  onPressed: () {
                    setState(() {
                      this.handler!.cleanTable();
                    });
                  }),
            ),
            SizedBox(width: 8.0),
            Container(
              width: 75,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GradiantV2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child:
                    Icon(Icons.search, color: backgroundColor, size: 25.0),
                onPressed: () {
                  showGeneralDialog(
                      barrierColor: Colors.black.withOpacity(0.5),
                      transitionBuilder: (context, a1, a2, widget) {
                        return Transform.scale(
                          scale: a1.value,
                          child: Opacity(
                            opacity: a1.value,
                            child: AlertDialog(
                              backgroundColor: backgroundColor,
                              shape: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(16.0)),
                              title: Center(
                                  child: Text(
                                'Buscar Agente',
                                style: TextStyle(
                                    color: GradiantV_2, fontSize: 20.0),
                              )),
                              content: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 0,
                                      blurStyle: BlurStyle.solid,
                                      blurRadius: 10,
                                      offset: Offset(0,
                                          0), // changes position of shadow
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 5,
                                      blurStyle: BlurStyle.inner,
                                      offset: Offset(0,
                                          0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: TextField(
                                    style: TextStyle(color: Colors.white),
                                    controller: agentEmployeeId,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Escriba aqui',
                                        labelStyle: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.5),
                                            fontSize: 15.0)),
                                  ),
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          textStyle: TextStyle(
                                            color: backgroundColor,
                                          ),
                                          backgroundColor: Gradiant2,
                                        ),
                                        onPressed: () => {
                                          fetchSearchAgents2(
                                              agentEmployeeId.text),
                                          Navigator.pop(context)
                                        },
                                        child: Text('Buscar',
                                            style: TextStyle(
                                                color: backgroundColor,
                                                fontSize: 15.0)),
                                      ),
                                    ),
                                    SizedBox(width: 10.0),
                                    Container(
                                      width: 100,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () => {
                                          Navigator.pop(context),
                                        },
                                        child: Text('Cerrar',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0)),
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
            Container(
              width: 75,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      backgroundColor: firstColor),
                  child: Icon(Icons.qr_code,
                      color: backgroundColor, size: 25.0),
                  onPressed: scanBarcodeNormal),
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
              return Text("Total de agentes: ${snapshot.data?.length}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold));
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
                              BoxShadow(
                                  blurStyle: BlurStyle.normal,
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: -30,
                                  offset: Offset(-25, -25)),
                              BoxShadow(
                                  blurStyle: BlurStyle.normal,
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 30,
                                  spreadRadius: -45,
                                  offset: Offset(20, -15)),
                            ]),
                            child: Card(
                              elevation: 20,
                              color: backgroundColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.all(4.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 15),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(
                                                  5, 5, 10, 0),
                                          title: Text('# No empleado: ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.white)),
                                          subtitle: Text(
                                              '${snapshot.data![i]!.noempid}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                          leading: Icon(
                                              Icons.confirmation_number,
                                              color: thirdColor,
                                              size: 40.0),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(
                                                  5, 5, 10, 0),
                                          title: Text('Nombre:',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.white)),
                                          subtitle: Text(
                                              '${snapshot.data![i]!.nameuser}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                          leading: Icon(
                                              Icons.account_box_sharp,
                                              color: thirdColor,
                                              size: 40.0),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(
                                                  5, 5, 10, 0),
                                          title: Text('Hora salida: ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.white)),
                                          subtitle: Text(
                                              '${snapshot.data![i]!.hourout}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                          leading: Icon(Icons.access_alarms,
                                              color: thirdColor,
                                              size: 40.0),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(
                                                  5, 5, 10, 0),
                                          title: Text('Direcci??n: ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.white)),
                                          subtitle: Text(
                                              '${snapshot.data![i]!.direction}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                          leading: Icon(Icons.location_pin,
                                              color: thirdColor,
                                              size: 40.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          blurStyle: BlurStyle.normal,
                                          color:
                                              Colors.white.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: -8,
                                          offset: Offset(-10, -6)),
                                      BoxShadow(
                                          blurStyle: BlurStyle.normal,
                                          color:
                                              Colors.black.withOpacity(0.6),
                                          blurRadius: 10,
                                          spreadRadius: -15,
                                          offset: Offset(18, 5)),
                                    ]),
                                    width: 150,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        backgroundColor: backgroundColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20.0)),
                                      ),
                                      onPressed: () async {
                                        final Database db =
                                            await handler!.initializeDB();
                                        await this.handler!.deleteUser(
                                            snapshot.data![i]!.idsend!);
                                        await db.rawQuery(
                                            "DELETE FROM userX WHERE nameuser = '${snapshot.data![i]!.nameuser}'");
                                        QuickAlert.show(
                                          context: context,
                                          title: "??Desea eliminar el Agente?",
                                          confirmBtnText: "Si",
                                          cancelBtnText: "Cancelar",
                                          showCancelBtn: true,  
                                          confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                          cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                            QuickAlert.show(
                                              context: context,
                                              title: "Eliminado",
                                              type: QuickAlertType.success,
                                            );
                                            setState(() {
                                              snapshot.data
                                                  !.remove(snapshot.data![i]);
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
                                      child: Text('Quitar',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
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
                                  BoxShadow(
                                      blurStyle: BlurStyle.normal,
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: -30,
                                      offset: Offset(-25, -25)),
                                  BoxShadow(
                                      blurStyle: BlurStyle.normal,
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 30,
                                      spreadRadius: -45,
                                      offset: Offset(20, -15)),
                                ]),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10.0)),
                                        backgroundColor: thirdColor,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 22)),
                                    child: Icon(Icons.save,
                                        color: backgroundColor, size: 25.0),
                                    onPressed: () async {
                                      showGeneralDialog(
                                          context: context,
                                          transitionBuilder:
                                              (context, a1, a2, widget) {
                                            return Center(
                                                child: ColorLoader3());
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 200),
                                          barrierDismissible: false,
                                          barrierLabel: '',
                                          pageBuilder: (context, animation1,
                                              animation2) {
                                            return Text('');
                                          });

                                      await fetchAgentsLeftPastToProgres(
                                          hourOut.text, vehicule.text);

                                      setState(() {
                                        this.handler!.cleanTable();
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50,)
                      ],
                    ),
                  ),
                );
              } else if (names.length == 0) {
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.symmetric(vertical: 25),
                  child: Container(
                    color: backgroundColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.bus_alert,
                            color: thirdColor,
                          ),
                          title: Text('Agentes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 26.0)),
                          subtitle: Text('No hay agentes en el viaje',
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
                return Center(child: CircularProgressIndicator());
              }
            })
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
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: Gradiant2,
                    padding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 40)),
                child: Text(
                    radioShowAndHide == false
                        ? 'Presione aqu?? para asignar conductor'
                        : 'Presione aqu?? si usted realizar?? el viaje',
                    style: TextStyle(color: backgroundColor)),
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
          Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: radioShowAndHide,
              child: getSearchableDropdown(context)),
        ],
      ),
    );
  }

  Widget getSearchableDropdown(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurStyle: BlurStyle.solid,
            blurRadius: 10,
            offset: Offset(0, 0), // changes position of shadow
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 5,
            blurStyle: BlurStyle.inner,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: DropdownSearch<TripsDrivers>(
                  mode: Mode.DIALOG,
                  showClearButton :false,
                  items: driverId ,
                  itemAsString: (TripsDrivers? u) => u!.driverFullname!,                  
                  onChanged: (value){                                        
                    setState(() {
                      driver = value!.driverId.toString();
                      prefs.driverIdx = driver.toString();
                      print(prefs.driverIdx);
                    });
                  },
                  showSearchBox: true,
                  filterFn: (instance, filter){
                    if(instance!.driverFullname!.contains(filter!)){
                      print(filter);
                      return true;
                    }else if(instance.driverFullname!.toLowerCase().contains(filter)){
                      print(filter);
                      return true;
                    }
                    else{
                      return false;
                    }
                  },
                  popupItemBuilder: (context,TripsDrivers item,bool isSelected){
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: !isSelected
                          ? null
                          : BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item.driverFullname!),
                      ),
                    );
                  },
                 ),
      // SearchableDropdown(
      //   closeButton: (selectedItem) {
      //     return (selectedItem == null || selectedItem.length == 0)
      //         ? "Cancelar"
      //         : "Aceptar";
      //   },
      //   menuBackgroundColor: backgroundColor,
      //   icon: Icon(Icons.person,
      //       color: thirdColor, size: 30.0, semanticLabel: 'Conductor'),
      //   items: driverId.map((item) {
      //     return new DropdownMenuItem(
      //         child: Text(item['driverFullname'],
      //             style: TextStyle(
      //                 color: Colors.white,
      //                 fontWeight: FontWeight.normal,
      //                 fontSize: 18.0)),
      //         value: item['driverId'].toString());
      //   }).toList(),
      //   isExpanded: true,
      //   value: driver,
      //   searchFn: (String keyword, items) {
      //     List<int> ret = [];
      //     if (items != null && keyword.isNotEmpty) {
      //       keyword.split(" ").forEach((k) {
      //         int i = 0;
      //         driverId.forEach((item) {
      //           if (k.isNotEmpty &&
      //               (item['driverFullname']
      //                   .toString()
      //                   .toLowerCase()
      //                   .contains(k.toLowerCase()))) {
      //             ret.add(i);
      //           }
      //           i++;
      //         });
      //       });
      //     }
      //     if (keyword.isEmpty) {
      //       ret = Iterable<int>.generate(items.length).toList();
      //     }
      //     return (ret);
      //   },
      //   isCaseSensitiveSearch: true,
      //   searchHint: new Text(
      //     'Seleccione ',
      //     style: new TextStyle(
      //         fontSize: 20, color: thirdColor, fontWeight: FontWeight.bold),
      //   ),
      //   onChanged: (value) {
      //     setState(() {
      //       driver = value;
      //       prefs.driverIdx = driver.toString();
      //       print(prefs.driverIdx);
      //     });
      //   },
      // ),
    );
  }

  Widget _crearDropdown(BuildContext context) {
    final String comp = "Company";
    final String comp2 = "Company 2";
    final String ibexTgu = "IBEX TGU";
    final String resultTgu = "RESULT TGU";
    final String partner = "PARTNER HERO TGU";
    final String startekSPS = "Startek SPS";
    final String starteTGU = "Startek TGU";
    final String aloricaSPS = "Alorica SPS";
    final String zerovarianceSPS = "Zero Variance SPS";
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurStyle: BlurStyle.solid,
            blurRadius: 10,
            offset: Offset(0, 0), // changes position of shadow
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 5,
            blurStyle: BlurStyle.inner,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.location_city,
              color: thirdColor,
              size: 30.0,
            ),
          ),
          
          Expanded(
              child: new DropdownButton(
            underline: SizedBox(),
            style: TextStyle(color: Colors.white60),
            dropdownColor: backgroundColor2,
            elevation: 20,
            hint: Text(prefs.companyPrueba,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 15.0)),
            items: data.map((e) {
              return new DropdownMenuItem(
                alignment: Alignment.centerLeft,
                child: Text(e['companyName'] == null || e['companyName'] == ""
                    ? prefs.companyPrueba
                    : e['companyName']),
                value: e['companyId'].toString(),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                companyId = val;
                prefs.companyId = companyId!;
                if (prefs.companyId == "1") {
                  prefs.companyPrueba = comp;
                } else if (prefs.companyId == "2") {
                  prefs.companyPrueba = startekSPS;
                } else if (prefs.companyId == "3") {
                  prefs.companyPrueba = starteTGU;
                } else if (prefs.companyId == "6") {
                  prefs.companyPrueba = aloricaSPS;
                } else if (prefs.companyId == "7") {
                  prefs.companyPrueba = zerovarianceSPS;
                } else if (prefs.companyId == "5") {
                  prefs.companyPrueba = comp2;
                } else if (prefs.companyId == "9") {
                  prefs.companyPrueba = ibexTgu;
                } else if (prefs.companyId == "11") {
                  prefs.companyPrueba = resultTgu;
                } else if (prefs.companyId == "12") {
                  prefs.companyPrueba = partner;
                }
                if (prefs.companyId != prefs.companyIdAgent) {
                  if (handleerrror == 'khe') {
                    this.handler!.cleanTable();
                    this.handler!.cleanTableAgent();
                  }
                }
              });
              print(val);
            },
            value: companyId,
          )),
        
        
        ],
      ),
    );
  }

  Widget _crearDropdownToDestination(BuildContext context) {
    final String destination1 = "Gasolinera";
    final String destination2 = "Emisoras";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        children: [
          Icon(Icons.location_city),
          SizedBox(width: 20.0),
          Expanded(
              child: new DropdownButton(
            hint: Text(prefs.destinationPrueba),
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
        Text('Compa????a',
                style: TextStyle(
                    color: GradiantV_2,
                    fontWeight: FontWeight.normal,
                    fontSize: 35.0)),
            SizedBox(height: 20.0),
        _crearDropdown(context),
        SizedBox(height: 10.0),
        Text('Destino',
                style: TextStyle(
                    color: GradiantV_2,
                    fontWeight: FontWeight.normal,
                    fontSize: 35.0)),
        SizedBox(height: 5.0),
        _crearDropdownToDestination(context),
        FutureBuilder<DriverData>(
            future: itemx,
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
        Container(
          width: 320,
          decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0,
                    blurStyle: BlurStyle.solid,
                    blurRadius: 10,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 5,
                    blurStyle: BlurStyle.inner,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              cursorColor: firstColor,
              style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  prefs.vehiculo = value;
                },
                controller: nameController,
                decoration: InputDecoration(
                  icon: Icon(Icons.directions_bus,
                          color: thirdColor, size: 30.0),
                      border: InputBorder.none,                  
                  hintText: prefs.vehiculoSolid == ""
                      ? "Veh??culo"
                      : prefs.vehiculoSolid,
                  hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 15.0)
                )),
          ),
        ),
        SizedBox(height: 20.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 75,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GradiantV_2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Icon(Icons.delete,
                          color: backgroundColor, size: 25.0),
                      onPressed: () {
                        setState(() {
                          this.handler!.cleanTableAgent();
                        });
                      }),
                ),
            SizedBox(width: 5.0),
            Container(
                  width: 75,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GradiantV2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child:
                        Icon(Icons.search, color: backgroundColor, size: 25.0),
                    onPressed: () {
                      showGeneralDialog(
                          barrierColor: Colors.black.withOpacity(0.5),
                          transitionBuilder: (context, a1, a2, widget) {
                            return Transform.scale(
                              scale: a1.value,
                              child: Opacity(
                                opacity: a1.value,
                                child: AlertDialog(
                                  backgroundColor: backgroundColor,
                                  shape: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(16.0)),
                                  title: Center(
                                      child: Text(
                                    'Buscar Agente',
                                    style: TextStyle(
                                        color: GradiantV_2, fontSize: 20.0),
                                  )),
                                  content: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 0,
                                          blurStyle: BlurStyle.solid,
                                          blurRadius: 10,
                                          offset: Offset(0,
                                              0), // changes position of shadow
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1),
                                          spreadRadius: 0,
                                          blurRadius: 5,
                                          blurStyle: BlurStyle.inner,
                                          offset: Offset(0,
                                              0), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: TextField(
                                        style: TextStyle(color: Colors.white),
                                        controller: agentEmployeeId,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelText: 'Escriba aqui',
                                            labelStyle: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                fontSize: 15.0)),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 100,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              textStyle: TextStyle(
                                                color: backgroundColor,
                                              ),
                                              backgroundColor: Gradiant2,
                                            ),
                                            onPressed: () => {
                                              fetchSearchAgentsSolid(
                                          agentEmployeeId.text),
                                              Navigator.pop(context)
                                            },
                                            child: Text('Buscar',
                                                style: TextStyle(
                                                    color: backgroundColor,
                                                    fontSize: 15.0)),
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Container(
                                          width: 100,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () => {
                                              Navigator.pop(context),
                                            },
                                            child: Text('Cerrar',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.0)),
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
            Container(
                  width: 75,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor: firstColor),
                      child: Icon(Icons.qr_code,
                          color: backgroundColor, size: 25.0),
                      onPressed: scanBarcodeNormalSolid),
                ) 
          ],
        ),
        SizedBox(height: 6.0),
        FutureBuilder(
          future: this.handler!.retrieveAgent(),
          builder: (BuildContext context, AsyncSnapshot<List<User?>> snapshot) {
            if (snapshot.hasData) {
              noemp.add("${snapshot.data?.length}");
              return Text("Total de agentes: ${snapshot.data?.length}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold));
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        SizedBox(height: 6.0),
        FutureBuilder(
            future: this.handler!.retrieveAgent(),
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
                                  BoxShadow(
                                      blurStyle: BlurStyle.normal,
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: -30,
                                      offset: Offset(-25, -25)),
                                  BoxShadow(
                                      blurStyle: BlurStyle.normal,
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 30,
                                      spreadRadius: -45,
                                      offset: Offset(20, -15)),
                                ]),                            
                            child: Card(
                              elevation: 20,
                                  color: backgroundColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: EdgeInsets.all(4.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 15),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('# No empleado: ',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                          subtitle:
                                            Text('${snapshot.data![i]!.noempid}',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white)),
                                        leading: Icon(Icons.confirmation_number,
                                            color: thirdColor,
                                                  size: 40.0),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(5, 5, 10, 0),
                                        title: Text('Nombre:',
                                            style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                        subtitle:
                                            Text('${snapshot.data![i]!.nameuser}',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white)),
                                        leading: Icon(Icons.account_box_sharp,
                                             color: thirdColor,
                                                  size: 40.0),
                                      ),
                                      ListTile(
                                        contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text('Hora: ',
                                            style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                      subtitle:
                                          Text('${snapshot.data![i]!.hourout}',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white)),
                                      leading: Icon(Icons.access_alarms,
                                          color: thirdColor,
                                                  size: 40.0),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 10, 0),
                                      title: Text('Direcci??n: ',
                                          style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                      subtitle:
                                          Text('${snapshot.data![i]!.direction}',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white)),
                                      leading: Icon(Icons.location_pin,
                                                color: thirdColor,
                                                  size: 40.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(boxShadow: [
                                          BoxShadow(
                                              blurStyle: BlurStyle.normal,
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              blurRadius: 10,
                                              spreadRadius: -8,
                                              offset: Offset(-10, -6)),
                                          BoxShadow(
                                              blurStyle: BlurStyle.normal,
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              blurRadius: 10,
                                              spreadRadius: -15,
                                              offset: Offset(18, 5)),
                                        ]),
                                        width: 150,
                                      child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              backgroundColor: backgroundColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                            ),
                                            onPressed: () async {
                                            final Database db =
                                                await handler!.initializeDB();
                                            await this
                                                .handler
                                                !.deleteAgent(snapshot.data![i]!.idsend);
                                            await db.rawQuery(
                                                "DELETE FROM agentInsert WHERE nameuser = '${snapshot.data![i]!.nameuser}'");
                                            setState(() {
                                              snapshot.data!.remove(snapshot.data![i]);
                                            });
                                          },
                                          child: Text('Quitar',
                                              style: TextStyle(color: Colors.white)),
                                                            ),
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
                              Container(
                                decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          blurStyle: BlurStyle.normal,
                                          color: Colors.white.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: -30,
                                          offset: Offset(-25, -25)),
                                      BoxShadow(
                                          blurStyle: BlurStyle.normal,
                                          color: Colors.black.withOpacity(0.6),
                                          blurRadius: 30,
                                          spreadRadius: -45,
                                          offset: Offset(20, -15)),
                                    ]),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            backgroundColor: thirdColor,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 22)),
                                    child: Icon(Icons.save),
                                    onPressed: () async {
                                      showGeneralDialog(
                                          context: context,
                                          transitionBuilder:
                                              (context, a1, a2, widget) {
                                            return Center(child: ColorLoader3());
                                          },
                                          transitionDuration:
                                              Duration(milliseconds: 200),
                                          barrierDismissible: false,
                                          barrierLabel: '',
                                          pageBuilder:
                                              (context, animation1, animation2) {
                                            return Text('');
                                          });
                                      // await fetchAgentsLeftPastToProgres( hourOut.text, vehicule.text);
                                              
                                      await fetchAgentsLeftPastToProgresToSolid();
                                      setState(() {
                                        this.handler!.cleanTableAgent();
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
                return Card(
                   shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.symmetric(vertical: 25),
                  child: Container(
                    color: backgroundColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.bus_alert,
                            color: thirdColor,
                          ),
                          title: Text('Agentes',
                              style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 26.0)),
                          subtitle: Text('No hay agentes en el viaje',
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
                return Center(child: CircularProgressIndicator());
              }
            })
      ],
    );
  }
}

class User {
  //final int id;
  final String? noempid;
  final String? nameuser;
  final String? hourout;
  final String? direction;
  final int? idsend;
  // final String vehicle;

  User({
    //this.id,
    this.noempid,
    this.nameuser,
    this.hourout,
    this.direction,
    this.idsend,
    //this.vehicle
  });

  User.fromMap(Map<String, dynamic> res)
      :
        //id = res["id"],
        noempid = res["noempid"],
        nameuser = res["nameuser"],
        hourout = res["hourout"],
        direction = res["direction"],
        idsend = res["idsend"]
  //vehicle = res["vehicle"]
  ;

  Map<String, Object> toMap() {
    return {
      //"id" :id ,
      'noempid': noempid!, 'nameuser': nameuser!, 'hourout': hourout!,
      'direction': direction!, 'idsend': idsend!,
      //vehicle: 'vehicle'
    };
  }
}
