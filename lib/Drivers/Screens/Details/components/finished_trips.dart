import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/AgentTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/agentsInTravelModel.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants.dart';

void main() {
  runApp(MyFinishedTrips());
}

class MyFinishedTrips extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;

  const MyFinishedTrips({Key? key, this.plantillaDriver}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyFinishedTrips> {
  bool checkBoxValue = false;
  final format = DateFormat("HH:mm");
  Future<TripsList3>? item;
  Future<TripsList2>? itemx;
  @override
  void initState() {
    super.initState();
    item = fetchAgentsCompleted();
    itemx = fetchAgentsInTravel2();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: DriverMenuLateral(),
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 15,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_circle_left),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: kDefaultPadding / 2)
            ],
          ),
          body: Container(
            color: backgroundColor,
            child: ListView(children: <Widget>[
              SizedBox(height: 40.0),
              Center(
                  child: Text('Agentes con hora asignada',
                      style: TextStyle(
                          color: GradiantV_2,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0))),
              SizedBox(height: 10.0),
              _agentToConfirm(),
              SizedBox(height: 20.0),
              Center(
                  child: Text('Agentes cancelados',
                      style: TextStyle(
                          color: GradiantV_2,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0))),
              SizedBox(height: 10.0),
              _agentToCancel(),
              SizedBox(height: 20.0),
            ]),
          )),
    );
  }

  Widget _agentToConfirm() {
    return FutureBuilder<TripsList3>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![0].inTrip!.length == 0) {
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
            return FutureBuilder<TripsList3>(
              future: item,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: abc.data!.trips![0].inTrip!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              blurStyle: BlurStyle.normal,
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: -20,
                              offset: Offset(-8, -6)),
                          BoxShadow(
                              blurStyle: BlurStyle.normal,
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: -15,
                              offset: Offset(18, 5)),
                        ]),
                        width: 500.0,
                        child: Column(
                          children: [
                            Card(
                              color: backgroundColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.all(15.0),
                              elevation: 2,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ExpansionTile(
                                      backgroundColor: backgroundColor,
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              if (abc.data!.trips![0]
                                                      .inTrip![index].traveled ==
                                                  1) ...{
                                                Text('✅',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 20)),
                                                SizedBox(width: 15),
                                                Text('Abordó',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                              } else ...{
                                                Icon(Icons.cancel,
                                                    color: Colors.red[500]),
                                                Text(' no abordó',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                              }
                                            ],
                                          ),
                                          ListTile(
                                            title: Text('Nombre: ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18)),
                                            subtitle: Text(
                                                '${abc.data!.trips![0].inTrip![index].agentFullname}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15)),
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
                                          margin: EdgeInsets.only(left: 15),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        15, 5, 10, 0),
                                                title: Text('Empresa: ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18)),
                                                subtitle: Text(
                                                    '${abc.data!.trips![0].inTrip![index].companyName}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                                leading: Icon(
                                                    Icons.location_city,
                                                    color: thirdColor,
                                                    size: 40),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        15, 5, 0, 0),
                                                title: Text('Teléfono: ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18)),
                                                subtitle: TextButton(
                                                    onPressed: () => launchUrl(
                                                        Uri.parse(
                                                            'tel://${abc.data!.trips![0].inTrip![index].agentPhone}')),
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                            right: 180),
                                                        child: Text(
                                                            '${abc.data!.trips![0].inTrip![index].agentPhone}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    14)))),
                                                leading: Icon(Icons.phone,
                                                    color: thirdColor,
                                                    size: 40),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        15, 5, 10, 0),
                                                title: Text('Entrada: ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18)),
                                                subtitle: Text(
                                                    '${abc.data!.trips![0].inTrip![index].hourIn}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                                leading: Icon(Icons.access_time,
                                                    color: thirdColor,
                                                    size: 40),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        15, 5, 10, 0),
                                                title: Text('Dirección: ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18)),
                                                subtitle: Text(
                                                    '${abc.data!.trips![0].inTrip![index].agentReferencePoint} \n ${abc.data!.trips![0].inTrip![index].neighborhoodName} ${abc.data!.trips![0].inTrip![index].districtName}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15)),
                                                leading: Icon(
                                                    Icons.location_pin,
                                                    color: thirdColor,
                                                    size: 40),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        15, 5, 10, 0),
                                                title: Text(
                                                    'Hora de encuentro:',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18)),
                                                subtitle: Text(
                                                    '${abc.data!.trips![0].inTrip![index].hourForTrip}',
                                                    style: TextStyle(
                                                        color: Gradiant2,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 25.0)),
                                                leading: Icon(Icons.access_time,
                                                    color: thirdColor,
                                                    size: 40),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20.0),
                                        Container(
                                          width: 200,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              textStyle: TextStyle(
                                                color:
                                                    backgroundColor, // foreground
                                              ),
                                              backgroundColor: firstColor,
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: firstColor,
                                                      width: 2,
                                                      style: BorderStyle.solid),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        backgroundColor:
                                                            backgroundColor,
                                                        content: Container(
                                                          width: 400,
                                                          height: 200,
                                                          child: Column(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                  height: 15),
                                                              if (abc
                                                                      .data
                                                                      !.trips![0]
                                                                      .inTrip![
                                                                          index]
                                                                      .commentDriver ==
                                                                  null) ...{
                                                                Center(
                                                                    child: Text(
                                                                  'Observación',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                                Text('')
                                                              } else ...{
                                                                Center(
                                                                  child: Text(
                                                                    'Observación',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            thirdColor),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 15),
                                                                Center(
                                                                  child: Text(
                                                                    '${abc.data!.trips![0].inTrip![index].commentDriver}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              },
                                                              SizedBox(
                                                                  height: 21),
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              backgroundColor, // foreground
                                                                        ),
                                                                        // foreground
                                                                        backgroundColor:
                                                                            firstColor),
                                                                onPressed: () =>
                                                                    {
                                                                  setState(() {
                                                                    Navigator.pop(
                                                                        context);
                                                                  }),
                                                                },
                                                                child: Text(
                                                                    'Entendido',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            backgroundColor)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                            },
                                            child: Text('Observaciones',
                                                style: TextStyle(
                                                    color: backgroundColor,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
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
        } else {
          return ColorLoader3();
        }
      },
    );
  }

  Widget _agentToCancel() {
    return FutureBuilder<TripsList2>(
      future: itemx,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![2].cancelados!.length == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      blurStyle: BlurStyle.normal,
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: -15,
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
                        leading: Icon(Icons.bus_alert,
                            color: thirdColor, size: 40.0),
                        title: Text('Agentes',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 20.0)),
                        subtitle: Text(
                            'No hay agentes cancelados para este viaje',
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
            return FutureBuilder<TripsList3>(
              future: item,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: abc.data!.trips![2].cancelados!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 500.0,
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.all(15.0),
                              elevation: 2,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ExpansionTile(
                                      backgroundColor: Colors.white,
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              if (abc
                                                      .data
                                                      !.trips![2]
                                                      .cancelados![index]
                                                      .traveled ==
                                                  1) ...{
                                                Text('✅ '),
                                                Text('Abordó')
                                              } else ...{
                                                Text('x ',
                                                    style: TextStyle(
                                                        color: Colors.red[500],
                                                        fontSize: 25)),
                                                Text(' no abordó')
                                              }
                                            ],
                                          ),
                                          ListTile(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                5, 5, 10, 0),
                                            title: Text('Nombre: '),
                                            subtitle: Text(
                                                '${abc.data!.trips![2].cancelados![index].agentFullname}'),
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
                                                    '${abc.data!.trips![2].cancelados![index].companyName}'),
                                                leading: Icon(Icons.kitchen,
                                                    color: Colors.green[500]),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        5, 5, 10, 0),
                                                title: Text('Teléfono: '),
                                                subtitle: TextButton(
                                                    onPressed: () => launchUrl(
                                                          Uri.parse(
                                                              'tel:${abc.data!.trips![2].cancelados![index].agentPhone}'),
                                                        ),
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                            right: 180),
                                                        child: Text(
                                                            '${abc.data!.trips![2].cancelados![index].agentPhone}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[500],
                                                                fontSize:
                                                                    14)))),
                                                leading: Icon(Icons.phone,
                                                    color: Colors.green[500]),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        5, 5, 10, 0),
                                                title: Text('Entrada: '),
                                                subtitle: Text(
                                                    '${abc.data!.trips![2].cancelados![index].hourIn}'),
                                                leading: Icon(Icons.access_time,
                                                    color: Colors.green[500]),
                                              ),
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        5, 5, 10, 0),
                                                title: Text('Dirección: '),
                                                subtitle: Text(
                                                    '${abc.data!.trips![2].cancelados![index].agentReferencePoint} \n${abc.data!.trips![2].cancelados![index].neighborhoodName} ${abc.data!.trips![2].cancelados![index].districtName}'),
                                                leading: Icon(
                                                    Icons.location_pin,
                                                    color: Colors.green[500]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20.0),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              textStyle: TextStyle(
                                                color:
                                                    Colors.white, // foreground
                                              ),
                                              backgroundColor:
                                                  kCardColorDriver2,
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: kCardColorDriver1,
                                                      width: 2,
                                                      style: BorderStyle.solid),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      content: Container(
                                                        width: 400,
                                                        height: 200,
                                                        child: Column(
                                                          children: <Widget>[
                                                            SizedBox(
                                                                height: 15),
                                                            if (abc
                                                                    .data
                                                                    !.trips![2]
                                                                    .cancelados![
                                                                        index]
                                                                    .comment ==
                                                                null) ...{
                                                              Center(
                                                                  child: Text(
                                                                'Observación',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                              SizedBox(
                                                                  height: 15),
                                                              Text(
                                                                  '${abc.data!.trips![2].cancelados![index].commentDriver}')
                                                            } else ...{
                                                              Center(
                                                                child: Text(
                                                                  'Observación',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 15),
                                                              Center(
                                                                child: Text(
                                                                  '${abc.data!.trips![2].cancelados![index].comment}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                            },
                                                            SizedBox(
                                                                height: 21),
                                                            TextButton(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                      textStyle:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white, // foreground
                                                                      ),
                                                                      // foreground
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green),
                                                              onPressed: () => {
                                                                setState(() {
                                                                  Navigator.pop(
                                                                      context);
                                                                }),
                                                              },
                                                              child: Text(
                                                                  'Entendido'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ));
                                          },
                                          child: Text('Observaciones',
                                              style: TextStyle(
                                                  color: Colors.white)),
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
        } else {
          return ColorLoader3();
        }
      },
    );
  }
}
