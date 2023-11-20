import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/finished_trips.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
//import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/models/AgentTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
//import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

class HistoryTripDriver extends StatefulWidget {
  final TripsHistory? item;
  const HistoryTripDriver({Key? key, this.item}) : super(key: key);

  @override
  _HistoryTripDriverState createState() => _HistoryTripDriverState();
}

class _HistoryTripDriverState extends State<HistoryTripDriver> {
  Future<List<TripsHistory>>? item;
  final prefs = new PreferenciasUsuario();
  TextEditingController tripId = new TextEditingController();
  String ip = "https://driver.smtdriver.com";
  @override
  void initState() {
    super.initState();
    item = fetchTripsHistory();
    tripId = new TextEditingController(text: prefs.tripId);
  }

  Future<TripsList3> fetchAgentsCompleted(String tripId) async {
    Map datas = {
      'tripId': tripId,
    };
    prefs.tripId = tripId;

    http.Response responsed =
        await http.get(Uri.parse('$ip/apis/agentsInTravel/${datas['tripId']}'));

    if (responsed.statusCode == 200) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyFinishedTrips(),
          ));
      return TripsList3.fromJson(json.decode(responsed.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<List<TripsHistory>>(
        future: item,
        builder: (BuildContext context, abc) {
          if (abc.connectionState == ConnectionState.done) {
            if (abc.data!.length < 1) {
              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15,bottom: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,  
                    ),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset( 
                            "assets/icons/advertencia.svg",
                            color: Theme.of(context).primaryIconTheme.color,
                            width: 18,
                            height: 18,
                          ),
                          Flexible(
                            child: Text(
                              '  No hay viajes registrados',
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15, color: Color.fromRGBO(213, 0, 0, 1), fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: abc.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Theme.of(context).dividerColor,),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, left: 20),
                          child: Column(
                            children: [
      
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                child: Row(
                                  children: [ 
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/Numeral.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Viaje: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].tripId}',
                                              style: TextStyle(fontWeight: FontWeight.w700),
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
                                        "assets/icons/calendar2.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Fecha: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
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
                              Padding(
                                padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/vehiculo.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Conductor: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].conductor}',
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
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/vehiculo.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Vehículo: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].vehiculo}',
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
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/compania.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Empresa: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].empresa}',
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
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/hora.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Hora: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].hora}',
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
                                        "assets/icons/agentes.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Agentes: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].agentes}',
                                              style: TextStyle(fontWeight: FontWeight.w700,),
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
                                        "assets/icons/advertencia.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Tipo: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].tipo}',
                                              style: TextStyle(fontWeight: FontWeight.normal,),
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
      
                              SizedBox(height: 15),
                              TextButton(
                                style: TextButton.styleFrom(
                                  fixedSize: Size(150, 25),
                                  elevation: 0,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                ),
                                child: Text('Ver viaje',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontSize: 16)),
                                  onPressed: () {
                                    fetchAgentsCompleted(abc.data![index].tripId.toString());
                                  },
                                ),
                                SizedBox(height: 10.0),                                      
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
      ),
    );
  }
}