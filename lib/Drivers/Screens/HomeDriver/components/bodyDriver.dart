import 'package:flutter/material.dart';
//import 'package:flutter/scheduler.dart';

import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/itemDriver_Card.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants.dart';
import 'package:package_info/package_info.dart';

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

  @override
  void initState() {
    super.initState();
    //_initPackageInfo();
    itemx = fetchRefres();
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     setState(() {
    //       fetchVersion();
    //       //_showVersionTrue();
    //     });
    //   }
    // });
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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          //texto inicial
          Text(
            "Smart Driver",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold, fontSize: 28, color: firstColor),
          ),
          FutureBuilder<DriverData>(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.departmentId != 2) {
                    return Expanded(
                      child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: plantillaDriver.length - 1,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisExtent: kDefaultPadding * 10,
                          ),
                          itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 20.0),
                                child: ItemDriverCard(
                                    plantillaDriver: plantillaDriver[index],
                                    press: () {
                                      // si.method();
                                      if (plantillaDriver[index].id == 5) {
                                        _noDisponible(context);
                                      } else if (plantillaDriver[index] ==
                                          plantillaDriver[0]) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailsDriverHour(
                                                plantillaDriver:
                                                    plantillaDriver[index],
                                              ),
                                            ));
                                      } else if (plantillaDriver[index] ==
                                          plantillaDriver[1]) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailsDriverTripInProgress(
                                                plantillaDriver:
                                                    plantillaDriver[index],
                                              ),
                                            ));
                                      } else if (plantillaDriver[index] ==
                                          plantillaDriver[2]) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailsDriverHoursOut(
                                                plantillaDriver:
                                                    plantillaDriver[index],
                                              ),
                                            ));
                                      } else if (plantillaDriver[index] ==
                                          plantillaDriver[3]) {
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
                              )),
                    );
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding),
                      child: GridView.builder(
                          itemCount: plantillaDriver.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisExtent: kDefaultPadding * 10,
                          ),
                          itemBuilder: (context, index) => ItemDriverCard(
                              plantillaDriver: plantillaDriver[index],
                              press: () {
                                // si.method();
                                if (plantillaDriver[index].id == 5) {
                                  _noDisponible(context);
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailsDriverScreen(
                                          plantillaDriver:
                                              plantillaDriver[index],
                                        ),
                                      ));
                                }
                              })),
                    ),
                  );
                } else {
                  return Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
              future: itemx),
          //Positioned(child: Icon(Icons.brightness_1)),
        ],
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
