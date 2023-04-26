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
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../constants.dart';
import '../../../components/progress_indicator.dart';
import '../../../models/agentsInTravelModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:url_launcher/url_launcher.dart';

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
  List<int>? counter;
  Future<TripsList2>? item;
  TextEditingController agentHours = new TextEditingController();
  TextEditingController vehicleController = new TextEditingController();
  var tripVehicle = '';
  bool vehicleL = false;
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";
  dynamic flagalert;
  
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
    Map data = {
      'agentId': agentId,
      'agentTripHour': agentTripHour,
      'tripId': tripId
    };

    //print(data);
    http.Response response = await http
        .post(Uri.parse('$ip/apis/registerAgentTripTime'), body: data);

    final resp = Driver.fromJson(json.decode(response.body));

    if (response.statusCode == 200 && resp.ok == true && agentTripHour != "") {
      //print(response.body);
      QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: resp.title,
      text: resp.message,
      );
    } else if (response.statusCode == 200 && resp.ok != true) {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: resp.title,
      text: resp.message,
      );
    }

    Map data2 = {"idU": agentId.toString(), "Estado": 'CONFIRMADO'};
    String sendData2 = json.encode(data2);
    await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/$tripId'), body: sendData2, headers: {"Content-Type": "application/json"});

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
    //print(response.body);
    if (response.statusCode == 200 && resp.ok == true) {
      //print(response.body);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomeDriverScreen()),
          (Route<dynamic> route) => false);
      //   SweetAlert.show(context,
      //   title: resp.title,
      //   subtitle: resp.message,
      //   style: SweetAlertStyle.success
      // );
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
    Map data2 = {"Estado": 'INICIADO'};
      String sendData2 = json.encode(data2);
      await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/Viaje_Estado/${prefs.tripId}'), body: sendData2, headers: {"Content-Type": "application/json"});
   
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
    WidgetsBinding.instance.addObserver(this);
    item = fetchAgentsInTravel2();
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
  static var now =
      TimeOfDay.fromDateTime(DateTime.parse(_eventdDate.toString()));
  final format = DateFormat('HH:mm');
  @override
  Widget build(BuildContext context) {
    contextP = context;
    return MaterialApp(
      color: backgroundColor,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: backgroundColor,
          drawer: DriverMenuLateral(),
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 15,
            actions: <Widget>[
              IconButton(
                icon:
                    Icon(Icons.textsms_rounded, color: thirdColor, size: 30.0),
                onPressed: () {
                  setRecargar(-1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              tripId: prefs.tripId,
                            )),
                  );
                },
              ),
              IconButton(
                icon:
                    Icon(Icons.arrow_circle_left, color: secondColor, size: 30),
                onPressed: () {
                  setRecargar(-1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Trips()),
                  );
                },
              ),
              SizedBox(width: kDefaultPadding / 2)
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(children: <Widget>[
              SizedBox(height: 25.0),
              Center(
                  child: Text('Asignación de Horas',
                      style: TextStyle(
                          color: firstColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0))),
              SizedBox(height: 20.0),
              ingresarVehiculo(),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text('Agentes confirmados',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: GradiantV_2,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0)),
              ),
              SizedBox(height: 10.0),
              _agentToConfirm(),
              SizedBox(height: 20.0),
              Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text('Agentes no confirmados',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: GradiantV_2,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0))),
              _agentoNoConfirm(),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text('Agentes que han cancelado',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: GradiantV_2,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0)),
              ),
              SizedBox(height: 10.0),
              _agentToCancel(),
              SizedBox(height: 20.0),
              _buttonsAgents(),
              SizedBox(height: 30.0),
            ]),
          )),
    );
  }

  Widget ingresarVehiculo() {
    final myFocusNode = FocusNode();
    myFocusNode.addListener(() async{
      if (!myFocusNode.hasFocus) {
        http.Response responses = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
        final data2 = DriverData.fromJson(json.decode(responses.body));
        Map data = {
          "driverId": data2.driverId.toString(),
          "tripId": prefs.tripId.toString(),
          "vehicleId": "",
          "tripVehicle": vehicleController.text
        };
        http.Response responsed = await http.post(Uri.parse('https://driver.smtdriver.com/apis/editTripVehicle'), body: data);
      }
    });
    return FutureBuilder<TripsList2>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2),spreadRadius: 0,blurStyle: BlurStyle.solid,blurRadius: 10,offset: Offset(0, 0), ),
                      BoxShadow(color: Colors.white.withOpacity(0.1),spreadRadius: 0,blurRadius: 5,blurStyle: BlurStyle.inner,offset: Offset(0, 0), ),
                    ],
                  ),
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.only(left:10.0, right: 10),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_transportation,color: thirdColor,size: 30.0,),
                        SizedBox(width: 10.0),
                        Flexible(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: vehicleController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Vehículo',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5),
                              fontSize: 15.0)
                            ),
                            onChanged: (value) => tripVehicle,
                            focusNode: myFocusNode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  SizedBox(width: 10,),
                  Container(
                    decoration: BoxDecoration(
                      color: firstColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.qr_code),
                      color: backgroundColor,
                      iconSize: 30.0,
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
                            if(context.mounted){
                              showGeneralDialog(
                                barrierColor: Colors.black.withOpacity(0.5),
                                transitionBuilder: (context, a1, a2, widget) {
                                  return Transform.scale(
                                    scale: a1.value,
                                    child: Opacity(
                                    opacity: a1.value,
                                    child: vehiculoE(resp, context),
                                  ),
                                  );
                                },
                                transitionDuration: Duration(milliseconds: 220),
                                barrierDismissible: false,
                                barrierLabel: '',
                                context: context,
                                pageBuilder: (context, animation1, animation2) {
                                  return widget;
                                }
                              );
                            }
                          }else{
                            if(context.mounted){
                              QuickAlert.show(context: context,title: "Alerta",text: "Vehículo no valido",type: QuickAlertType.error,); 
                            }
                          }
                          setRecargar(0);
                        }
                      }
                    ),
                  ),
                ],
              ),
            );
        } else {
          return ColorLoader3();
        }
      },
    );
  }

  AlertDialog vehiculoE(resp, BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AlertDialog(
      //scrollable: true,
      backgroundColor: backgroundColor,shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Center(child: Flexible(child: Text('Vehículo Encontrado',style: TextStyle(color: GradiantV_2, fontSize: 20.0),))),
      content: SizedBox(
        width: size.width * 0.8,
        //height: MediaQuery.of(context).size.height/1.9,
        child: SingleChildScrollView(
          child: Flexible(
            child: Column(
              children: [
                const SizedBox(height: 8.0),
                Text('Descripcion:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                  )
                ),
                SizedBox(height: 5,),
                Text(resp['vehicle']['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0
                  )
                ),
                SizedBox(height: 15,),
                Text('Placa:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                  )
                ),
                SizedBox(height: 10,),
                Text(resp['vehicle']['registrationNumber'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0
                  )
                ),
              ],
            ),
          ),
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
              margin: EdgeInsets.only(right: 15.0, left: 15),
              child: Card(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.supervised_user_circle,
                          color: thirdColor),
                      title: Text('Agentes',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 20.0)),
                      subtitle: Text(
                          'No hay agentes confirmados para este viaje',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 15.0)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                                          Padding(padding: const EdgeInsets.fromLTRB(14,0,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.person,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(
                                                  child: Text('Nombre: ${abc.data!.trips![0].agentes![index].agentFullname}',
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
                                              Text('Empresa: ${abc.data!.trips![0].agentes![index].companyName}',
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
                                                    'tel://${abc.data!.trips![0].agentes![index].agentPhone}',
                                                  )),
                                              child: Container(
                                                  child: Text('Teléfono: ${abc.data!.trips![0].agentes![index].agentPhone}',
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
                                              Text('Entrada: ${abc.data!.trips![0].agentes![index].hourIn}',
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
                                                child: Text( abc.data!.trips![0].agentes![index].agentReferencePoint==null
                                                      ||abc.data!.trips![0].agentes![index].agentReferencePoint==""
                                                      ?"Dirección: ${abc.data!.trips![0].agentes![index].neighborhoodName}, ${abc.data!.trips![0].agentes![index].townName}":'Dirección: ${abc.data!.trips![0].agentes![index].agentReferencePoint}, ${abc.data!.trips![0].agentes![index].neighborhoodName}, ${abc.data!.trips![0].agentes![index].townName},',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      //fontWeight: FontWeight.bold,
                                                      fontSize: 18.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (abc.data!.trips![0].agentes![index].neighborhoodReferencePoint != null)... {
                                          SizedBox(height: 18),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 30),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_pin,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(
                                                  child: Text('Acceso autorizado: ${abc.data!.trips![0].agentes![index].neighborhoodReferencePoint}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        //fontWeight: FontWeight.bold,
                                                        fontSize: 18.0)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        },
                                        SizedBox(height: 30.0),
                                              if (abc
                                                      .data
                                                      !.trips![0]
                                                      .agentes![index]
                                                      .hourForTrip ==
                                                  "00:00") ...{
                                                Text('Hora de encuentro: ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0)),
                                              } else ...{
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                            'Hora de encuentro:',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    18.0)),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                            ' ${abc.data!.trips![0].agentes![index].hourForTrip}',
                                                            style: TextStyle(
                                                                color:
                                                                    thirdColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    19.0))
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              },
                                              SizedBox(height: 10.0),

                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 0,
                                                      blurStyle:
                                                          BlurStyle.solid,
                                                      blurRadius: 10,
                                                      offset: Offset(0,
                                                          0), // changes position of shadow
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                      spreadRadius: 0,
                                                      blurRadius: 5,
                                                      blurStyle:
                                                          BlurStyle.inner,
                                                      offset: Offset(0,
                                                          0), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 40.0),
                                                child: Column(
                                                  children: [
                                                    DateTimeField(decoration:InputDecoration(border: InputBorder.none,),
                                                      keyboardType: TextInputType.datetime,
                                                      format: format,
                                                      onShowPicker: (context,currentValue) async {
                                                        var time =await showTimePicker(context: context,initialTime:TimeOfDay.now(),);                                                            
                                                        validateHour(abc.data!.trips![0].agentes![index].agentId.toString(), abc.data!.trips![0].agentes![index].tripId.toString(), time);
                                                        return DateTimeField.convert(flagalert);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(height: 20.0),
                                        // Usamos una fila para ordenar los botones del card
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
    return FutureBuilder<TripsList2>(
      future: item,
      builder: (BuildContext context, abc) {
        
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![1].noConfirmados!.length == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
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
                  elevation: 10,
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading:
                            Icon(Icons.person,color: thirdColor),
                        title: Text('Agentes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            )),
                        subtitle: Text(
                            'No hay agentes no confirmados para este viaje',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0)),
                      ),
                    ],
                  ),
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
                      Size size = MediaQuery.of(context).size;
                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                        width: size.width,
                        child: Column(
                          children: [
                            Container(
                              child: Card(
                                color: backgroundColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(0.0),
                                elevation: 10,
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
                                                    child: Text('Nombre: ${abc.data!.trips![1].noConfirmados![index].agentFullname}',
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
                                                Text('Empresa: ${abc.data!.trips![1].noConfirmados![index].companyName}',
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
                                                      'tel://${abc.data!.trips![1].noConfirmados![index].agentPhone}',
                                                    )),
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        right: 128),
                                                    child: Text(
                                                        'Teléfono: ${abc.data!.trips![1].noConfirmados![index].agentPhone}',
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
                                                Text('Entrada: ${abc.data!.trips![1].noConfirmados![index].hourIn}',
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
                                                  child: Text(abc.data!.trips![1].noConfirmados![index].agentReferencePoint==null || abc.data!.trips![1].noConfirmados![index].agentReferencePoint==""
                                                          ?"Dirección: ${abc.data!.trips![1].noConfirmados![index].neighborhoodName}, ${abc.data!.trips![1].noConfirmados![index].townName}":'Dirección: ${abc.data!.trips![1].noConfirmados![index].agentReferencePoint}, ${abc.data!.trips![1].noConfirmados![index].neighborhoodName}, ${abc.data!.trips![1].noConfirmados![index].townName},',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        //fontWeight: FontWeight.bold,
                                                        fontSize: 18.0)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (abc.data!.trips![1].noConfirmados![index].neighborhoodReferencePoint != null)... {
                                            SizedBox(height: 18),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 30),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.location_pin,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(
                                                    child: Text('Acceso autorizado: ${abc.data!.trips![1].noConfirmados![index].neighborhoodReferencePoint}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          //fontWeight: FontWeight.bold,
                                                          fontSize: 18.0)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          },
                                          //aqui lo demás
                                          /*SizedBox(height: 30.0),
                                          Text('Hora de encuentro: ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0)),
                                          SizedBox(height: 10.0),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 0,
                                                  blurStyle: BlurStyle.solid,
                                                  blurRadius: 10,
                                                  offset: Offset(0,
                                                      0), // changes position of shadow
                                                ),
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                  spreadRadius: 0,
                                                  blurRadius: 5,
                                                  blurStyle: BlurStyle.inner,
                                                  offset: Offset(0,
                                                      0), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 40.0),
                                            child: Column(
                                              children: [
                                                DateTimeField(
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                  keyboardType:
                                                      TextInputType.datetime,
                                                  format: format,
                                                  onShowPicker: (context,currentValue) async {
                                                    var time =await showTimePicker(context: context,initialTime:TimeOfDay.now(),);                                                        
                                                    validateHour(abc.data!.trips![1].noConfirmados![index].agentId.toString(),abc.data!.trips![1].noConfirmados![index].tripId.toString(), time );                                                    
                                                    return DateTimeField.convert(flagalert);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),*/
                                          SizedBox(height: 20.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                width: 150,
                                                height: 45,
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    textStyle: TextStyle(
                                                      color: Colors
                                                          .white, // foreground
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .red,
                                                                width: 2,
                                                                style:
                                                                    BorderStyle
                                                                        .solid),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
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
                                                        QuickAlert.show(
                                                        context: context,
                                                        type: QuickAlertType.success,
                                                        title: "...",
                                                        text: "¡Cancelado!",                                                        
                                                        );
                                                      },
                                                    );                                                  
                                                  },
                                                  child: Text('No confirmó',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 17)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 30.0),
                                          // Usamos una fila para ordenar los botones del card
                                        ],
                                      ),
                                    ),
                                  
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
            );
          }
        } else {
          return ColorLoader3();
        }
      },
    );
  }


  validateHour(String agentId, String tripId, dynamic time)async{
    //var time =await showTimePicker(context: context,initialTime:TimeOfDay.now(),);    
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
                _refresh();
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
            _refresh();
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
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
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
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(                      
                      leading: Icon(Icons.directions_car, color: thirdColor),
                      title: Text('Agentes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          )),
                      subtitle: Text(
                          'No hay agentes que hayan cancelado este viaje',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 15.0)),
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
              textStyle: TextStyle(
                color: Colors.white, // foreground
              ),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(" Pasar viaje en proceso"),
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
                QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: 'Su viaje está en proceso',
                title: 'Confirmado'
                );
                new Future.delayed(new Duration(seconds: 2), () {
                    fetchPastInProgress();
                  });
              },
              onCancelBtnTap: () {
                Navigator.pop(context);
                QuickAlert.show(
                context: context,
                title: "...",
                type: QuickAlertType.success,
                text: "¡Cancelado!",                                
                );
              },
              );
            },
          ),
          SizedBox(width: 5),
          ElevatedButton(
            style: TextButton.styleFrom(
              textStyle: TextStyle(
                color: Colors.white, // foreground
              ),
              // foreground
              backgroundColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Marcar agentes como "Cancelados"'),
            onPressed: () {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                title: "...",
                text: "¿Está seguro que desea marcarlos como cancelados?",
                confirmBtnText: "Confirmar",
                cancelBtnText: "Cancelar",
                showCancelBtn: true,  
                confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
                onConfirmBtnTap: () {
                  Navigator.pop(context);
                  QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text: "Han sido marcado como cancelados",                
                  );
                  new Future.delayed(new Duration(seconds: 2), () {
                      fetchTripAgentsNotConfirm();
                    });
                },
                onCancelBtnTap: () {
                  Navigator.pop(context);
                  QuickAlert.show(
                  context: context,
                  title: "...",
                  type: QuickAlertType.success,
                  text: "¡Entendido!",                
                  );
                },
              );
            },
          ),     
        ],
      ),
    );
  }
}