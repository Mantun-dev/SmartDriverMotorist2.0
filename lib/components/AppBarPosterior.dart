import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Drivers/Screens/Details/components/detailsDriver_assignHour.dart';
import '../Drivers/Screens/Details/components/details_TripProgress.dart';
import '../Drivers/Screens/DriverProfile/driverProfile.dart';
import '../Drivers/models/countNotify.dart';
import '../Drivers/models/network.dart';
import '../Drivers/models/plantillaDriver.dart';




class AppBarPosterior extends StatefulWidget {
  final int? item;

  AppBarPosterior({this.item});

  @override
  _AppBarPosterior createState() => _AppBarPosterior(item: item);
}

class _AppBarPosterior extends State<AppBarPosterior> {
  int? item;
  int? counter;
  String? tripIdTologin;
  String? driverId;
  int totalNotificaciones = 0;
  Future<List<CountNotifications>>? itemN;

  _AppBarPosterior({this.item});

  @override
  void initState() {
    super.initState();
    getData();
    itemN = fetchCountNotify();
  }

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(size: 25),
      automaticallyImplyLeading: false, // Ocultar el ícono del Drawer
      actions: <Widget>[
        Expanded(
          child: item==0?Padding(
            padding: const EdgeInsets.only(top:10),
            child: Column(
              children: [
                Container(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(
                      "assets/icons/inicio.svg",
                      color: Theme.of(context).focusColor,
                    ),
                  ),

                  Text(
                    "Inicio",
                    style: TextStyle(
                            color: Theme.of(context).focusColor, fontSize: 10, fontFamily: 'Roboto'
                          ),
                  )
              ],
            ),
          ):GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 200 ),
                    pageBuilder: (_, __, ___) => HomeDriverScreen(),
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
              },
              child: Padding(
                padding: const EdgeInsets.only(top:10),
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      child: SvgPicture.asset(
                        "assets/icons/inicio.svg",
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                    "Inicio",
                    style: TextStyle(
                            color: Theme.of(context).hintColor, fontSize: 10, fontFamily: 'Roboto'
                          ),
                  )
                  ],
                ),
              ),
            ),
        ),

        Stack(
          children: [
            item==2?Padding(
              padding: const EdgeInsets.only(top:10),
              child: Column(
                children: [
                  Container(
                  width: 28,
                  height: 28,
                  child: SvgPicture.asset(
                    "assets/icons/notificacion.svg",
                    color: Theme.of(context).focusColor,
                  ),
                            ),
                            Text(
                    "Notificaciones",
                    style: TextStyle(
                            color: Theme.of(context).focusColor, fontSize: 10, fontFamily: 'Roboto'
                          ),
                  )
                ],
              ),
            ):GestureDetector(
            onTap: item==2?null:() async{

              showGeneralDialog(
                barrierColor: Colors.black.withOpacity(0.6),
                transitionBuilder: (context, a1, a2, widget) {
                  final curvedValue = Curves.easeInOut.transform(a1.value);
                  Size size = MediaQuery.of(context).size;
                  return Transform.translate(
                    offset: Offset(0.0, (1 - curvedValue) * size.height / 2),
                    child: Opacity(
                      opacity: a1.value,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FutureBuilder<List<CountNotifications>>(
                        future: itemN,
                        builder: (BuildContext context, abc) {
                          if (abc.connectionState == ConnectionState.done) {
                            return Container(
                                width: size.width,
                                decoration: BoxDecoration(
                                  color: prefs.tema ? Color.fromRGBO(47, 46, 65, 1) : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                      children: [

                                        SizedBox(height: 15),
                                        Center(
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).dividerColor,
                                                borderRadius: BorderRadius.circular(80)
                                              ),
                                              height: 6,
                                              width: 50,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),

                                        Center(child: Text('Pendientes',style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 20, fontWeight: FontWeight.w500))),
                                        SizedBox(height: 15),

                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                            ),
                                            onPressed: () => {
                                              Navigator.pop(context),
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) {
                                                return DetailsDriverHour(
                                                    plantillaDriver: plantillaDriver[0]);
                                              })),
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 18,
                                                        height: 18,
                                                        child: SvgPicture.asset(
                                                          "assets/icons/asignar_viajes.svg",
                                                          color: Theme.of(context).primaryIconTheme.color,
                                                        ),
                                                      ),
                                                      
                                                      Text("  Horas de encuentro", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
                                                    ],
                                                  ),
                                                ),
                                            
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color.fromRGBO(178, 13, 13, 1),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2.5),
                                                    child: Text(
                                                      '${abc.data![0].tripsCreated}',
                                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                Container(
                                                  width: 18,
                                                  height: 18,
                                                  child: SvgPicture.asset(
                                                    "assets/icons/flechader.svg",
                                                    color: Theme.of(context).primaryIconTheme.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                       
                                        //********************************************************************************* */

                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: TextButton(style: TextButton.styleFrom(backgroundColor: Colors.transparent,),
                                            onPressed: () => {
                                              Navigator.pop(context),
                                              Navigator.push(context,
                                                MaterialPageRoute(builder: (context) {return DetailsDriverTripInProgress(plantillaDriver: plantillaDriver[1]);})),
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 18,
                                                        height: 18,
                                                        child: SvgPicture.asset(
                                                          "assets/icons/viaje_proceso.svg",
                                                          color: Theme.of(context).primaryIconTheme.color,
                                                        ),
                                                      ),
                                                      
                                                      Text("  Viajes en proceso", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
                                                    ],
                                                  ),
                                                ),
                                            
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color.fromRGBO(178, 13, 13, 1),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2.5),
                                                    child: Text(
                                                      '${abc.data![0].tripsInProgress}',
                                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                Container(
                                                  width: 18,
                                                  height: 18,
                                                  child: SvgPicture.asset(
                                                    "assets/icons/flechader.svg",
                                                    color: Theme.of(context).primaryIconTheme.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 60)
                                      ],
                                    ),
                                ),
                              );
                          
                          } else {
                            return Text('');
                          }
                        },
                        ),
                      ),
                    ),
                  );
                },
                transitionDuration: Duration(milliseconds: 200),
                barrierDismissible: true,
                barrierLabel: '',
                context: context,
                pageBuilder: (context, animation1, animation2) {
                  return widget;
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top:10),
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    child: SvgPicture.asset(
                      "assets/icons/notificacion.svg",
                      color: Theme.of(context).hintColor,
                    ),
                  ),

                  Text(
                    "Notificaciones",
                    style: TextStyle(
                            color: Theme.of(context).hintColor, fontSize: 10, fontFamily: 'Roboto'
                          ),
                  )
                ],
              ),
            ),
          ),
            Positioned(
              top: 5,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                child: Container(
                  
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: Theme.of(context).hoverColor, width: 1.5)),
                  child: Center(
                    child:   Text(
                        '$totalNotificaciones',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).hoverColor)
                      ),
                  ),
                ),
              ),
            ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(right: 25, left: 25),
            child: SizedBox(),
          ),

        Stack(
          children: [
            item==3?Padding(
              padding: const EdgeInsets.only(top:10, right: 18),
              child: Column(
                children: [
                  Container(
                  width: 28,
                  height: 28,
                  child: SvgPicture.asset(
                    "assets/icons/chats.svg",
                    color: Theme.of(context).focusColor,
                  ),
                            ),
                            Text(
                    "Chats",
                    style: TextStyle(
                            color: Theme.of(context).focusColor, fontSize: 10, fontFamily: 'Roboto'
                          ),
                  )
                ],
              ),
            ):GestureDetector(
            onTap: item==3?null:() {
                setState(() {
                  
                });
              },
            child: Padding(
              padding: const EdgeInsets.only(top:10, right: 18),
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    child: SvgPicture.asset(
                      "assets/icons/chats.svg",
                      color: Theme.of(context).hintColor,
                    ),
                  ),

                  Text(
                    "Chats",
                    style: TextStyle(
                            color: Theme.of(context).hintColor, fontSize: 10, fontFamily: 'Roboto'
                          ),
                  )
                ],
              ),
            ),
          ),
            Positioned(
              top: 5,
              left: 25,
              child: Container(
                width: 20,
                height: 20,
                child: Container(
                  
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: Theme.of(context).hoverColor, width: 1.5)),
                  child: Center(
                    child:  Text(
                    counter!=null?'$counter':'0',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).hoverColor)
                  ),
                  ),
                ),
              ),
            ),
                ],
              ),

        Expanded(
          child: item==1?Padding(
            padding: const EdgeInsets.only(top:10),
            child: Column(
              children: [
                Container(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(
                      "assets/icons/usuario2.svg",
                      color: Theme.of(context).focusColor
                    ),
                  ),

                  Text(
                    "Perfil",
                    style: TextStyle(
                            color: Theme.of(context).focusColor, fontSize: 10, fontFamily: 'Roboto'
                          ),
                  )
              ],
            ),
          ):GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 200 ),
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
              },
              child: Padding(
                padding: const EdgeInsets.only(top:10),
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      child: SvgPicture.asset(
                        "assets/icons/usuario2.svg",
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                    "Perfil",
                    style: TextStyle(
                            color: Theme.of(context).hintColor, fontSize: 10, fontFamily: 'Roboto'
                          ),
                  )
                  ],
                ),
              ),
            ),
        ),
      ],
    );
  }

  void getData() async{
    
    var listaN = await fetchCountNotify();

    if(mounted){
      setState(() {
        totalNotificaciones = listaN[0].total;
      });
    }
  }

}
