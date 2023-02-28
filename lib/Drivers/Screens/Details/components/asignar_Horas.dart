import 'package:flutter/material.dart';

import 'package:flutter_auth/Drivers/Screens/Details/components/travel_In_Trips.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';

import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_auth/constants.dart';
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
          MaterialPageRoute(
            builder: (context) => Trips(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500.0,
      color: backgroundColor,
      child: Column(
        children: [
          FutureBuilder<List<TripsCompanies>>(
            future: itemx,
            builder: (BuildContext context, abc) {
              if (abc.connectionState == ConnectionState.done) {
                if (abc.data!.length < 1) {
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
                    child: Card(
                      color: backgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.bus_alert,
                              color: thirdColor,
                            ),
                            title: Text('Agentes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20.0)),
                            subtitle: Text('No hay viajes pendientes',
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
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            fetchTravelInTrip(
                                abc.data![index].companyId.toString());
                          },
                          child: Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  blurStyle: BlurStyle.normal,
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: -8,
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
                              margin: EdgeInsets.all(12),
                              elevation: 10,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 20.0),
                                  Container(
                                    child: Row(
                                      crossAxisAlignment : CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          height: 80,
                                          width: 170,
                                          child: Column(
                                            children: [
                                              if (abc.data![index].companyId == 1) ...{
                                                Container(
                                                  height: 80,
                                                  width: 170,
                                                  child: SvgPicture.asset(
                                                      "assets/images/Grupo11.svg"),
                                                ),
                                              },
                                              if (abc.data![index].companyId ==
                                                      2 ||
                                                  abc.data![index].companyId ==
                                                      3) ...{
                                                Container(
                                                  height: 80,
                                                  width: 170,
                                                  child: Image.asset(
                                                      'assets/images/startek.webp'),
                                                ),
                                              },
                                              if (abc.data![index].companyId ==
                                                  6) ...{
                                                Container(
                                                  height: 80,
                                                  width: 170,
                                                  child: Image.asset(
                                                      'assets/images/Alorica_Logo.png'),
                                                ),
                                              },
                                              if (abc.data![index].companyId ==
                                                  7) ...{
                                                Container(
                                                  height: 80,
                                                  width: 170,
                                                  child: Image.asset(
                                                      'assets/images/zero.png'),
                                                ),
                                              },
                                              if (abc.data![index].companyId ==
                                                  8) ...{
                                                Container(
                                                  height: 80,
                                                  width: 170,
                                                  child: Image.asset(
                                                      'assets/images/emerge-bpo-largex5-logo.png'),
                                                ),
                                              },
                                              if (abc.data![index].companyId ==
                                                  9) ...{
                                                Container(
                                                  height: 80,
                                                  width: 170,
                                                  child: Image.asset(
                                                      'assets/images/ibex-logo.jpg'),
                                                ),
                                              },
                                              if (abc.data![index].companyId == 10) ...{
                                                Container(
                                                  height: 80,
                                                  width: 170,
                                                  child: Image.asset(
                                                      'assets/images/itel.jpg'),
                                                ),
                                              }
                                            ],
                                          ),
                                        ),
                                        Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            margin: EdgeInsets.only(bottom: 25),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red),
                                            child: Text(
                                              '${abc.data![index].trips}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13),
                                            )),
                                      ],
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
                return ColorLoader3();
              }
            },
          )
        ],
      ),
    );
  }
}
