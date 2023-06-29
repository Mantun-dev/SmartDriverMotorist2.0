//import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatViews.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/trip_In_Process.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/agentInProgress.dart';
import 'package:flutter_auth/Drivers/models/comment.dart';
import 'package:flutter_auth/Drivers/models/messageDriver.dart';
import 'package:flutter_auth/Drivers/models/messageTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/registerTripAsCompleted.dart';
import 'package:flutter_auth/main.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:flutter_auth/constants.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

import '../../../components/progress_indicator.dart';
import 'details_TripProgress.dart';
import 'package:geolocator/geolocator.dart';

//import 'package:shop_app/screens/details/details_screen.dart';

//import '../../constants.dart';

void main() {
  runApp(MyConfirmAgent());
}

class MyConfirmAgent extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;

  const MyConfirmAgent({Key? key, this.plantillaDriver})
      : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyConfirmAgent> {
  Future<TripsList4>? item;
  Future<DriverData>? driverData;
  bool traveled = false;
  final tmpArray = [];
  bool traveled1 = true;
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";
  var tripId;

  List<TextEditingController> check = [];
  List<TextEditingController> comment = new List.empty(growable: true);
  TextEditingController vehicleController = new TextEditingController();
  TextEditingController agentEmployeeId = new TextEditingController();

  var tripVehicle = '';
  bool vehicleL = false;

  Future<Message> fetchCheckAgentTrip(String agentId) async {
    int flag = (traveled) ? 1 : 0;

    Map datas = {
      'agentId': agentId,
      'tripId': prefs.tripId,
      'traveled': flag.toString()
    };
    print(datas);

    http.Response response =
        await http.post(Uri.parse('$ip/apis/agentCheckIn'), body: datas);

    final resp = Message.fromJson(json.decode(response.body));

    if (response.statusCode == 200 && resp.ok == true) {
      print('enviado');
    } else if (response.statusCode == 500) {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: resp.message,
      );
    }

    return Message.fromJson(json.decode(response.body));
  }

  Future<Driver2> fetchRegisterTripCompleted() async {
    http.Response response = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(response.body));

    http.Response responses = await http
        .get(Uri.parse('https://admin.smtdriver.com/test/registerTripAsCompleted/${prefs.tripId}/${data.driverId}/mobile'));
        print(responses.body);
    final si = Driver2.fromJson(json.decode(responses.body));
    
    //print(responses.body);
    LoadingIndicatorDialog().dismiss();
    if (responses.statusCode == 200 && si.ok!) {
      Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => HomeDriverScreen(),
              ),
              (Route<dynamic> route) => false,
            );
      if (mounted) {  
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Completado',
          text: 'Su viaje ha sido completado',
        );    
      }
                
    } else if (si.ok != true) {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: si.title,
      text: si.message,
      );      
    }
    Map data2 = {"Estado": 'FINALIZADO'};
      String sendData2 = json.encode(data2);
      http.Response response2 = await http
        .put(Uri.parse('https://apichat.smtdriver.com/api/salas/Viaje_Estado/${prefs.tripId}'), body: sendData2, headers: {"Content-Type": "application/json"});
    print(response2.body);
    return Driver2.fromJson(json.decode(responses.body));
    //throw Exception('Failed to load Data');
  }

  Future<Driver> fetchRegisterCommentAgent(String agentId, String tripId, String comment) async {
    Map datas = {'agentId': agentId, 'tripId': tripId};
    Map datas2 = {
      'agentId': agentId,
      'tripId': tripId,
      'commentDriver': comment
    };

    
    http.Response responses =
        await http.post(Uri.parse('$ip/apis/getDriverComment'), body: datas);
    final si = Driver.fromJson(json.decode(responses.body));
    http.Response response = await http
        .post(Uri.parse('$ip/apis/agentTripSetComment'), body: datas2);
    print(responses.body);
    print(response.body);
    if (responses.statusCode == 200 &&
        si.ok == true &&
        responses.statusCode == 200) {
          QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Enviado',
      text: si.message,
      );
      Navigator.pop(context);
    } else if (si.ok != true) {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: si.title,
      text: si.message,
      );
    }
    return Driver.fromJson(json.decode(responses.body));
  }

  Future<Driver> fetchRegisterAgentDidntGetOut(
    String agentId,
    String tripId,
  ) async {
    Map datas = {'agentId': agentId, 'tripId': tripId};
    http.Response responses =
        await http.post(Uri.parse('$ip/apis/agentDidntGetOut'), body: datas);
    final si = Driver.fromJson(json.decode(responses.body));

    print(responses.body);
    if (responses.statusCode == 200 && si.ok!) {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: si.title,
      text: si.message,
      );
    } else if (si.ok != true) {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: si.title,
      text: si.message,
      );
    }
    return Driver.fromJson(json.decode(responses.body));
  }

  Future<Driver> fetchTripCancel() async {
    http.Response responses = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(responses.body));
    http.Response response = await http.get(Uri.parse(
        '$ip/apis/driverCancelTrip/${prefs.tripId}/${data.driverId}'));

    final resp = Driver.fromJson(json.decode(response.body));

    if (response.statusCode == 200 && resp.ok == true) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomeDriverScreen()),
          (Route<dynamic> route) => false);
    } else if (response.statusCode == 500) {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Ok',
      text: resp.message,
      );
    }

    Map data2 = {"Estado": 'FINALIZADO'};
    String sendData2 = json.encode(data2);
    await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/Viaje_Estado/${prefs.tripId}'), body: sendData2, headers: {"Content-Type": "application/json"});      
    return Driver.fromJson(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    setUb(2);
    item = fetchAgentsTripInProgress();
    comment = new List<TextEditingController>.empty(growable: true);
    check = [];
    driverData = fetchRefres();
    getInfoViaje();
  }

  void getInfoViaje() async{
    http.Response responseSala = await http.get(Uri.parse('$ip/apis/agentsInTravel/${prefs.tripId}'));
    final infoViaje = json.decode(responseSala.body);
   

    if(mounted){
      if(infoViaje[3]['viajeActual']['tripVehicle']!=null){

        setState(() {
          tripVehicle = infoViaje[3]['viajeActual']['tripVehicle'];
          vehicleL = true;
          vehicleController.text=tripVehicle;
          tripId=infoViaje[3]['viajeActual']['tripId'];
        });
      }else{
        setState(() {
          tripVehicle = '';
          vehicleL = true;
          vehicleController.text=tripVehicle;
          tripId=infoViaje[3]['viajeActual']['tripId'];
        });
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: backgroundColor,
          drawer: DriverMenuLateral(),
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 10,
            actions: <Widget>[
              IconButton(
                icon:
                    Icon(Icons.textsms_rounded, color: thirdColor, size: 30.0),
                onPressed: () {
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
                icon: Icon(Icons.arrow_circle_left),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Process();
                      },
                    ),
                  );
                  SizedBox(width: kDefaultPadding / 2);
                },
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: ListView(children: <Widget>[
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(' Viaje en proceso ',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: GradiantV_2,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0)),
              ),
              SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(horizontal: 15.0),
                width: 300,
                height: 90,
                child: Column(
                  children: [
                    SizedBox(height: 10.0),
                    Center(
                        child: Text(
                            'Nota: Debe marcar el abordaje al momento en que el agente ingrese a la unidad, en caso de no abordar, solo debe llenar la observación.',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0))),
                  ],
                ),
              ),
              ingresarVehiculo(),
              
              escanearAgente(context),   
              SizedBox(height: 10.0),
              _agentToConfirm(),
              SizedBox(height: 10.0),
            ]),
          )),
    );
  }

  Widget escanearAgente(BuildContext contextP) {

    return FutureBuilder<TripsList4>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          return Column(
            children: [
              SizedBox(height: 10.0),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Text('Escanee el codigo del agente', style: TextStyle(color: Colors.white70,fontWeight: FontWeight.normal,fontSize: 15.0),),
                      SizedBox(height: 5),
                      Row(
                        children: [
                           GestureDetector(
                            onTap: (){
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
                                                  onPressed: () async{
                                                   
                                                      LoadingIndicatorDialog().show(context);

                                                      Map data =   {
                                                        'agentUser':agentEmployeeId.text, 
                                                        'tripId':tripId.toString(),
                                                        'itsManualSearch':"1"
                                                      };

                                                      print(data);

                                                      http.Response response = await http
                                                          .post(Uri.parse('https://driver.smtdriver.com/apis/agents/validateCheckIn'), body: data);

                                                      final resp = json.decode(response.body);

                                                      if(mounted){
                                                        LoadingIndicatorDialog().dismiss();
                                                        if(resp['type']=='error'){
                                                          return;
                                                        } 

                                                        if(resp['allow']==0){
                                                          LoadingIndicatorDialog().dismiss();
                                                          QuickAlert.show(
                                                            context: context,
                                                            title: '¡Alerta!',
                                                            text: resp['msg'],
                                                            type: QuickAlertType.warning,
                                                          ); 
                                                          return;
                                                        } 

                                                        int index = 0;

                                                        for (int i = 0; i < abc.data!.trips![0].tripAgent!.length; i++) {  
                                                          if(abc.data!.trips![0].tripAgent![i].agentId==resp['agentId']){

                                                            if(abc.data!.trips![0].tripAgent![i].traveled == 1){
                                                              traveled = true;
                                                            }else{
                                                              traveled = false;
                                                            }
                                                            index = i;
                                                          }
                                                        }

                                                        LoadingIndicatorDialog().dismiss();
                                                        QuickAlert.show(
                                                          context: contextP,
                                                          type: QuickAlertType.confirm,
                                                          title: traveled==true ?'No abordó':'Abordó',
                                                          text: traveled==true ?"¿Está seguro que desea marcar como no \nabordado al agente ${abc.data!.trips![0].tripAgent![index].agentFullname}?":"¿Está seguro que desea marcar como \nabordado al agente ${abc.data!.trips![0].tripAgent![index].agentFullname}?",
                                                          confirmBtnText: 'Confirmar',
                                                          cancelBtnText: 'Cancelar',
                                                          showCancelBtn: true,  
                                                          confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                                          cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),
                                                          onConfirmBtnTap: () async{

                                                            Navigator.pop(contextP);

                                                            LoadingIndicatorDialog().show(contextP);
                                                            if(traveled==false && abc.data!.trips![0].tripAgent![index].didntGetOut==1){
                                                              abc.data!.trips![0].tripAgent![index].didntGetOut=0;
                                                              fetchRegisterCommentAgent(
                                                              abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                                              prefs.tripId,
                                                              ''
                                                            );  
                                                            }

                                                            if(abc.data!.trips![0].tripAgent![index].commentDriver=="Canceló transporte"){
                                                              abc.data!.trips![0].tripAgent![index].commentDriver="";

                                                              fetchRegisterCommentAgent(
                                                              abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                                              prefs.tripId,
                                                              ''
                                                            );   
                                                            }
                                                            Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                      
                                                            traveled = !traveled;
                                                            abc.data!.trips![0].tripAgent![index].traveled = traveled;
                                                            
                                                            Map data =   {
                                                              'agentId':abc.data!.trips![0].tripAgent![index].agentId.toString(), 
                                                              'tripId':tripId.toString(),
                                                              'latitude':position.latitude.toString(),
                                                              'longitude':position.longitude.toString(),
                                                              'actionName':'Abordaje'
                                                            };
                                                          
                                                            http.Response response2 = await http.post(Uri.parse('https://driver.smtdriver.com/apis/agents/registerTripAction'), body: data);
                                                            final resp2 = json.decode(response2.body);
                                                            Navigator.pop(contextP);
                                                            LoadingIndicatorDialog().dismiss();
                                                            

                                                            QuickAlert.show(
                                                            context: context,
                                                            title: resp2['title'],
                                                            text: "El agente ${abc.data!.trips![0].tripAgent![index].agentFullname} ha abordado.",
                                                            type: QuickAlertType.success,
                                                          ); 
                                                          agentEmployeeId.text='';
                                                          setState(() { });
                                                          },
                                                          onCancelBtnTap: () {
                                                            Navigator.pop(contextP);
                                                          },
                                                        );
                                                    
                                                      }
                                                    
                                                  },
                                                  child: Text('Abordar',style: TextStyle(color: backgroundColor,fontSize: 15.0)),
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
                             child: Container(
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.all(Radius.circular(15)),
                                 boxShadow: [
                                   BoxShadow(color: Colors.black.withOpacity(0.2),spreadRadius: 0,blurStyle: BlurStyle.solid,blurRadius: 10,offset: Offset(0, 0), ),
                                   BoxShadow(color: Colors.white.withOpacity(0.1),spreadRadius: 0,blurRadius: 5,blurStyle: BlurStyle.inner,offset: Offset(0, 0), ),
                                 ],
                               ),
                               width: 220,
                               child: Padding(
                                 padding: const EdgeInsets.all(10),
                                 child: Row(
                                   children: [
                                    Icon(Icons.person,color: thirdColor,size: 30.0,),
                                    SizedBox(width: 10.0),
                                     Text(
                                       'Abordar Agente',
                                       style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
                                     ),
                                   ],
                                 ),
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
                              onPressed: () async{
                                
                                String codigoQR = await FlutterBarcodeScanner.scanBarcode("#9580FF", "Cancelar", true, ScanMode.QR);
                      
                                if (codigoQR == "-1") {
                                  return;
                                } else {
                                  LoadingIndicatorDialog().show(context);

                                  Map data =   {
                                    'agentUser':codigoQR, 
                                    'tripId':tripId.toString()
                                  };

                                  print(data);
                                  http.Response response = await http
                                      .post(Uri.parse('https://driver.smtdriver.com/apis/agents/validateCheckIn'), body: data);

                                  final resp = json.decode(response.body);

                                  if(mounted){
                                    LoadingIndicatorDialog().dismiss();
                                    if(resp['type']=='error'){
                                      return;
                                    } 

                                    if(resp['allow']==0){
                                      LoadingIndicatorDialog().dismiss();
                                      QuickAlert.show(
                                        context: context,
                                        title: '¡Alerta!',
                                        text: resp['msg'],
                                        type: QuickAlertType.warning,
                                      ); 
                                      return;
                                    } 

                                    int index = 0;

                                    for (int i = 0; i < abc.data!.trips![0].tripAgent!.length; i++) {  
                                      if(abc.data!.trips![0].tripAgent![i].agentId==resp['agentId']){

                                        if(abc.data!.trips![0].tripAgent![i].traveled == 1){
                                          traveled = true;
                                        }else{
                                          traveled = false;
                                        }
                                        index = i;
                                      }
                                    }

                                    LoadingIndicatorDialog().dismiss();
                                    QuickAlert.show(
                                      context: contextP,
                                      type: QuickAlertType.confirm,
                                      title: traveled==true ?'No abordó':'Abordó',
                                      text: traveled==true ?"¿Está seguro que desea marcar como no \nabordado al agente ${abc.data!.trips![0].tripAgent![index].agentFullname}?":"¿Está seguro que desea marcar como \nabordado al agente ${abc.data!.trips![0].tripAgent![index].agentFullname}?",
                                      confirmBtnText: 'Confirmar',
                                      cancelBtnText: 'Cancelar',
                                      showCancelBtn: true,  
                                      confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                      cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),
                                      onConfirmBtnTap: () async{

                                        Navigator.pop(contextP);

                                        LoadingIndicatorDialog().show(contextP);
                                        if(traveled==false && abc.data!.trips![0].tripAgent![index].didntGetOut==1){
                                          abc.data!.trips![0].tripAgent![index].didntGetOut=0;
                                          fetchRegisterCommentAgent(
                                          abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                          prefs.tripId,
                                          ''
                                        );  
                                        }

                                        if(abc.data!.trips![0].tripAgent![index].commentDriver=="Canceló transporte"){
                                          abc.data!.trips![0].tripAgent![index].commentDriver="";

                                          fetchRegisterCommentAgent(
                                          abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                          prefs.tripId,
                                          ''
                                        );   
                                        }
                                        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  
                                        traveled = !traveled;
                                        abc.data!.trips![0].tripAgent![index].traveled = traveled;
                                        
                                        Map data =   {
                                          'agentId':abc.data!.trips![0].tripAgent![index].agentId.toString(), 
                                          'tripId':tripId.toString(),
                                          'latitude':position.latitude.toString(),
                                          'longitude':position.longitude.toString(),
                                          'actionName':'Abordaje'
                                        };
                                      
                                        http.Response response2 = await http.post(Uri.parse('https://driver.smtdriver.com/apis/agents/registerTripAction'), body: data);
                                        final resp2 = json.decode(response2.body);

                                        LoadingIndicatorDialog().dismiss();
                                        

                                        QuickAlert.show(
                                        context: context,
                                        title: resp2['title'],
                                        text: "El agente ${abc.data!.trips![0].tripAgent![index].agentFullname} ha abordado.",
                                        type: QuickAlertType.success,
                                      ); 

                                      setState(() { });
                                      },
                                      onCancelBtnTap: () {
                                        Navigator.pop(contextP);
                                      },
                                    );
                                
                                  }
                                }
                              }
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        } else {
          return ColorLoader3();
        }
      },
    );
  }

  Widget ingresarVehiculo() {

    return FutureBuilder<TripsList4>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: FutureBuilder<DriverData>(
              future: driverData,
              builder: (BuildContext context, abc) {
                if (abc.connectionState == ConnectionState.done) {
                  DriverData? data = abc.data;
                  return Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      if(data?.driverType=='Motorista')
                        Text('Escanee el codigo qr del vehículo', style: TextStyle(color: Colors.white70,fontWeight: FontWeight.normal,fontSize: 15.0),),
                      if(data?.driverType=='Motorista')
                        SizedBox(height: 5,),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.2),spreadRadius: 0,blurStyle: BlurStyle.solid,blurRadius: 10,offset: Offset(0, 0), ),
                                BoxShadow(color: Colors.white.withOpacity(0.1),spreadRadius: 0,blurRadius: 5,blurStyle: BlurStyle.inner,offset: Offset(0, 0), ),
                              ],
                            ),
                            width: 200,
                            child: Padding(
                              padding: const EdgeInsets.only(left:10.0, right: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.emoji_transportation,color: thirdColor,size: 30.0,),
                                  SizedBox(width: 10.0),
                                  Flexible(
                                    child: TextField(
                                      enabled: data?.driverType=='Motorista'?false:true,
                                      style: TextStyle(color: Colors.white),
                                      controller: vehicleController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Vehículo',
                                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5),
                                        fontSize: 15.0)
                                      ),
                                      onChanged: (value) => tripVehicle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if(data?.driverType!='Motorista')
                            SizedBox(width: 10,),
                          
                          if(data?.driverType!='Motorista')
                            Container(
                                decoration: BoxDecoration(
                                  color: firstColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.save_outlined),
                                  color: backgroundColor,
                                  iconSize: 30.0,
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

  Widget _agentToConfirm() {

    bool traveledB(abc,index){
      return (abc.data!.trips![0].tripAgent![index].traveled ==0)
        ? false
      : (abc.data!.trips![0].tripAgent![index].traveled ==1)
        ? true
      : (abc.data!.trips![0].tripAgent![index].traveled == null)
        ? abc.data!.trips![0].tripAgent![index].traveled 
      ??false
      : (abc.data!.trips![0].tripAgent![index].traveled == true)
        ? abc.data!.trips![0].tripAgent![index].traveled 
      ??false : false;
    }

    alertaAbordo(abc, index, isChecked)async{
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,          
        text: isChecked==false ?"¿Está seguro que desea marcar como no \nabordado al agente?":"¿Está seguro que desea marcar como \nabordado al agente?",
        confirmBtnText: "Confirmar",
        cancelBtnText: "Cancelar",
        title: isChecked==false ?'No abordó':'Abordó',
        showCancelBtn: true,  
        confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
        cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
        onConfirmBtnTap: () {

          if(traveled==false && abc.data!.trips![0].tripAgent![index].didntGetOut==1){
            abc.data!.trips![0].tripAgent![index].didntGetOut=0;
            fetchRegisterCommentAgent(
            abc.data!.trips![0].tripAgent![index].agentId.toString(),
            prefs.tripId,
            ''
          );  
          }

          if(abc.data!.trips![0].tripAgent![index].commentDriver=="Canceló transporte"){
            abc.data!.trips![0].tripAgent![index].commentDriver="";

            fetchRegisterCommentAgent(
            abc.data!.trips![0].tripAgent![index].agentId.toString(),
            prefs.tripId,
            ''
          );   
          }

          traveled = isChecked!;
          abc.data!.trips![0].tripAgent![index].traveled = traveled;
          if (isChecked == true) {
            print('subio');
            fetchCheckAgentTrip(abc.data!.trips![0].tripAgent![index].agentId.toString());
            print('////////');
          } else if (isChecked == false) {
            print('bajo');
            fetchCheckAgentTrip(abc.data!.trips![0].tripAgent![index].agentId.toString());
            print('////////');
          }
          Navigator.pop(context);
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
      ); 
      
      setState(() {});
    }

    // ignore: non_constant_identifier_names
    alertaPaso_noSalio(abc, index)async{
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,          
        text: "¿Está seguro que desea marcar como no salio el agente?",
        confirmBtnText: "Confirmar",
        cancelBtnText: "Cancelar",
        title: '¿Está seguro?',
        showCancelBtn: true,  
        confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
        cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
        onConfirmBtnTap: () async{
          LoadingIndicatorDialog().show(context);
          //fetchRegisterAgentDidntGetOut(abc.data!.trips![0].tripAgent![index].agentId.toString(),prefs.tripId);
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          Map data =   {
            'agentId':abc.data!.trips![0].tripAgent![index].agentId.toString(), 
            'tripId':tripId.toString(),
            'latitude':position.latitude.toString(),
            'longitude':position.longitude.toString(),
            'actionName':'No salió'
          };
                                      
        http.Response response = await http.post(Uri.parse('https://driver.smtdriver.com/apis/agents/registerTripAction'), body: data);
        
        LoadingIndicatorDialog().dismiss();

          abc.data!.trips![0].tripAgent![index].didntGetOut = 1;
          if(abc.data!.trips![0].tripAgent![index].traveled = traveled){
            abc.data!.trips![0].tripAgent![index].traveled = false;
            traveled = abc.data!.trips![0].tripAgent![index].traveled;
          }        

          if(abc.data!.trips![0].tripAgent![index].commentDriver=="Canceló transporte"){
            abc.data!.trips![0].tripAgent![index].commentDriver="Pasé por él (ella) y no salió";
          }
          Navigator.pop(context);
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
      ); 
      
      setState(() {});
    }

    alertaCancelo(abc, index)async{
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,          
        text: "¿Está seguro que desea marcar como canceló transporte?",
        confirmBtnText: "Confirmar",
        cancelBtnText: "Cancelar",
        title: '¿Está seguro?',
        showCancelBtn: true,  
        confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
        cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
        onConfirmBtnTap: () {

          fetchRegisterCommentAgent(
            abc.data!.trips![0].tripAgent![index].agentId.toString(),
            prefs.tripId,
            'Canceló transporte'
          );   
          if(abc.data!.trips![0].tripAgent![index].didntGetOut==1){
            abc.data!.trips![0].tripAgent![index].didntGetOut=0;
          }

          if(abc.data!.trips![0].tripAgent![index].traveled = true){
            abc.data!.trips![0].tripAgent![index].traveled = false;
            traveled = abc.data!.trips![0].tripAgent![index].traveled;

            fetchCheckAgentTrip(abc.data!.trips![0].tripAgent![index].agentId.toString());
          }  

          setState(() {
            abc.data!.trips![0].tripAgent![index].commentDriver='Canceló transporte';
          });
          Navigator.pop(context);
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
      ); 
      
      setState(() {});
    }
    Size size = MediaQuery.of(context).size;
    return FutureBuilder<TripsList4>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![0].tripAgent!.length == 0) {
            return Card(
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.bus_alert),
                    title: Text('Agentes',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 20.0)),
                    subtitle: Text('No hay agentes confirmados para este viaje',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0)),
                  ),
                ],
              ),
            );
          } else {

            List<TextEditingController> check = [];
            for (int i = 0; i < abc.data!.trips![0].tripAgent!.length; i++) {
              check.add(TextEditingController());
            }
            
            return abc.data!.trips![1].actualTravel!.tripType=='Salida' ?Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin:  EdgeInsets.only(left: 18),
                    child: Text(
                        'Total de agentes: ${abc.data!.trips![0].tripAgent!.length}',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0)),
                  ),
                ),
                SizedBox(height: 10.0),
                Center(child: _buttonsAgents()),
              SizedBox(height: 10.0),
                Container(
                  height: size.height*0.38, 
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: abc.data!.trips![0].tripAgent!.length,
                      itemBuilder: (context, index) {
                
                        return Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                blurStyle: BlurStyle.normal,
                                color:  traveledB(abc,index)==true ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: -18,
                                offset: Offset(-15, -6)),
                            BoxShadow(
                                blurStyle: BlurStyle.normal,
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: -15,
                                offset: Offset(18, 5)),
                          ]),
                          width: 500.0,
                          child: Card(
                            color: backgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(15.0),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ExpansionTile(
                                backgroundColor: backgroundColor,
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        SizedBox(width: 3.0),
                                        RoundCheckBox(
                                            border: Border.all(
                                                style: BorderStyle.none),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            uncheckedColor: Colors.red,
                                            uncheckedWidget: Icon(
                                              Icons.close,
                                              color: backgroundColor,
                                              size: 15,
                                            ),
                                            checkedColor: firstColor,
                                            checkedWidget: Icon(
                                              Icons.check,
                                              color: backgroundColor,
                                              size: 15,
                                            ),
                                            size: 20,
                                            isChecked: traveledB(abc,index),
                                            onTap: (bool? isChecked) {
                                              alertaAbordo(abc, index, isChecked);
                                            }),
                                        SizedBox(width: 15.0),
                                        Text('Abordó ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20.0)),
                                      ],
                                    ),
                                    SizedBox(height: 15,),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.person,color: thirdColor),
                                          SizedBox(width: 15,),
                                          Flexible(
                                            child: Text('Nombre: ${abc.data!.trips![0].tripAgent![index].agentFullname}',
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
                                  Container(
                                    margin: EdgeInsets.only(left: 18),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_city,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Flexible(
                                              child: Text('Empresa: ${abc.data!.trips![0].tripAgent![index].companyName}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            ),
                                          ],
                                        ),
                                      ), 
                                      SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.phone,color: thirdColor),
                                            SizedBox(width: 7,),
                                            Flexible(
                                              child: TextButton(
                                              onPressed: () => launchUrl(
                                                  Uri.parse(
                                                      'tel://${abc.data!.trips![0].tripAgent![index].agentPhone}')),
                                              child: Container(
                                                  child: Text(
                                                      'Teléfono: ${abc.data!.trips![0].tripAgent![index].agentPhone}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight
                                                                  .normal,
                                                          fontSize: 18.0)))
                                                          ),
                                            ),
                                          ],
                                        ),
                                      ),                  
                                      SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Flexible(
                                              child: Text('Entrada: ${abc.data!.trips![0].tripAgent![index].hourIn}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_pin,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Flexible(
                                              child: Text(abc.data!.trips![0].tripAgent![index].agentReferencePoint==null
                                                      ||abc.data!.trips![0].tripAgent![index].agentReferencePoint==""
                                                      ?"Dirección: ${abc.data!.trips![0].tripAgent![index].neighborhoodName}, ${abc.data!.trips![0].tripAgent![index].townName}":'Dirección: ${abc.data!.trips![0].tripAgent![index].agentReferencePoint}, ${abc.data!.trips![0].tripAgent![index].neighborhoodName}, ${abc.data!.trips![0].tripAgent![index].townName},',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            ),
                                          ],
                                        ),
                                      ), 
                                    if (abc.data!.trips![0].tripAgent![index].neighborhoodReferencePoint != null)... {
                                      SizedBox(height: 15,),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning_amber_outlined,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Flexible(child: Text('Acceso autorizado: ${abc.data!.trips![0].tripAgent![index].neighborhoodReferencePoint}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            ),
                                          ],
                                        ),
                                      ), 
                                    },
                                    SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Column(
                                              crossAxisAlignment :CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Hora de encuentro: ',style: TextStyle(color: Colors.white,fontSize: 18.0)),
                                                Text(textAlign:TextAlign.start,'${abc.data!.trips![0].tripAgent![index].hourForTrip}',style: TextStyle(
                                                  color: firstColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15.0),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 150,
                                            height: 40,
                                            decoration:
                                                BoxDecoration(boxShadow: [
                                              BoxShadow(
                                                  blurStyle: BlurStyle.normal,
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  blurRadius: 15,
                                                  spreadRadius: -10,
                                                  offset: Offset(-15, -6)),
                                              BoxShadow(
                                                  blurStyle: BlurStyle.normal,
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  blurRadius: 30,
                                                  spreadRadius: -15,
                                                  offset: Offset(18, 5)),
                                            ]),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                textStyle: TextStyle(
                                                    color: backgroundColor),
                                                // foreground
                                                backgroundColor: firstColor,
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        style:
                                                            BorderStyle.none),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                              ),
                                              onPressed: () async {
                                                http.Response response =
                                                    await http.get(Uri.parse(
                                                        '$ip/apis/getDriverComment/${abc.data!.trips![0].tripAgent![index].agentId}/${abc.data!.trips![0].tripAgent![index].tripId}'));
                                                final send = Comment.fromJson(
                                                    json.decode(
                                                        response.body));
                                                    check[index].text = send.comment!.commentDriver;
                                                showGeneralDialog(
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.5),
                                                    transitionBuilder:
                                                        (context, a1, a2,
                                                            widget) {
                                                      return Transform.scale(
                                                        scale: a1.value,
                                                        child: Opacity(
                                                          opacity: a1.value,
                                                          child: AlertDialog(
                                                            backgroundColor:
                                                                backgroundColor,
                                                            shape: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0)),
                                                            title: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      25.0),
                                                              child: Text(
                                                                  '¿Razón por la cual no ingresó a la unidad?',
                                                                  style: TextStyle(
                                                                      color:
                                                                          GradiantV_2,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20)),
                                                            ),
                                                            content:
                                                                Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            15)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.2),
                                                                    spreadRadius:
                                                                        0,
                                                                    blurStyle:
                                                                        BlurStyle
                                                                            .solid,
                                                                    blurRadius:
                                                                        10,
                                                                    offset: Offset(
                                                                        0,
                                                                        0), // changes position of shadow
                                                                  ),
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.1),
                                                                    spreadRadius:
                                                                        0,
                                                                    blurRadius:
                                                                        5,
                                                                    blurStyle:
                                                                        BlurStyle
                                                                            .inner,
                                                                    offset: Offset(
                                                                        0,
                                                                        0), // changes position of shadow
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15.0),
                                                                child:
                                                                    TextField(
                                                                  cursorColor:
                                                                      firstColor,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                  decoration: InputDecoration(
                                                                      border: InputBorder
                                                                          .none,
                                                                      hintText:
                                                                          'Escriba aquí',
                                                                      hintStyle:
                                                                          TextStyle(color: Colors.white70)),
                                                                  controller:
                                                                      check[
                                                                          index],
                                                                ),
                                                              ),
                                                            ),
                                                            actions: [
                            
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(15)),
                                                                    width: 95,
                                                                    height:
                                                                        40,
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(30), // <-- Radius
                                                                          ),
                                                                          elevation: 10,
                                                                          textStyle: TextStyle(color: Colors.white), // foreground
                                                                          backgroundColor: Gradiant2),
                                                                      onPressed:
                                                                          () =>
                                                                              {
                                                                                if(check[index].text.isEmpty){
                                                                                  Navigator.pop(context),
                                                                                  QuickAlert.show(
                                                                                    context: context,
                                                                                    type: QuickAlertType.error,
                                                                                    title: 'Alerta',
                                                                                    text: 'No puede ir vacío la observación',
                                                                                  ),
                                                                                }else{
                                                                                fetchRegisterCommentAgent(
                                                                                    abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                                                                    prefs.tripId,
                                                                                    check[index].text),
                                                                                Navigator.pop(
                                                                                    context),
                                                                                }
                                                                      },
                                                                      child: Text(
                                                                          'Guardar',
                                                                          style: TextStyle(
                                                                              color: backgroundColor,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15)),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 95,
                                                                    height:
                                                                        40,
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(30), // <-- Radius
                                                                          ),
                                                                          textStyle: TextStyle(color: Colors.white), // foreground
                                                                          // foreground
                                                                          backgroundColor: Colors.red),
                                                                      onPressed:
                                                                          () =>
                                                                              {
                                                                        Navigator.pop(
                                                                            context),
                                                                      },
                                                                      child: Text(
                                                                          'Cerrar',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      10.0),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    transitionDuration:
                                                        Duration(
                                                            milliseconds:
                                                                200),
                                                    barrierDismissible: true,
                                                    barrierLabel: '',
                                                    context: context,
                                                    pageBuilder: (context,
                                                        animation1,
                                                        animation2) {
                                                      return Text('');
                                                    });
                                              },
                                              child: Text('Observaciones',
                                                  style: TextStyle(
                                                    color: backgroundColor,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.0),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ) : Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin:  EdgeInsets.only(left: 18),
                    child: Text(
                        'Total de agentes: ${abc.data!.trips![0].tripAgent!.length}',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0)),
                  ),
                ),
              SizedBox(height: 10.0),
              Center(child: _buttonsAgents()),
              SizedBox(height: 10.0),
                Container(
                  height: size.height*0.38, 
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: abc.data!.trips![0].tripAgent!.length,
                      itemBuilder: (context, index) {
                
                        return Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                blurStyle: BlurStyle.normal,
                                color:  traveledB(abc,index)==true ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: -18,
                                offset: Offset(-15, -6)),
                            BoxShadow(
                                blurStyle: BlurStyle.normal,
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: -15,
                                offset: Offset(18, 5)),
                          ]),
                          width: 500.0,
                          child: Card(
                            color: backgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(15.0),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ExpansionTile(
                                backgroundColor: backgroundColor,
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    /*Row(
                                      children: [
                                        SizedBox(width: 3.0),
                                        traveledB(abc,index)==true ? RoundCheckBox(
                                            border: Border.all(
                                                style: BorderStyle.none),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            uncheckedColor: Colors.red,
                                            uncheckedWidget: Icon(
                                              Icons.close,
                                              color: backgroundColor,
                                              size: 15,
                                            ),
                                            checkedColor: firstColor,
                                            checkedWidget: Icon(
                                              Icons.check,
                                              color: backgroundColor,
                                              size: 15,
                                            ),
                                            size: 20,
                                            isChecked: traveledB(abc,index),
                                            onTap: (bool? isChecked) {
                                              alertaAbordo(abc, index, isChecked);
                                            }
                                          ) 
                                          :Icon(
                                            Icons.close,
                                            color:Colors.red,
                                            size: 15,
                                          ),
                                        
                                        SizedBox(width: 15.0),
                                        Text('Abordó ',
                                        style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20.0)),
                            
                                      ],
                                    ),*/
                                    Row(
                                      children: [
                                        SizedBox(width: 3.0),
                                        RoundCheckBox(
                                            border: Border.all(
                                                style: BorderStyle.none),
                                            animationDuration:
                                                Duration(seconds: 1),
                                            uncheckedColor: Colors.red,
                                            uncheckedWidget: Icon(
                                              Icons.close,
                                              color: backgroundColor,
                                              size: 15,
                                            ),
                                            checkedColor: firstColor,
                                            checkedWidget: Icon(
                                              Icons.check,
                                              color: backgroundColor,
                                              size: 15,
                                            ),
                                            size: 20,
                                            isChecked: traveledB(abc,index),
                                            onTap: (bool? isChecked) {
                                              alertaAbordo(abc, index, isChecked);
                                            }),
                                        SizedBox(width: 15.0),
                                        Text('Abordó ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20.0)),
                                      ],
                                    ),
                                    SizedBox(height: 15,),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.person,color: thirdColor),
                                          SizedBox(width: 15,),
                                          Flexible(
                                            child: Text('Nombre: ${abc.data!.trips![0].tripAgent![index].agentFullname}',
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
                                  Container(
                                    margin: EdgeInsets.only(left: 18),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_city,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Flexible(
                                              child: Text('Empresa: ${abc.data!.trips![0].tripAgent![index].companyName}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            ),
                                          ],
                                        ),
                                      ), 
                                      SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.phone,color: thirdColor),
                                            SizedBox(width: 7,),
                                            Flexible(
                                              child: TextButton(
                                              onPressed: () => launchUrl(
                                                  Uri.parse(
                                                      'tel://${abc.data!.trips![0].tripAgent![index].agentPhone}')),
                                              child: Container(
                                                  child: Text(
                                                      'Teléfono: ${abc.data!.trips![0].tripAgent![index].agentPhone}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight
                                                                  .normal,
                                                          fontSize: 18.0)))
                                                          ),
                                            ),
                                          ],
                                        ),
                                      ),                  
                                      SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Flexible(
                                              child: Text('Entrada: ${abc.data!.trips![0].tripAgent![index].hourIn}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_pin,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Flexible(
                                              child: Text(abc.data!.trips![0].tripAgent![index].agentReferencePoint==null
                                                      ||abc.data!.trips![0].tripAgent![index].agentReferencePoint==""
                                                      ?"Dirección: ${abc.data!.trips![0].tripAgent![index].neighborhoodName}, ${abc.data!.trips![0].tripAgent![index].townName}":'Dirección: ${abc.data!.trips![0].tripAgent![index].agentReferencePoint}, ${abc.data!.trips![0].tripAgent![index].neighborhoodName}, ${abc.data!.trips![0].tripAgent![index].townName},',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            ),
                                          ],
                                        ),
                                      ), 
                                    if (abc.data!.trips![0].tripAgent![index].neighborhoodReferencePoint != null)... {
                                      SizedBox(height: 15,),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning_amber_outlined,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Flexible(child: Text('Acceso autorizado: ${abc.data!.trips![0].tripAgent![index].neighborhoodReferencePoint}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            ),
                                          ],
                                        ),
                                      ), 
                                    },
                                    SizedBox(height: 15,),
                                        Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,20,0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time,color: thirdColor),
                                            SizedBox(width: 15,),
                                            Column(
                                              crossAxisAlignment :CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Hora de encuentro: ',style: TextStyle(color: Colors.white,fontSize: 18.0)),
                                                Text(textAlign:TextAlign.start,'${abc.data!.trips![0].tripAgent![index].hourForTrip}',style: TextStyle(
                                                  color: firstColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15.0),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (abc.data!.trips![0].tripAgent![index]
                                              .didntGetOut ==
                                          1) ...{
                                        Text('Se pasó pero no salió.',
                                            style: TextStyle(
                                                color: Colors.orangeAccent,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 15))
                                      } else ...{
                                        Column(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 40,
                                              decoration:
                                                  BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                    blurStyle:
                                                        BlurStyle.normal,
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    blurRadius: 15,
                                                    spreadRadius: -10,
                                                    offset: Offset(-15, -6)),
                                                BoxShadow(
                                                    blurStyle:
                                                        BlurStyle.normal,
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    blurRadius: 30,
                                                    spreadRadius: -15,
                                                    offset: Offset(18, 5)),
                                              ]),
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  textStyle: TextStyle(
                                                      color: Colors.white),
                                                  backgroundColor: Colors.red,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              style:
                                                                  BorderStyle
                                                                      .none),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                ),
                                                onPressed: () {
                                                  alertaPaso_noSalio(abc, index);
                                                },
                                                child:
                                                    Text('Se pasó y no salió',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      },
                                      Column(
                                        children: [
                                          Container(
                                            width: 150,
                                            height: 40,
                                            decoration:
                                                BoxDecoration(boxShadow: [
                                              BoxShadow(
                                                  blurStyle: BlurStyle.normal,
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  blurRadius: 15,
                                                  spreadRadius: -10,
                                                  offset: Offset(-15, -6)),
                                              BoxShadow(
                                                  blurStyle: BlurStyle.normal,
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  blurRadius: 30,
                                                  spreadRadius: -15,
                                                  offset: Offset(18, 5)),
                                            ]),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                textStyle: TextStyle(
                                                    color: backgroundColor),
                                                // foreground
                                                backgroundColor: firstColor,
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        style:
                                                            BorderStyle.none),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                              ),
                                              onPressed: () async {
                                                http.Response response =
                                                    await http.get(Uri.parse(
                                                        '$ip/apis/getDriverComment/${abc.data!.trips![0].tripAgent![index].agentId}/${abc.data!.trips![0].tripAgent![index].tripId}'));
                                                final send = Comment.fromJson(
                                                    json.decode(
                                                        response.body));
                                                    check[index].text = send.comment!.commentDriver;
                                                showGeneralDialog(
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.5),
                                                    transitionBuilder:
                                                        (context, a1, a2,
                                                            widget) {
                                                      return Transform.scale(
                                                        scale: a1.value,
                                                        child: Opacity(
                                                          opacity: a1.value,
                                                          child: AlertDialog(
                                                            backgroundColor:
                                                                backgroundColor,
                                                            shape: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0)),
                                                            title: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      25.0),
                                                              child: Text(
                                                                  '¿Razón por la cual no ingresó a la unidad?',
                                                                  style: TextStyle(
                                                                      color:
                                                                          GradiantV_2,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20)),
                                                            ),
                                                            content:
                                                                Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            15)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.2),
                                                                    spreadRadius:
                                                                        0,
                                                                    blurStyle:
                                                                        BlurStyle
                                                                            .solid,
                                                                    blurRadius:
                                                                        10,
                                                                    offset: Offset(
                                                                        0,
                                                                        0), // changes position of shadow
                                                                  ),
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.1),
                                                                    spreadRadius:
                                                                        0,
                                                                    blurRadius:
                                                                        5,
                                                                    blurStyle:
                                                                        BlurStyle
                                                                            .inner,
                                                                    offset: Offset(
                                                                        0,
                                                                        0), // changes position of shadow
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15.0),
                                                                child:
                                                                    TextField(
                                                                  cursorColor:
                                                                      firstColor,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                  decoration: InputDecoration(
                                                                      border: InputBorder
                                                                          .none,
                                                                      hintText:
                                                                          'Escriba aquí',
                                                                      hintStyle:
                                                                          TextStyle(color: Colors.white70)),
                                                                  controller:
                                                                      check[
                                                                          index],
                                                                ),
                                                              ),
                                                            ),
                                                            actions: [
                            
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(15)),
                                                                    width: 95,
                                                                    height:
                                                                        40,
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(30), // <-- Radius
                                                                          ),
                                                                          elevation: 10,
                                                                          textStyle: TextStyle(color: Colors.white), // foreground
                                                                          backgroundColor: Gradiant2),
                                                                      onPressed:
                                                                          () =>
                                                                              {
                                                                                if(check[index].text.isEmpty){
                                                                                  Navigator.pop(context),
                                                                                  QuickAlert.show(
                                                                                    context: context,
                                                                                    type: QuickAlertType.error,
                                                                                    title: 'Alerta',
                                                                                    text: 'No puede ir vacío la observación',
                                                                                  ),
                                                                                }else{
                                                                                fetchRegisterCommentAgent(
                                                                                    abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                                                                    prefs.tripId,
                                                                                    check[index].text),
                                                                                Navigator.pop(
                                                                                    context),
                                                                                }
                                                                      },
                                                                      child: Text(
                                                                          'Guardar',
                                                                          style: TextStyle(
                                                                              color: backgroundColor,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15)),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 95,
                                                                    height:
                                                                        40,
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(30), // <-- Radius
                                                                          ),
                                                                          textStyle: TextStyle(color: Colors.white), // foreground
                                                                          // foreground
                                                                          backgroundColor: Colors.red),
                                                                      onPressed:
                                                                          () =>
                                                                              {
                                                                        Navigator.pop(
                                                                            context),
                                                                      },
                                                                      child: Text(
                                                                          'Cerrar',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      10.0),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    transitionDuration:
                                                        Duration(
                                                            milliseconds:
                                                                200),
                                                    barrierDismissible: true,
                                                    barrierLabel: '',
                                                    context: context,
                                                    pageBuilder: (context,
                                                        animation1,
                                                        animation2) {
                                                      return Text('');
                                                    });
                                              },
                                              child: Text('Observaciones',
                                                  style: TextStyle(
                                                    color: backgroundColor,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15.0),
                
                                  if (abc.data!.trips![0].tripAgent![index].commentDriver=='Canceló transporte') ...{
                                    Text('Canceló transporte',
                                      style: TextStyle(
                                        color: Colors.orangeAccent,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15
                                      )
                                    )
                                  } else ...{
                                    Container(
                                      height: 40,
                                      decoration:
                                      BoxDecoration(boxShadow: [
                                        BoxShadow(
                                          blurStyle:
                                          BlurStyle.normal,
                                          color: Colors.white.withOpacity(0.2),
                                                      blurRadius: 15,
                                                      spreadRadius: -10,
                                                      offset: Offset(-15, -6)),
                                                  BoxShadow(
                                                      blurStyle:
                                                          BlurStyle.normal,
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      blurRadius: 30,
                                                      spreadRadius: -15,
                                                      offset: Offset(18, 5)),
                                                ]),
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    textStyle: TextStyle(
                                                        color: Colors.white),
                                                    backgroundColor: Colors.red,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                style:
                                                                    BorderStyle
                                                                        .none),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                  ),
                                                  onPressed: () {
                                                    alertaCancelo(abc, index);
                                                  },
                                                  child:
                                                      Text('Canceló transporte',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                ),
                                              ),
                                    SizedBox(height: 20.0),
                                  }
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            );
          }
        } else {
          return ColorLoader3();
        }
      },
    );
  
  }

  Widget _buttonsAgents() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          width: 200,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: 10,
                textStyle: TextStyle(color: backgroundColor),
                backgroundColor: firstColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                )),
            child: Text("Completar Viaje",
                style: TextStyle(
                    color: backgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            onPressed: () {
              QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: "Completar viaje",                
              text: "¿Está seguro que desea completar el viaje?",
              confirmBtnText: "Confirmar",
              cancelBtnText: "Cancelar",
              showCancelBtn: true,  
              confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
              cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
              onConfirmBtnTap: () {
                Navigator.pop(context);  

                if(tripVehicle == ''){
                  QuickAlert.show(context: context,title: "Alerta",text: 'Tiene que ingresar un vehiculo.',type: QuickAlertType.error,);
                  return;
                }          
                LoadingIndicatorDialog().show(context);                     
                fetchRegisterTripCompleted();
              },
              onCancelBtnTap: () {
                Navigator.pop(context);
              },
              );
            },
          ),
        ),

      ],
    );
  }
}