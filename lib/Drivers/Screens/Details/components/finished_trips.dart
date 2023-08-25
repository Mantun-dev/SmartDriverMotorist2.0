import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/AgentTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/agentsInTravelModel.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
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

  launchSalidasMaps(lat,lng)async{
    String destination = '$lat,$lng';
    String url = 'google.navigation:q=$destination&mode=d';
    await launchUrl(Uri.parse(url));
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
                        //width: 500.0,
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
                                    padding: const EdgeInsets.all(1.0),
                                    child: ExpansionTile(
                                      collapsedIconColor: Colors.white,
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
                                                        fontSize: 15)),
                                                SizedBox(width: 18),
                                                Text('Abordó',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18)),
                                              } else ...{
                                                Icon(Icons.cancel,
                                                    color: Colors.red[500]),
                                                SizedBox(width: 15,),
                                                Text('no abordó',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18)),
                                              },
                                              Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (abc.data!.trips![0]
                                                      .inTrip![index].latitude==null) {
                                              QuickAlert.show(
                                                context: context,
                                                title: "Alerta",
                                                text: 'Este agente no cuenta con ubicación',
                                                type: QuickAlertType.error,
                                              );
                                            }else{
                                              launchSalidasMaps(abc.data!.trips![0]
                                                      .inTrip![index].latitude,abc.data!.trips![0]
                                                      .inTrip![index].longitude);                                          
                                            }
                                            //print('Dirección we');
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                Icon(Icons.location_on_outlined, color:abc.data!.trips![0]
                                                      .inTrip![index].latitude==null? Colors.red :firstColor, size: 30,),
                                                Text('Ubicación ',style: TextStyle(color:Colors.white,fontWeight: FontWeight.normal,fontSize: 16.0)),                                      
                                              ],)
                                            ],
                                          ),
                                        ),
                                      ), 
                                            ],
                                          ),
                                          Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(0,10,20,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.supervised_user_circle_rounded,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(child: Text('Nombre: ${abc.data!.trips![0].inTrip![index].agentFullname}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                ],
                                                ),
                                              ),                       
                                            ],
                                          ),
                                        ],
                                      ),
                                      //trailing: SizedBox(),
                                      children: [
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(padding: const EdgeInsets.fromLTRB(16,4,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_city,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(child: Text('Empresa: ${abc.data!.trips![0].inTrip![index].companyName}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                              ],
                                              ),
                                            ),                       
                                          ],
                                        ),
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(16,0,0,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.phone,color: thirdColor),
                                                  SizedBox(width: 8,),
                                                  TextButton(onPressed: () => launchUrl(
                                                  Uri.parse('tel://${abc.data!.trips![0].inTrip![index].agentPhone}')),
                                                  child: Text('Teléfono: ${abc.data!.trips![0].inTrip![index].agentPhone}',style: TextStyle(color: Colors.white,fontSize:18))),
                                                  ],
                                                ),
                                              ),                       
                                            ],
                                          ),
                                          Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(16,0,20,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.access_time,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(child: Text('Entrada: ${abc.data!.trips![0].inTrip![index].hourIn}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                ],
                                                ),
                                              ),                       
                                            ],
                                        ),
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(padding: const EdgeInsets.fromLTRB(16,10,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_pin,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(child: Text('Dirección: ${abc.data!.trips![0].inTrip![index].agentReferencePoint} ${abc.data!.trips![0].inTrip![index].neighborhoodName} ${abc.data!.trips![0].inTrip![index].districtName}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                              ],
                                              ),
                                            ),                       
                                          ],
                                        ),
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(16,10,20,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.access_time,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(child: Text('Hora de encuentro: ',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                  Text('${abc.data!.trips![0].inTrip![index].hourForTrip}',
                                                    style: TextStyle(
                                                    color: Gradiant2,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 25.0))
                                                  ],
                                                ),
                                              ),                       
                                            ],
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
                                      collapsedIconColor: Colors.white,
                                      backgroundColor: backgroundColor,
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              if (abc.data!.trips![2].cancelados![index].traveled == 1) ...{
                                                Text('✅',style: TextStyle(color: Colors.green,fontSize: 20)),
                                                SizedBox(width: 15),
                                                Text('Abordó',style: TextStyle(color: Colors.white,fontSize: 20)),
                                              } else ...{
                                                Icon(Icons.cancel,color: Colors.red[500]),
                                                Text(' no abordó',style: TextStyle(color: Colors.white,fontSize: 20)),
                                              }
                                            ],
                                          ),
                                          Column(crossAxisAlignment:CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(padding: const EdgeInsets.fromLTRB(0,10,20,0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.supervised_user_circle_rounded,color: thirdColor),
                                                  SizedBox(width: 15,),
                                                  Flexible(child: Text('Nombre: ${abc.data!.trips![2].cancelados![index].agentFullname}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                                ],
                                                ),
                                              ),                       
                                            ],
                                          ),
                                        ],
                                      ),
                                      //trailing: SizedBox(),
                                      children: [
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(padding: const EdgeInsets.fromLTRB(15,5,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.kitchen,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(child: Text('Empresa: ${abc.data!.trips![2].cancelados![index].companyName}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                              ],
                                              ),
                                            ),                       
                                          ],
                                        ),
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(padding: const EdgeInsets.fromLTRB(15,0,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone,color: thirdColor),
                                                SizedBox(width: 10,),
                                                TextButton(onPressed: () => launchUrl(Uri.parse('tel:${abc.data!.trips![2].cancelados![index].agentPhone}')),
                                                  child: Container(
                                                  child: Text('${abc.data!.trips![2].cancelados![index].agentPhone}',style: TextStyle(color: Colors.white,fontSize:18)))),
                                                ],
                                              ),
                                            ),                       
                                          ],
                                        ),
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(padding: const EdgeInsets.fromLTRB(15,0,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(child: Text('Entrada: ${abc.data!.trips![2].cancelados![index].hourIn}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                              ],
                                              ),
                                            ),                       
                                          ],
                                        ),
                                        Column(crossAxisAlignment:CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(padding: const EdgeInsets.fromLTRB(15,10,20,0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_pin,color: thirdColor),
                                                SizedBox(width: 15,),
                                                Flexible(child: Text('Dirección: ${abc.data!.trips![2].cancelados![index].agentReferencePoint} ${abc.data!.trips![2].cancelados![index].neighborhoodName} ${abc.data!.trips![2].cancelados![index].districtName}',style: TextStyle(color: Colors.white,fontSize: 18.0)),),
                                              ],
                                              ),
                                            ),                       
                                          ],
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
                                                      AlertDialog(backgroundColor:backgroundColor,
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
                                                                                .bold,
                                                                        color:
                                                                            thirdColor),
                                                                  )),
                                                                SizedBox(
                                                                  height: 15),
                                                                Text('${abc.data!.trips![2].cancelados![index].commentDriver}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white),)
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
                                                                   '${abc.data!.trips![2].cancelados![index].comment}',
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
                                            child: Text('Observaciones',style: TextStyle(color: backgroundColor,fontSize: 18,fontWeight:FontWeight.w500)),
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


}