//import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
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

class MyConfirmAgent extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;
  final departmentId;
  final departmentName;

  const MyConfirmAgent({Key? key, this.plantillaDriver, this.departmentId, this.departmentName}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyConfirmAgent> {
  int totalAbordado = 0;
  int totalAgente = 0;
  int totalNoAbordado = 0;
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

  bool abordados = true;
  bool noabordaron = false;

  String apiKey = 'AIzaSyBJJYIS4G4n-3AP93am08XyDyDiA-vgPmM';

  bool flagEOS = false;
  List<bool> enRuta = [];

  List<TextEditingController> check = [];
  List<TextEditingController> comment = new List.empty(growable: true);
  TextEditingController vehicleController = new TextEditingController();
  TextEditingController agentEmployeeId = new TextEditingController();

  var tripVehicle = '';
  bool vehicleL = false;
  bool cargarInfoViaje = false;
  bool cargarL = false;
  bool cargarTotal = false;
  List<String> waypoints = [];
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
        context,
        title: "${resp.message}",
        tipo: 1,
        onOkay: () {},
      );
    }

    return Message.fromJson(json.decode(response.body));
  }

  void gettotalAbordado() async {
    var lista = await item;
    totalAgente = lista!.trips![0].tripAgent!.length;
    tipoViaje = lista.trips![1].actualTravel!.tripType!;
    
    for (int i = 0; i < lista.trips![0].tripAgent!.length; i++) {
      if (traveledB(lista, i)) {
        totalAbordado++;
      }else{
        totalNoAbordado++;
      }

      enRuta.add(false);
    }
    cargarTotal = true;
    setState(() {});

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
          context,
          title: "Su viaje ha sido completado",
          tipo: 2,
          onOkay: () {},
        );
      }
    } else if (si.ok != true) {
      WarningSuccessDialog().show(
        context,
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

  Future<bool> fetchRegisterCommentAgent(
      String agentId, String tripId, String comment) async {
        LoadingIndicatorDialog().show(context);
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

    LoadingIndicatorDialog().dismiss();
    if (responses.statusCode == 200 &&
        si.ok == true &&
        responses.statusCode == 200) {

      return true;
    } else if (si.ok != true) {
      WarningSuccessDialog().show(
        context,
        title: "${si.message}",
        tipo: 1,
        onOkay: () {},
      );
    }
    return false;
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

    } else if (si.ok != true) {
      WarningSuccessDialog().show(
        context,
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
        context,
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

    await fetchAgentsTripInProgress().then((value) => {

      //print(value.trips![1].actualTravel!.tripType),

      if(value.trips![1].actualTravel!.tripType=='Entrada'){
        flagEOS = true,
        cargarL = true,
        setState(() {})
      }else{
        flagEOS = false,
        cargarL = true,
        setState(() {})
      },
      
    });
  }

  launchSalidasMaps(lat,lng)async{
    String destination = '$lat,$lng';
    String url = 'google.navigation:q=$destination&mode=d';
    await launchUrl(Uri.parse(url));
  }

 Future<void> launchGoogleMapsx(String apiKey, String startLat, String startLng, List<String> waypoints1) async {
    String baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
    String origin = '$startLat,$startLng';
    
    if (!flagEOS) {      
      var distances = [];
      for (var i = 0; i < waypoints1.length; i++) {      
        String urlDistance = '$baseUrl?origin=$origin&destination=${waypoints1[i]}&key=$apiKey';
        final responseDistance = await http.get(Uri.parse(urlDistance));
        if (responseDistance.statusCode == 200) {
          final dataDistance = json.decode(responseDistance.body);
          print(responseDistance.body);
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
      if (maxIndex >= 0 && maxIndex< waypoints1.length) {
        String elementoMovido = waypoints1.removeAt(maxIndex);
        waypoints1.add(elementoMovido);
      } else {
        print('Posición inválida');
      }
      String destination = waypoints1.last;
      String waypointsString = waypoints1.join('|');    
      String url = '$baseUrl?origin=$origin&destination=$destination&waypoints=optimize:true|$waypointsString&key=$apiKey';

      // ignore: avoid_print
      final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          List<dynamic> sortedWaypoints = data['routes'][0]['waypoint_order']
            .map((index) => waypoints1[index])
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
      LoadingIndicatorDialog().dismiss();
      String destination = waypoints1.last;
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
        cargarInfoViaje=true;
        setState(() {
          tripVehicle = infoViaje[3]['viajeActual']['tripVehicle'];
          vehicleL = true;
          vehicleController.text = tripVehicle;
          tripId = infoViaje[3]['viajeActual']['tripId'];
        });
      } else {
        cargarInfoViaje=true;
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

    if(cargarInfoViaje == true && cargarL == true && cargarTotal == true)
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ingresarVehiculo(),
            escanearAgente(),
            SizedBox(height: 20.0),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Total de agentes: $totalAgente',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, bottom: 2, right: 8, left: 8),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buttonsAgents(),
                  if(tipoViaje!='Entrada')...{
                    Expanded(child: SizedBox()),
                    _buttonsRuta(),
                  }
                ],
              ),
            ),   
            SizedBox(height: 10.0),
            opcionesBotones(),  
            SizedBox(height: 5.0),
            _agentToConfirm(),
            SizedBox(height: 10.0),
          ],
        ),
      )
    );
    else return WillPopScope(
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

  Widget escanearAgente() {

    return FutureBuilder<TripsList4>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          return Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.0),
              Center(child: Text('Marcar abordaje', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),)),
              SizedBox(height: 5),
              Row(
                children: [
                   Expanded(
                  child: GestureDetector(
                    onTap: () {
                      
                      showGeneralDialog(
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionBuilder: (context, a1, a2, widget) {
                          return Transform.scale(scale: a1.value,
                            child: Opacity(opacity: a1.value,
                              child: AlertDialog(
                                backgroundColor: Theme.of(navigatorKey.currentContext!).cardColor,
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Theme.of(navigatorKey.currentContext!).dividerColor, // Cambia el color de los bordes aquí
                                    width: 1.0, // Cambia el ancho de los bordes aquí
                                  ),
                                ),
                                
                                title: Center(child: Text('Buscar Agente',style: Theme.of(navigatorKey.currentContext!).textTheme.labelMedium!.copyWith(fontSize: 20, fontWeight: FontWeight.normal))),
                                content: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardTheme.color,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                      width: 1
                                    ) // Radio de la esquina
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TextField(
                                      controller: agentEmployeeId,
                                      style: TextStyle(
                                        color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Número de empleado o identidad',
                                        hintStyle: TextStyle(
                                          color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: BorderSide(color: Colors.black),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cerrar',
                                            style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.bold)
                                          ),
                                        ),
                                      ),
                                  
                                      SizedBox(width: 10.0),
                                      
                                      Expanded(
                                        child: TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: BorderSide(color: Color.fromRGBO(40, 93, 169, 1)),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(40, 93, 169, 1)),
                                          ),
                                          onPressed: () async{
                                            permiso = await checkLocationPermission();
                                              if (!permiso!) {
                                                WarningSuccessDialog().show(
                                                  context,
                                                  title: "Usted negó el acceso a la ubicación. Esto es necesario para poder abordar agentes. Si no da acceso en configuraciones, no podrá abordar agentes.",
                                                  tipo: 1,
                                                  onOkay: () async {
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
                                                    context,
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
                                                      context,
                                                      title: '${resp['msg']}',
                                                      tipo: 1,
                                                      onOkay: () {},
                                                    ); 
                                                    return;
                                                  
                                                  }else{
                                                  if(resp['msg']=='Agente no se encuentra registrado en este viaje.'){
                                                    LoadingIndicatorDialog().dismiss();
                                                    QuickAlert.show(
                                                      context: context,
                                                      type: QuickAlertType.warning,
                                                      title: '¡Alerta!',
                                                      text: 'Agente no se encuentra registrado en este viaje. Desea agregarlo al viaje?',
                                                      confirmBtnText: 'Confirmar',
                                                      cancelBtnText: 'Cancelar',
                                                      showCancelBtn: true,  
                                                      confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                                      cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),
                                                      onConfirmBtnTap: () async{
                                      
                                                        LoadingIndicatorDialog().show(context);
                                      
                                                         Map datas = {
                                                          "companyId": abc.data!.trips![1].actualTravel!.companyId.toString(),
                                                          "agentEmployeeId": agentEmployeeId.text
                                                        };
                                      
                                                        http.Response responsed =
                                                            await http.post(Uri.parse('$ip/apis/searchAgent'), body: datas);
                                                        final data1 = Search.fromJson(json.decode(responsed.body));
                                      
                                      
                                                        if(data1.agent!.msg!=null){
                                                          LoadingIndicatorDialog().dismiss();
                                      
                                                          if(data1.ok==true){
                                                            Navigator.pop(context);
                                                            Navigator.pop(context);
                                                            WarningSuccessDialog().show(
                                                              context,
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
                                      
                                                          LoadingIndicatorDialog().dismiss();
                                      
                                                          if(mounted){
                                                            Navigator.pop(context);
                                                            Navigator.pop(context);
                                                            WarningSuccessDialog().show(
                                                              context,
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
                                                            itemAbordaje.trips![0].tripAgent![indexP].agentId.toString(),
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
                                                          
                                                          LoadingIndicatorDialog().dismiss();
                                                          if(mounted){
                                                            Navigator.push(context,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));
                                      
                                                            WarningSuccessDialog().show(
                                                              context,
                                                              title: 'Se agrego el agente ${itemAbordaje.trips![0].tripAgent![indexP].agentFullname} al viaje.',
                                                              tipo: 2,
                                                              onOkay: () {},
                                                            );  
                                                            
                                                          } 
                                                        }
                                      
                                                      },
                                                      onCancelBtnTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  return;
                                                  }else{
                                                    LoadingIndicatorDialog().dismiss();
                                                    WarningSuccessDialog().show(
                                                              context,
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
                                                QuickAlert.show(
                                                  context: context,
                                                  type: QuickAlertType.confirm,
                                                  title: 'Abordó',
                                                  text: "¿Está seguro que desea marcar como \nabordado al agente ${abc.data!.trips![0].tripAgent![index].agentFullname}?",
                                                  confirmBtnText: 'Confirmar',
                                                  cancelBtnText: 'Cancelar',
                                                  showCancelBtn: true,  
                                                  confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                                  cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),
                                                  onConfirmBtnTap: () async{
                                                    Navigator.pop(context);
                                      
                                                    LoadingIndicatorDialog().show(context);
                                      
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
                                                                                                              agentEmployeeId.text='';
                                                  abc.data!.trips![0].tripAgent![index].commentDriver=null;                                                         
                                                  totalAbordado++;
                                                  totalNoAbordado--;
                                                   
                                                    LoadingIndicatorDialog().dismiss();
                                                    
                                      
                                                    WarningSuccessDialog().show(
                                                              context,
                                                              title: 'El agente ${abc.data!.trips![0].tripAgent![index].agentFullname} ha abordado.',
                                                              tipo: 2,
                                                              onOkay: () {},
                                                            );  
                                                  setState(() { });
                                                  },
                                                  onCancelBtnTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                );
                                            
                                              }
                                            
                                          },
                                          child: Text(
                                            'Abordar',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15
                                            ),
                                          ),
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
                                "assets/icons/usuario.svg",
                                color: Theme.of(context).primaryIconTheme.color,
                                width: 15,
                                height: 15,
                              ),
                              SizedBox(width: 6),
                            Flexible(
                              child: TextField(
                                enabled: false,
                                style: TextStyle(
                                  color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Número de empleado o identidad',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.normal
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      permiso = await checkLocationPermission();
                        if (!permiso!) {
                          WarningSuccessDialog().show(
                            context,
                            title: "Usted negó el acceso a la ubicación. Esto es necesario para poder abordar agentes. Si no da acceso en configuraciones, no podrá abordar agentes.",
                            tipo: 1,
                            onOkay: () async {
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
                                                    context,
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
                                                    context,
                                                    title: "${resp['msg']}",
                                                    tipo: 1,
                                                    onOkay: () {},
                                                  );
                                                    return;
                                                  
                                                  }else{
                                                  if(resp['msg']=='Agente no se encuentra registrado en este viaje.'){
                                                    LoadingIndicatorDialog().dismiss();
                                                    QuickAlert.show(
                                                      context: navigatorKey.currentContext!,
                                                      type: QuickAlertType.warning,
                                                      title: '¡Alerta!',
                                                      text: 'Agente no se encuentra registrado en este viaje. Desea agregarlo al viaje?',
                                                      confirmBtnText: 'Confirmar',
                                                      cancelBtnText: 'Cancelar',
                                                      showCancelBtn: true,  
                                                      confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                                      cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),
                                                      onConfirmBtnTap: () async{

                                                        LoadingIndicatorDialog().show(navigatorKey.currentContext!);

                                                         Map datas = {
                                                          "companyId": abc.data!.trips![1].actualTravel!.companyId.toString(),
                                                          "agentEmployeeId": codigoQR
                                                        };

                                                        http.Response responsed =
                                                            await http.post(Uri.parse('$ip/apis/searchAgent'), body: datas);
                                                        final data1 = Search.fromJson(json.decode(responsed.body));


                                                        if(data1.agent!.msg!=null){
                                                          LoadingIndicatorDialog().dismiss();

                                                          if(data1.ok==true){
                                                            Navigator.pop(navigatorKey.currentContext!);
                                                            WarningSuccessDialog().show(
                                                              context,
                                                              title: "${data1.agent!.msg!}",
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
                                                          LoadingIndicatorDialog().dismiss();
                                                          
                                                          if(mounted){
                                                            Navigator.pop(navigatorKey.currentContext!);
                                                            Navigator.pop(navigatorKey.currentContext!);
                                                            WarningSuccessDialog().show(
                                                              context,
                                                              title: "${dataR['message']}",
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
                                                            itemAbordaje.trips![0].tripAgent![indexP].agentId.toString(),
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
                                                            
                                                          LoadingIndicatorDialog().dismiss();
                                                          if(mounted){
                                                            Navigator.pop(navigatorKey.currentContext!);
                                                            Navigator.push(navigatorKey.currentContext!,MaterialPageRoute(builder: (context) => MyConfirmAgent(),));

                                                           WarningSuccessDialog().show(
                                                              context,
                                                              title: "Se agrego el agente ${itemAbordaje.trips![0].tripAgent![indexP].agentFullname} al viaje.",
                                                              tipo: 2,
                                                              onOkay: () {},
                                                            );
                                                            
                                                          } 
                                                        }

                                                      },
                                                      onCancelBtnTap: () {
                                                        Navigator.pop(navigatorKey.currentContext!);
                                                      },
                                                    );
                                                  return;
                                                  }else{
                                                    LoadingIndicatorDialog().dismiss();
                                                    WarningSuccessDialog().show(
                                                              context,
                                                              title: "${resp['msg']}",
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
                            QuickAlert.show(
                              context: navigatorKey.currentContext!,
                              type: QuickAlertType.confirm,
                              title: 'Abordó',
                              text: "¿Está seguro que desea marcar como \nabordado al agente ${abc.data!.trips![0].tripAgent![index].agentFullname}?",
                              confirmBtnText: 'Confirmar',
                              cancelBtnText: 'Cancelar',
                              showCancelBtn: true,  
                              confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                              cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),
                              onConfirmBtnTap: () async{

                                Navigator.pop(navigatorKey.currentContext!);

                                LoadingIndicatorDialog().show(context);

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
                                
                                abc.data!.trips![0].tripAgent![index].commentDriver=null;
                                totalAbordado++;
                                totalNoAbordado--;

                                WarningSuccessDialog().show(
                                  context,
                                  title: "El agente ${abc.data!.trips![0].tripAgent![index].agentFullname} ha abordado.",
                                  tipo: 2,
                                  onOkay: () {},
                                );

                              setState(() { });
                              },
                              onCancelBtnTap: () {
                                Navigator.pop(navigatorKey.currentContext!);
                              },
                            );
                        
                          }
                        }
                    }
                  ),
                ),

                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: (){
                      WarningSuccessDialog().show(
                        navigatorKey.currentContext!,
                        title: "Debe marcar el abordaje al momento de que el agente ingrese a la unidad, en caso de no abordar, solo debe presionar que no abordó",
                        tipo: 3,
                        onOkay: () {},
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color:  Theme.of(context).primaryIconTheme.color!, width: 2.0), // Borde blanco
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/info.svg",
                        color: Theme.of(context).primaryIconTheme.color,
                        height: 14,
                        width: 14,
                      ),
                    ),
                  )
                ],
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
                              String codigoQR = await FlutterBarcodeScanner.scanBarcode("#9580FF", "Cancelar", true, ScanMode.QR);
                    
                              if (codigoQR == "-1") {

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
      backgroundColor: Theme.of(navigatorKey.currentContext!).cardColor,
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Center(
          child: Text(
        'Vehículo Encontrado',
        style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 20),
      )),
      content: Container(
        height: 130,
        child: Column(
          children: [
            const SizedBox(height: 8.0),
            Text('Descripcion:',
                style:  Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 5,
            ),
            Text(resp['vehicle']['name'],
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
            SizedBox(
              height: 15,
            ),
            Text('Placa:',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, )),
            SizedBox(
              height: 10,
            ),
            Text(resp['vehicle']['registrationNumber'],
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
          ],
        ),
      ),
      actions: [
        Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: BorderSide(color: Colors.black),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cancelar',
                                            style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.bold)
                                          ),
                                        ),
                                      ),
                                  
                                      SizedBox(width: 10.0),
                                      
                                      Expanded(
                                        child: TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: BorderSide(color: Color.fromRGBO(40, 93, 169, 1)),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(40, 93, 169, 1)),
                                          ),
                                          onPressed: () async{
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
                                                  context,
                                                  title: "${resp2['message']}",
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
                                                  context,
                                                  title: "${resp2['message']}",
                                                  tipo: 1,
                                                  onOkay: () {},
                                                ); 
                                            }
                                          },
                                          child: Text(
                                            'Agregar',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15
                                            ),
                                          ),
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

    // ignore: non_constant_identifier_names
    alertaPaso_noSalio(abc, index) async {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: "¿Está seguro que desea marcar como no salio el agente?",
        confirmBtnText: "Confirmar",
        cancelBtnText: "Cancelar",
        title: '¿Está seguro?',
        showCancelBtn: true,
        confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
        cancelBtnTextStyle: TextStyle(
            color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          LoadingIndicatorDialog().show(context);
          bool abordo = traveledB(abc, index);
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

          LoadingIndicatorDialog().dismiss();

          abc.data!.trips![0].tripAgent![index].didntGetOut = 1;
          if (abc.data!.trips![0].tripAgent![index].traveled = traveled) {
            abc.data!.trips![0].tripAgent![index].traveled = false;
            traveled = abc.data!.trips![0].tripAgent![index].traveled;
          }

          if(abordo){
            traveled = !traveled;
            abc.data!.trips![0].tripAgent![index].traveled = 0;
            totalAbordado--;
            totalNoAbordado++;
          }
          
          setState(() {      
            abc.data!.trips![0].tripAgent![index].commentDriver = "Pasé por él (ella) y no salió";
          });
          
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
      );

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
          Navigator.pop(context);
          bool abordo = traveledB(abc, index);
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

          if(abordo){
            traveled = !traveled;
            abc.data!.trips![0].tripAgent![index].traveled = 0;
            totalAbordado--;
            totalNoAbordado++;
          }
          
          setState(() {
            abc.data!.trips![0].tripAgent![index].commentDriver = 'Canceló transporte';         
          });
          
        },
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
      );

    }

  Widget datosAgentes(bool traveledB(dynamic abc, dynamic index), AsyncSnapshot<TripsList4> abc, int index, BuildContext context, var check2) {
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
                                      traveledB(abc, index)
                                      ? Container(
                                        width: 18,
                                        height: 18,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromRGBO(0, 191, 95, 1), // Borde blanco
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: SvgPicture.asset(
                                            "assets/icons/check.svg",
                                            color: Colors.white,
                                            width: 2,
                                            height: 2,
                                          ),
                                        ),
                                      )
                                      : Container(
                                        width: 18,
                                        height: 18,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromRGBO(178, 13, 13, 1), // Borde blanco
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Center(child: Text('X', style: TextStyle(color: Colors.white, fontSize: 12))),
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
                                                        text: '${abc.data!.trips![0].tripAgent![index].agentFullname}',
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
                                  padding: const EdgeInsets.only(right: 10, left: 10),
                                  child: InkWell(
                                      onTap: () {
                                        if (abc.data!.trips![0].tripAgent![index].latitude==null) {
                                          WarningSuccessDialog().show(
                                            context,
                                            title: "Este agente no cuenta con ubicación",
                                            tipo: 1,
                                            onOkay: () {},
                                          ); 
                                        }else{
                                          launchSalidasMaps(abc.data!.trips![0].tripAgent![index].latitude,abc.data!.trips![0].tripAgent![index].longitude);                                          
                                        }
                                        //print('Dirección we');
                                      },
                                      child:  Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 10),
                                                    child: Container(
                                                      width: 15,
                                                      height: 15,
                                                      child: Icon(Icons.location_on_outlined, color:abc.data!.trips![0].tripAgent![index].latitude==null? Colors.red :Color.fromRGBO(0, 191, 95, 1)),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Flexible(
                                                    child: Text(
                                                      'Ubicación',
                                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                    ),
                                                  ),
                                                                             
                                                ],
                                              ),
                                    ),
                                ),
                                Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),

                                SizedBox(height: 20),

                                      if (abc.data!.trips![0].tripAgent![index].hourForTrip == "00:00") ...{
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
                                                                  text: abc.data!.trips![0].tripAgent![index].hourForTrip==null?' --':
                                                                  '${abc.data!.trips![0].tripAgent![index].hourForTrip}',
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
                                                              text: abc.data!.trips![0].tripAgent![index].agentReferencePoint==null
                                                              ||abc.data!.trips![0].tripAgent![index].agentReferencePoint==""
                                                              ?"${abc.data!.trips![0].tripAgent![index].neighborhoodName}, ${abc.data!.trips![0].tripAgent![index].townName}":'${abc.data!.trips![0].tripAgent![index].agentReferencePoint}, ${abc.data!.trips![0].tripAgent![index].neighborhoodName}, ${abc.data!.trips![0].tripAgent![index].townName},',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),

                                      if (abc.data!.trips![0].tripAgent![index].neighborhoodReferencePoint != null)... {
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
                                                                text: '${abc.data!.trips![0].tripAgent![index].neighborhoodReferencePoint}',
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
                                                                  text: '${abc.data!.trips![0].tripAgent![index].hourIn}',
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
                                                            'tel://${abc.data!.trips![0].tripAgent![index].agentPhone}',
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
                                                                text: '${abc.data!.trips![0].tripAgent![index].agentPhone}',
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
                                                              text: '${abc.data!.trips![0].tripAgent![index].companyName}',
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
                                      if(tipoViaje=='Entrada')...{
             
              TextButton(
                                        style: TextButton.styleFrom(
                                          side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                                          fixedSize: Size(150, 25),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async{

                                          Size size = MediaQuery.of(context).size;
                                          showGeneralDialog(
                                            barrierColor: Colors.black.withOpacity(0.6),
                                            transitionBuilder: (context, a1, a2, widget) {
                                              final curvedValue = Curves.easeInOut.transform(a1.value);
                                              return Transform.translate(
                                                offset: Offset(0.0, (1 - curvedValue) * size.height / 2),
                                                child: Opacity(
                                                  opacity: a1.value,
                                                  child: Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: Container(
                                                      height: size.height/3,
                                                      width: size.width,
                                                      decoration: BoxDecoration(
                                                        color: prefs.tema ? Color.fromRGBO(47, 46, 65, 1) : Colors.white,
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(30.0),
                                                          topRight: Radius.circular(30.0),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 30),
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                      padding: const EdgeInsets.only(right: 120, left: 120, top: 15, bottom: 20),
                                                                      child: GestureDetector(
                                                                        onTap: () => Navigator.pop(context),
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                            color: Theme.of(navigatorKey.currentContext!).dividerColor,
                                                                            borderRadius: BorderRadius.circular(80)
                                                                          ),
                                                                          height: 6,
                                                                        ),
                                                                      ),
                                                                    ),
                                                              
                                                              GestureDetector(
                                                                onTap: () => abc.data!.trips![0].tripAgent![index].commentDriver == 'Pasé por él (ella) y no salió'? null :alertaPaso_noSalio(abc, index),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(width: size.width/4.8),
                                                                    Container(
                                                                      width: 16,
                                                                      height: 16,
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.circle,
                                                                        border: Border.all(color: Theme.of(navigatorKey.currentContext!).primaryIconTheme.color!, width: 1),
                                                                      ),
                                                                      child: Center(
                                                                        child: Container(
                                                                          width: 9,
                                                                          height: 9,
                                                                          decoration: BoxDecoration(
                                                                            shape: BoxShape.circle,
                                                                            color: abc.data!.trips![0].tripAgent![index].commentDriver == 'Pasé por él (ella) y no salió'? Theme.of(navigatorKey.currentContext!).primaryIconTheme.color!: Colors.transparent,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 5),
                                                                    Text(
                                                                      'Se pasó y no salió',
                                                                      style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 20),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(height: 20),
                                                              GestureDetector(
                                                                onTap: () => abc.data!.trips![0].tripAgent![index].commentDriver == 'Canceló transporte'?null:alertaCancelo(abc, index),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(width: size.width/4.8),
                                                                    Container(
                                                                      width: 16,
                                                                      height: 16,
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.circle,
                                                                        border: Border.all(color: Theme.of(navigatorKey.currentContext!).primaryIconTheme.color!, width: 1),
                                                                      ),
                                                                      child: Center(
                                                                        child: Container(
                                                                          width: 9,
                                                                          height: 9,
                                                                          decoration: BoxDecoration(
                                                                            shape: BoxShape.circle,
                                                                            color:abc.data!.trips![0].tripAgent![index].commentDriver == 'Canceló transporte'? Theme.of(navigatorKey.currentContext!).primaryIconTheme.color!: Colors.transparent,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 5),
                                                                    Text(
                                                                      'Cancelo transporte',
                                                                      style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 20),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(height: 20),
                                                              GestureDetector(
                                                                onTap: () async {
                          http.Response response =
                              await http.get(Uri.parse(
                                  '$ip/apis/getDriverComment/${abc.data!.trips![0].tripAgent![index].agentId}/${abc.data!.trips![0].tripAgent![index].tripId}'));
                          final send = Comment.fromJson(
                              json.decode(
                                  response.body));
                              check2[index].text = send.comment!.commentDriver;
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
                                            color: GradiantV_2,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                          )
                                        ),
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
                                                check2[
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
                                                    () async{
                                                        {
                                                          if(check2[index].text.isEmpty){
                                                            Navigator.pop(context);
                                                            WarningSuccessDialog().show(
                                                              context,
                                                              title: "No puede ir vacío la observación",
                                                              tipo: 1,
                                                              onOkay: () {},
                                                            );
                                                          }else{
                                                            Navigator.pop(context);
                                                            bool val = await fetchRegisterCommentAgent(
                                                              abc.data!.trips![0].tripAgent![index].agentId.toString(),
                                                              prefs.tripId,
                                                              check2[index].text
                                                            );
                                                              
                                                            if(val)
                                                              setState(() {
                                                                abc.data!.trips![0].tripAgent![index].commentDriver = check2[index].text;
                                                              });
                                                          }
                                                }},
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
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(width: size.width/4.8),
                                                                        Container(
                                                                          width: 16,
                                                                          height: 16,
                                                                          decoration: BoxDecoration(
                                                                            shape: BoxShape.circle,
                                                                            border: Border.all(color: Theme.of(navigatorKey.currentContext!).primaryIconTheme.color!, width: 1),
                                                                          ),
                                                                          child: Center(
                                                                            child: Container(
                                                                              width: 9,
                                                                              height: 9,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: abc.data!.trips![0].tripAgent![index].commentDriver != 'Canceló transporte'? abc.data!.trips![0].tripAgent![index].commentDriver != 'Pasé por él (ella) y no salió'? Theme.of(navigatorKey.currentContext!).primaryIconTheme.color!: Colors.transparent: Colors.transparent,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 5),
                                                                        Text(
                                                                          'Comentario',
                                                                          style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 20),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    if(abc.data!.trips![0].tripAgent![index].commentDriver != 'Canceló transporte' && abc.data!.trips![0].tripAgent![index].commentDriver != 'Pasé por él (ella) y no salió')...{
                                                                    SizedBox(height: 10),
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(10),
                                                                        border: Border.all(
                                                                          color: Theme.of(context).dividerColor,
                                                                          width: 1
                                                                        ) // Radio de la esquina
                                                                      ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(10),
                                                                        child: Text(
                                                                          abc.data!.trips![0].tripAgent![index].commentDriver == null ?'Sin comentario' :'${abc.data!.trips![0].tripAgent![index].commentDriver}',
                                                                          style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  },
                                                                  ],
                                                                ),
                                                              ),
                                                              
                                                              SizedBox(height: 20),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            transitionDuration: Duration(milliseconds: 200),
                                            barrierDismissible: true,
                                            barrierLabel: '',
                                            context: context,
                                            pageBuilder: (context, animation1, animation2) {
                                              return widget;
                                            },
                                          );                               
                                        },
                                        child: Text('Observaciones',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
            
            }else...{
            TextButton(
                                        style: TextButton.styleFrom(
                                          side: BorderSide(width: 1, color: abc.data!.trips![0].tripAgent![index].commentDriver == 'No abordó'? Colors.grey:Theme.of(context).primaryColorDark),
                                          fixedSize: Size(150, 25),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async{
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
                      totalAbordado--;
                      totalNoAbordado++;
                    }
                    abc.data!.trips![0].tripAgent![index].commentDriver = 'No abordó';
                    abc.data!.trips![0].tripAgent![index].traveled = 0;
                  });
              
                  fetchRegisterCommentAgent(
                    abc.data!.trips![0].tripAgent![index].agentId.toString(),
                    prefs.tripId,
                    'No abordó'
                  );                             
                },
                child: Text('No abordó',
                  style: abc.data!.trips![0].tripAgent![index].commentDriver == 'No abordó'? Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey): Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
            SizedBox(height: 10.0),
            if(abc.data!.trips![0].tripAgent![index].latitude==null)...{
              TextButton(
                style: TextButton.styleFrom(
                  side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                  fixedSize: Size(150, 25),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                ),
                onPressed: () async{
                
                  LoadingIndicatorDialog().show(context);
                  
                  http.Response response = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
                  final data = DriverData.fromJson(json.decode(response.body));

                  var latitudM;
                  var longitudM;
                  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                  latitudM = position.latitude;
                  longitudM = position.longitude;

                  Map datos =   {

                    'agentId': abc.data!.trips![0].tripAgent![index].agentId.toString(), 
                    'tripId': tripId.toString(),
                    'latitude': latitudM.toString(),
                    'longitude': longitudM.toString(),
                    'userId': data.driverId.toString(),
                    'userAgent': "mobile"
                  };
                  
                  http.Response responses = await http.post(Uri.parse('https://admin.smtdriver.com/registerUbicationFromTrip'), body: datos);
                   final resp = json.decode(responses.body);

                  LoadingIndicatorDialog().dismiss();
                   if(resp['ok']==true){
                      WarningSuccessDialog().show(
                        context,
                        title: "${resp['db'][0]['msg']}",
                         tipo: 2,
                        onOkay: () {},
                      ); 
                   }else{
                    WarningSuccessDialog().show(
                      context,
                       title: "${resp['message']}",
                        tipo: 1,
                      onOkay: () {},
                    ); 
                   }                

                },
                child: Text(
                  'Guardar Ubicación',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)
                )
              ),
              SizedBox(height: 20.0),
            }
            }
          ],
        ),
                    ),
    );
  }

  Widget entrada(AsyncSnapshot<TripsList4> abc, bool traveledB(dynamic abc, dynamic index), BuildContext context, List<TextEditingController> check) {
    return Column(
    children: List.generate(
      abc.data!.trips![0].tripAgent!.length,
      (index) {
        if(abordados){
          if(traveledB(abc,index))
            return datosAgentes(traveledB, abc, index, context, check);
          else
            return SizedBox();
        }else{
          if(!traveledB(abc,index))
            return datosAgentes(traveledB, abc, index, context, check);
          else
            return SizedBox();
        }
      },
    ),
    );
  }

  Widget salida(AsyncSnapshot<TripsList4> abc, bool traveledB(dynamic abc, dynamic index), BuildContext context) {
    return Column(
      children: List.generate(
        abc.data!.trips![0].tripAgent!.length,
        (index) {
          if(abordados){
          if(traveledB(abc,index))
            return datosAgentes(traveledB, abc, index, context, check);
          else
            return SizedBox();
        }else{
          if(!traveledB(abc,index))
            return datosAgentes(traveledB, abc, index, context, check);
          else
            return SizedBox();
        }
        },
      ),
    );
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
            
            List<TextEditingController> check = [];
            for (int i = 0; i < abc.data!.trips![0].tripAgent!.length; i++) {
              check.add(TextEditingController());
            }
            
            return abc.data!.trips![1].actualTravel!.tripType=='Salida' ?
              salida(abc, traveledB, context) 
            : entrada(abc, traveledB, context, check,);
          }
        } else {
          return ColorLoader3();
        }
      },
    );
  }

  Widget opcionesBotones() {
    return item!=null? Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0, bottom: 2, right: 8, left: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
              
                    elevation: 0,
                    backgroundColor: abordados!=true?Colors.transparent:Theme.of(context).unselectedWidgetColor,
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Abordaron',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, color: abordados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                      
                      SizedBox(width: 5),
                      
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: abordados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '$totalAbordado',
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: abordados == true ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight, fontSize: 9)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: abordados==true?null:() {
                    setState(() {
                      abordados = true;
                      noabordaron = false;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    elevation: 0,
                    backgroundColor: noabordaron!=true?Colors.transparent:Theme.of(context).unselectedWidgetColor,
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No abordaron',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, color: noabordaron==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                    
                      SizedBox(width: 5),
                  
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: noabordaron == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(                             
                              '$totalNoAbordado',
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: noabordaron == true ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight, fontSize: 9)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: noabordaron==true?null:() {
                    setState(() {
                      abordados = false;
                      noabordaron = true;
                    });
                  },
                ),
              ),
          
            ],
          ),
      ),
    ):
    WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buttonsRuta() {
    return FutureBuilder<TripsList4>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {                 
            return TextButton(
              style: TextButton.styleFrom(
                fixedSize: Size(150, 25),
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(  
                    "assets/icons/navegacion-gps.svg",
                    color: Colors.white,
                    height: 20,
                    width: 20,
                  ),
                  SizedBox(width: 8),
                  Text('Generar ruta',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontSize: 16)),
                ],
              ),
              onPressed: () async{
                      permiso = await checkLocationPermission();
                      if (!permiso!) {
                        WarningSuccessDialog().show(
                          context,
                          title: "Usted negó el acceso a la ubicación. Esto es necesario para poder abordar agentes. Si no da acceso en configuraciones, no podrá abordar agentes.",
                          tipo: 1,
                         onOkay: () async {
                            try {
                              AppSettings.openLocationSettings();
                            } catch (error) {
                              print(error);
                            }
                          },
                        ); 
                        return;
                      }

                      showGeneralDialog(
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionBuilder: (context, a1, a2, widget) {
                          return StatefulBuilder(
                            builder: (context, setState){
                              return Transform.scale(scale: a1.value,
                            child: Opacity(opacity: a1.value,
                              child: AlertDialog(
                                backgroundColor: Theme.of(navigatorKey.currentContext!).cardColor,
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Theme.of(navigatorKey.currentContext!).dividerColor, // Cambia el color de los bordes aquí
                                    width: 1.0, // Cambia el ancho de los bordes aquí
                                  ),
                                ),
                                
                                title: Text(
                                  'Seleccionar agentes para la ruta',
                                  style: Theme.of(navigatorKey.currentContext!).textTheme.labelMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(
                                      abc.data!.trips![0].tripAgent!.length,
                                      (index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  '${abc.data!.trips![0].tripAgent![index].agentFullname}',
                                                  style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 16),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                                                                
                                              
                                                TextButton(
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),
                                                    ),
                                                    backgroundColor: enRuta[index]==false? MaterialStateProperty.all(Colors.green) : MaterialStateProperty.all(Colors.red),
                                                  ),
                                                  onPressed:() {
                                                    setState(() {
                                                      enRuta[index]=!enRuta[index];
                                                      if(enRuta[index]==true){
                                                        waypoints.add('${abc.data!.trips![0].tripAgent![index].latitude},${abc.data!.trips![0].tripAgent![index].longitude}');
                                                      }else{
                                                        final targetString = '${abc.data!.trips![0].tripAgent![index].latitude},${abc.data!.trips![0].tripAgent![index].longitude}';
                                                        waypoints.remove(targetString);
                                                      }
                                                    });
                                                  },
                                                  child: Text(
                                                    enRuta[index]==false? 'Agregar': 'Quitar',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: BorderSide(color: Colors.black),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cerrar',
                                            style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.bold)
                                          ),
                                        ),
                                      ),
                                  
                                      SizedBox(width: 10.0),
                                      
                                      Expanded(
                                        child: TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: BorderSide(color: Color.fromRGBO(40, 93, 169, 1)),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(40, 93, 169, 1)),
                                          ),
                                          onPressed: () async{

                                            if(waypoints.length==0){
                                              WarningSuccessDialog().show(
                                                context,
                                                title: "Debe agregar al menos 1 agente para generar la ruta",
                                                tipo: 1,
                                                onOkay: () {},
                                              );
                                              return;
                                            }

                                            LoadingIndicatorDialog().show(context);
                                            var latitudM;
                                            var longitudM;
                                            Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                          
                                            latitudM = position.latitude;
                                            longitudM = position.longitude;
                                            
                                            if(latitudM!=null && longitudM!=null){
                                              launchGoogleMapsx(apiKey,latitudM.toString(), longitudM.toString(), waypoints);
                                            }
                                          },
                                          child: Text(
                                            'Generar Ruta',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15
                                            ),
                                          ),
                                        ),
                                      ),
                                  
                                      
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                            }
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
            );

        } else {
          return ColorLoader3();
        }
      },
    );
  }

  Widget _buttonsAgents() {
    return TextButton(
      style: TextButton.styleFrom(
        fixedSize: Size(150, 25),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
      ),
      child: Text('Completar viaje',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontSize: 16)),
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
                  context,
                  title: "Tiene que ingresar un veiculo",
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
    );
  }
}