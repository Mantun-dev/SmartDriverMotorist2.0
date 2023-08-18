import 'package:flutter/material.dart';

import 'package:flutter_auth/Drivers/Screens/Details/components/trip_In_Process.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';

import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProcessTrip extends StatefulWidget {
  final TripsCompanies? itemx;
  const ProcessTrip({Key? key, this.itemx}) : super(key: key);

  @override
  _ProcessTripState createState() => _ProcessTripState();
}

class _ProcessTripState extends State<ProcessTrip> {
  Future<List<TripsCompanies>>? itemx;
  TextEditingController companyId = new TextEditingController();
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";
  @override
  void initState() {
    super.initState();
    itemx = fetchProgressTripGet();
    companyId = new TextEditingController(text: prefs.companyId);
  }

  fetchAgentsAsigmentChekc(String companyId) async {
    prefs.companyId = companyId;
    if (companyId == companyId) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Process(),
          ));
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
              return Column(
                  children: [

                    Center(
                      child: Text(
                        'No hay viajes progreso',
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
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: abc.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15,bottom: 18),
                      child: InkWell(
                        onTap: () {
                          fetchAgentsAsigmentChekc(
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
                                        if (abc.data![index].companyId ==
                                            1) ...{
                                          Container(
                                            height: 50,
                                            child: SvgPicture.asset(
                                                'assets/images/Grupo11.svg'),
                                          ),
                                        } else
                                        if (abc.data![index].companyId ==
                                                2 ||
                                            abc.data![index].companyId ==
                                                3) ...{
                                          Container(
                                            height: 50,
                                            child: Image.asset(
                                                'assets/images/startek.webp'),
                                          ),
                                        } else
                                        if (abc.data![index].companyId ==
                                            6) ...{
                                          Container(
                                            height: 50,
                                            child: Image.asset(
                                                'assets/images/Alorica_Logo.png'),
                                          ),
                                        } else
                                        if (abc.data![index].companyId ==
                                            7) ...{
                                          Container(
                                            height: 50,
                                            child: Image.asset(
                                                'assets/images/zero.png'),
                                          ),
                                        } else
                                        if (abc.data![index].companyId ==
                                            8) ...{
                                          Container(
                                            height: 50,
                                            child: Image.asset(
                                                'assets/images/emerge-bpo-largex5-logo.png'),
                                          ),
                                        } else
                                        if (abc.data![index].companyId ==
                                            9) ...{
                                          Container(
                                            height: 50,
                                            child: Image.asset(
                                                'assets/images/ibex-logo.jpg'),
                                          ),
                                        } else
                                        if (abc.data![index].companyId ==
                                            10) ...{
                                          Container(
                                            height: 50,
                                            child: Image.asset(
                                                'assets/images/itel.jpg'),
                                          ),
                                        }
                                        else...{
                                          Container(
                                            height: 50,
                                          )
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
            return ColorLoader3();
          }
        },
      );
  }
}
