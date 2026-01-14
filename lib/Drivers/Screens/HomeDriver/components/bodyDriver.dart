import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agent_Confirm_Before.dart';
//import 'package:flutter/scheduler.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/details_solidtrip.dart';
//import 'package:flutter/scheduler.dart';

import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/itemDriver_Card.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/helpers/res_apis.dart';
import 'package:flutter_auth/providers/device_info.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info/package_info.dart';

import '../../../../components/progress_indicator.dart';
import '../../../../helpers/base_client.dart';
import '../../../../main.dart';
import '../../../SharePreferences/preferencias_usuario.dart';
import '../../Chat/listaChas.dart';
import '../../Details/components/detailsDriver_assignHour.dart';
import '../../Details/components/details_HoursOut.dart';
import '../../Details/components/details_TripProgress.dart';
import '../../Details/components/details_history.dart';
import '../../DriverProfile/driverProfile.dart';
//import 'package:new_version/new_version.dart';
import 'package:http/http.dart' as http;
class Body extends StatefulWidget {
  final DriverData? itemx;

  const Body({Key? key, this.itemx}) : super(key: key);
  @override
  _BodyState createState() => _BodyState();
}

  late bool status;
class _BodyState extends State<Body> with AutomaticKeepAliveClientMixin<Body> {
  Future<DriverData>? itemx;
  FocusNode _focusNode = FocusNode();
  bool isMenuOpen = false;
  List<dynamic>? ventanas;
  List<dynamic>? ventanas2;
  TextEditingController buscarText = TextEditingController();
  bool light1 = false;
  String msg = "";  
  bool status = false;
  int showButton = 0;

  @override
  void initState() {
    super.initState(); 
    status = false; 
    statusWorklog();  
    saveDeviceId();
    itemx = fetchRefres();
    print(itemx);
     _focusNode.addListener(_onFocusChange);
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     setState(() {
    //       showAlertVersion();
    //     });
    //   }
    // });


    ventanas=[
        {
          'nombre': 'Horas de encuentro',
          'icono': 'assets/icons/asignar_viajes.svg',
          'ruta': 0,
        },
        {
          'nombre': 'Viajes en proceso',
          'icono': 'assets/icons/viaje_proceso.svg',
          'ruta': 1,
        },
        {
          'nombre': 'Registrar salidas',
          'icono': 'assets/icons/QR.svg',
          'ruta': 2,
        },
        {
          'nombre': 'Historial de viajes',
          'icono': 'assets/icons/historial_de_viaje.svg',
          'ruta': 3,
        },
        {
          'nombre': 'Viajes ejecutivos',
          'icono': 'assets/icons/ejecutivo.svg',
          'ruta': 4,
        },
        {
          'nombre': 'Chats',
          'icono': 'assets/icons/chats.svg',
          'ruta': 5,
        },
        {
          'nombre': 'Perfil',
          'icono': 'assets/icons/usuario2.svg',
          'ruta': 6,
        },
    ];
    ventanas2=ventanas;
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

  void saveDeviceId()async{
    String ip = "https://driver.smtdriver.com";
    http.Response responses = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));

    try {
      final data = DriverData.fromJson(json.decode(responses.body));
      String? deviceId = await getDeviceId();
      print(deviceId);
      Map body = {'driverId': data.driverId.toString(), 'deviceId': deviceId.toString() , 'deviceOS': 'Android'};
      var res = await BaseClient().post(RestApis.registerDevice, body, {"Content-Type": "application/json"});
      print(res);
    } catch (e) {
      print('Error decoding JSON: $e');
      print('Response body: ${responses.body}');
    }

  }
  // fetchVersion() async {
  //   final PackageInfo info = await PackageInfo.fromPlatform();
  //   String version = "${info.version}";
  //   String newVersion = "";
  //   print(version);
  //   if (newVersion != "") {
  //     final dataVersion = version.split(".");
  //     final dataNewVersion = newVersion.split(".");
  //     List<int> numbersVersion = dataVersion.map(int.parse).toList();
  //     List<int> numbersNewVersion = dataNewVersion.map(int.parse).toList();
  //     if (numbersVersion[0] == numbersNewVersion[0] &&
  //         numbersVersion[1] == numbersNewVersion[1] &&
  //         numbersVersion[2] == numbersNewVersion[2]) {
  //     } else if (numbersNewVersion == []) {
  //       print("Ingresando");
  //     } else {
  //       print("Hay Nueva version disponible");
  //     }
  //     print(newVersion.split('.'));
  //   } else {
  //     print("Version no disponible");
  //   }
  // }

  // _launchURL() async {
  //   const url =
  //       'https://play.google.com/store/apps/details?id=com.driverapp.devs';
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

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
                      height: 160,
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.warning,
                              color: Colors.orangeAccent, size: 35.0),
                          SizedBox(height: 10),
                          Text(
                            'Se le solicita colocar su hora de entrada laboral:',
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
                                     // _launchURL(),
                                    },
                                    child: Text('Aceptar'),
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

  statusWorklog()async{
    final prefs = new PreferenciasUsuario();
    http.Response response = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final rep = DriverData.fromJson(json.decode(response.body));

    Map data = {"driverId": rep.driverId};
    var statusApi = await BaseClient().post('https://driver.smtdriver.com/apis/statusWorkLog',data, {"Content-Type": "application/json"});
    final respStatus= json.decode(statusApi); 
    if (mounted) {      
      setState(() {      
        msg =   respStatus['message']['recordset'][0]['msg'];
        respStatus['message']['recordset'][0]['status']==1?status=true:status=false;
        showButton = respStatus['message']['recordset'][0]['showButton'];    
      });
    }   
  }

  Future<Map<String, dynamic>> validationWorkLog() async {
    final prefs = PreferenciasUsuario();
    http.Response response = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final rep = DriverData.fromJson(json.decode(response.body));

    Map data = {"driverId": rep.driverId};
    var status = await BaseClient().post('https://driver.smtdriver.com/apis/validationWorkLog', data, {"Content-Type": "application/json"});
    final respStatus = json.decode(status);    

    return {
      'msg': respStatus['message']['recordsets'][0][0]['msg'],
      'allow': respStatus['message']['recordsets'][0][0]['allow']
    };
  }

  registerWorkLog() async {
    final prefs = PreferenciasUsuario();
    http.Response response = await http.get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final rep = DriverData.fromJson(json.decode(response.body));

    Map data = {"driverId": rep.driverId};
    var status = await BaseClient().post('https://driver.smtdriver.com/apis/registerWorkLog', data, {"Content-Type": "application/json"});
    final respStatus = json.decode(status);  

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "¡Listo!",
      text: respStatus['message']['recordsets'][0][0]['msg'],
      confirmBtnText: "Cerrar"
    );    
    statusWorklog();
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
        child: Padding(
          padding: const EdgeInsets.only(right: 12, left: 12),
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
                  SizedBox(height: 10), 
                  if(showButton==1)...{
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(child: Text(msg, style: Theme.of(context).textTheme.labelLarge, )),
                        SizedBox(width: 10), 
                        FlutterSwitch(
                          height: 25,
                          width: 55,
                          value: status,
                          onToggle: (bool value) async{
                            LoadingIndicatorDialog().show(context);
                            var result = await validationWorkLog();
                            LoadingIndicatorDialog().dismiss();
                            if (result['allow'] == 1) {  
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.confirm,
                                title: status==true?"Finalizar jornada":"Iniciar jornada",
                                text: status==true?"¿Está seguro de finalizar la jornada laboral?":"¿Está seguro de iniciar la jornada laboral?",
                                confirmBtnText: 'Confirmar',
                                cancelBtnText: 'Cancelar',
                                showCancelBtn: true,  
                                confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ),
                                onConfirmBtnTap: () {
                                  setState(() {                              
                                    status = value;
                                  });
                                  Navigator.pop(context);
                                  registerWorkLog();
                                  
                                },
                                onCancelBtnTap: () {
                                  Navigator.pop(context);                                
                                },
                              );                                                          
                            }else{
                              var snackBar = SnackBar(
                                  content: Text(result['msg'] +' 🚨',
                                      style: TextStyle(fontSize: 20)),
                                  backgroundColor: Colors.red,
                                  dismissDirection: DismissDirection.up,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).size.height - 150,
                                      left: 10,
                                      right: 10),
                                );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                            
                          },
                          inactiveIcon: Icon(Icons.close, color: Colors.black),
                          activeIcon: Icon(Icons.check, color: Colors.black),
                          activeColor: Colors.green,
                          inactiveColor: Colors.red,
                        ),
                      ],
                    ),     
                    SizedBox(height: 10),      
                  },

                  ventanas2!=null?
                  Stack(
                    children: [
                      if(isMenuOpen==true && ventanas2!.length>0)
                        Padding(
                          padding: const EdgeInsets.only(top:40.0),
                          child: menu(size, context),
                        ),
            
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            width: 2,
                            color: Theme.of(context).disabledColor
                          )
                        ),
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          controller: buscarText,
                          onChanged: (value) {
        
                            if(value.isEmpty)
                              ventanas2=ventanas;
                            else
                              ventanas2=ventanas!.where((ventana) {
                                String nombre = ventana['nombre'].toString().toLowerCase();
                                return nombre.contains(value.toLowerCase());
                              }).toList();
        
                            setState(() {});
                          },
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            prefixIcon: SvgPicture.asset(  
                              "assets/icons/buscador.svg",
                              color: Theme.of(context).primaryIconTheme.color,
                              width: 25,
                              height: 25,
                            ),
                            hintText: 'Buscar',
                            hintStyle: TextStyle(
                              color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto'
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      
                    ],
                  ):Text(''),
              
                  SizedBox(height: 15),      
              
                  FutureBuilder<DriverData>(
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
                                    children: List.generate(snapshot.data!.driverCoord==true ? 5 : 4, (index) {
                                      return ItemDriverCard(
                                          plantillaDriver: plantillaDriver[index],
                                          press: () {
                                            setPantallaP(0);
                                            // si.method();
                                            if (plantillaDriver[index] == plantillaDriver[0]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverHour(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else if (plantillaDriver[index] == plantillaDriver[1]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverTripInProgress(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else if (plantillaDriver[index] == plantillaDriver[2]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverHoursOut(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else if (plantillaDriver[index] == plantillaDriver[3]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverHistory(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            }else if (plantillaDriver[index] == plantillaDriver[4]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsAgentConfirmBefore(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          });
                                    }),
                                  ),
                              ],
                            );
                          }else{
                            return GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                children: List.generate(snapshot.data!.driverCoord==true ? 5 : 4
                                  // plantillaDriver.length-2
                                  , (index) {
                                  return ItemDriverCard(
                                    viajeSolido: false,
                                      plantillaDriver: plantillaDriver[index],
                                      press: () {
                                        setPantallaP(0);
                                        // si.method();
                                        if (plantillaDriver[index] == plantillaDriver[0]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverHour(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else if (plantillaDriver[index] == plantillaDriver[1]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverTripInProgress(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else if (plantillaDriver[index] == plantillaDriver[2]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverHoursOut(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else if (plantillaDriver[index] == plantillaDriver[3]) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverHistory(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            }else if (plantillaDriver[index].id == 4) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(milliseconds: 200),
                                                  pageBuilder: (_, __, ___) => DetailsDriverTripInProgress(plantillaDriver: plantillaDriver[index]),                                  
                                                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                            
                                            // else if (plantillaDriver[index].id == 5) {
                                            //   _noDisponible(context);
                                            // }
                                            // else if (plantillaDriver[index].id == 6) {
                                            //   Navigator.push(
                                            //     context,
                                            //     PageRouteBuilder(
                                            //       transitionDuration: Duration(milliseconds: 200),
                                            //       pageBuilder: (_, __, ___) => DetailsSolidTrip(plantillaDriver: plantillaDriver[index]),                                  
                                            //       transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                            //         return SlideTransition(
                                            //           position: Tween<Offset>(
                                            //             begin: Offset(1.0, 0.0),
                                            //             end: Offset.zero,
                                            //           ).animate(animation),
                                            //           child: child,
                                            //         );
                                            //       },
                                            //     ),
                                            //   );
                                            // }
                                      });
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
                  
                  SizedBox(height: 15),  
                ],
              ),
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
                backgroundColor: Theme.of(context).cardColor,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide( // Add this line to specify the border color
                    color: Theme.of(context).disabledColor, // Change the color to the desired color
                    width: 2.0, // You can also adjust the border width if needed
                  ),
                ),
                title: Center(
                  child: Text(
                    'Página disponible \n\t\t\t\tpróximamente',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                  ),
                ),
                actions: [
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cerrar',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Colors.white),
                      ),
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

  Container menu(size, contextP) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: ventanas2!.asMap().entries.map((entry) {
              dynamic ventana = entry.value;
              String nombre = ventana['nombre'];
              String icono = ventana['icono'];
              int index = ventana['ruta'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: GestureDetector(
                  onTap: () {
                    rutas(index);
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            child: SvgPicture.asset(
                              icono,
                              color: Theme.of(context).primaryIconTheme.color,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            nombre,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(height: 12)
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void rutas(int i){
    switch(i){
      case 0:
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
            pageBuilder: (_, __, ___) => DetailsDriverHour(plantillaDriver: plantillaDriver[0]),
            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ); 
      break;
        
      case 1:
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
            pageBuilder: (_, __, ___) => DetailsDriverTripInProgress(plantillaDriver: plantillaDriver[1]),
            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ); 
      break;

      case 2:
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
            pageBuilder: (_, __, ___) => DetailsDriverHoursOut(plantillaDriver: plantillaDriver[2]),
            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      break;

      case 3:
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
            pageBuilder: (_, __, ___) => DetailsDriverHistory(plantillaDriver: plantillaDriver[3]),
            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      break;

      case 4:
        _noDisponible(context);
      break;

      case 5:
      Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
            pageBuilder: (_, __, ___) => ChatsList(),
            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      
      break;
        
      case 6:
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
            pageBuilder: (_, __, ___) => DriverProfilePage(),
            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      break;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
