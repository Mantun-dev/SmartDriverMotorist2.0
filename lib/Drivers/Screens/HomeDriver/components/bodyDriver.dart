import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/details_solidtrip.dart';
//import 'package:flutter/scheduler.dart';

import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/itemDriver_Card.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants.dart';
import 'package:package_info/package_info.dart';

import '../../../../main.dart';
import '../../Details/components/detailsDriver_assignHour.dart';
import '../../Details/components/details_HoursOut.dart';
import '../../Details/components/details_TripProgress.dart';
import '../../Details/components/details_history.dart';
//import 'package:new_version/new_version.dart';

class Body extends StatefulWidget {
  final DriverData? itemx;

  const Body({Key? key, this.itemx}) : super(key: key);
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> with AutomaticKeepAliveClientMixin<Body> {
  Future<DriverData>? itemx;
  FocusNode _focusNode = FocusNode();
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    //_initPackageInfo();
    itemx = fetchRefres();
     _focusNode.addListener(_onFocusChange);
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     setState(() {
    //       fetchVersion();
    //       //_showVersionTrue();
    //     });
    //   }
    // });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // TextField está en foco
      isMenuOpen=true;
    } else {
      // TextField ya no está en foco
      isMenuOpen=false;
    }
    setState(() { });
  }

  fetchVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    String version = "${info.version}";
    String newVersion = "";
    print(version);
    if (newVersion != "") {
      final dataVersion = version.split(".");
      final dataNewVersion = newVersion.split(".");
      List<int> numbersVersion = dataVersion.map(int.parse).toList();
      List<int> numbersNewVersion = dataNewVersion.map(int.parse).toList();
      if (numbersVersion[0] == numbersNewVersion[0] &&
          numbersVersion[1] == numbersNewVersion[1] &&
          numbersVersion[2] == numbersNewVersion[2]) {
      } else if (numbersNewVersion == []) {
        print("Ingresando");
      } else {
        print("Hay Nueva version disponible");
      }
      print(newVersion.split('.'));
    } else {
      print("Version no disponible");
    }
  }

  _launchURL() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.driverapp.devs';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  showAlertVersion() async {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
              transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
              child: Opacity(
                  opacity: a1.value,
                  child: AlertDialog(
                    content: Container(
                      width: 400,
                      height: 140,
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.warning,
                              color: Colors.orangeAccent, size: 35.0),
                          SizedBox(height: 10),
                          Text(
                            'Actualización disponible',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(width: 27),
                              TextButton(
                                style: TextButton.styleFrom(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    backgroundColor: Colors.orange),
                                onPressed: () => {
                                  Navigator.pop(context),
                                },
                                child: Text('Después'),
                              ),
                              SizedBox(width: 20),
                              Column(
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        backgroundColor: Colors.green),
                                    onPressed: () => {
                                      Navigator.pop(context),
                                      _launchURL(),
                                    },
                                    child: Text('Descargar'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )));
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Text('');
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        setState(() {
          _focusNode.unfocus();
        });
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700.0, // Aquí defines el ancho máximo deseado
        ),
        child: Container(
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
      
                //texto inicial
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    'Hola, ${prefs.nombreUsuarioFull}',
                    style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
      
                SizedBox(height: 15),      
      
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder<DriverData>(
                        future: itemx,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.departmentId != 2) {
                            return Column(
                              children: [
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                    children: List.generate(4, (index) {
                                      return Padding(
                                          padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 8),
                                          child: ItemDriverCard(
                                              plantillaDriver: plantillaDriver[index],
                                              press: () {
                                                setPantallaP(0);
                                                // si.method();
                                                if (plantillaDriver[index] == plantillaDriver[0]) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailsDriverHour(
                                                          plantillaDriver:
                                                              plantillaDriver[index],
                                                        ),
                                                      ));
                                                } else if (plantillaDriver[index] == plantillaDriver[1]) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailsDriverTripInProgress(
                                                          plantillaDriver:
                                                              plantillaDriver[index],
                                                        ),
                                                      ));
                                                } else if (plantillaDriver[index] == plantillaDriver[2]) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailsDriverHoursOut(
                                                          plantillaDriver:
                                                              plantillaDriver[index],
                                                        ),
                                                      ));
                                                } else if (plantillaDriver[index] == plantillaDriver[3]) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailsDriverHistory(
                                                          plantillaDriver:
                                                              plantillaDriver[index],
                                                        ),
                                                      ));
                                                }
                                              }),
                                        );
                                    }),
                                  ),
                                  Center(
                                    child: ItemDriverCard(
                                      plantillaDriver: plantillaDriver[4],
                                      viajeSolido: true,
                                      press: () {
                                        _noDisponible(context);
                                      },
                                    ),
                                  ),
                              ],
                            );
                          }else{
                            return GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                children: List.generate(plantillaDriver.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0, left: 8, bottom: 8),
                                    child: ItemDriverCard(
                                      viajeSolido: false,
                                        plantillaDriver: plantillaDriver[index],
                                        press: () {
                                          setPantallaP(0);
                                          // si.method();
                                          if (plantillaDriver[index] == plantillaDriver[0]) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsDriverHour(
                                                        plantillaDriver:
                                                            plantillaDriver[index],
                                                      ),
                                                    ));
                                              } else if (plantillaDriver[index] == plantillaDriver[1]) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsDriverTripInProgress(
                                                        plantillaDriver:
                                                            plantillaDriver[index],
                                                      ),
                                                    ));
                                              } else if (plantillaDriver[index] == plantillaDriver[2]) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsDriverHoursOut(
                                                        plantillaDriver:
                                                            plantillaDriver[index],
                                                      ),
                                                    ));
                                              } else if (plantillaDriver[index] == plantillaDriver[3]) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsDriverHistory(
                                                        plantillaDriver:
                                                            plantillaDriver[index],
                                                      ),
                                                    ));
                                              }else if (plantillaDriver[index].id == 5) {
                                                _noDisponible(context);
                                              }else if (plantillaDriver[index].id == 6) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsSolidTrip(
                                                        plantillaDriver:
                                                            plantillaDriver[index],
                                                      ),
                                                    ));
                                              }
                                        }),
                                  );
                                })
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
                                          'Cargando menú...', 
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
                ),
                //Positioned(child: Icon(Icons.brightness_1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _noDisponible(BuildContext context) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Center(
                    child: Text('Página disponible \n\t\t\t\tpróximamente')),
                actions: [
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => {
                        Navigator.pop(context),
                      },
                      child: Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Text('');
        });
  }

  @override
  bool get wantKeepAlive => true;
}
