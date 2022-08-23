import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/driverBackground.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/itemDriver_Card.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';

import 'package:flutter_auth/Drivers/models/network.dart';
//import 'package:flutter_auth/Drivers/components/descriptionDriver.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants.dart';
import 'package:package_info/package_info.dart';
//import 'package:new_version/new_version.dart';

class Body extends StatefulWidget {
  final DriverData itemx;

  const Body({Key key, this.itemx}) : super(key: key);
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> with AutomaticKeepAliveClientMixin<Body>{
  Future<DriverData> itemx;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() { 
    super.initState();
    //_initPackageInfo();
    itemx = fetchRefres();
    SchedulerBinding.instance.addPostFrameCallback((_){
      if (mounted) {        
        setState(() {        
          fetchVersion(); 
          //_showVersionTrue();
        });
      }
    });
  }



  fetchVersion()async{  
      final PackageInfo info = await PackageInfo.fromPlatform(); 
      String version = "${info.version}";
      String newVersion = "";
        print(version);
      if (newVersion != "") {        
        final dataVersion = version.split(".");
        final dataNewVersion = newVersion.split(".");
        List<int> numbersVersion = dataVersion.map(int.parse).toList();
        List<int> numbersNewVersion = dataNewVersion.map(int.parse).toList();
        if (numbersVersion[0] == numbersNewVersion[0] && numbersVersion[1] == numbersNewVersion[1] && numbersVersion[2] == numbersNewVersion[2]) {
          print("Tamos bien");        
        } else if(numbersNewVersion == []){
          print("Tamos bien");
        } else {
          print("Hay nueva version we");
        }
        print(newVersion.split('.'));      
      }else{
        print("Nel perru :V dx");
      }
  }
  


  // void _showVersionTrue() async{    
  //     //validacion
  //     if (prefs.versionOld != prefs.versionNew) {
  //       showAlertVersion();        
  //     }    
  // }

_launchURL() async {
  const url = 'https://play.google.com/store/apps/details?id=com.driverapp.devs';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

  showAlertVersion()async{
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(opacity: a1.value,
            child:AlertDialog(
        content: Container(
          width: 400,
          height: 140,
          child: Column(
            children: <Widget>[

              Icon(Icons.warning, color: Colors.orangeAccent, size: 35.0),
              SizedBox(height: 10),
              Text(
                'Actualización disponible',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 27),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.orange
                      ),
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
                        primary: Colors.white,
                        backgroundColor: Colors.green
                      ),
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
      )
    ) );
        
    },
    transitionDuration: Duration(milliseconds: 200),
    barrierDismissible: false,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return null;
    }); 
  
}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DriverBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 70.0),
            //texto inicial
            child: Text(
              "Smart Driver",
              style: Theme.of(context)
                  .textTheme.headline5
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
          //Categories(),
          SizedBox(height: 30.0),
          FutureBuilder<DriverData>(builder: (context, snapshot) {
            if (snapshot.hasData) {                
              if (snapshot.data.departmentId != 2) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: GridView.builder(
                        itemCount: plantillaDriver.length-1,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: kDefaultPadding,
                          crossAxisSpacing: kDefaultPadding,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (context, index) => ItemDriverCard(
                              plantillaDriver: plantillaDriver[index],
                              press: () {
                              // si.method();
                              if (plantillaDriver[index].id == 5) {
                                _noDisponible(context);
                              }else{
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsDriverScreen(
                                        plantillaDriver: plantillaDriver[index],
                                      ),
                                    ));
                              }           
                              } 
                            )),
                  ),
                );
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  child: GridView.builder(
                      itemCount: plantillaDriver.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: kDefaultPadding,
                        crossAxisSpacing: kDefaultPadding,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) => ItemDriverCard(
                            plantillaDriver: plantillaDriver[index],
                            press: () {
                            // si.method();
                            if (plantillaDriver[index].id == 5) {
                              _noDisponible(context);
                            }else{
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsDriverScreen(
                                      plantillaDriver: plantillaDriver[index],
                                    ),
                                  ));
                            }           
                            } 
                          )),
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
          }, future: itemx),
          
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
                            title: Center(child: Text('Página disponible \n\t\t\t\tpróximamente')),                          
                              actions: [                                
                                Center(
                                  child: TextButton(                                    
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
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
                        return null;
    });
}

  @override
  bool get wantKeepAlive => true;
}
