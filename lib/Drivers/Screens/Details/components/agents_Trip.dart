//import 'package:back_button_interceptor/back_button_interceptor.dart';
//import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatViews.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/travel_In_Trips.dart';
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
import 'package:flutter_auth/main.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../components/AppBarPosterior.dart';
import '../../../../components/AppBarSuperior.dart';
import '../../../../components/backgroundB.dart';
import '../../../../constants.dart';
import '../../../components/progress_indicator.dart';
import '../../../models/agentsInTravelModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:url_launcher/url_launcher.dart';
//import 'package:geolocator/geolocator.dart';


void main() {
  runApp(MyAgent());
}

int recargar=-1;

void setRecargar(int numero){
  recargar=numero;
}

int gerRecargar(){
  return recargar;
}

class MyAgent extends StatefulWidget {
  final TripsList2? item;
  final PlantillaDriver? plantillaDriver;

  const MyAgent({Key? key, this.plantillaDriver, this.item}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyAgent> with WidgetsBindingObserver {
  Future<DriverData>? driverData;
  List<int>? counter;
  Future<TripsList2>? item;
  TextEditingController agentHours = new TextEditingController();
  TextEditingController vehicleController = new TextEditingController();
  var tripVehicle = '';
  bool vehicleL = false;
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";
  dynamic flagalert;

  bool confirmados = true;
  bool no_confirmados = false;
  bool cancelados = false;
  
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(AppLifecycleState.resumed==state){
      if(mounted){
        if(gerRecargar()==0){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MyAgent()))
          .then((_) => MyAgent());
        }
      }
    }
    
  }

  Future<Driver> fetchHours(
      String agentId, String agentTripHour, String tripId) async {
        LoadingIndicatorDialog().show(context);      
    Map data = {
      'agentId': agentId,
      'agentTripHour': agentTripHour,
      'tripId': tripId
    };

    //print(data);
    http.Response response = await http
        .post(Uri.parse('$ip/apis/registerAgentTripTime'), body: data);

    final resp = Driver.fromJson(json.decode(response.body));

    Map data2 = {"idU": agentId.toString(), "Estado": 'CONFIRMADO'};
    String sendData2 = json.encode(data2);
    await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/$tripId'), body: sendData2, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200 && resp.ok == true && agentTripHour != "") {
      //print(response.body);
      LoadingIndicatorDialog().dismiss();      
      if(mounted){
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Hecho!',
          text: resp.message,
        );

        _refresh();
      }
    } else if (response.statusCode == 200 && resp.ok != true) {
      LoadingIndicatorDialog().dismiss();     
      if(mounted){
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: resp.title,
          text: resp.message,
        );
      }
    }

    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver> fetchNoConfirm(String agentId, String tripId) async {
    Map data = {'agentId': agentId, 'tripId': tripId};
    //print(data);
    http.Response response = await http
        .post(Uri.parse('$ip/apis/markAgentAsNotConfirmed'), body: data);
    if (mounted) {
      setState(() {
        final resp = Driver.fromJson(json.decode(response.body));

        if (response.statusCode == 200 && resp.ok == true) {
          //print(response.body);
              QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Hecho!',
          text: resp.message,
          confirmBtnText: 'OK'
          );
        } else if (response.statusCode == 500) {
          QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: resp.title,
          text: resp.message,
          );
        }
      });
    }
    Map data2 = {"idU": agentId.toString(), "Estado": 'RECHAZADO'};
    String sendData2 = json.encode(data2);
    await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/$tripId'), body: sendData2, headers: {"Content-Type": "application/json"});

    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver> fetchPastInProgress() async {
    
    http.Response response = await http
        .get(Uri.parse('$ip/apis/passTripToProgress/${prefs.tripId}'));
    final resp = Driver.fromJson(json.decode(response.body));
    LoadingIndicatorDialog().dismiss();
    //print(response.body);
    if (response.statusCode == 200 && resp.ok == true) {
      //print(response.body);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomeDriverScreen()),
          (Route<dynamic> route) => false);

          QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: 'Su viaje está en proceso',
                title: 'Confirmado'
                );
      //   SweetAlert.show(context,
      //   title: resp.title,
      //   subtitle: resp.message,
      //   style: SweetAlertStyle.success
      // );
      Map data2 = {"Estado": 'INICIADO'};
      String sendData2 = json.encode(data2);
      await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/Viaje_Estado/${prefs.tripId}'), body: sendData2, headers: {"Content-Type": "application/json"});
    } else if (response.statusCode == 200 && resp.ok == false) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: resp.title,
          text: resp.message,
          );
    } else if (response.statusCode == 500) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: resp.title,
          text: resp.message,
          );
    }
   
    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver> fetchTripCancel() async {
    http.Response responses = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(responses.body));
    http.Response response = await http.get(Uri.parse(
        '$ip/apis/driverCancelTrip/${prefs.tripId}/${data.driverId}'));

    final resp = Driver.fromJson(json.decode(response.body));

    if (response.statusCode == 200 && resp.ok == true) {
      //print(response.body);

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomeDriverScreen()),
          (Route<dynamic> route) => false);
      // SweetAlert.show(context,
      // title: 'ok',
      // subtitle: resp.message,
      // style: SweetAlertStyle.success
      // );
    } else if (response.statusCode == 500) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ok',
          text: resp.message,
          );
    }

    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver> fetchTripAgentsNotConfirm() async {
    http.Response response =
        await http.get(Uri.parse('$ip/apis/cancelAgentsTrip/${prefs.tripId}'));

    final resp = Driver.fromJson(json.decode(response.body));

    if (response.statusCode == 200) {
      //print(response.body);

      Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MyAgent()))
          .then((_) => MyAgent());
    } else if (response.statusCode == 500) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ok',
          text: resp.message,
          );
    }
      
    http.Response responseSala = await http.get(Uri.parse('https://apichat.smtdriver.com/api/salas/Tripid/${prefs.tripId}'));
    final respS = json.decode(responseSala.body);

    for(int i = 0; i<respS['salas']['Agentes'].length; i++){

      if(respS['salas']['Agentes'][i]['Estado']=='ESPERA'){
        Map data2 = {"idU": respS['salas']['Agentes'][i]['agenteId'].toString(), "Estado": 'RECHAZADO'};
        String sendData2 = json.encode(data2);
        await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/${prefs.tripId}'), body: sendData2, headers: {"Content-Type": "application/json"});
      }
    }

    return Driver.fromJson(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    setRecargar(0);
    setUb(1);
    WidgetsBinding.instance.addObserver(this);
    item = fetchAgentsInTravel2();
    driverData = fetchRefres();
    getInfoViaje();
  }

  void getInfoViaje() async{
    http.Response responseSala = await http.get(Uri.parse('$ip/apis/agentsInTravel/${prefs.tripId}'));
    final infoViaje = json.decode(responseSala.body);

    if(infoViaje[3]['viajeActual']['tripVehicle']!=null){
      if(mounted){
        setState(() {
          tripVehicle = infoViaje[3]['viajeActual']['tripVehicle'];
          vehicleL = true;
          vehicleController.text=tripVehicle;
        });
      }
    }else{
      if(mounted){
        setState(() {
          tripVehicle = '';
          vehicleL = true;
          vehicleController.text=tripVehicle;
        });
      }
    }
    
  }
  
  BuildContext? contextP;

  static DateTime _eventdDate = DateTime.now();
  static var now = TimeOfDay.fromDateTime(DateTime.parse(_eventdDate.toString()));
  final format = DateFormat('HH:mm');
  
  @override
  Widget build(BuildContext context) {
    contextP = context;
    return BackgroundBody(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: AppBarSuperior(item: 111,)
                  ),
                  body: Column(
                    children: [
                      Padding(
                        padding:const EdgeInsets.only(left: 20, right: 20, top: 10),
                        child: _buttonsAgents(),
                      ),
                      Expanded(
                        child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: body()),
                      ),
                      SafeArea(child: AppBarPosterior(item:-1)),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ingresarVehiculo(),
            SizedBox(height: 30.0),
            opcionesBotones(),
            SizedBox(height: 30.0),
            if(confirmados == true) _agentToConfirm(),
            if(no_confirmados == true) _agentoNoConfirm(),
            if(cancelados == true) _agentToCancel(),
            SizedBox(height: 30.0),
          ],
        ),
      )
    );
  }

  Row opcionesBotones() {
    return Row(
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                fixedSize: Size(150, 25),
                elevation: 0,
                backgroundColor: confirmados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Text('Confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: confirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
              onPressed: confirmados==true?null:() {
                setState(() {
                  confirmados = true;
                  no_confirmados = false;
                  cancelados = false;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                fixedSize: Size(150, 25),
                elevation: 0,
                backgroundColor: no_confirmados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Text('No confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: no_confirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
              onPressed: no_confirmados==true?null:() {
                setState(() {
                  confirmados = false;
                  no_confirmados = true;
                  cancelados = false;
                });
              },
            ),
          ),

          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                fixedSize: Size(150, 25),
                elevation: 0,
                backgroundColor: cancelados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Text('Cancelados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: cancelados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
              onPressed: cancelados==true?null:() {
                setState(() {
                  confirmados = false;
                  no_confirmados = false;
                  cancelados = true;
                });
              },
            ),
          ),
        ],
      );
  }

  Widget ingresarVehiculo() {
    return FutureBuilder<TripsList2>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          return FutureBuilder<DriverData>(
          future: driverData,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              DriverData? data = abc.data;
              return Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [

                  if(data?.driverType=='Motorista')
                    Center(child: Text('Escanee el código QR del vehículo', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),)),
                  if(data?.driverType=='Motorista')
                    SizedBox(height: 6,),

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
                                    enabled: data?.driverType=='Motorista'?false:true,
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                                    ),
                                    controller: vehicleController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Vehículo',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                                      ),
                                    ),
                                    onChanged: (value) => tripVehicle,
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
                          onPressed: vehicleL==false?null:() async{
                            setRecargar(-1);
                            String codigoQR = await FlutterBarcodeScanner.scanBarcode("#9580FF", "Cancelar", true, ScanMode.QR);
                  
                            if (codigoQR == "-1") {
                              setRecargar(0);
                              return;
                            } else {
                              LoadingIndicatorDialog().show(context);
                              http.Response responseSala = await http.get(Uri.parse('https://app.mantungps.com/3rd/vehicles/$codigoQR'),headers: {"Content-Type": "application/json", "x-api-key": 'a10xhq0p21h3fb9y86hh1oxp66c03f'});
                              final resp = json.decode(responseSala.body);
                              LoadingIndicatorDialog().dismiss();
                              if(resp['type']=='success'){
                                print(responseSala.body);
                                print('###########################');
                                if(mounted){
                                  showDialog(
                                          context: context,
                                          builder: (context) => vehiculoE(resp, context),);
                                }
                              }else{
                                if(mounted){
                                  QuickAlert.show(context: context,title: "Alerta",text: "Vehículo no valido",type: QuickAlertType.error,); 
                                }
                              }
                              setRecargar(0);
                            }
                          }
                        ),
                      ),


                        if(data?.driverType!='Motorista')
                        SizedBox(width: 6),

                        if(data?.driverType!='Motorista')
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
                                    "assets/icons/Guardar.svg",
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                          onPressed: vehicleL==false?null:() async{
                            LoadingIndicatorDialog().show(context);
                            http.Response responses = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
                            final data2 = DriverData.fromJson(json.decode(responses.body));
                            Map data = {
                              "driverId": data2.driverId.toString(),
                              "tripId": prefs.tripId.toString(),
                              "vehicleId": "",
                              "tripVehicle": vehicleController.text
                            };
                            http.Response responsed = await http.post(Uri.parse('https://driver.smtdriver.com/apis/editTripVehicle'), body: data);
                          
                            final resp2 = json.decode(responsed.body);
                            LoadingIndicatorDialog().dismiss();
                            if(resp2['type']=='success'){
                              if(mounted){
                                QuickAlert.show(context: context,title: "Exito",text: resp2['message'],type: QuickAlertType.success,);
                                setState(() {
                                  tripVehicle = vehicleController.text;
                                });
                              }      
                          
                            }else{
                              QuickAlert.show(context: context,title: "Alerta",text: resp2['message'],type: QuickAlertType.error,);
                            }
                          }
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return WillPopScope(
                        onWillPop: () async => false,
                        child: SimpleDialog(
                          elevation: 20,
                          backgroundColor: Theme.of(context).cardColor,
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                                    child: CircularProgressIndicator(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Cargando...', 
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                      ),
                                  )
                                ],
                              ),
                            )
                          ] ,
                        ),
                      );
            }
          },
            );
        } else {
          return WillPopScope(
                        onWillPop: () async => false,
                        child: SimpleDialog(
                          elevation: 20,
                          backgroundColor: Theme.of(context).cardColor,
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                                    child: CircularProgressIndicator(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Cargando...', 
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                      ),
                                  )
                                ],
                              ),
                            )
                          ] ,
                        ),
                      );
        }
      },
    );
  }

  AlertDialog vehiculoE(resp, BuildContext context) {
    var size = MediaQuery.of(context).size;
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
                                                                      onPressed: () async{
                                                                        LoadingIndicatorDialog().show(context);
                                                                        http.Response responses = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
                                                                        final data2 = DriverData.fromJson(json.decode(responses.body));
                                                                        Map data = {
                                                                          "driverId": data2.driverId.toString(),
                                                                          "tripId": prefs.tripId.toString(),
                                                                          "vehicleId": resp['vehicle']['_id'],
                                                                          "tripVehicle": "${resp['vehicle']['name']} [${resp['vehicle']['registrationNumber']}]"
                                                                        };
                                                                        http.Response responsed = await http.post(Uri.parse('https://driver.smtdriver.com/apis/editTripVehicle'), body: data);
                                                                        
                                                                        final resp2 = json.decode(responsed.body);
                                                                        LoadingIndicatorDialog().dismiss();
                                                                        if(resp2['type']=='success'){
                                                                          if(mounted){
                                                                            Navigator.pop(context);
                                                                            QuickAlert.show(context: context,title: "Exito",text: resp2['message'],type: QuickAlertType.success,);
                                                                            setState(() {
                                                                              tripVehicle = "${resp['vehicle']['name']} [${resp['vehicle']['registrationNumber']}]";
                                                                              vehicleController.text=tripVehicle;  
                                                                            });
                                                                          }
                                                                        }else{
                                                                          QuickAlert.show(context: context,title: "Alerta",text: resp2['message'],type: QuickAlertType.error,);
                                                                        }
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

//AgentToConfirm
  Widget _agentToConfirm() {
    return FutureBuilder<TripsList2>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![0].agentes!.length == 0) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1
                ) // Radio de la esquina
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset( 
                      "assets/icons/advertencia.svg",
                      color: Theme.of(context).primaryIconTheme.color,
                      width: 18,
                      height: 18,
                    ),
                    Flexible(
                      child: Text(
                          '  No hay agentes confirmados para este viaje',
                          style: TextStyle(
                            color: Color.fromRGBO(213, 0, 0, 1),
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0
                          )
                        ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return FutureBuilder<TripsList2>(
              future: item,
              builder: (BuildContext context, abc) {
                if (abc.connectionState == ConnectionState.done) {
                  Size size = MediaQuery.of(context).size;
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: abc.data!.trips![0].agentes!.length,
                    itemBuilder: (context, index) {
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Theme.of(context).dividerColor,),
                          ),
                          child: ExpansionTile(
                            iconColor: Theme.of(context).primaryIconTheme.color,
                            tilePadding: const EdgeInsets.only(right: 10, left: 10),
                              title: Column(
                              children: [

                                SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10, left: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                                width: 18,
                                                height: 18,
                                                child: SvgPicture.asset(
                                                  "assets/icons/usuario.svg",
                                                  color: Color.fromRGBO(213, 0, 0, 1),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Flexible(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Nombre: ',
                                                        style: TextStyle(fontWeight: FontWeight.w500),
                                                      ),
                                                      TextSpan(
                                                        text: '${abc.data!.trips![0].agentes![index].agentFullname}',
                                                        style: TextStyle(fontWeight: FontWeight.normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )                   
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20),
                                      if (abc.data!.trips![0].agentes![index].hourForTrip == "00:00") ...{
                                        Padding(
                                            padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                          width: 18,
                                                          height: 18,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/hora.svg",
                                                            color: Theme.of(context).primaryIconTheme.color,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Flexible(
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Hora de encuentro: ',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )                   
                                              ],
                                            ),
                                          ),
                                      } else ...{
                                        Padding(
                                            padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                          width: 18,
                                                          height: 18,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/hora.svg",
                                                            color: Theme.of(context).primaryIconTheme.color,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Flexible(
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Hora de encuentro: ',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                                TextSpan(
                                                                  text: abc.data!.trips![0].agentes![index].hourForTrip==null?' --':
                                                                  '${abc.data!.trips![0].agentes![index].hourForTrip}',
                                                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )                   
                                              ],
                                            ),
                                          ),
                                      },
                                      Container(
                                        height: 1,
                                        color: Theme.of(context).dividerColor,
                                      ),

                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/Casa.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Dirección: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: abc.data!.trips![0].agentes![index].agentReferencePoint==null
                                                              ||abc.data!.trips![0].agentes![index].agentReferencePoint==""
                                                              ?"${abc.data!.trips![0].agentes![index].neighborhoodName}, ${abc.data!.trips![0].agentes![index].townName}":'Dirección: ${abc.data!.trips![0].agentes![index].agentReferencePoint}, ${abc.data!.trips![0].agentes![index].neighborhoodName}, ${abc.data!.trips![0].agentes![index].townName},',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),

                                      if (abc.data!.trips![0].agentes![index].neighborhoodReferencePoint != null)... {
                                        Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        SizedBox(height: 20),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                          child: Row(
                                            children: [
                                              Container(
                                                        width: 18,
                                                        height: 18,
                                                        child: SvgPicture.asset(
                                                          "assets/icons/warning.svg",
                                                          color: Theme.of(context).primaryIconTheme.color,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Flexible(
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                            children: [
                                                              TextSpan(
                                                                text: 'Acceso autorizado: ',
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              TextSpan(
                                                                text: '${abc.data!.trips![0].agentes![index].neighborhoodReferencePoint}',
                                                                style: TextStyle(fontWeight: FontWeight.normal),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )                   
                                            ],
                                          ),
                                        ),
                                }
                              ],
                            ),
                              trailing: SizedBox(),
                              children: [
                                
                              Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                            padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                          width: 18,
                                                          height: 18,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/hora.svg",
                                                            color: Theme.of(context).primaryIconTheme.color,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Flexible(
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Entrada: ',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                                TextSpan(
                                                                  text: '${abc.data!.trips![0].agentes![index].hourIn}',
                                                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )                   
                                              ],
                                            ),
                                          ),
                                          Padding(
                                        padding: const EdgeInsets.only(right: 10, left: 10),
                                        child: Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),

                              
                              SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/telefono_num.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          launchUrl(Uri.parse(
                                                            'tel://${abc.data!.trips![0].agentes![index].agentPhone}',
                                                          ));
                                                        },
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                            children: [
                                                              TextSpan(
                                                                text: 'Teléfono: ',
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              TextSpan(
                                                                text: '${abc.data!.trips![0].agentes![index].agentPhone}',
                                                                style: TextStyle(fontWeight: FontWeight.normal),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10, left: 10),
                                        child: Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),

                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/compania.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Empresa: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: '${abc.data!.trips![0].agentes![index].companyName}',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ), 
                                      SizedBox(height: 20.0),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                                          fixedSize: Size(150, 25),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async{
                                          var time =await showTimePicker(context: context,initialTime:TimeOfDay.now(),);                                                 
                                          validateHour(abc.data!.trips![0].agentes![index].agentId.toString(), abc.data!.trips![0].agentes![index].tripId.toString(), time);
                                          DateTimeField.convert(flagalert);                                           
                                        },
                                        child: Row(
                                          children: [
                                            SvgPicture.asset( 
                                              "assets/icons/cambia_hora.svg",
                                              color: Theme.of(context).primaryColorDark,
                                              width: 20,
                                              height: 20,
                                            ),
                                            SizedBox(width: 5),
                                            Flexible(
                                              child: Text('Cambiar hora',
                                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      // Usamos una fila para ordenar los botones del card
                              ],
                            ),
                          ),
                        );
                      });
                } else {
                  return WillPopScope(
                        onWillPop: () async => false,
                        child: SimpleDialog(
                          elevation: 20,
                          backgroundColor: Theme.of(context).cardColor,
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                                    child: CircularProgressIndicator(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Cargando...', 
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                      ),
                                  )
                                ],
                              ),
                            )
                          ] ,
                        ),
                      );
                }
              },
            );
          }
        } else {
          return WillPopScope(
                        onWillPop: () async => false,
                        child: SimpleDialog(
                          elevation: 20,
                          backgroundColor: Theme.of(context).cardColor,
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                                    child: CircularProgressIndicator(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Cargando...', 
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                      ),
                                  )
                                ],
                              ),
                            )
                          ] ,
                        ),
                      );
        }
      },
    );
  }

//AgentNoConfirm
  Widget _agentoNoConfirm() {
    return FutureBuilder<TripsList2>(
      future: item,
      builder: (BuildContext context, abc) {
        
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![1].noConfirmados!.length == 0) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1
                ) // Radio de la esquina
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset( 
                      "assets/icons/advertencia.svg",
                      color: Theme.of(context).primaryIconTheme.color,
                      width: 18,
                      height: 18,
                    ),
                    Flexible(
                      child: Text(
                          '  No hay agentes no confirmados para este viaje',
                          style: TextStyle(
                            color: Color.fromRGBO(213, 0, 0, 1),
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0
                          )
                        ),
                    ),
                  ],
                ),
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
                    itemCount: abc.data!.trips![1].noConfirmados!.length,
                    itemBuilder: (context, index) {
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Theme.of(context).dividerColor,),
                          ),
                          child: ExpansionTile(
                            iconColor: Theme.of(context).primaryIconTheme.color,
                            tilePadding: const EdgeInsets.only(right: 10, left: 10),
                            title: Column(
                              children: [

                                SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10, left: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                                width: 18,
                                                height: 18,
                                                child: SvgPicture.asset(
                                                  "assets/icons/usuario.svg",
                                                  color: Color.fromRGBO(213, 0, 0, 1),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Flexible(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Nombre: ',
                                                        style: TextStyle(fontWeight: FontWeight.w500),
                                                      ),
                                                      TextSpan(
                                                        text: '${abc.data!.trips![1].noConfirmados![index].agentFullname}',
                                                        style: TextStyle(fontWeight: FontWeight.normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )                   
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/hora.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Entrada: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: '${abc.data!.trips![1].noConfirmados![index].hourIn}',
                                                              style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 1,
                                        color: Theme.of(context).dividerColor,
                                      ),

                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/Casa.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Dirección: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: abc.data!.trips![1].noConfirmados![index].agentReferencePoint==null || abc.data!.trips![1].noConfirmados![index].agentReferencePoint==""
                                                                    ?"${abc.data!.trips![1].noConfirmados![index].neighborhoodName}, ${abc.data!.trips![1].noConfirmados![index].townName}":'${abc.data!.trips![1].noConfirmados![index].agentReferencePoint}, ${abc.data!.trips![1].noConfirmados![index].neighborhoodName}, ${abc.data!.trips![1].noConfirmados![index].townName},',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),

                                      if (abc.data!.trips![1].noConfirmados![index].neighborhoodReferencePoint != null)... {
                                      Container(
                                        height: 1,
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/warning.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Acceso autorizado: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: '${abc.data!.trips![1].noConfirmados![index].neighborhoodReferencePoint}',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      
                                      },
                              ],
                            ),
                            
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/telefono_num.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          launchUrl(Uri.parse(
                                                            'tel://${abc.data!.trips![1].noConfirmados![index].agentPhone}',
                                                          ));
                                                        },
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                            children: [
                                                              TextSpan(
                                                                text: 'Teléfono: ',
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              TextSpan(
                                                                text: '${abc.data!.trips![1].noConfirmados![index].agentPhone}',
                                                                style: TextStyle(fontWeight: FontWeight.normal),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),

                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/compania.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Empresa: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: '${abc.data!.trips![1].noConfirmados![index].companyName}',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ), 
                                      SizedBox(height: 20.0),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                                          fixedSize: Size(150, 25),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.confirm,
                                          title: "...",          
                                          text: "¿Está seguro que desea marcar como no \nconfirmado al agente?",
                                            confirmBtnText: "Confirmar",
                                            cancelBtnText: "Cancelar",
                                            showCancelBtn: true,  
                                            confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                            cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
                                            onConfirmBtnTap: () {
                                              Navigator.pop(contextP!);
                                              fetchNoConfirm(abc.data!.trips![1].noConfirmados![index].agentId.toString(),abc.data!.trips![1].noConfirmados![index].tripId.toString());                                        
                                              _refresh();
                                            },
                                            onCancelBtnTap: () {
                                              Navigator.pop(contextP!);
                                            },
                                          );                                                  
                                        },
                                        child: Text('No confirmó',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(height: 10.0),
                                      // Usamos una fila para ordenar los botones del card
                              ],
                          ),
                        ),
                      );
                    });
              },
            );
          }
        } else {
          return WillPopScope(
                        onWillPop: () async => false,
                        child: SimpleDialog(
                          elevation: 20,
                          backgroundColor: Theme.of(context).cardColor,
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                                    child: CircularProgressIndicator(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Cargando...', 
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                      ),
                                  )
                                ],
                              ),
                            )
                          ] ,
                        ),
                      );
        }
      },
    );
  }


  validateHour(String agentId, String tripId, dynamic time)async{
    //var time =await showTimePicker(context: context,initialTime:TimeOfDay.now(),);   
    if(time==null){
      return;
    } 
    String _eventTime = now.toString().substring(10, 15);
    _eventTime = time.toString().substring(10, 15);
    if (time!= null) {      
      QuickAlert.show(context: context,
          type: QuickAlertType.confirm,
          title: "Agregando hora",          
          text: "¿Es correcta la hora\n$_eventTime del agente?",
          confirmBtnText: "Confirmar",
          cancelBtnText: "Cancelar",
          showCancelBtn: true,  
          confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
          cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
          onConfirmBtnTap: () async{ 
            Navigator.pop(contextP!);           
              setState(() {                              
                //print(_eventTime);
                fetchHours(agentId,_eventTime,tripId);
                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyAgent())).then((_) => MyAgent());
                //Navigator.of(context).popUntil((route) =>  route.);
                //Navigator.push(context,MaterialPageRoute(builder: (_) => MyAgent()));              
              }); 
              // await Future.delayed(Duration(seconds: 2), () {
              //   cancelHour();
              // },);                                                                                                                                                                               
          },
          onCancelBtnTap: () {  
            Navigator.pop(contextP!);
            setState(() {            
              flagalert = time;                                            
            });
          },);                                                         
    }                                                                                                  
  }

  
  Future<void> _refresh() async {
    // Mostrar un indicador de carga mientras se actualiza el contenido
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text("Actualizando...")));

    // Simulando un proceso de actualización de datos
    await Future.delayed(Duration(seconds: 1));

    // Actualizar el contenido de la página
    setState(() {
      // Código para actualizar el contenido
      item = fetchAgentsInTravel2();
    });

    // Ocultar el indicador de carga
    //Scaffold.of(context).hideCurrentSnackBar();
}

  void cancelHour(){
    if (mounted) {   
      Navigator.maybePop(context,MaterialPageRoute(builder: (context) {return MyAgent();},),);
      _refresh();                                
    }  
  }

//AgentToCancel
  Widget _agentToCancel() {
    return FutureBuilder<TripsList2>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![2].cancelados!.length == 0) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1
                ) // Radio de la esquina
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset( 
                      "assets/icons/advertencia.svg",
                      color: Theme.of(context).primaryIconTheme.color,
                      width: 18,
                      height: 18,
                    ),
                    Flexible(
                      child: Text(
                          '  No hay agentes que hayan cancelado este viaje',
                          style: TextStyle(
                            color: Color.fromRGBO(213, 0, 0, 1),
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0
                          )
                        ),
                    ),
                  ],
                ),
              ),
            );
          } else if (abc.data!.trips![2].cancelados!.length > 0) {
            return FutureBuilder<TripsList2>(
              future: item,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: abc.data!.trips![2].cancelados!.length,
                    itemBuilder: (context, index) {
                      print(abc.data!.trips![2].cancelados![index].agentPhone);
                      Size size = MediaQuery.of(context).size;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          width: size.width,
                          child: Column(
                            children: [
                              Container(
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
                                  margin: EdgeInsets.all(5.0),
                                  elevation: 2,
                                  child: Column(
                                    children: <Widget>[
                                        Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: ExpansionTile(
                                        backgroundColor: backgroundColor,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(14,0,20,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.person,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(
                                                    child: Text('Nombre: ${abc.data!.trips![2].cancelados![index].agentFullname}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          //fontWeight: FontWeight.bold,
                                                          fontSize: 18.0)),
                                                  ),
                                                ],
                                              ),
                                            ),                       
                                          ],
                                        ),
                                        trailing: SizedBox(),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_city,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Text('Empresa: ${abc.data!.trips![2].cancelados![index].companyName}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      //fontWeight: FontWeight.bold,
                                                      fontSize: 18.0)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8,),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30),
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone,
                                                color: thirdColor),
                                                SizedBox(width: 8,),
                                                TextButton(
                                                onPressed: () =>
                                                    launchUrl(Uri.parse(
                                                      'tel://${abc.data!.trips![2].cancelados![index].agentPhone}',
                                                    )),
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        right: 140),
                                                    child: Text(
                                                        'Teléfono: ${abc.data!.trips![2].cancelados![index].agentPhone}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18)))),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8,),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Text('Entrada: ${abc.data!.trips![2].cancelados![index].hourIn}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      //fontWeight: FontWeight.bold,
                                                      fontSize: 18.0)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 18),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(30,0,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_pin,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(
                                                  child: Text('Dirección: ${abc.data!.trips![2].cancelados![index].agentReferencePoint} ${abc.data!.trips![2].cancelados![index].neighborhoodName} ${abc.data!.trips![2].cancelados![index].districtName}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        //fontWeight: FontWeight.bold,
                                                        fontSize: 18.0)),
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
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
            );
          }
          return SizedBox();
        } else {
          return WillPopScope(
                        onWillPop: () async => false,
                        child: SimpleDialog(
                          elevation: 20,
                          backgroundColor: Theme.of(context).cardColor,
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                                    child: CircularProgressIndicator(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Cargando...', 
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                      ),
                                  )
                                ],
                              ),
                            )
                          ] ,
                        ),
                      );
        }
      },
    );
  }

//Buttons
  Widget _buttonsAgents() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontSize: 12),
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 12, left: 12),
          child: Text("Pasar viaje a proceso", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontSize: 12),),
        ),
        onPressed: () {
          QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "...",
          text: "¿Está seguro que desea pasar el viaje en proceso?",
          confirmBtnText: "Confirmar",
          cancelBtnText: "Cancelar",
          showCancelBtn: true,  
          confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
          cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),         
          onConfirmBtnTap: () {
    
            Navigator.pop(context);
            LoadingIndicatorDialog().show(context);
            new Future.delayed(new Duration(seconds: 2), () {
                fetchPastInProgress();
              });
            
              
          },
          onCancelBtnTap: () {
            Navigator.pop(context);
          },
          );
        },
      ),
    );
  }
}