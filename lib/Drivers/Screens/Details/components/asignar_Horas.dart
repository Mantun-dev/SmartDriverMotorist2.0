import 'package:flutter/material.dart';

import 'package:flutter_auth/Drivers/Screens/Details/components/travel_In_Trips.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';

import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AsignarHoras extends StatefulWidget {
  final TripsCompanies? itemx;
  const AsignarHoras({Key? key, this.itemx}) : super(key: key);

  @override
  _AsignarHorasState createState() => _AsignarHorasState();
}

class _AsignarHorasState extends State<AsignarHoras> {
  Future<List<TripsCompanies>>? itemx;
  TextEditingController companyId = new TextEditingController();
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";

  @override
  void initState() {
    super.initState();
    itemx = fetchCompaniesGet();
    companyId = new TextEditingController(text: prefs.companyId);
  }

  fetchTravelInTrip(String companyId) {
    prefs.companyId = companyId;
    if (companyId == companyId) {
      Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (_, __, ___) => Trips(),
                        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(1.0, 0.0), // Cambiar Offset de inicio a (1.0, 0.0)
                              end: Offset.zero, // Mantener Offset de final en (0.0, 0.0)
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Container(
          child: body(),
        ),
      ],
    );
  }

  FutureBuilder<List<TripsCompanies>> body() {
    return FutureBuilder<List<TripsCompanies>>(
          future: itemx,
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
                                '  No hay viajes pendientes',
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
                        padding: const EdgeInsets.only(left: 15, right: 15,bottom: 18),
                        child: InkWell(
                          onTap: () {
                            fetchTravelInTrip(
                                abc.data![index].companyId.toString());
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                color: Theme.of(context).dividerColor, // Color del borde
                                width: 1.0,         // Ancho del borde
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Column(
                                        children: [
                                          if (abc.data![index].companyId == 1) ...{
                                            Container(
                                              height: 50,
                                              child: SvgPicture.asset("assets/images/Grupo11.svg"),
                                            ),
                                          },
                                          if (abc.data![index].companyId == 2 || abc.data![index].companyId == 3) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/startek.webp'
                                              ),
                                            ),
                                          },
                                          if (abc.data![index].companyId == 6 || abc.data![index].companyId == 13) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/Alorica_Logo.png'),
                                            ),
                                          },
                                          if (abc.data![index].companyId == 7) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/zero.png'),
                                            ),
                                          },
                                          if (abc.data![index].companyId == 8) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/emerge-bpo-largex5-logo.png'),
                                            ),
                                          },
                                          if (abc.data![index].companyId == 9) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/ibex-logo.jpg'),
                                            ),
                                          },
                                          if (abc.data![index].companyId == 10) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/itel.jpg'),
                                            ),
                                          },

                                          if (abc.data![index].companyId == 11) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/results.png'),
                                            ),
                                          },

                                          if (abc.data![index].companyId == 15) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/relaylogo.png'),
                                            ),
                                          },

                                          if (abc.data![index].companyId == 16) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/TTEC.png'),
                                            ),
                                          },

                                          if (abc.data![index].companyId == 18) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/GGA.webp'),
                                            ),
                                          },
                                          if (abc.data![index].companyId == 20) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset("assets/images/altiam2.jpeg"),
                                            ),
                                          },
                                          if (abc.data![index].companyId == 21) ...{
                                            Container(
                                              height: 50,
                                              child: Image.asset(
                                                  'assets/images/corpstartek.webp'
                                              ),
                                            ),
                                          }

                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromRGBO(178, 13, 13, 1),
                                        ),
                                        child: Text(
                                          '${abc.data![index].trips}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 25),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        child: SvgPicture.asset(
                                          "assets/icons/flechader.svg",
                                          color: Theme.of(context).primaryIconTheme.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
        );
  }
}
