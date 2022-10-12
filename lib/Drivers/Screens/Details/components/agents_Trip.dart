//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
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
import 'package:sweetalert/sweetalert.dart';
import '../../../../constants.dart';
import '../../../models/agentsInTravelModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyAgent());
}

class MyAgent extends StatefulWidget {
  final TripsList2 item;
  final PlantillaDriver plantillaDriver;

  const MyAgent({Key key, this.plantillaDriver, this.item}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyAgent> {
  Future<TripsList2> item;
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
      SweetAlert.show(context,
          title: resp.title,
          subtitle: resp.message,
          style: SweetAlertStyle.success);
    } else if (response.statusCode == 200 && resp.ok != true) {
      SweetAlert.show(
        context,
        title: resp.title,
        subtitle: resp.message,
        style: SweetAlertStyle.error,
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
          SweetAlert.show(context,
              title: resp.title,
              subtitle: resp.message,
              style: SweetAlertStyle.success);
        } else if (response.statusCode == 500) {
          SweetAlert.show(
            context,
            title: resp.title,
            subtitle: resp.message,
            style: SweetAlertStyle.error,
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
      SweetAlert.show(
        context,
        title: resp.title,
        subtitle: resp.message,
        style: SweetAlertStyle.error,
      );
    } else if (response.statusCode == 500) {
      SweetAlert.show(
        context,
        title: resp.title,
        subtitle: resp.message,
        style: SweetAlertStyle.error,
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
      SweetAlert.show(
        context,
        title: 'ok',
        subtitle: resp.message,
        style: SweetAlertStyle.error,
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
      SweetAlert.show(
        context,
        title: 'ok',
        subtitle: resp.message,
        style: SweetAlertStyle.error,
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: DriverMenuLateral(),
          appBar: AppBar(
            title: Text('Asignación de Horas'),
            backgroundColor: kColorDriverAppBar,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
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
            SizedBox(height: 40.0),
            Center(
                child: Text('Agentes confirmados',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
            _agentToConfirm(),
            SizedBox(height: 40.0),
            Center(
                child: Text('Agentes no confirmados',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
            _agentoNoConfirm(),
            SizedBox(height: 40.0),
            Center(
                child: Text('Agentes que han cancelado',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0))),
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
          if (abc.data.trips[0].agentes.length == 0) {
            return Card(
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
                            color: Colors.black,
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
            return FutureBuilder<TripsList2>(
              future: item,
              builder: (BuildContext context, abc) {
                if (abc.connectionState == ConnectionState.done) {
                  Size size = MediaQuery.of(context).size;
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.trips[0].agentes.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: size.width,
                          child: Column(
                            children: [
                              InkWell(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: EdgeInsets.all(5.0),
                                  elevation: 2,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: ExpansionTile(
                                          backgroundColor: Colors.white,
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        5, 5, 10, 0),
                                                title: Text('Nombre: '),
                                                subtitle: Text(
                                                    '${abc.data.trips[0].agentes[index].agentFullname}'),
                                                leading: Icon(
                                                    Icons
                                                        .supervised_user_circle_rounded,
                                                    color: Colors.green[500]),
                                              ),
                                            ],
                                          ),
                                          trailing: SizedBox(),
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(left: 15),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 5, 10, 0),
                                                    title: Text('Empresa: '),
                                                    subtitle: Text(
                                                        '${abc.data.trips[0].agentes[index].companyName}'),
                                                    leading: Icon(Icons.kitchen,
                                                        color:
                                                            Colors.green[500]),
                                                  ),
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 5, 10, 0),
                                                    title: Text('Teléfono: '),
                                                    subtitle: TextButton(
                                                        onPressed: () =>
                                                            launchUrl(Uri.parse(
                                                                'tel://${abc.data.trips[0].agentes[index].agentPhone}')),
                                                        child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 180),
                                                            child: Text(
                                                                '${abc.data.trips[0].agentes[index].agentPhone}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .blue[
                                                                        500],
                                                                    fontSize:
                                                                        14)))),
                                                    leading: Icon(Icons.phone,
                                                        color:
                                                            Colors.green[500]),
                                                  ),
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 5, 10, 0),
                                                    title: Text('Entrada: '),
                                                    subtitle: Text(
                                                        '${abc.data.trips[0].agentes[index].hourIn}'),
                                                    leading: Icon(Icons.timer,
                                                        color:
                                                            Colors.green[500]),
                                                  ),
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 5, 10, 0),
                                                    title: Text('Dirección: '),
                                                    subtitle: Text(
                                                        '${abc.data.trips[0].agentes[index].agentReferencePoint} ${abc.data.trips[0].agentes[index].neighborhoodName} \n${abc.data.trips[0].agentes[index].districtName}'),
                                                    leading: Icon(
                                                        Icons.location_pin,
                                                        color:
                                                            Colors.green[500]),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            //aqui lo demás

                                            SizedBox(height: 30.0),
                                            if (abc.data.trips[0].agentes[index]
                                                    .hourForTrip ==
                                                "00:00") ...{
                                              Text('Hora de encuentro: '),
                                            } else ...{
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                          'Hora de encuentro: '),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                          '${abc.data.trips[0].agentes[index].hourForTrip}',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blue[400],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 19.0))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            },
                                            SizedBox(height: 10.0),

                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    )
                                                  ]),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 40.0),
                                              child: Column(
                                                children: [
                                                  DateTimeField(
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
                                                                .trips[0]
                                                                .agentes[index]
                                                                .agentId
                                                                .toString(),
                                                            _eventTime,
                                                            abc
                                                                .data
                                                                .trips[0]
                                                                .agentes[index]
                                                                .tripId
                                                                .toString());
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    MyAgent())).then(
                                                            (_) => MyAgent());
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
                                onTap: () {
                                  // if (agentHours != 00.00) {
                                  // }
                                },
                              ),
                            ],
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
          if (abc.data.trips[1].noConfirmados.length == 0) {
            return Card(
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
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 20.0)),
                    subtitle: Text(
                        'No hay agentes no confirmados para este viaje',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0)),
                  ),
                ],
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
                    itemCount: abc.data.trips[1].noConfirmados.length,
                    itemBuilder: (context, index) {
                      Size size = MediaQuery.of(context).size;
                      return Container(
                        width: size.width,
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.all(5.0),
                              elevation: 2,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: ExpansionTile(
                                      backgroundColor: Colors.white,
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          ListTile(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                5, 5, 10, 0),
                                            title: Text('Nombre: '),
                                            subtitle: Text(
                                                '${abc.data.trips[1].noConfirmados[index].agentFullname}'),
                                            leading: Icon(
                                                Icons
                                                    .supervised_user_circle_rounded,
                                                color: Colors.green[500]),
                                          ),
                                        ],
                                      ),
                                      trailing: SizedBox(),
                                      children: [
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('Empresa: '),
                                          subtitle: Text(
                                              '${abc.data.trips[1].noConfirmados[index].companyName}'),
                                          leading: Icon(Icons.kitchen,
                                              color: Colors.green[500]),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('Teléfono: '),
                                          subtitle: TextButton(
                                              onPressed: () => launchUrl(Uri.parse(
                                                  'tel://${abc.data.trips[1].noConfirmados[index].agentPhone}')),
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 180),
                                                  child: Text(
                                                      '${abc.data.trips[1].noConfirmados[index].agentPhone}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.blue[500],
                                                          fontSize: 14)))),
                                          leading: Icon(Icons.phone,
                                              color: Colors.green[500]),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('Entrada: '),
                                          subtitle: Text(
                                              '${abc.data.trips[1].noConfirmados[index].hourIn}'),
                                          leading: Icon(Icons.timer,
                                              color: Colors.green[500]),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('Dirección: '),
                                          subtitle: Text(
                                              '${abc.data.trips[1].noConfirmados[index].agentReferencePoint} \n ${abc.data.trips[1].noConfirmados[index].neighborhoodName} ${abc.data.trips[1].noConfirmados[index].districtName}'),
                                          leading: Icon(Icons.location_pin,
                                              color: Colors.green[500]),
                                        ),
                                        //aqui lo demás
                                        SizedBox(height: 30.0),
                                        Text('Hora de encuentro: '),
                                        SizedBox(height: 10.0),
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1, color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                )
                                              ]),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 40.0),
                                          child: Column(
                                            children: [
                                              DateTimeField(
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
                                                              .trips[1]
                                                              .noConfirmados[
                                                                  index]
                                                              .agentId
                                                              .toString(),
                                                          _eventTime,
                                                          abc
                                                              .data
                                                              .trips[1]
                                                              .noConfirmados[
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
                                                  return DateTimeField.convert(
                                                      time);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20.0),
                                        // Usamos una fila para ordenar los botones del card
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            textStyle: TextStyle(
                                              color: Colors.white, // foreground
                                            ),
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Colors.red,
                                                    width: 2,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            SweetAlert.show(context,
                                                subtitle:
                                                    "¿Está seguro que desea marcar como no \nconfirmado al agente?",
                                                style: SweetAlertStyle.confirm,
                                                confirmButtonText: "Confirmar",
                                                cancelButtonText: "Cancelar",
                                                showCancelButton: true,
                                                onPress: (bool isConfirm) {
                                              if (isConfirm) {
                                                SweetAlert.show(context,
                                                    subtitle:
                                                        "Agente marcado como no confirmó",
                                                    style: SweetAlertStyle
                                                        .success);
                                                new Future.delayed(
                                                    new Duration(seconds: 2),
                                                    () {
                                                  fetchNoConfirm(
                                                      abc
                                                          .data
                                                          .trips[1]
                                                          .noConfirmados[index]
                                                          .agentId
                                                          .toString(),
                                                      abc
                                                          .data
                                                          .trips[1]
                                                          .noConfirmados[index]
                                                          .tripId
                                                          .toString());
                                                  Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  MyAgent()))
                                                      .then((_) => MyAgent());
                                                });
                                              } else {
                                                SweetAlert.show(context,
                                                    subtitle: "¡Cancelado!",
                                                    style: SweetAlertStyle
                                                        .success);
                                              }
                                              // return false to keep dialog
                                              return false;
                                            });
                                          },
                                          child: Text('No confirmó',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
          if (abc.data.trips[2].cancelados.length == 0) {
            return Card(
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
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 20.0)),
                    subtitle: Text(
                        'No hay agentes que hayan cancelado este viaje',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0)),
                  ),
                ],
              ),
            );
          } else if (abc.data.trips[2].cancelados.length > 0) {
            return FutureBuilder<TripsList2>(
              future: item,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: abc.data.trips[2].cancelados.length,
                    itemBuilder: (context, index) {
                      print(abc.data.trips[2].cancelados[index].agentPhone);
                      Size size = MediaQuery.of(context).size;
                      return Container(
                        width: size.width,
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.all(5.0),
                              elevation: 2,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: ExpansionTile(
                                      backgroundColor: Colors.white,
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          ListTile(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                5, 5, 10, 0),
                                            title: Text('Nombre: '),
                                            subtitle: Text(
                                                '${abc.data.trips[2].cancelados[index].agentFullname}'),
                                            leading: Icon(
                                                Icons
                                                    .supervised_user_circle_rounded,
                                                color: Colors.green[500]),
                                          ),
                                        ],
                                      ),
                                      trailing: SizedBox(),
                                      children: [
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('Empresa: '),
                                          subtitle: Text(
                                              '${abc.data.trips[2].cancelados[index].companyName}'),
                                          leading: Icon(Icons.kitchen,
                                              color: Colors.green[500]),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('Teléfono: '),
                                          subtitle: TextButton(
                                              onPressed: () => launchUrl(Uri.parse(
                                                  'tel://${abc.data.trips[2].cancelados[index].agentPhone}')),
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 180),
                                                  child: Text(
                                                      '${abc.data.trips[2].cancelados[index].agentPhone}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.blue[500],
                                                          fontSize: 14)))),
                                          leading: Icon(Icons.phone,
                                              color: Colors.green[500]),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('Entrada: '),
                                          subtitle: Text(
                                              '${abc.data.trips[2].cancelados[index].hourIn}'),
                                          leading: Icon(Icons.timer,
                                              color: Colors.green[500]),
                                        ),
                                        ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(5, 5, 10, 0),
                                          title: Text('Dirección: '),
                                          subtitle: Text(
                                              '${abc.data.trips[2].cancelados[index].agentReferencePoint} \n ${abc.data.trips[2].cancelados[index].neighborhoodName} ${abc.data.trips[2].cancelados[index].districtName}'),
                                          leading: Icon(Icons.location_pin,
                                              color: Colors.green[500]),
                                        ),
                                        SizedBox(height: 20.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
              SweetAlert.show(context,
                  subtitle: "¿Está seguro que desea pasar el viaje en proceso?",
                  style: SweetAlertStyle.confirm,
                  confirmButtonText: "Confirmar",
                  cancelButtonText: "Cancelar",
                  showCancelButton: true, onPress: (bool isConfirm) {
                if (isConfirm) {
                  SweetAlert.show(context,
                      title: 'Confirmado',
                      subtitle: 'Su viaje está en proceso',
                      style: SweetAlertStyle.success);
                  new Future.delayed(new Duration(seconds: 2), () {
                    fetchPastInProgress();
                  });
                } else {
                  SweetAlert.show(context,
                      subtitle: "¡Cancelado!", style: SweetAlertStyle.success);
                }
                // return false to keep dialog
                return false;
              });
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
              SweetAlert.show(context,
                  subtitle: "¿Está seguro que desea marcarlos como cancelados?",
                  style: SweetAlertStyle.confirm,
                  confirmButtonText: "Confirmar",
                  cancelButtonText: "Cancelar",
                  showCancelButton: true, onPress: (bool isConfirm) {
                if (isConfirm) {
                  SweetAlert.show(context,
                      subtitle: "Han sido marcado como cancelados",
                      style: SweetAlertStyle.success);
                  new Future.delayed(new Duration(seconds: 2), () {
                    fetchTripAgentsNotConfirm();
                  });
                } else {
                  SweetAlert.show(context,
                      subtitle: "¡Entendido!", style: SweetAlertStyle.success);
                }
                // return false to keep dialog
                return false;
              });
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
              SweetAlert.show(context,
                  subtitle: "¿Está seguro que desea cancelar el viaje?",
                  style: SweetAlertStyle.confirm,
                  confirmButtonText: "Confirmar",
                  cancelButtonText: "Cancelar",
                  showCancelButton: true, onPress: (bool isConfirm) {
                if (isConfirm) {
                  SweetAlert.show(context,
                      subtitle: "El viaje ha sido cancelado",
                      style: SweetAlertStyle.success);
                  new Future.delayed(new Duration(seconds: 2), () {
                    fetchTripCancel();
                  });
                } else {
                  SweetAlert.show(context,
                      subtitle: "¡No ha sido cancelado el viaje!",
                      style: SweetAlertStyle.success);
                }
                // return false to keep dialog
                return false;
              });
            },
          ),
        ],
      ),
    );
  }
}
