//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatViews.dart';

import 'package:flutter_auth/Drivers/Screens/Details/components/travel_In_Trips.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_auth/Drivers/models/registerTripAsCompleted.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../constants.dart';
import '../../../models/agentsInTravelModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyAgent());
}

class MyAgent extends StatefulWidget {
  final TripsList2? item;
  final PlantillaDriver? plantillaDriver;

  const MyAgent({Key? key, this.plantillaDriver, this.item}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyAgent> {
  List<int>? counter;
  Future<TripsList2>? item;
  TextEditingController agentHours = new TextEditingController();
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";

  Future<Driver> fetchHours(
      String agentId, String agentTripHour, String tripId) async {
    Map data = {
      'agentId': agentId,
      'agentTripHour': agentTripHour,
      'tripId': tripId
    };

    print(data);
    http.Response response = await http
        .post(Uri.parse('$ip/apis/registerAgentTripTime'), body: data);

    final resp = Driver.fromJson(json.decode(response.body));

    if (response.statusCode == 200 && resp.ok == true && agentTripHour != "") {
      print(response.body);
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

    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver> fetchNoConfirm(String agentId, String tripId) async {
    Map data = {'agentId': agentId, 'tripId': tripId};
    print(data);
    http.Response response = await http
        .post(Uri.parse('$ip/apis/markAgentAsNotConfirmed'), body: data);
    if (mounted) {
      setState(() {
        final resp = Driver.fromJson(json.decode(response.body));

        if (response.statusCode == 200 && resp.ok == true) {
          print(response.body);
              QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
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
      });
    }
    return Driver.fromJson(json.decode(response.body));
  }

  Future<Driver> fetchPastInProgress() async {
    http.Response response = await http
        .get(Uri.parse('$ip/apis/passTripToProgress/${prefs.tripId}'));
    final resp = Driver.fromJson(json.decode(response.body));
    print(response.body);
    if (response.statusCode == 200 && resp.ok == true) {
      print(response.body);
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
      print(response.body);

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
      print(response.body);

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

    return Driver.fromJson(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    item = fetchAgentsInTravel2();
  }

  static DateTime _eventdDate = DateTime.now();
  static var now =
      TimeOfDay.fromDateTime(DateTime.parse(_eventdDate.toString()));
  final format = DateFormat('HH:mm');
  @override
  Widget build(BuildContext context) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Trips()),
                  );
                },
              ),
              SizedBox(width: kDefaultPadding / 2)
            ],
          ),
          body: ListView(children: <Widget>[
            SizedBox(height: 25.0),
            Center(
                child: Text('Asignaci??n de Horas',
                    style: TextStyle(
                        color: firstColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
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
          ])),
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
                          color: thirdColor, size: 40),
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
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Container(
                            width: size.width,
                            child: Column(
                              children: [
                                InkWell(
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
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 5, 10, 0),
                                                    title: Text('Nombre:',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.0)),
                                                    subtitle: Text(
                                                        '${abc.data!.trips![0].agentes![index].agentFullname}',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 15.0)),
                                                    leading: Icon(
                                                        Icons
                                                            .supervised_user_circle_rounded,
                                                        color: thirdColor,
                                                        size: 40),
                                                  ),
                                                ],
                                              ),
                                              trailing: SizedBox(),
                                              children: [
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 18),
                                                  child: Column(
                                                    children: [
                                                      ListTile(contentPadding:EdgeInsets.fromLTRB(5, 5, 10, 0),
                                                        title: Text('Empresa: ',style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold,fontSize:18.0)),
                                                        subtitle: Text(
                                                            '${abc.data!.trips![0].agentes![index].companyName}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize:
                                                                    15.0)),
                                                        leading: Icon(
                                                            Icons.location_city,
                                                            color: thirdColor,
                                                            size: 40),
                                                      ),
                                                      ListTile(
                                                        contentPadding:
                                                            EdgeInsets.fromLTRB(
                                                                5, 5, 10, 0),
                                                        title: Text(
                                                            'Tel??fono: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    18.0)),
                                                        subtitle: TextButton(
                                                            onPressed: () =>
                                                                launchUrl(Uri.parse(
                                                                    'tel://${abc.data!.trips![0].agentes![index].agentPhone}')),
                                                            child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            175),
                                                                child: Text(
                                                                    '${abc.data!.trips![0].agentes![index].agentPhone}',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            15)))),
                                                        leading: Icon(
                                                            Icons.phone,
                                                            color: thirdColor,
                                                            size: 40),
                                                      ),
                                                      ListTile(
                                                        contentPadding:
                                                            EdgeInsets.fromLTRB(
                                                                5, 5, 10, 0),
                                                        title: Text('Entrada: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    18.0)),
                                                        subtitle: Text(
                                                            '${abc.data!.trips![0].agentes![index].hourIn}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize:
                                                                    15.0)),
                                                        leading: Icon(
                                                            Icons.access_time,
                                                            color: thirdColor,
                                                            size: 40),
                                                      ),
                                                      ListTile(contentPadding: EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 25),
                                                        title: Text('Direcci??n: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    18.0)),
                                                        subtitle: Text(
                                                          abc.data!.trips![0].agentes![index].agentReferencePoint==null
                                                        ||abc.data!.trips![0].agentes![index].agentReferencePoint==""
                                                        ?"${abc.data!.trips![0].agentes![index].neighborhoodName}, ${abc.data!.trips![0].agentes![index].townName}":'${abc.data!.trips![0].agentes![index].agentReferencePoint}, ${abc.data!.trips![0].agentes![index].neighborhoodName}, ${abc.data!.trips![0].agentes![index].townName},',style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize:
                                                                    15.0)),
                                                        leading: Icon(Icons.location_pin,color: thirdColor, size: 40,),
                                                      ),
                                                      if (abc.data!.trips![0].agentes![index].neighborhoodReferencePoint != null)... {                                                    
                                                        ListTile(contentPadding: EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 25),
                                                          title: Text('Acceso autorizado: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    18.0)),
                                                          subtitle: Text('${abc.data!.trips![0].agentes![index].neighborhoodReferencePoint}',style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize:
                                                                    15.0)),
                                                          leading: Icon(Icons.directions,color: thirdColor, size: 40,),
                                                        ),
                                                      },
                                                    ],
                                                  ),
                                                ),

                                                //aqui lo dem??s

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
                                                      DateTimeField(
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .datetime,
                                                        format: format,
                                                        onShowPicker: (context,
                                                            currentValue) async {
                                                          final time =
                                                              await showTimePicker(
                                                            context: context,
                                                            initialTime: TimeOfDay
                                                                .fromDateTime(
                                                                    currentValue ??
                                                                        DateTime
                                                                            .now()),
                                                          );
                                                          if (time != null &&
                                                              agentHours.text !=
                                                                  null) {
                                                            String _eventTime =
                                                                now
                                                                    .toString()
                                                                    .substring(
                                                                        10, 15);
                                                            _eventTime = time
                                                                .toString()
                                                                .substring(
                                                                    10, 15);
                                                            print(_eventTime);
                                                            fetchHours(
                                                                abc
                                                                    .data
                                                                    !.trips![0]
                                                                    .agentes![
                                                                        index]
                                                                    .agentId
                                                                    .toString(),
                                                                _eventTime,
                                                                abc
                                                                    .data
                                                                    !.trips![0]
                                                                    .agentes![
                                                                        index]
                                                                    .tripId
                                                                    .toString());
                                                            Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        MyAgent())).then(
                                                                (_) =>
                                                                    MyAgent());
                                                          }
                                                          print(agentHours);
                                                          return DateTimeField
                                                              .convert(time);
                                                        },
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
                                  onTap: () {
                                    // if (agentHours != 00.00) {
                                    // }
                                  },
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
                            Icon(Icons.person, size: 40.0, color: thirdColor),
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
                                margin: EdgeInsets.all(5.0),
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
                                            ListTile(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      5, 5, 10, 0),
                                              title: Text('Nombre:',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0)),
                                              subtitle: Text(
                                                  '${abc.data!.trips![1].noConfirmados![index].agentFullname}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 15.0)),
                                              leading: Icon(Icons.person,
                                                  color: thirdColor,
                                                  size: 40.0),
                                            ),
                                          ],
                                        ),
                                        trailing: SizedBox(),
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 20),
                                            title: Text('Empresa: ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            subtitle: Text(
                                                '${abc.data!.trips![1].noConfirmados![index].companyName}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15.0)),
                                            leading: Icon(Icons.location_city,
                                                color: thirdColor, size: 40.0),
                                          ),
                                          ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 20),
                                            title: Text('Tel??fono: ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            subtitle: TextButton(
                                                onPressed: () =>
                                                    launchUrl(Uri.parse(
                                                      'tel://${abc.data!.trips![1].noConfirmados![index].agentPhone}',
                                                    )),
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        right: 175),
                                                    child: Text(
                                                        '${abc.data!.trips![1].noConfirmados![index].agentPhone}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15)))),
                                            leading: Icon(Icons.phone,
                                                color: thirdColor, size: 40.0),
                                          ),
                                          ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 25),
                                            title: Text('Entrada: ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            subtitle: Text(
                                                '${abc.data!.trips![1].noConfirmados![index].hourIn}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15.0)),
                                            leading: Icon(Icons.access_time,
                                                color: thirdColor, size: 40.0),
                                          ),
                                          ListTile(contentPadding: EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 25),
                                                        title: Text('Direcci??n: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    18.0)),
                                                        subtitle: Text(
                                                          abc.data!.trips![1].noConfirmados![index].agentReferencePoint==null
                                                        ||abc.data!.trips![1].noConfirmados![index].agentReferencePoint==""
                                                        ?"${abc.data!.trips![1].noConfirmados![index].neighborhoodName}, ${abc.data!.trips![1].noConfirmados![index].townName}":'${abc.data!.trips![1].noConfirmados![index].agentReferencePoint}, ${abc.data!.trips![1].noConfirmados![index].neighborhoodName}, ${abc.data!.trips![1].noConfirmados![index].townName},',style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize:
                                                                    15.0)),
                                                        leading: Icon(Icons.location_pin,color: thirdColor, size: 40,),
                                                      ),
                                                      if (abc.data!.trips![1].noConfirmados![index].neighborhoodReferencePoint != null)... {                                                    
                                                        ListTile(contentPadding: EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 25),
                                                          title: Text('Acceso autorizado: ',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    18.0)),
                                                          subtitle: Text('${abc.data!.trips![1].noConfirmados![index].neighborhoodReferencePoint}',style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize:
                                                                    15.0)),
                                                          leading: Icon(Icons.directions,color: thirdColor, size: 40,),
                                                        ),
                                                      },
                                          //aqui lo dem??s
                                          SizedBox(height: 30.0),
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
                                                  onShowPicker: (context,
                                                      currentValue) async {
                                                    final time =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.now(),
                                                    );
                                                    if (time != null) {
                                                      setState(() {
                                                        String _eventTime = now
                                                            .toString()
                                                            .substring(10, 15);
                                                        _eventTime = time
                                                            .toString()
                                                            .substring(10, 15);
                                                        print(_eventTime);
                                                        fetchHours(
                                                            abc
                                                                .data
                                                                !.trips![1]
                                                                .noConfirmados![
                                                                    index]
                                                                .agentId
                                                                .toString(),
                                                            _eventTime,
                                                            abc
                                                                .data
                                                                !.trips![1]
                                                                .noConfirmados![
                                                                    index]
                                                                .tripId
                                                                .toString());
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        MyAgent()),
                                                            (Route<dynamic>
                                                                    route) =>
                                                                false);
                                                      });
                                                    }
                                                    return DateTimeField
                                                        .convert(time);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
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
                                                    text: "??Est?? seguro que desea marcar como no \nconfirmado al agente?",
                                                      confirmBtnText: "Confirmar",
                                                      cancelBtnText: "Cancelar",
                                                      showCancelBtn: true,  
                                                      confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                                      cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
                                                      onConfirmBtnTap: () {
                                                        QuickAlert.show(
                                                        context: context,
                                                        type: QuickAlertType.success,
                                                        text: "Agente marcado como no confirm??",
                                                        );
                                                        new Future.delayed(
                                                            new Duration(
                                                                seconds: 2),
                                                            () {
                                                          fetchNoConfirm(
                                                              abc
                                                                  .data
                                                                  !.trips![1]
                                                                  .noConfirmados![
                                                                      index]
                                                                  .agentId
                                                                  .toString(),
                                                              abc
                                                                  .data
                                                                  !.trips![1]
                                                                  .noConfirmados![
                                                                      index]
                                                                  .tripId
                                                                  .toString());
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      MyAgent())).then(
                                                              (_) => MyAgent());
                                                        });
                                                      },
                                                      onCancelBtnTap: () {
                                                        Navigator.pop(context);
                                                        QuickAlert.show(
                                                        context: context,
                                                        type: QuickAlertType.success,
                                                        text: "??Cancelado!",                                                        
                                                        );
                                                      },
                                                    );                                                  
                                                  },
                                                  child: Text('No confirm??',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 17)),
                                                ),
                                              ),
                                              // Padding(
                                              //   padding:
                                              //       const EdgeInsets.all(5.0),
                                              //   child: TextButton(
                                              //       child: Container(
                                              //         height: 30,
                                              //         width: 80,
                                              //         child: Row(
                                              //           children: [
                                              //             InkWell(
                                              //                 onTap: () => {
                                              //                       fetchRefresProfile().then(
                                              //                           (value) =>
                                              //                               {
                                              //                                 Navigator.push(
                                              //                                     context,
                                              //                                     MaterialPageRoute(
                                              //                                         builder: (context) => ChatScreen(
                                              //                                               id: "${value.driver.driverId}",
                                              //                                               rol: "MOTORISTA",
                                              //                                               nombre: "${value.driver.driverFullname}".toUpperCase(),
                                              //                                             )))
                                              //                               })
                                              //                     },
                                              //                 child: Container(
                                              //                   width: 30,
                                              //                   height: 30,
                                              //                   child: Stack(
                                              //                     children: [
                                              //                       Icon(
                                              //                         Icons
                                              //                             .telegram,
                                              //                         color:
                                              //                             backgroundColor,
                                              //                         size: 30,
                                              //                       ),
                                              //                       Container(
                                              //                         width: 30,
                                              //                         height:
                                              //                             30,
                                              //                         alignment:
                                              //                             Alignment
                                              //                                 .topLeft,
                                              //                         margin: EdgeInsets
                                              //                             .only(
                                              //                                 top: 0),
                                              //                         child:
                                              //                             Container(
                                              //                           width:
                                              //                               15,
                                              //                           height:
                                              //                               15,
                                              //                           decoration: BoxDecoration(
                                              //                               shape:
                                              //                                   BoxShape.circle,
                                              //                               color: Color(0xffc32c37),
                                              //                               border: Border.all(color: Color(0xffc32c37), width: 1)),
                                              //                           child:
                                              //                               Padding(
                                              //                             padding:
                                              //                                 const EdgeInsets.all(0.0),
                                              //                             child:
                                              //                                 Center(
                                              //                               child:
                                              //                                   Text(
                                              //                                 "0",
                                              //                                 style: TextStyle(fontSize: 10, color: Colors.white),
                                              //                               ),
                                              //                             ),
                                              //                           ),
                                              //                         ),
                                              //                       ),
                                              //                     ],
                                              //                   ),
                                              //                 )),
                                              //             SizedBox(width: 5),
                                              //             Text('Chat',
                                              //                 style: TextStyle(
                                              //                     color:
                                              //                         backgroundColor,
                                              //                     fontSize: 15,
                                              //                     fontWeight:
                                              //                         FontWeight
                                              //                             .bold)),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //       style: TextButton.styleFrom(
                                              //         textStyle: TextStyle(
                                              //           color: Colors
                                              //               .white, // foreground
                                              //         ),
                                              //         backgroundColor:
                                              //             firstColor,
                                              //         shape: RoundedRectangleBorder(
                                              //             side: BorderSide(
                                              //                 color: firstColor,
                                              //                 width: 2,
                                              //                 style: BorderStyle
                                              //                     .solid),
                                              //             borderRadius:
                                              //                 BorderRadius
                                              //                     .circular(
                                              //                         10)),
                                              //       ),
                                              //       onPressed: () {
                                              //         Navigator
                                              //             .pushAndRemoveUntil(
                                              //                 context,
                                              //                 MaterialPageRoute(
                                              //                     builder:
                                              //                         (context) =>
                                              //                             // ConversationList(name, messageText: messageText, imageUrl: imageUrl, time: time, isMessageRead: isMessageRead)),
                                              //                             ChatScreen(
                                              //                               rol:
                                              //                                   "MOTORISTA",
                                              //                               id: "0",
                                              //                               nombre:
                                              //                                   "DEREK",
                                              //                             )),
                                              //                 (Route<dynamic>
                                              //                         route) =>
                                              //                     false);
                                              //       }),
                                              // ),
                                            ],
                                          ),
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
                      leading: Icon(Icons.directions_car,
                          size: 40, color: thirdColor),
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
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        5, 5, 10, 0),
                                                title: Text('Nombre: ',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20.0,
                                                    )),
                                                subtitle: Text(
                                                    '${abc.data!.trips![2].cancelados![index].agentFullname}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 15.0)),
                                                leading: Icon(
                                                    Icons
                                                        .supervised_user_circle_rounded,
                                                    size: 40,
                                                    color: thirdColor),
                                              ),
                                            ],
                                          ),
                                          trailing: SizedBox(),
                                          children: [
                                            ListTile(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 25),
                                              title: Text('Empresa: ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                  )),
                                              subtitle: Text(
                                                  '${abc.data!.trips![2].cancelados![index].companyName}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 15.0)),
                                              leading: Icon(Icons.location_city,
                                                  size: 40, color: thirdColor),
                                            ),
                                            ListTile(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 25),
                                              title: Text('Tel??fono: ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                  )),
                                              subtitle: TextButton(
                                                  onPressed: () =>
                                                      launchUrl(Uri.parse(
                                                        'tel://${abc.data!.trips![2].cancelados![index].agentPhone}',
                                                      )),
                                                  child: Container(
                                                      padding: EdgeInsets.only(
                                                          right: 170),
                                                      child: Text(
                                                          '${abc.data!.trips![2].cancelados![index].agentPhone}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 15.0,
                                                          )))),
                                              leading: Icon(Icons.phone,
                                                  color: thirdColor,
                                                  size: 40.0),
                                            ),
                                            ListTile(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 25),
                                              title: Text('Entrada: ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                  )),
                                              subtitle: Text(
                                                  '${abc.data!.trips![2].cancelados![index].hourIn}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 15.0)),
                                              leading: Icon(Icons.access_time,
                                                  size: 40, color: thirdColor),
                                            ),
                                            ListTile(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 25),
                                              title: Text('Direcci??n: ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                  )),
                                              subtitle: Text(
                                                  '${abc.data!.trips![2].cancelados![index].agentReferencePoint} \n ${abc.data!.trips![2].cancelados![index].neighborhoodName} ${abc.data!.trips![2].cancelados![index].districtName}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 15.0)),
                                              leading: Icon(Icons.location_pin,
                                                  size: 40, color: thirdColor),
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
              text: "??Est?? seguro que desea pasar el viaje en proceso?",
              confirmBtnText: "Confirmar",
              cancelBtnText: "Cancelar",
              showCancelBtn: true,  
              confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
              cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),         
              onConfirmBtnTap: () {
                QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: 'Su viaje est?? en proceso',
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
                type: QuickAlertType.success,
                text: "??Cancelado!",                                
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
              text: "??Est?? seguro que desea marcarlos como cancelados?",
              confirmBtnText: "Confirmar",
              cancelBtnText: "Cancelar",
              showCancelBtn: true,  
              confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
              cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
              onConfirmBtnTap: () {
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
                type: QuickAlertType.success,
                text: "??Entendido!",                
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
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Marcar como cancelado"),
            onPressed: () {
               QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: "??Est?? seguro que desea cancelar el viaje?",
              confirmBtnText: "Confirmar",
              cancelBtnText: "Cancelar",
              showCancelBtn: true,  
              confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
              cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
              onConfirmBtnTap: () {
                QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: "El viaje ha sido cancelado",                
                );
                new Future.delayed(new Duration(seconds: 2), () {
                    fetchTripCancel();
                  });
              },
              onCancelBtnTap: () {
                Navigator.pop(context);
                QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: "??No ha sido cancelado el viaje!",                
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
