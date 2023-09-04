//import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:app_settings/app_settings.dart';
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
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:convert' show json;
import 'package:flutter_auth/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

import '../../../../components/AppBarPosterior.dart';
import '../../../../components/AppBarSuperior.dart';
import '../../../../components/ConfirmationDialog.dart';
import '../../../../components/backgroundB.dart';
import '../../../../components/warning_dialog.dart';
import '../../../components/progress_indicator.dart';
import '../../../models/search.dart';
//import 'details_TripProgress.dart';

//import 'package:shop_app/screens/details/details_screen.dart';

//import '../../constants.dart';

void main() {
  runApp(MyConfirmAgent());
}

int recargar=-1;

void setRecargar(int numero){
  recargar=numero;
}

int gerRecargar(){
  return recargar;
}

class MyConfirmAgent extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;
  final departmentId;
  final departmentName;

  const MyConfirmAgent({Key? key, this.plantillaDriver, this.departmentId, this.departmentName}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyConfirmAgent> {
  ConfirmationLoadingDialog loadingDialog = ConfirmationLoadingDialog();
  ConfirmationDialog confirmationDialog = ConfirmationDialog();
  int totalAbordado = 0;
  Future<TripsList4>? item;
  Future<DriverData>? driverData;
  bool traveled = false;
  final tmpArray = [];
  bool traveled1 = true;
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";
  var tripId;
  bool? permiso;
  final int comp = 1;
  final int startekSPS = 2;
  final int starteTGU = 3;
  final int comp2 = 5;
  final int ibexTgu = 9;
  final int resultTgu = 11;
  final int partner = 12;
  final int aloricaSPS = 6;
  final int zerovarianceSPS = 7;
  final int aloricaCeiba = 13;
  final int itelSPS = 10;
  bool cargarCoordenadas = false;
  String tipoViaje = '';

  String apiKey = 'AIzaSyBJJYIS4G4n-3AP93am08XyDyDiA-vgPmM';
  var latidudeInicial;
  var longitudInicial;

  var latidudeFinal;
  var longitudFinal;

  List<String> waypoints = [];  
  List<String> waypointsAbordados= [];  

  bool flagEOS = false;

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

    http.Response response =
        await http.post(Uri.parse('$ip/apis/agentCheckIn'), body: datas);

    final resp = Message.fromJson(json.decode(response.body));

    if (response.statusCode == 200 && resp.ok == true) {
      
    } else if (response.statusCode == 500) {
      WarningSuccessDialog().show(
        navigatorKey.currentContext!,
        title: '$resp.message',
        tipo: 1,
        onOkay: () {},
      );
    }

    return Message.fromJson(json.decode(response.body));
  }

  void gettotalAbordado() async {
    var lista = await item;

    for (int i = 0; i < lista!.trips![0].tripAgent!.length; i++) {
      if (traveledB(lista, i)) {
        waypointsAbordados.add( lista.trips![0].tripAgent![i].agentId.toString());
        totalAbordado++;
      }
    }

  }

  bool traveledB(lista, index) {
    return (lista!.trips![0].tripAgent![index].traveled == 0)
        ? false
        : (lista!.trips![0].tripAgent![index].traveled == 1)
            ? true
            : (lista!.trips![0].tripAgent![index].traveled == null)
                ? lista!.trips![0].tripAgent![index].traveled ?? false
                : (lista!.trips![0].tripAgent![index].traveled == true)
                    ? lista!.trips![0].tripAgent![index].traveled ?? false
                    : false;
  }

  Future<Driver2> fetchRegisterTripCompleted() async {
    http.Response response = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(response.body));

    http.Response responses = await http.get(Uri.parse(
        'https://admin.smtdriver.com/test/registerTripAsCompleted/${prefs.tripId}/${data.driverId}/mobile'));
    final si = Driver2.fromJson(json.decode(responses.body));

    LoadingIndicatorDialog().dismiss();
    //print(responses.body);
    if (responses.statusCode == 200 && si.ok!) {
      new Future.delayed(new Duration(seconds: 2), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => HomeDriverScreen()),
            (Route<dynamic> route) => false);
      });
      if (mounted) {
        WarningSuccessDialog().show(
                                      navigatorKey.currentContext!,
                                      title: "Su viaje ha sido completado",
                                      tipo: 2,
                                      onOkay: () {},
                                    );
      }
    } else if (si.ok != true) {
      WarningSuccessDialog().show(
                                      navigatorKey.currentContext!,
                                      title: "${si.message}",
                                      tipo: 1,
                                      onOkay: () {},
                                    );
    }
    Map data2 = {"Estado": 'FINALIZADO'};
    String sendData2 = json.encode(data2);
    await http.put(
        Uri.parse(
            'https://apichat.smtdriver.com/api/salas/Viaje_Estado/${prefs.tripId}'),
        body: sendData2,
        headers: {"Content-Type": "application/json"});
    //print(response2.body);

    if(tipoViaje == 'Salida'){
      http.Response responseSala = await http.get(Uri.parse('https://apichat.smtdriver.com/api/salas/Tripid/${prefs.tripId}'));
      final respS = json.decode(responseSala.body);

      for(int i = 0; i<respS['salas']['Agentes'].length; i++){
        Map data2 = {"idU": respS['salas']['Agentes'][i]['agenteId'].toString(), "Estado": 'CONFIRMADO'};
        String sendData2 = json.encode(data2);
        await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/${prefs.tripId}'), body: sendData2, headers: {"Content-Type": "application/json"});
      }
    }

    return Driver2.fromJson(json.decode(responses.body));
    //throw Exception('Failed to load Data');
  }

  Future<Driver> fetchRegisterCommentAgent(
      String agentId, String tripId, String comment) async {
    Map datas = {'agentId': agentId, 'tripId': tripId};
    Map datas2 = {
      'agentId': agentId,
      'tripId': tripId,
      'commentDriver': comment
    };

    http.Response responses =
        await http.post(Uri.parse('$ip/apis/getDriverComment'), body: datas);
    final si = Driver.fromJson(json.decode(responses.body));
      await http.post(Uri.parse('$ip/apis/agentTripSetComment'), body: datas2);

    if (responses.statusCode == 200 &&
        si.ok == true &&
        responses.statusCode == 200) {
      WarningSuccessDialog().show(
                                      navigatorKey.currentContext!,
                                      title: "Enviado",
                                      tipo: 2,
                                      onOkay: () {},
                                    );
      Navigator.pop(context);
    } else if (si.ok != true) {
      WarningSuccessDialog().show(
                                      navigatorKey.currentContext!,
                                      title: "${si.message}",
                                      tipo: 1,
                                      onOkay: () {},
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

    if (responses.statusCode == 200 && si.ok!) {
     WarningSuccessDialog().show(
                                      navigatorKey.currentContext!,
                                      title: "${si.message}",
                                      tipo: 2,
                                      onOkay: () {},
                                    );
    } else if (si.ok != true) {
      WarningSuccessDialog().show(
                                      navigatorKey.currentContext!,
                                      title: "${si.message}",
                                      tipo: 1,
                                      onOkay: () {},
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
      WarningSuccessDialog().show(
                                      navigatorKey.currentContext!,
                                      title: "${resp.message}",
                                      tipo: 1,
                                      onOkay: () {},
                                    );
    }

    Map data2 = {"Estado": 'FINALIZADO'};
    String sendData2 = json.encode(data2);
    await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/Viaje_Estado/${prefs.tripId}'),body: sendData2,headers: {"Content-Type": "application/json"});

    return Driver.fromJson(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    setUb(2);
    item = fetchAgentsTripInProgress();
    getLocation();
    comment = new List<TextEditingController>.empty(growable: true);
    check = [];
    driverData = fetchRefres();
    gettotalAbordado();
    getInfoViaje();
  }

  Future<int> addAgente(var idAgente, var lista) async {

    for (int i = 0; i < lista.trips![0].tripAgent!.length; i++) { 
      if(lista.trips![0].tripAgent![i].agentId==idAgente){
        if(lista.trips![0].tripAgent![i].traveled == 1){
          traveled = true;
        }else{
          traveled = false;
        }
        return i;
      }
    }
    return 0;
  }

  void getLocation() async{

    var lat = '';
    var long = '';

    //print(this.widget.departmentId);
    //print(this.widget.departmentName);
    //15.561147, -88.020942 san pedro
    //15.773001, -86.792570 ceiba
    //14.046092, -87.174631 tegus
    if(prefs.companyId==comp.toString()){
      lat = '15.561147';
      long = '-88.020942';
    }
    if(prefs.companyId==comp2.toString()){
      lat = '14.046092';
      long = '-87.174631';
    }
    if(prefs.companyId==starteTGU.toString()){
      lat = '14.046092';
      long = '-87.174631';
    }
    if(prefs.companyId==startekSPS.toString()){
      lat = '15.561147';
      long = '-88.020942';
    }
    if(prefs.companyId==aloricaSPS.toString()){
      lat = '15.561147';
      long = '-88.020942';
    }
    if(prefs.companyId==resultTgu.toString()){
      //14.083637, -87.185030
      lat = '14.083637';
      long = '-87.185030';
    }
    if(prefs.companyId==itelSPS.toString()){
      lat = '15.561147';
      long = '-88.020942';
    }
    if(prefs.companyId == zerovarianceSPS.toString()){
      lat = '15.561147';
      long = '-88.020942';
    }
    if(prefs.companyId == aloricaCeiba.toString()){
      lat = '15.773001';
      long = '-86.792570';
    }

    await fetchAgentsTripInProgress().then((value) => {

      //print(value.trips![1].actualTravel!.tripType),

      if(value.trips![1].actualTravel!.tripType=='Entrada'){
        flagEOS = true,
        for(var i = 0; i < value.trips![0].tripAgent!.length; i++){

          if(i==0){
            latidudeInicial = value.trips![0].tripAgent![i].latitude,
            longitudInicial = value.trips![0].tripAgent![i].longitude,
          },

          waypoints.add('${value.trips![0].tripAgent![i].latitude},${value.trips![0].tripAgent![i].longitude}')
        },

        waypoints.add('$lat,$long'),
        setState(() {})
      }else{
        latidudeFinal = lat,
        longitudFinal = long,
        flagEOS = false,

        for(var i = 0; i < value.trips![0].tripAgent!.length; i++){
          
          waypoints.add('${value.trips![0].tripAgent![i].latitude},${value.trips![0].tripAgent![i].longitude}')
        },
        //waypoints.add('$lat,$long'),
        setState(() {
          //print(waypoints);
        })
      },
      
    });
    //print(waypoints);
  }

  void obtenerUbicacion() async{
     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {      
     var latitudM = position.latitude;
     var longitudM = position.longitude;
      latidudeInicial = latitudM;
      longitudInicial = longitudM;
      // print('khee');
      // print(latitudM);
      // print(longitudM);
    });
  }

  launchSalidasMaps(lat,lng)async{
    String destination = '$lat,$lng';
    String url = 'google.navigation:q=$destination&mode=d';
    await launchUrl(Uri.parse(url));
  }

 Future<void> launchGoogleMapsx(String apiKey, String startLat, String startLng, List<String> waypoints) async {
    String baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
    String origin = '$startLat,$startLng';
    
    if (!flagEOS) {      
      var distances = [];
      for (var i = 0; i < waypoints.length; i++) {      
        String urlDistance = '$baseUrl?origin=$origin&destination=${waypoints[i]}&key=$apiKey';
        final responseDistance = await http.get(Uri.parse(urlDistance));
        if (responseDistance.statusCode == 200) {
          final dataDistance = json.decode(responseDistance.body);
          double distanceValue = double.parse(dataDistance['routes'][0]['legs'][0]['distance']['value'].toString());
          distances.add(distanceValue);
        }
      }
      int maxIndex = 0;
      double maxValue = distances[0];
      for (int i = 1; i < distances.length; i++) {
        if (distances[i] > maxValue) {
          maxValue = distances[i];
          maxIndex = i;
        }
      }
      if (maxIndex >= 0 && maxIndex< waypoints.length) {
        String elementoMovido = waypoints.removeAt(maxIndex);
        waypoints.add(elementoMovido);
      } else {
        print('Posición inválida');
      }
      String destination = waypoints.last;
      String waypointsString = waypoints.join('|');    
      String url = '$baseUrl?origin=$origin&destination=$destination&waypoints=optimize:true|$waypointsString&key=$apiKey';

      // ignore: avoid_print
      final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          List<dynamic> sortedWaypoints = data['routes'][0]['waypoint_order']
            .map((index) => waypoints[index])
            .toList();
      
          print('******* ruta');
          print('Waypoints en el orden de la API: $sortedWaypoints');
          String url = 'google.navigation:q=$origin';
          
          //print(sortedWaypoints);
          if (sortedWaypoints.isNotEmpty) {
            String sortedWaypointsString = sortedWaypoints.join('|');
            url += '&waypoints=$sortedWaypointsString';
          }

          LoadingIndicatorDialog().dismiss();
          //if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
          // } else {
          //   throw 'No se pudo abrir la URL: $url';
          // }
        }
    }else{
      String destination = waypoints.last;
      String url = 'google.navigation:q=$destination&mode=d';
      await launchUrl(Uri.parse(url));
    }
  }


  void getInfoViaje() async {
    http.Response responseSala =
        await http.get(Uri.parse('$ip/apis/agentsInTravel/${prefs.tripId}'));
    final infoViaje = json.decode(responseSala.body);

    if (mounted) {
      if (infoViaje[3]['viajeActual']['tripVehicle'] != null) {
        setState(() {
          tripVehicle = infoViaje[3]['viajeActual']['tripVehicle'];
          vehicleL = true;
          vehicleController.text = tripVehicle;
          tripId = infoViaje[3]['viajeActual']['tripId'];
        });
      } else {
        setState(() {
          tripVehicle = '';
          vehicleL = true;
          vehicleController.text = tripVehicle;
          tripId = infoViaje[3]['viajeActual']['tripId'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBody(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: AppBarSuperior(item: 222)
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child:body()),
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
            SizedBox(height: 10.0),
            _buttonsAgents(),
            SizedBox(height: 10.0),
            escanearAgente(),
            SizedBox(height: 10.0),
            _agentToConfirm(),
            SizedBox(height: 10.0),
          ],
        ),
      )
    );
  }


  Widget escanearAgente() {

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
                                                    permiso = await checkLocationPermission();
                                                      if (!permiso!) {
                                                        WarningSuccessDialog().show(
                                                          navigatorKey.currentContext!,
                                                          title: 'Usted negó el acceso a la ubicación. Esto es necesario para poder abordar agentes. Si no da acceso en configuraciones, no podrá abordar agentes.',
                                                          tipo: 1,
                                                          onOkay: () {
                                                            try {
                                                              AppSettings.openLocationSettings();
                                                              } catch (error) {
                                                                print(error);
                                                              }
                                                          },
                                                        );
                                                        return;
                                                      }
                                                   
                                                      LoadingIndicatorDialog().show(context);

                                                      Map data =   {
                                                        'agentUser':agentEmployeeId.text, 
                                                        'tripId':tripId.toString(),
                                                        'itsManualSearch':"1"
                                                      };

                                                      http.Response response = await http
                                                          .post(Uri.parse('https://driver.smtdriver.com/apis/agents/validateCheckIn'), body: data);

                                                      final resp = json.decode(response.body);

                                                      if(mounted){
                                                        LoadingIndicatorDialog().dismiss();
                                                        if(resp['type']=='error'){
                                                          WarningSuccessDialog().show(
                                                          navigatorKey.currentContext!,
                                                          title: "${resp['msg']}",
                                                          tipo: 1,
                                                          onOkay: () {},
                                                        );
                                                          return;
                                                        } 

                                                        if(resp['allow']==0){
                                                          if(abc.data!.trips![1].actualTravel!.tripType!='Salida'){
                                                            
                                                            LoadingIndicatorDialog().dismiss();
                                                            WarningSuccessDialog().show(
                                                              navigatorKey.currentContext!,
                                                              title: resp['msg'],
                                                              tipo: 1,
                                                              onOkay: () {},
                                                            );
                                                            return;
                                                          
                                                          }else{
                                                          if(resp['msg']=='Agente no se encuentra registrado en este viaje.'){
                                                            LoadingIndicatorDialog().dismiss();
                                                            confirmationDialog.show(
                                                                context,
                                                                title: 'Usted negó el acceso a la ubicación. Esto es necesario para poder abordar agentes. Si no da acceso en configuraciones, no podrá abordar agentes.',
                                                                type: "0",
                                                                onConfirm: () async {
                                                                  loadingDialog.show(context);

                                                                 Map datas = {
                                                                  "companyId": abc.data!.trips![1].actualTravel!.companyId.toString(),
                                                                  "agentEmployeeId": agentEmployeeId.text
                                                                };

                                                                http.Response responsed =
                                                                    await http.post(Uri.parse('$ip/apis/searchAgent'), body: datas);
                                                                final data1 = Search.fromJson(json.decode(responsed.body));


                                                                if(data1.agent!.msg!=null){
                                                                  loadingDialog.dismiss();

                                                                  if(data1.ok==true){
                                                                    confirmationDialog.dismiss();
                                                                    Navigator.pop(context);                                         
                                                                    WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${data1.agent!.msg!}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );

                                                                    return;
                                                                  }
                                                                }

                                                                Map datas2 = {
                                                                  "agentId": data1.agent!.agentId.toString(),
                                                                  "tripId": abc.data!.trips![1].actualTravel!.tripId.toString(),
                                                                  "tripHour": abc.data!.trips![1].actualTravel!.tripHour.toString()
                                                                };

                                                                final sendDatas = await http.post(Uri.parse('$ip/apis/registerAgentTripEntryByDriver'),body: datas2);

                                                                final dataR = json.decode(sendDatas.body);


                                                                if(dataR['type']=='error'){

                                                                  loadingDialog.dismiss();

                                                                  if(mounted){
                                                                    confirmationDialog.dismiss();
                                                                    Navigator.pop(context);
                                                                    WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${dataR['message']}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                                                  }

                                                                return;

                                                                }else{
                                                                  var itemAbordaje = await fetchAgentsTripInProgress();

                                                                  int indexP = await addAgente(resp['agentId'], itemAbordaje);
                                                                  abc.data!.trips![0].tripAgent=itemAbordaje.trips![0].tripAgent;

                                                                  fetchRegisterCommentAgent(
                                                                    abc.data!.trips![0].tripAgent![indexP].agentId.toString(),
                                                                    prefs.tripId,
                                                                    ''
                                                                  ); 

                                                                  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  
                                                                  traveled = !traveled;
                                                                  abc.data!.trips![0].tripAgent![indexP].traveled = traveled;
                                                                  
                                                                  Map data =   {
                                                                    'agentId':data1.agent!.agentId.toString(), 
                                                                    'tripId':abc.data!.trips![1].actualTravel!.tripId.toString(),
                                                                    'latitude':position.latitude.toString(),
                                                                    'longitude':position.longitude.toString(),
                                                                    'actionName':'Abordaje'
                                                                  };
                                                                
                                                                  await http.post(Uri.parse('https://driver.smtdriver.com/apis/agents/registerTripAction'), body: data);

                                                                  Map data2 = {
                                                                    "Agentes": [
                                                                      {
                                                                        "agenteN": itemAbordaje.trips![0].tripAgent![indexP].agentFullname,
                                                                        "agenteId": itemAbordaje.trips![0].tripAgent![indexP].agentId.toString(),
                                                                        "Estado": "CONFIRMADO"
                                                                      }
                                                                    ]                                                               
                                                                  };
                                                                  
                                                                  String sendData2 = json.encode(data2);
                                                                  await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/Tripid/${abc.data!.trips![1].actualTravel!.tripId.toString()}'), body: sendData2, headers: {"Content-Type": "application/json"});
                                                                  
                                                                  loadingDialog.dismiss();
                                                                  confirmationDialog.dismiss();
                                                                  if(mounted){
                                                                    Navigator.push(context,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));

                                                                    WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: 'Se agrego el agente ${itemAbordaje.trips![0].tripAgent![indexP].agentFullname} al viaje.',
                                                                      tipo: 2,
                                                                      onOkay: () {},
                                                                    );
                                                                    
                                                                  } 
                                                                }
                                                      
                                                    },
                                                    onCancel: () {},
                                                  );
                                                          return;
                                                          }else{
                                                            LoadingIndicatorDialog().dismiss();
                                                            WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${resp['msg']}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                                            return;
                                                          }
                                                        }
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
                                                        confirmationDialog.show(
                                                                context,
                                                                title: 'Usted negó el acceso a la ubicación. Esto es necesario para poder abordar agentes. Si no da acceso en configuraciones, no podrá abordar agentes.',
                                                                type: "0",
                                                                onConfirm: () async {

                                                                  Navigator.pop(context);

                                                            loadingDialog.show(context);
                                                            if(traveled==false && abc.data!.trips![0].tripAgent![index].didntGetOut==1){
                                                              abc.data!.trips![0].tripAgent![index].didntGetOut=0;
                                                              fetchRegisterCommentAgent(
                                                                abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                                                prefs.tripId,
                                                                'No abordó'
                                                              );  
                                                              waypointsAbordados.removeWhere((element) => element == abc.data!.trips![0].tripAgent![index].agentId.toString());
                                                              totalAbordado--;
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
                                                            confirmationDialog.dismiss();
                                                            loadingDialog.dismiss();
                                                            

                                                            WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: 'El agente ${abc.data!.trips![0].tripAgent![index].agentFullname} ha abordado.',
                                                                      tipo: 2,
                                                                      onOkay: () {},
                                                                    );
                                                          agentEmployeeId.text='';
                                                          abc.data!.trips![0].tripAgent![index].commentDriver='';
                                                          totalAbordado++;
                                                          waypointsAbordados.add(abc.data!.trips![0].tripAgent![index].agentId.toString());
                                                          setState(() { });
                                                    },
                                                    onCancel: () {},
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
                                permiso = await checkLocationPermission();
                                if (!permiso!) {
                                  WarningSuccessDialog().show(
                                                          navigatorKey.currentContext!,
                                                          title: 'Usted negó el acceso a la ubicación. Esto es necesario para poder abordar agentes. Si no da acceso en configuraciones, no podrá abordar agentes.',
                                                          tipo: 1,
                                                          onOkay: () {
                                                            try {
                                                              AppSettings.openLocationSettings();
                                                              } catch (error) {
                                                                print(error);
                                                              }
                                                          },
                                                        );
                                  return;
                                }
                                
                                String codigoQR = await FlutterBarcodeScanner.scanBarcode("#9580FF", "Cancelar", true, ScanMode.QR);
                      
                                if (codigoQR == "-1") {
                                  return;
                                } else {
                                  LoadingIndicatorDialog().show(context);

                                  Map data =   {
                                    'agentUser':codigoQR, 
                                    'tripId':tripId.toString()
                                  };

                                  http.Response response = await http
                                      .post(Uri.parse('https://driver.smtdriver.com/apis/agents/validateCheckIn'), body: data);

                                  final resp = json.decode(response.body);

                                  if(mounted){
                                                        LoadingIndicatorDialog().dismiss();
                                                        if(resp['type']=='error'){
                                                          WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${resp['msg']}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                                          return;
                                                        } 

                                                        if(resp['allow']==0){
                                                          if(abc.data!.trips![1].actualTravel!.tripType!='Salida'){
                                                            
                                                            LoadingIndicatorDialog().dismiss();
                                                            WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${resp['msg']}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                                            return;
                                                          
                                                          }else{
                                                          if(resp['msg']=='Agente no se encuentra registrado en este viaje.'){
                                                            LoadingIndicatorDialog().dismiss();
                                                            confirmationDialog.show(
                                                                          context,
                                                                          title: 'Agente no se encuentra registrado en este viaje. Desea agregarlo al viaje?',
                                                                          type: "0",
                                                                          onConfirm: () async {
                                                                        
                                                                loadingDialog.show(navigatorKey.currentContext!);

                                                                 Map datas = {
                                                                  "companyId": abc.data!.trips![1].actualTravel!.companyId.toString(),
                                                                  "agentEmployeeId": codigoQR
                                                                };

                                                                http.Response responsed =
                                                                    await http.post(Uri.parse('$ip/apis/searchAgent'), body: datas);
                                                                final data1 = Search.fromJson(json.decode(responsed.body));


                                                                if(data1.agent!.msg!=null){
                                                                  loadingDialog.dismiss();

                                                                  if(data1.ok==true){
                                                                    confirmationDialog.dismiss();
                                                                    WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${data1.agent!.msg!}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );

                                                                    return;
                                                                  }
                                                                }

                                                                Map datas2 = {
                                                                  "agentId": data1.agent!.agentId.toString(),
                                                                  "tripId": abc.data!.trips![1].actualTravel!.tripId.toString(),
                                                                  "tripHour": abc.data!.trips![1].actualTravel!.tripHour.toString()
                                                                };

                                                                final sendDatas = await http.post(Uri.parse('$ip/apis/registerAgentTripEntryByDriver'),body: datas2);

                                                                final dataR = json.decode(sendDatas.body);

                                                                if(dataR['type']=='error'){
                                                                  loadingDialog.dismiss();
                                                                  
                                                                  if(mounted){
                                                                    confirmationDialog.dismiss();
                                                                    Navigator.pop(navigatorKey.currentContext!);
                                                                   WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${dataR['message']}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                                                  }

                                                                return;

                                                                }else{

                                                                  var itemAbordaje = await fetchAgentsTripInProgress();

                                                                  int indexP = await addAgente(resp['agentId'], itemAbordaje);
                                                                  abc.data!.trips![0].tripAgent=itemAbordaje.trips![0].tripAgent;

                                                                  fetchRegisterCommentAgent(
                                                                    abc.data!.trips![0].tripAgent![indexP].agentId.toString(),
                                                                    prefs.tripId,
                                                                    ''
                                                                  ); 


                                                                  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  
                                                                  traveled = !traveled;
                                                                  abc.data!.trips![0].tripAgent![indexP].traveled = traveled;
                                                                  
                                                                  Map data =   {
                                                                    'agentId':data1.agent!.agentId.toString(), 
                                                                    'tripId':abc.data!.trips![1].actualTravel!.tripId.toString(),
                                                                    'latitude':position.latitude.toString(),
                                                                    'longitude':position.longitude.toString(),
                                                                    'actionName':'Abordaje'
                                                                  };
                                                                
                                                                  await http.post(Uri.parse('https://driver.smtdriver.com/apis/agents/registerTripAction'), body: data);
                                                                    
                                                                  Map data2 = {
                                                                    "Agentes": [
                                                                      {
                                                                        "agenteN": itemAbordaje.trips![0].tripAgent![indexP].agentFullname,
                                                                        "agenteId": itemAbordaje.trips![0].tripAgent![indexP].agentId.toString(),
                                                                        "Estado": "CONFIRMADO"
                                                                      }
                                                                    ]                                                               
                                                                  };
                                                                  
                                                                  String sendData2 = json.encode(data2);
                                                                  await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/Tripid/${abc.data!.trips![1].actualTravel!.tripId.toString()}'), body: sendData2, headers: {"Content-Type": "application/json"});
                                                                 
                                                                  loadingDialog.dismiss();
                                                                  if(mounted){
                                                                    confirmationDialog.dismiss();
                                                                    Navigator.push(navigatorKey.currentContext!,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));

                                                                    WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: 'Se agrego el agente ${itemAbordaje.trips![0].tripAgent![indexP].agentFullname} al viaje.',
                                                                      tipo: 2,
                                                                      onOkay: () {},
                                                                    );
                                                                    
                                                                  } 
                                                                }
                                                                
                                                              },
                                                            onCancel: () {},
                                                            );   
                                                          return;
                                                          }else{
                                                            LoadingIndicatorDialog().dismiss();
                                                            WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${resp['msg']}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                                            return;
                                                          }
                                                        }
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
                                    confirmationDialog.show(
                                      context,
                                      title: traveled==true ?"¿Está seguro que desea marcar como no \nabordado al agente ${abc.data!.trips![0].tripAgent![index].agentFullname}?":"¿Está seguro que desea marcar como \nabordado al agente ${abc.data!.trips![0].tripAgent![index].agentFullname}?",
                                      type: "0",
                                      onConfirm: () async {
                                        confirmationDialog.dismiss();

                                        loadingDialog.show(context);
                                        if(traveled==false && abc.data!.trips![0].tripAgent![index].didntGetOut==1){
                                          abc.data!.trips![0].tripAgent![index].didntGetOut=0;
                                          fetchRegisterCommentAgent(
                                            abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                            prefs.tripId,
                                            'No abordó'
                                          );  
                                          waypointsAbordados.removeWhere((element) => element == abc.data!.trips![0].tripAgent![index].agentId.toString());
                                          totalAbordado--;
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

                                          loadingDialog.dismiss();
                                          

                                          WarningSuccessDialog().show(
                                                                        navigatorKey.currentContext!,
                                                                        title: "El agente ${abc.data!.trips![0].tripAgent![index].agentFullname} ha abordado.",
                                                                        tipo: 2,
                                                                        onOkay: () {},
                                                                      );
                                        abc.data!.trips![0].tripAgent![index].commentDriver='';
                                        totalAbordado++;
                                        waypointsAbordados.add(abc.data!.trips![0].tripAgent![index].agentId.toString());
                                        setState(() { });
                                      },
                                    onCancel: () {},
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

  Future<bool> checkLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Widget ingresarVehiculo() {
    return FutureBuilder<TripsList4>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          return FutureBuilder<DriverData>(
            future: driverData,
            builder: (BuildContext context, abc) {
              if (abc.connectionState == ConnectionState.done) {
                DriverData? data = abc.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  if(mounted){
                                    showDialog(
                                            context: context,
                                            builder: (context) => vehiculoE(resp, context),);
                                  }
                                }else{
                                  if(mounted){
                                    WarningSuccessDialog().show(
                                      navigatorKey.currentContext!,
                                      title: "Vehículo no valido",
                                      tipo: 1,
                                      onOkay: () {},
                                    );
                                  }
                                }
                                setRecargar(0);
                              }
                            }
                          ),
                        ),

                        if (data?.driverType != 'Motorista')
                          SizedBox(
                            width: 10,
                          ),
                        if (data?.driverType != 'Motorista')
                          Container(
                            decoration: BoxDecoration(
                              color: firstColor,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: IconButton(
                                icon: Icon(Icons.save_outlined),
                                color: backgroundColor,
                                iconSize: 30.0,
                                onPressed: vehicleL == false
                                    ? null
                                    : () async {
                                        LoadingIndicatorDialog()
                                            .show(context);
                                        http.Response responses =
                                            await http.get(Uri.parse(
                                                '$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
                                        final data2 = DriverData.fromJson(
                                            json.decode(responses.body));
                                        Map data = {
                                          "driverId":
                                              data2.driverId.toString(),
                                          "tripId": prefs.tripId.toString(),
                                          "vehicleId": "",
                                          "tripVehicle":
                                              vehicleController.text
                                        };
                                        http.Response responsed = await http.post(
                                            Uri.parse(
                                                'https://driver.smtdriver.com/apis/editTripVehicle'),
                                            body: data);

                                        final resp2 =
                                            json.decode(responsed.body);
                                        LoadingIndicatorDialog().dismiss();
                                        if (resp2['type'] == 'success') {
                                          if (mounted) {
                                            WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${resp2['message']}',
                                                                      tipo: 2,
                                                                      onOkay: () {},
                                                                    );
                                            setState(() {
                                              tripVehicle =
                                                  vehicleController.text;
                                            });
                                          }
                                          //getCurrentLocation();
                                        } else {
                                          WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${resp2['message']}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                        }
                                      }),
                          ),
                      ],
                    ),
                  ],
                );
              } else {
                return ColorLoader3();
              }
            },
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  textStyle: TextStyle(
                    color: backgroundColor,
                  ),
                  backgroundColor: Gradiant2,
                ),
                onPressed: () async {
                  LoadingIndicatorDialog().show(context);
                  http.Response responses = await http.get(Uri.parse(
                      '$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
                  final data2 =
                      DriverData.fromJson(json.decode(responses.body));
                  Map data = {
                    "driverId": data2.driverId.toString(),
                    "tripId": prefs.tripId.toString(),
                    "vehicleId": resp['vehicle']['_id'],
                    "tripVehicle":
                        "${resp['vehicle']['name']} [${resp['vehicle']['registrationNumber']}]"
                  };
                  http.Response responsed = await http.post(
                      Uri.parse(
                          'https://driver.smtdriver.com/apis/editTripVehicle'),
                      body: data);

                  final resp2 = json.decode(responsed.body);
                  LoadingIndicatorDialog().dismiss();
                  if (resp2['type'] == 'success') {
                    if (mounted) {
                      Navigator.pop(context);
                      WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${resp2['message']}',
                                                                      tipo: 2,
                                                                      onOkay: () {},
                                                                    );
                      setState(() {
                        tripVehicle =
                            "${resp['vehicle']['name']} [${resp['vehicle']['registrationNumber']}]";
                        vehicleController.text = tripVehicle;
                      });
                    }
                  } else {
                    WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: '${resp2['message']}',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                  }
                },
                child: Text('Agregar',
                    style: TextStyle(color: backgroundColor, fontSize: 15.0)),
              ),
            ),
            SizedBox(width: 10.0),
            Container(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.red,
                ),
                onPressed: () => {
                  Navigator.pop(context),
                },
                child: Text('Cancelar',
                    style: TextStyle(color: Colors.white, fontSize: 15.0)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _agentToConfirm() {
    bool traveledB(abc, index) {
      return (abc.data!.trips![0].tripAgent![index].traveled == 0)
          ? false
          : (abc.data!.trips![0].tripAgent![index].traveled == 1)
              ? true
              : (abc.data!.trips![0].tripAgent![index].traveled == null)
                  ? abc.data!.trips![0].tripAgent![index].traveled ?? false
                  : (abc.data!.trips![0].tripAgent![index].traveled == true)
                      ? abc.data!.trips![0].tripAgent![index].traveled ?? false
                      : false;
    }

    alertaAbordo(abc, index, isChecked)async{
      await confirmationDialog.show(
                                      context,
                                      title: isChecked==false ?"¿Está seguro que desea marcar como no \nabordado al agente?":"¿Está seguro que desea marcar como \nabordado al agente?",
                                      type: "0",
                                      onConfirm: () async {
                                        if(traveled==false && abc.data!.trips![0].tripAgent![index].didntGetOut==1){
            abc.data!.trips![0].tripAgent![index].didntGetOut=0;
            fetchRegisterCommentAgent(
            abc.data!.trips![0].tripAgent![index].agentId.toString(),
            prefs.tripId,
            'No abordó'
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
            //print('subio');
            abc.data!.trips![0].tripAgent![index].commentDriver='';
            fetchCheckAgentTrip(abc.data!.trips![0].tripAgent![index].agentId.toString());
            totalAbordado++;
            waypointsAbordados.add(abc.data!.trips![0].tripAgent![index].agentId.toString());
            //print('////////');
          } else if (isChecked == false) {
            //print('bajo');
            fetchCheckAgentTrip(abc.data!.trips![0].tripAgent![index].agentId.toString());
            //print('////////');
            abc.data!.trips![0].tripAgent![index].commentDriver='No abordó';
            waypointsAbordados.removeWhere((element) => element == abc.data!.trips![0].tripAgent![index].agentId.toString());
            totalAbordado--;
            fetchRegisterCommentAgent(
              abc.data!.trips![0].tripAgent![index].agentId.toString(),
              prefs.tripId,
              'No abordó'
            );  
          }
          confirmationDialog.dismiss();
                                      },
                                    onCancel: () {},
                                  );  
      
      setState(() {});
    }

    // ignore: non_constant_identifier_names
    alertaPaso_noSalio(abc, index) async {
      await confirmationDialog.show(
        context,
        title: '¿Está seguro que desea marcar como no salio el agente?',
        type: "0",
        onConfirm: () async {
          loadingDialog.show(context);
          //fetchRegisterAgentDidntGetOut(abc.data!.trips![0].tripAgent![index].agentId.toString(),prefs.tripId);
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          Map data = {
            'agentId': abc.data!.trips![0].tripAgent![index].agentId.toString(),
            'tripId': tripId.toString(),
            'latitude': position.latitude.toString(),
            'longitude': position.longitude.toString(),
            'actionName': 'No salió'
          };

          http.Response response = await http.post(
              Uri.parse(
                  'https://driver.smtdriver.com/apis/agents/registerTripAction'),
              body: data);

          loadingDialog.dismiss();

          abc.data!.trips![0].tripAgent![index].didntGetOut = 1;
          if (abc.data!.trips![0].tripAgent![index].traveled = traveled) {
            abc.data!.trips![0].tripAgent![index].traveled = false;
            traveled = abc.data!.trips![0].tripAgent![index].traveled;
          }

          if (abc.data!.trips![0].tripAgent![index].commentDriver ==
              "Canceló transporte") {
            abc.data!.trips![0].tripAgent![index].commentDriver =
                "Pasé por él (ella) y no salió";
          }
          confirmationDialog.dismiss();
        },
        onCancel: () {},
      ); 

      setState(() {});
    }

    alertaCancelo(abc, index) async {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: "¿Está seguro que desea marcar como canceló transporte?",
        confirmBtnText: "Confirmar",
        cancelBtnText: "Cancelar",
        title: '¿Está seguro?',
        showCancelBtn: true,
        confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
        cancelBtnTextStyle: TextStyle(
            color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
        onConfirmBtnTap: () {
          fetchRegisterCommentAgent(
              abc.data!.trips![0].tripAgent![index].agentId.toString(),
              prefs.tripId,
              'Canceló transporte');
          if (abc.data!.trips![0].tripAgent![index].didntGetOut == 1) {
            abc.data!.trips![0].tripAgent![index].didntGetOut = 0;
          }

          if (abc.data!.trips![0].tripAgent![index].traveled = true) {
            abc.data!.trips![0].tripAgent![index].traveled = false;
            traveled = abc.data!.trips![0].tripAgent![index].traveled;

            fetchCheckAgentTrip(
                abc.data!.trips![0].tripAgent![index].agentId.toString());
          }

          setState(() {
            abc.data!.trips![0].tripAgent![index].commentDriver =
                'Canceló transporte';
          });
          Navigator.pop(context);
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
      );

      setState(() {});
    }

    //Size size = MediaQuery.of(context).size;
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
            tipoViaje = abc.data!.trips![1].actualTravel!.tripType!;
            List<TextEditingController> check = [];
            for (int i = 0; i < abc.data!.trips![0].tripAgent!.length; i++) {
              check.add(TextEditingController());
            }
            
            return abc.data!.trips![1].actualTravel!.tripType=='Salida' ?Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
                      children: [
                        Text(
                          'Total de agentes: ${abc.data!.trips![0].tripAgent!.length}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          'Abordados: $totalAbordado',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
              _buttonsRuta(),
              SizedBox(height: 10.0),
                Column(
                  children: List.generate(
                    abc.data!.trips![0].tripAgent!.length,
                    (index) {
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurStyle: BlurStyle.normal,
                              color: traveledB(abc, index) ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: -18,
                              offset: Offset(-15, -6),
                            ),
                            BoxShadow(
                              blurStyle: BlurStyle.normal,
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: -15,
                              offset: Offset(18, 5),
                            ),
                          ],
                        ),
                        width: 500.0,
                        child: Card(
                          color: backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                                      traveledB(abc, index)
                                          ? RoundCheckBox(
                                              border: Border.all(style: BorderStyle.none),
                                              animationDuration: Duration(seconds: 1),
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
                                              isChecked: traveledB(abc, index),
                                              onTap: (bool? isChecked) {
                                                alertaAbordo(abc, index, isChecked);
                                              },
                                            )
                                          : Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 15,
                                            ),
                                      SizedBox(width: 15.0),
                                      Text('Abordó ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16.0)),  
                                      
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (abc.data!.trips![0].tripAgent![index].latitude==null) {
                                              WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: 'Este agente no cuenta con ubicación',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                            }else{
                                              launchSalidasMaps(abc.data!.trips![0].tripAgent![index].latitude,abc.data!.trips![0].tripAgent![index].longitude);                                          
                                            }
                                            //print('Dirección we');
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                Icon(Icons.location_on_outlined, color:abc.data!.trips![0].tripAgent![index].latitude==null? Colors.red :firstColor, size: 30,),
                                                Text('Ubicación ',style: TextStyle(color:Colors.white,fontWeight: FontWeight.normal,fontSize: 16.0)),                                      
                                              ],)
                                            ],
                                          ),
                                        ),
                                      ),                                    
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.person, color: thirdColor),
                                        SizedBox(width: 15),
                                        Flexible(
                                          child: Text(
                                            'Nombre: ${abc.data!.trips![0].tripAgent![index].agentFullname}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time, color: thirdColor),
                                            SizedBox(width: 15),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Hora de encuentro: ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                                Text(
                                                  '${abc.data!.trips![0].tripAgent![index].hourForTrip}',
                                                  style: TextStyle(
                                                    color: firstColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  if (abc.data!.trips![0].tripAgent![index].neighborhoodReferencePoint != null)
                                    ...{
                                      SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning_amber_outlined, color: thirdColor),
                                            SizedBox(width: 15),
                                            Flexible(
                                              child: Text(
                                                'Acceso autorizado: ${abc.data!.trips![0].tripAgent![index].neighborhoodReferencePoint}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    },
                                ],
                              ),
                              trailing: SizedBox(),
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 18),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_city, color: thirdColor),
                                            SizedBox(width: 15),
                                            Flexible(
                                              child: Text(
                                                'Empresa: ${abc.data!.trips![0].tripAgent![index].companyName}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.phone, color: thirdColor),
                                            SizedBox(width: 7),
                                            Flexible(
                                              child: TextButton(
                                                onPressed: () => launchUrl(Uri.parse('tel://${abc.data!.trips![0].tripAgent![index].agentPhone}')),
                                                child: Container(
                                                  child: Text(
                                                    'Teléfono: ${abc.data!.trips![0].tripAgent![index].agentPhone}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time, color: thirdColor),
                                            SizedBox(width: 15),
                                            Flexible(
                                              child: Text(
                                                'Salida: ${abc.data!.trips![0].tripAgent![index].hourIn}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_pin, color: thirdColor),
                                            SizedBox(width: 15),
                                            Flexible(
                                              child: Text(
                                                abc.data!.trips![0].tripAgent![index].agentReferencePoint == null ||
                                                        abc.data!.trips![0].tripAgent![index].agentReferencePoint == ''
                                                    ? "Dirección: ${abc.data!.trips![0].tripAgent![index].neighborhoodName}, ${abc.data!.trips![0].tripAgent![index].townName}"
                                                    : 'Dirección: ${abc.data!.trips![0].tripAgent![index].agentReferencePoint}, ${abc.data!.trips![0].tripAgent![index].neighborhoodName}, ${abc.data!.trips![0].tripAgent![index].townName},',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                blurStyle: BlurStyle.normal,
                                                color: Colors.white.withOpacity(0.2),
                                                blurRadius: 15,
                                                spreadRadius: -10,
                                                offset: Offset(-15, -6),
                                              ),
                                              BoxShadow(
                                                blurStyle: BlurStyle.normal,
                                                color: Colors.black.withOpacity(0.6),
                                                blurRadius: 30,
                                                spreadRadius: -15,
                                                offset: Offset(18, 5),
                                              ),
                                            ],
                                          ),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              textStyle: TextStyle(color: backgroundColor),
                                              backgroundColor: abc.data!.trips![0].tripAgent![index].commentDriver != 'No abordó'
                                                  ? Colors.red
                                                  : Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(style: BorderStyle.none),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (abc.data!.trips![0].tripAgent![index].commentDriver == 'No abordó') {
                                                return;
                                              }
                  
                                              Map<String, String> datas = {
                                                'agentId': abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                                'tripId': prefs.tripId.toString(),
                                                'traveled': '0',
                                              };
                  
                                              await http.post(Uri.parse('$ip/apis/agentCheckIn'), body: datas);                
                  
                                              setState(() {
                                                if (traveledB(abc, index)) {
                                                  waypointsAbordados.removeWhere((element) => element == abc.data!.trips![0].tripAgent![index].agentId.toString());
                                                  totalAbordado--;
                                                }
                                                abc.data!.trips![0].tripAgent![index].commentDriver = 'No abordó';
                                                abc.data!.trips![0].tripAgent![index].traveled = 0;
                                              });
                  
                                              fetchRegisterCommentAgent(
                                                abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                                prefs.tripId,
                                                'No abordó',
                                              );
                                            },
                                            child: Text(
                                              'No abordó',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
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
                    },
                  ),
                ),
              ],
            ) : Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin:  EdgeInsets.only(left: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Total de agentes: ${abc.data!.trips![0].tripAgent!.length}',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0)),
                        Text(
                          'Abordados: $totalAbordado',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 10.0),
              //_buttonsRuta(),
              SizedBox(height: 10.0),
                Column(
                children: List.generate(
                  abc.data!.trips![0].tripAgent!.length,
                  (index) {
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
                          margin: EdgeInsets.all(15),
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
                                          animationDurate:ion:
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
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [                                      
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
                                              fontSize: 16.0)),

                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (abc.data!.trips![0].tripAgent![index].latitude==null) {
                                              WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: 'Este agente no cuenta con ubicación',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
                                            }else{
                                              waypoints.clear();
                                              waypoints.add('${abc.data!.trips![0].tripAgent![index].latitude},${abc.data!.trips![0].tripAgent![index].longitude}');
                                              launchGoogleMapsx(apiKey, latidudeInicial.toString(), longitudInicial.toString(), waypoints);
                                            }
                                            //print('Dirección we');
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                Icon(Icons.location_on_outlined, color: abc.data!.trips![0].tripAgent![index].latitude==null? Colors.red : firstColor, size: 30,),
                                                Text('Ubicación ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal,fontSize: 16.0)),                                      
                                              ],)
                                            ],
                                          ),
                                        ),
                                      ),
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
                                                fontSize: 16.0)),
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
                                          Column(
                                            crossAxisAlignment :CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text('Hora de encuentro: ',style: TextStyle(color: Colors.white,fontSize: 18.0)),
                                              Text(textAlign:TextAlign.start,'${abc.data!.trips![0].tripAgent![index].hourForTrip}',style: TextStyle(
                                                color: firstColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                            ],
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
                                                  fontSize: 16.0)),
                                          ),
                                        ],
                                      ),
                                    ), 
                                  },
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
                                                  fontSize: 16.0)),
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
                                                        fontSize: 16.0)))
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
                                                  fontSize: 16.0)),
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
                                                  fontSize: 16.0)),
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
                                                                                WarningSuccessDialog().show(
                                                                                  navigatorKey.currentContext!,
                                                                                  title: 'No puede ir vacío la observación',
                                                                                  tipo: 1,
                                                                                  onOkay: () {},
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
                  },
                ),
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

  Widget _buttonsRuta() {
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
            child: Text("Generar ruta",
                style: TextStyle(
                    color: backgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            onPressed: () async{

              permiso = await checkLocationPermission();
              if (!permiso!) {
                WarningSuccessDialog().show(
                                                          navigatorKey.currentContext!,
                                                          title: 'Usted negó el acceso a la ubicación. Esto es necesario para poder abordar agentes. Si no da acceso en configuraciones, no podrá abordar agentes.',
                                                          tipo: 1,
                                                          onOkay: () {
                                                            try {
                                                              AppSettings.openLocationSettings();
                                                              } catch (error) {
                                                                print(error);
                                                              }
                                                          },
                                                        );
                return;
              }

              obtenerUbicacion();
              llenarArreglo();
              LoadingIndicatorDialog().show(context);
              Future.delayed(const Duration(seconds: 2), () {
                launchGoogleMapsx(apiKey,latidudeInicial.toString(), longitudInicial.toString(), waypoints);
              });
              
            },
          ),
        ),
      ],
    );
  }

  void llenarArreglo() async{
    var verificarAbordado;
    await fetchAgentsTripInProgress().then((value) async{


              if(value.trips![1].actualTravel!.tripType!='Entrada'){
                waypoints.clear();
                
                for(var i = 0; i < value.trips![0].tripAgent!.length; i++){
                  
                  verificarAbordado = waypointsAbordados.where((element) => element == value.trips![0].tripAgent![i].agentId.toString());

                  if(verificarAbordado.isNotEmpty)
                    waypoints.add('${value.trips![0].tripAgent![i].latitude},${value.trips![0].tripAgent![i].longitude}');
                }

                setState(() {});
              }else{
                Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                latidudeInicial = position.latitude;
                longitudInicial = position.longitude;

              }
              
    });
            
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
                confirmBtnTextStyle:
                    TextStyle(fontSize: 15, color: Colors.white),
                cancelBtnTextStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                onConfirmBtnTap: () {
                  Navigator.pop(context);

                  if (tripVehicle == '') {
                    WarningSuccessDialog().show(
                                                                      navigatorKey.currentContext!,
                                                                      title: 'Tiene que ingresar un vehiculo.',
                                                                      tipo: 1,
                                                                      onOkay: () {},
                                                                    );
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