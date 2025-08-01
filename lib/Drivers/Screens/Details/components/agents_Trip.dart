//import 'package:back_button_interceptor/back_button_interceptor.dart';
//import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatscreen.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_auth/Drivers/models/registerTripAsCompleted.dart';
import 'package:flutter_auth/main.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
//import 'package:quickalert/quickalert.dart';
import '../../../../components/AppBarPosterior.dart';
import '../../../../components/AppBarSuperior.dart';
import '../../../../components/ConfirmationDialog.dart';
import '../../../../components/backgroundB.dart';
import '../../../../components/warning_dialog.dart';
//import '../../../../constants.dart';
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
  var confirmVal = 0;
  
  bool noconfirmados = false;
  var noConfirmVal = 0;

  bool cancelados = false;
  var cancelVal = 0;

  int? idMotorista;
  String? nombreMotorista;

  var arrayMessaje=[];

  ConfirmationLoadingDialog loadingDialog = ConfirmationLoadingDialog();
  ConfirmationDialog confirmationDialog = ConfirmationDialog();
  
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
      confirmationDialog.dismiss();  
      if(mounted){
        WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: '${resp.message}',
          tipo: 2,
          onOkay: () {},
        );

        _refresh();
      }
    } else if (response.statusCode == 200 && resp.ok != true) {
      LoadingIndicatorDialog().dismiss();    
      confirmationDialog.dismiss();   
      if(mounted){
        WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: '${resp.message}',
          tipo: 1,
          onOkay: () {},
        );
      }
    }

    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver> fetchNoConfirm(String agentId, String tripId) async {
    LoadingIndicatorDialog().show(context);  
    Map data = {'agentId': agentId, 'tripId': tripId};
    //print(data);
    http.Response response = await http
        .post(Uri.parse('$ip/apis/markAgentAsNotConfirmed'), body: data);
    if (mounted) {
      
        final resp = Driver.fromJson(json.decode(response.body));

        Map data2 = {"idU": agentId.toString(), "Estado": 'RECHAZADO'};
        String sendData2 = json.encode(data2);
        await http.put(Uri.parse('https://apichat.smtdriver.com/api/salas/$tripId'), body: sendData2, headers: {"Content-Type": "application/json"});

        if (response.statusCode == 200 && resp.ok == true) {
          LoadingIndicatorDialog().dismiss();
          confirmationDialog.dismiss();
          //print(response.body);
          if(mounted){
            WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: '${resp.message}',
          tipo: 2,
          onOkay: () {},
        );
          }

          _refresh();

        } else if (response.statusCode == 500) {
          LoadingIndicatorDialog().dismiss();
          confirmationDialog.dismiss();
          if(mounted){
            WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: '${resp.message}',
          tipo: 1,
          onOkay: () {},
        );
          }
        }
      
    }

    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver> fetchPastInProgress() async {
    
    http.Response response = await http
        .get(Uri.parse('$ip/apis/passTripToProgress/${prefs.tripId}'));
    final resp = Driver.fromJson(json.decode(response.body));
    LoadingIndicatorDialog().dismiss();
    confirmationDialog.dismiss();
    //print(response.body);
    if (response.statusCode == 200 && resp.ok == true) {
      //print(response.body);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomeDriverScreen()),
          (Route<dynamic> route) => false);

          WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: 'Su viaje está en proceso',
          tipo: 2,
          onOkay: () {},
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
      WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: '${resp.message}',
          tipo: 1,
          onOkay: () {},
        );
    } else if (response.statusCode == 500) {
      WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: '${resp.message}',
          tipo: 1,
          onOkay: () {},
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
      WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: '${resp.message}',
          tipo: 1,
          onOkay: () {},
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
      WarningSuccessDialog().show(
          navigatorKey.currentContext!,
          title: '${resp.message}',
          tipo: 1,
          onOkay: () {},
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
    print(prefs.driverCompanyId);
    getNumberToElement();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {        
        getCounterNotification(prefs.tripId);
      });
    });
  }

  void getNumberToElement(){
    fetchAgentsInTravel2().then((value) =>{
      setState((){
        confirmVal = value.trips![0].agentes!.length;
        noConfirmVal = value.trips![1].noConfirmados!.length;
        cancelVal = value.trips![2].cancelados!.length;
      })
    });
  }

  void getCounterNotification(String tripId) async {
    
    http.Response responses = await http.get(Uri.parse('https://apichat.smtdriver.com/api/mensajes/$tripId'));
    var getData = json.decode(responses.body);
    print(getData);
    idMotorista = getData['Motorista']['Id'];
    nombreMotorista = getData['Motorista']['Nombre'];

    if (getData.isNotEmpty) {
      for(var i=0;i<getData['Agentes'].length;i++){
       //print(getData['Agentes'][i]);
          setState(() {
            arrayMessaje.add({
              "nombreAgent": getData['Agentes'][i]['Nombre'],
              "cantMessage": getData['Agentes'][i]['sinleer_Motorista']
            });   
          });
      }
    }
        //print(arrayMessaje);
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

  launchSalidasMaps(lat,lng)async{
    String destination = '$lat,$lng';
    String url = 'google.navigation:q=$destination&mode=d';
    await launchUrl(Uri.parse(url));
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
            if(noconfirmados == true) _agentoNoConfirm(),
            if(cancelados == true) _agentToCancel(),
            SizedBox(height: 30.0),
          ],
        ),
      )
    );
  }

  Widget opcionesBotones() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                fixedSize: Size(150, 25),
                elevation: 0,
                backgroundColor: confirmados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: confirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                  SizedBox(width: 5),                      
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: confirmados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          '$confirmVal',
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: confirmados == true ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight, fontSize: 9)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: confirmados==true?null:() {
                setState(() {
                  confirmados = true;
                  noconfirmados = false;
                  cancelados = false;
                });
              },
            ),

            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: TextButton(
                style: TextButton.styleFrom(
                  side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                  fixedSize: Size(150, 25),
                  elevation: 0,
                  backgroundColor: noconfirmados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: noconfirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                    SizedBox(width: 5),                      
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: noconfirmados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            '$noConfirmVal',
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: noconfirmados == true ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight, fontSize: 9)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: noconfirmados==true?null:() {
                  setState(() {
                    confirmados = false;
                    noconfirmados = true;
                    cancelados = false;
                  });
                },
              ),
            ),

            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                fixedSize: Size(150, 25),
                elevation: 0,
                backgroundColor: cancelados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Cancelados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: cancelados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                  SizedBox(width: 5),                      
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cancelados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            '$cancelVal',
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: cancelados == true ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight, fontSize: 9)
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: cancelados==true?null:() {
                setState(() {
                  confirmados = false;
                  noconfirmados = false;
                  cancelados = true;
                });
              },
            ),
          ],
        ),
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
                    if(prefs.driverCompanyId == "")...{
                      if(data?.driverType=='Motorista')
                        Center(child: Text('Escanee el código QR del vehículo', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),)),
                      if(data?.driverType=='Motorista')
                        SizedBox(height: 6,),
                    },

                  Row(
                    children: [

                      if(prefs.driverCompanyId == "")...{
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
                      }else...{
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
                                      //enabled: data?.driverType=='Motorista'?false:true,
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
                      },

                      if(prefs.driverCompanyId == "")...{
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
                                      width: 15,
                                      height: 15,
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
                      },  


                        if (data?.driverType != 'Motorista' || prefs.driverCompanyId != "")
                        SizedBox(width: 10,),
                        if (data?.driverType != 'Motorista' || prefs.driverCompanyId != "")
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
                                    width: 15,
                                      height: 15,
                                  ),
                          onPressed: vehicleL==false?null:() async{
                            LoadingIndicatorDialog().show(context);
                            http.Response responses = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
                            final data2 = DriverData.fromJson(json.decode(responses.body));
                            Map data = {
                              "driverId": data2.driverId.toString(),
                              "tripId": prefs.tripId.toString(),
                              "vehicleId": "",
                              "tripVehicle": vehicleController.text,
                              "vehicleGroup": ""
                            };
                            http.Response responsed = await http.post(Uri.parse('https://driver.smtdriver.com/apis/editTripVehicle'), body: data);
                          
                            final resp2 = json.decode(responsed.body);
                            LoadingIndicatorDialog().dismiss();
                            if(resp2['type']=='success'){
                              if(mounted){
                                WarningSuccessDialog().show(
                                    navigatorKey.currentContext!,
                                    title: resp2['message'],
                                    tipo: 1,
                                    onOkay: () {},
                                  );
                                setState(() {
                                  tripVehicle = vehicleController.text;
                                });
                              }      
                          
                            }else{
                              WarningSuccessDialog().show(
                                    navigatorKey.currentContext!,
                                    title: resp2['message'],
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
                Text('Descripcion:',style:  Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 5,
                ),
                Text(resp['vehicle']['name'],style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
                SizedBox(
                  height: 15,
                ),
                Text('Placa:',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, )),
                SizedBox(
                  height: 10,
                ),
                Text(resp['vehicle']['registrationNumber'],style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
              ],
        ),
      ),
      actions: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 100,
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),side: BorderSide(color: Color.fromRGBO(40, 93, 169, 1)),),
                    ),
                    backgroundColor: MaterialStateProperty.all(Color.fromRGBO(40, 93, 169, 1)),
                  ),
                onPressed: () async{
                  LoadingIndicatorDialog().show(context);
                  http.Response responses = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
                  final data2 = DriverData.fromJson(json.decode(responses.body));
                  Map data = {
                    "driverId": data2.driverId.toString(),
                    "tripId": prefs.tripId.toString(),
                    "vehicleId": resp['vehicle']['_id'],
                    "tripVehicle": "${resp['vehicle']['name']} [${resp['vehicle']['registrationNumber']}]",
                    "vehicleGroup": "${resp['vehicle']['groups'].isEmpty?'':resp['vehicle']['groups'][0]['groupId']['name']}",
                    "vehicleOwnerId": "${resp['vehicle']['driverId']==null?-1:resp['vehicle']['driverId']}"
                  };

                  http.Response responsed = await http.post(Uri.parse('https://driver.smtdriver.com/apis/editTripVehicle'), body: data);
                  
                  final resp2 = json.decode(responsed.body);
                  LoadingIndicatorDialog().dismiss();
                  if(resp2['type']=='success'){
                    if(mounted){
                      Navigator.pop(context);
                      WarningSuccessDialog().show(
                        navigatorKey.currentContext!,
                        title: resp2['message'],
                        tipo: 2,
                        onOkay: () {},
                      );
                      setState(() {
                        tripVehicle = "${resp['vehicle']['name']} [${resp['vehicle']['registrationNumber']}]";
                        vehicleController.text=tripVehicle;  
                      });
                    }
                  }else{
                    WarningSuccessDialog().show(
                        navigatorKey.currentContext!,
                        title: resp2['message'],
                        tipo: 1,
                        onOkay: () {},
                      );
                  }
                },
                child: Text('Agregar',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                  ),
                ),
                SizedBox(width: 10.0),
                  Container(width: 100,
                    child: ElevatedButton(
                      style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),side: BorderSide(color: Colors.black),),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                    onPressed: () => {
                                                                        Navigator.pop(context),
                                                                      },
                                                                      child: Text('Cancelar',
                    style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
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
                                                  color:  abc.data!.trips![0].agentes![index].hourForTrip==null?Color.fromRGBO(213, 0, 0, 1):Theme.of(context).primaryIconTheme.color,
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

                                Padding(
                                  padding: const EdgeInsets.only(right: 10, left: 6, top: 14),
                                  child: InkWell(
                                  onTap: () {
                                    if (abc.data!.trips![0].agentes![index].latitude==null) {
                                      WarningSuccessDialog().show(
                                        context,
                                        title: "Este agente no cuenta con ubicación",
                                        tipo: 1,
                                        onOkay: () {},
                                      ); 
                                    }else{
                                      launchSalidasMaps(abc.data!.trips![0].agentes![index].latitude,abc.data!.trips![0].agentes![index].longitude);                                          
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
                                                  child: Icon(Icons.location_on_outlined, color:abc.data!.trips![0].agentes![index].latitude==null? Colors.red :Color.fromRGBO(0, 191, 95, 1)),
                                                ),
                                              ),
                                              SizedBox(width: 18),
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
                                                                  text: abc.data!.trips![0].agentes![index].hourForTrip==null?'--':
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
                                                              ?"${abc.data!.trips![0].agentes![index].neighborhoodName}, ${abc.data!.trips![0].agentes![index].townName}":'${abc.data!.trips![0].agentes![index].agentReferencePoint}, ${abc.data!.trips![0].agentes![index].neighborhoodName}, ${abc.data!.trips![0].agentes![index].townName},',
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
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
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
                                                  pageBuilder: (_, __, ___) => ChatScreen(
                                                    idAgent: abc.data!.trips![0].agentes![index].agentId.toString(),
                                                    nombreAgent: abc.data!.trips![0].agentes![index].agentFullname,
                                                    nombre: "$nombreMotorista",
                                                    id: '$idMotorista',
                                                    rol: "MOTORISTA",
                                                    tipoViaje: 'entrada',
                                                    idV: abc.data!.trips![0].agentes![index].tripId.toString(),
                                                    pantalla: true,
                                                  ),
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                              },
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:10, right: 18),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: 28,
                                                          height: 28,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/chats.svg",
                                                            color: Theme.of(context).hintColor,
                                                          ),
                                                        ),
                                                        
                                                        Text(
                                                          "Chat",
                                                          style: TextStyle(
                                                                  color: Theme.of(context).hintColor, fontSize: 10, fontFamily: 'Roboto'
                                                                ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                    for(var i=0; i< arrayMessaje.length; i++)...{
                                                      if(arrayMessaje[i]['nombreAgent']== abc.data!.trips![0].agentes![index].agentFullname!.toUpperCase())...{
                                                        Positioned(
                                                        top: 5,
                                                        left: 25,
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          child: Container(
                                                            
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.transparent,
                                                                border: Border.all(color: Theme.of(context).hoverColor, width: 1.5)),
                                                            child: Center(
                                                              child:  Text(
                                                              "${arrayMessaje[i]['cantMessage']}",
                                                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).hoverColor)
                                                            ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      },                          
                                                    },
                                                    
                                                ],
                                              ),
                                      )
                                      ],
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
                                                  color: abc.data!.trips![1].noConfirmados![index].hourForTrip==null?Color.fromRGBO(213, 0, 0, 1):Theme.of(context).primaryIconTheme.color,
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
                                Padding(
                                  padding: const EdgeInsets.only(right: 10, left: 6, top: 14),
                                  child: InkWell(
                                  onTap: () {
                                    if (abc.data!.trips![1].noConfirmados![index].latitude==null) {
                                      WarningSuccessDialog().show(
                                        context,
                                        title: "Este agente no cuenta con ubicación",
                                        tipo: 1,
                                        onOkay: () {},
                                      ); 
                                    }else{
                                      launchSalidasMaps(abc.data!.trips![1].noConfirmados![index].latitude,abc.data!.trips![1].noConfirmados![index].longitude);                                          
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
                                                  child: Icon(Icons.location_on_outlined, color:abc.data!.trips![1].noConfirmados![index].latitude==null? Colors.red :Color.fromRGBO(0, 191, 95, 1)),
                                                ),
                                              ),
                                              SizedBox(width: 18),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                                              fixedSize: Size(150, 25),
                                              elevation: 0,
                                              backgroundColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                            ),
                                            onPressed: () {
                                              confirmationDialog.show(
                                                          context,
                                                          title: '¿Está seguro que desea marcar como no confirmado al agente?',
                                                          type: "0",
                                                          onConfirm: () async {
                                                        
                                                fetchNoConfirm(abc.data!.trips![1].noConfirmados![index].agentId.toString(),abc.data!.trips![1].noConfirmados![index].tripId.toString());                                                               
                                                
                                              },
                                            onCancel: () {},
                                            );                                                
                                            },
                                            child: Text('No confirmó',
                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
                                                  pageBuilder: (_, __, ___) => ChatScreen(
                                                    idAgent: abc.data!.trips![1].noConfirmados![index].agentId.toString(),
                                                    nombreAgent: abc.data!.trips![1].noConfirmados![index].agentFullname,
                                                    nombre: "$nombreMotorista",
                                                    id: '$idMotorista',
                                                    rol: "MOTORISTA",
                                                    tipoViaje: 'entrada',
                                                    idV: abc.data!.trips![1].noConfirmados![index].tripId.toString(),
                                                    pantalla: true,
                                                  ),
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                              },
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:10, right: 18),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: 28,
                                                          height: 28,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/chats.svg",
                                                            color: Theme.of(context).hintColor,
                                                          ),
                                                        ),
                                                        
                                                        Text(
                                                          "Chat",
                                                          style: TextStyle(
                                                                  color: Theme.of(context).hintColor, fontSize: 10, fontFamily: 'Roboto'
                                                                ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                    for(var i=0; i< arrayMessaje.length; i++)...{
                                                      if(arrayMessaje[i]['nombreAgent']== abc.data!.trips![1].noConfirmados![index].agentFullname!.toUpperCase())...{
                                                        Positioned(
                                                        top: 5,
                                                        left: 25,
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          child: Container(
                                                            
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.transparent,
                                                                border: Border.all(color: Theme.of(context).hoverColor, width: 1.5)),
                                                            child: Center(
                                                              child:  Text(
                                                              "${arrayMessaje[i]['cantMessage']}",
                                                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).hoverColor)
                                                            ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      },                          
                                                    },
                                                    
                                                ],
                                              ),
                                      )],
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
      confirmationDialog.show(
        context,
        title: '¿Es correcta la hora $_eventTime del agente?',
        type: "0",
        onConfirm: () async {
          setState(() {   
            fetchHours(agentId,_eventTime,tripId);
          });                                                
                                            
        },
        onCancel: () {
          setState(() {            
            flagalert = time;                                            
          });
        },
      );                                                         
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

                                Padding(
                                  padding: const EdgeInsets.only(right: 10, left: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                                width: 18,
                                                height: 18,
                                                child: SvgPicture.asset(
                                                  "assets/icons/usuario.svg",
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
                                                        text: 'Nombre: ',
                                                        style: TextStyle(fontWeight: FontWeight.w500),
                                                      ),
                                                      TextSpan(
                                                        text: '${abc.data!.trips![2].cancelados![index].agentFullname}',
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
                                  padding: const EdgeInsets.only(right: 10, left: 6, top: 10),
                                  child: InkWell(
                                  onTap: () {
                                    if (abc.data!.trips![2].cancelados![index].latitude==null) {
                                      WarningSuccessDialog().show(
                                        context,
                                        title: "Este agente no cuenta con ubicación",
                                        tipo: 1,
                                        onOkay: () {},
                                      ); 
                                    }else{
                                      launchSalidasMaps(abc.data!.trips![2].cancelados![index].latitude,abc.data!.trips![2].cancelados![index].longitude);                                          
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
                                                  child: Icon(Icons.location_on_outlined, color:abc.data!.trips![2].cancelados![index].latitude==null? Colors.red :Color.fromRGBO(0, 191, 95, 1)),
                                                ),
                                              ),
                                              SizedBox(width: 18),
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

                              ],
                            ),
                            
                            children: [

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
                                                              text: '${abc.data!.trips![2].cancelados![index].companyName}',
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
                                                                text: '${abc.data!.trips![2].cancelados![index].agentPhone}',
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
                                                              text: '${abc.data!.trips![2].cancelados![index].hourIn}',
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
                                                              text: '${abc.data!.trips![2].cancelados![index].agentReferencePoint} ${abc.data!.trips![2].cancelados![index].neighborhoodName} ${abc.data!.trips![2].cancelados![index].districtName}',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),

                                      if (abc.data!.trips![2].cancelados![index].neighborhoodReferencePoint != null)... {
                                      Container(
                                        height: 1,
                                        color: Theme.of(context).dividerColor,
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
                                                              text: '${abc.data!.trips![2].cancelados![index].neighborhoodReferencePoint}',
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
                                      InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
                                                  pageBuilder: (_, __, ___) => ChatScreen(
                                                    idAgent: abc.data!.trips![2].cancelados![index].agentId.toString(),
                                                    nombreAgent: abc.data!.trips![2].cancelados![index].agentFullname,
                                                    nombre: "$nombreMotorista",
                                                    id: '$idMotorista',
                                                    rol: "MOTORISTA",
                                                    tipoViaje: 'entrada',
                                                    idV: abc.data!.trips![2].cancelados![index].tripId.toString(),
                                                    pantalla: true,
                                                  ),
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                              },
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:10, right: 18),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: 28,
                                                          height: 28,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/chats.svg",
                                                            color: Theme.of(context).hintColor,
                                                          ),
                                                        ),
                                                        
                                                        Text(
                                                          "Chat",
                                                          style: TextStyle(
                                                                  color: Theme.of(context).hintColor, fontSize: 10, fontFamily: 'Roboto'
                                                                ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                    for(var i=0; i< arrayMessaje.length; i++)...{
                                                      if(arrayMessaje[i]['nombreAgent']== abc.data!.trips![2].cancelados![index].agentFullname!.toUpperCase())...{
                                                        Positioned(
                                                        top: 5,
                                                        left: 25,
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          child: Container(
                                                            
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.transparent,
                                                                border: Border.all(color: Theme.of(context).hoverColor, width: 1.5)),
                                                            child: Center(
                                                              child:  Text(
                                                              "${arrayMessaje[i]['cantMessage']}",
                                                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).hoverColor)
                                                            ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      },                          
                                                    },
                                                    
                                                ],
                                              ),
                                      ),

                              SizedBox(height: 20.0),
  
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
          confirmationDialog.show(
            context,
            title: '¿Estás seguro que deseas pasar el viaje a proceso?',
            type: "0",
            onConfirm: () async {
              LoadingIndicatorDialog().show(context);
              new Future.delayed(new Duration(seconds: 2), () {
                  fetchPastInProgress();
                });
            },
            onCancel: () {},
          );
        },
      ),
    );
  }
}