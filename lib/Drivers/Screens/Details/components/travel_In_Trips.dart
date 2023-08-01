//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';

import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_auth/components/AppBarSuperior.dart';

import '../../../../components/AppBarPosterior.dart';
import '../../../../components/backgroundB.dart';
import '../../../../constants.dart';
import '../../../models/plantillaDriver.dart';
import 'detailsDriver_assignHour.dart';

void main() => runApp(Trips());

class Trips extends StatefulWidget {
  final TripsPending2? item;

  const Trips({Key? key, this.item}) : super(key: key);
  @override
  _TripsState createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  Future<List<TripsPending2>>? item;
  TextEditingController tripId = new TextEditingController();
  final prefs = new PreferenciasUsuario();

  @override
  void initState() {
    super.initState();
    item = fetchTripsPending();
    tripId = new TextEditingController(text: prefs.tripId);
    // BackButtonInterceptor.add(myInterceptor);
  }

  fetchAgentsInTravel2(String tripId) async {
    prefs.tripId = tripId;
    if (tripId == tripId) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyAgent(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BackgroundBody(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: AppBarSuperior(item: 11,)
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: body(size)),
                      ),
                      SafeArea(child: AppBarPosterior(item:-1)),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget body(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 30),
          FutureBuilder<List<TripsPending2>>(future: item,
            builder: (BuildContext context, abc) {
              if (abc.connectionState == ConnectionState.done) {
                if (abc.data!.length < 1) {
                  return Column(
                    children: [
                      SizedBox(height: 5),
                      Center(
                        child: Text(
                          'No hay viajes pendientes',
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      
                    ],
                  );
                } else {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,physics: ClampingScrollPhysics(),
                    itemCount: abc.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Theme.of(context).dividerColor,),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2, left: 2),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.tag,color: thirdColor),
                                        SizedBox(width: 15,),
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14),
                                              children: [
                                                TextSpan(
                                                  text: 'Viaje: ',
                                                  style: TextStyle(fontWeight: FontWeight.normal),
                                                ),
                                                TextSpan(
                                                  text: '${abc.data![index].tripId}',
                                                  style: TextStyle(fontWeight: FontWeight.normal),
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
                                        Icon(Icons.calendar_today,color: thirdColor),
                                        SizedBox(width: 15,),
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14),
                                              children: [
                                                TextSpan(
                                                  text: 'Fecha: ',
                                                  style: TextStyle(fontWeight: FontWeight.normal),
                                                ),
                                                TextSpan(
                                                  text: '${abc.data![index].fecha}',
                                                  style: TextStyle(fontWeight: FontWeight.normal),
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
                                  Row(
                                    children: [
                                      Icon(Icons.location_city_rounded,color: thirdColor),
                                      SizedBox(width: 15,),
                                      Text('Empresa: ${abc.data![index].empresa}',style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                      ],
                                  ),

                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,color: thirdColor),
                                      SizedBox(width: 15,),
                                      Text('Hora: ${abc.data![index].hora}',style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                      ],
                                  ),
                                  SizedBox(height: 13),
                                  Row(
                                    children: [
                                      Icon(Icons.supervised_user_circle,color: thirdColor),
                                      SizedBox(width: 15,),
                                      Text('Agentes: ${abc.data![index].agentes}',style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                      ],
                                  ),
                                  SizedBox(height: 13),
                                  Container(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        fixedSize: Size(200, 50),
                                        elevation: 10,
                                        backgroundColor: backgroundColor,
                                        textStyle: TextStyle(color: Colors.white,),
                                        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
                                      ),
                                      child: Text('Ver viaje',style: TextStyle(color: firstColor,fontSize: 20)),
                                        onPressed: () {
                                          fetchAgentsInTravel2(abc.data![index].tripId.toString());
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20.0),                                      
                                ],
                              ),
                            ),
                          ),
                        );
                      });
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
          )
        ],
      ),
    );
  }
}
