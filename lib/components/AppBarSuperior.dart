
import 'package:flutter/material.dart';
import 'package:flutter_auth/components/progress_indicator.dart';
import 'package:flutter_auth/main.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quickalert/quickalert.dart';

import '../Drivers/Screens/Details/components/detailsDriver_assignHour.dart';
import '../Drivers/Screens/Details/components/details_HoursOut.dart';
import '../Drivers/Screens/Details/components/details_TripProgress.dart';
import '../Drivers/Screens/Details/components/details_history.dart';
import '../Drivers/Screens/DriverProfile/driverProfile.dart';
import '../Drivers/Screens/HomeDriver/components/itemDriver_Card.dart';
import '../Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import '../Drivers/Screens/Welcome/welcome_screen.dart';
import '../Drivers/SharePreferences/preferencias_usuario.dart';
import '../Drivers/models/network.dart';
import '../Drivers/models/plantillaDriver.dart';



class AppBarSuperior extends StatefulWidget {
  final int? item;

  AppBarSuperior({this.item});

  @override
  _AppBarSuperior createState() => _AppBarSuperior(item: item);
}

class _AppBarSuperior extends State<AppBarSuperior> {
  int? item;
  final prefs = new PreferenciasUsuario();

  _AppBarSuperior({this.item});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white, size: 25),
      automaticallyImplyLeading: false, 
      actions: <Widget>[

        item!=0?Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 200),
                    pageBuilder: (_, __, ___) => HomeDriverScreen(),
                    transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(-1.0, 0.0), // Cambiar Offset de inicio a (1.0, 0.0)
                          end: Offset.zero, // Mantener Offset de final en (0.0, 0.0)
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
            },
            child: Container(
              width: 45,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/icons/flecha_atras_oscuro.svg",
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ):Padding(
          padding: const EdgeInsets.all(8.0),
          child: menu(size, context),
        ),

        if(item==0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Container(
                width: 110,
                height: 110,
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
          ),

        if(item==1)
          Expanded(
            child: Center(
              child: Text(
                "Datos personales",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 21
                ),
              ),
            ),
          ),

          if(item==2)
          Expanded(
            child: Center(
              child: Text(
                "Próximos viajes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 21
                ),
              ),
            ),
          ),

          if(item==3)
          Expanded(
            child: Center(
              child: Text(
                "Historial de viajes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 21
                ),
              ),
            ),
          ),

          if(item==4)
          Expanded(
            child: Center(
              child: Text(
                "Código QR",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 21
                ),
              ),
            ),
          ),

          if(item==5)
          Expanded(
            child: Center(
              child: Text(
                "Solicitud de cambios",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 21
                ),
              ),
            ),
          ),

          if(item==6)
          Expanded(
            child: Center(
              child: Text(
                "Salas",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 21
                ),
              ),
            ),
          ),

          if(item==7)
          Expanded(
            child: Center(
              child: Text(
                "Solicitudes Enviadas",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 21
                ),
              ),
            ),
          ),

          if(item==8)
          Expanded(
            child: Center(
              child: Text(
                "Notificaciones",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 21
                ),
              ),
            ),
          ),

        item==0?Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 0.5,
                  ),
                borderRadius: BorderRadius.circular(10.0),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (_, __, ___) => DriverProfilePage(),
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
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      "assets/icons/usuario.svg",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 10,
                  height: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(0, 255, 85, 1),
                          border: Border.all(color: Colors.black, width: 0.5),
                    )),
              ),
          ],
        ):Padding(
          padding: const EdgeInsets.all(8.0),
          child: menu(size, navigatorKey.currentContext),
        )
        
      ],
    );
  }

  Container menu(size, contextP) {
    return Container(
      width: 45,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 0.5,
        ),
      borderRadius: BorderRadius.circular(10.0),
      ),
      child: IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.white,
        ),
        onPressed: () {
          showGeneralDialog(
            barrierColor: Colors.black.withOpacity(0.6),
            transitionBuilder: (context, a1, a2, widget) {
              final curvedValue = Curves.easeInOut.transform(a1.value);
              return Transform.translate(
                offset: Offset(0.0, (1 - curvedValue) * size.height / 2),
                child: Opacity(
                  opacity: a1.value,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(

                      width: size.width,
                      decoration: BoxDecoration(
                        color: prefs.tema ? Color.fromRGBO(47, 46, 65, 1) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 120, left: 120, top: 15, bottom: 20),
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(contextP).dividerColor,
                                      borderRadius: BorderRadius.circular(80)
                                    ),
                                    height: 6,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      navigatorKey.currentContext!,
                                      PageRouteBuilder(
                                        transitionDuration: Duration(milliseconds: 200),
                                        pageBuilder: (_, __, ___) => DriverProfilePage(),
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
                                                "assets/icons/usuario.svg",
                                                color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                              ),
                                            ),
                                            Text(
                                              ' Mi perfil',
                                              style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/flechader.svg",
                                          color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      navigatorKey.currentContext!,
                                      PageRouteBuilder(
                                        transitionDuration: Duration(milliseconds: 200),
                                        pageBuilder: (_, __, ___) => DetailsDriverHour(
                                                          plantillaDriver:
                                                              plantillaDriver[0],
                                                        ),
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
                                                color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                              ),
                                            ),
                                            Text(' Asignar horas de encuentro', 
                                              style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/flechader.svg",
                                          color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                             SizedBox(height: 18),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      navigatorKey.currentContext!,
                                      PageRouteBuilder(
                                        transitionDuration: Duration(milliseconds: 200),
                                        pageBuilder: (_, __, ___) => DetailsDriverTripInProgress(
                                                          plantillaDriver:
                                                              plantillaDriver[1],
                                                        ),
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
                                                color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                              ),
                                            ),
                                            Text(' Viajes en proceso', 
                                              style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/flechader.svg",
                                          color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      navigatorKey.currentContext!,
                                      PageRouteBuilder(
                                        transitionDuration: Duration(milliseconds: 200),
                                        pageBuilder: (_, __, ___) => DetailsDriverHoursOut(
                                                          plantillaDriver:
                                                              plantillaDriver[2],
                                                        ),
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
                                                "assets/icons/QR.svg",
                                                color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                              ),
                                            ),
                                            Text(' Registrar salidas', 
                                              style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/flechader.svg",
                                          color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              if(prefs.companyId!='7')...{
                                SizedBox(height: 18),                                                     
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                      navigatorKey.currentContext!,
                                      PageRouteBuilder(
                                        transitionDuration: Duration(milliseconds: 200),
                                        pageBuilder: (_, __, ___) => DetailsDriverHistory(
                                                          plantillaDriver:
                                                              plantillaDriver[3],
                                                        ),
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
                                                  "assets/icons/historial_de_viaje.svg",
                                                  color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                                ),
                                              ),
                                              Text(' Historial de viajes', 
                                                style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 18,
                                          height: 18,
                                          child: SvgPicture.asset(
                                            "assets/icons/flechader.svg",
                                            color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              },

                              SizedBox(height: 18),                                                     
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      showGeneralDialog(
                                        barrierColor: Colors.black.withOpacity(0.5),
                                        transitionBuilder: (context, a1, a2, widget) {
                                          return Transform.scale(
                                            scale: a1.value,
                                            child: Opacity(
                                              opacity: a1.value,
                                              child: AlertDialog(
                                                backgroundColor: Theme.of(contextP).cardColor,
                                                shape: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  borderSide: BorderSide( // Add this line to specify the border color
                                                    color: Theme.of(context).disabledColor, // Change the color to the desired color
                                                    width: 2.0, // You can also adjust the border width if needed
                                                  ),
                                                ),
                                                title: Center(
                                                    child: Text('Página disponible \n\t\t\t\tpróximamente', style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16),)),
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
                                                      child: Text('Cerrar', style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Colors.white)),
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
                                                  "assets/icons/ejecutivo.svg",
                                                  color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                                ),
                                              ),
                                              Text(' Viajes de ejecutivos', 
                                                style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 18,
                                          height: 18,
                                          child: SvgPicture.asset(
                                            "assets/icons/flechader.svg",
                                            color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              
                              SizedBox(height: 12),      
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: GestureDetector(
                                  onTap: () {
                                    
                                    Navigator.pop(context);
                                    eventBus.fire(ThemeChangeEvent(true)); // Cambia el valor de prefs.tema a true
                                    
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
                                                "assets/icons/tema.svg",
                                                color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                              ),
                                            ),
                                            Text(' Tema', 
                                              style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0), // Ajustar el padding aquí
                                              decoration: BoxDecoration(
                                                color: prefs.tema ? const Color.fromARGB(255, 34, 32, 32) : const Color.fromRGBO(158, 158, 158, 1),
                                                borderRadius: BorderRadius.circular(25.0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  AnimatedOpacity(
                                                    opacity: prefs.tema ? 0.0 : 1.0,
                                                    duration: const Duration(milliseconds: 300),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(25.0),
                                                        color: Color.fromRGBO(40, 93, 169, 1),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: SvgPicture.asset(
                                                          "assets/icons/light.svg",
                                                          color: Colors.white,
                                                          height: 10,
                                                          width: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  AnimatedOpacity(
                                                    opacity: prefs.tema ? 1.0 : 0.0,
                                                    duration: const Duration(milliseconds: 300),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(25.0),
                                                        color: Color.fromRGBO(40, 93, 169, 1),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: SvgPicture.asset(
                                                          "assets/icons/dark.svg",
                                                          color: Colors.white,
                                                          height: 10,
                                                          width: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              /*SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: GestureDetector(
                                  onTap: () {
                                    
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 25,
                                              height: 25,
                                              child: SvgPicture.asset(
                                                "assets/icons/idioma.svg",
                                                color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                              ),
                                            ),
                                            Text(' Idiomas', 
                                              style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 15,
                                        height: 15,
                                        child: SvgPicture.asset(
                                          "assets/icons/flechader.svg",
                                          color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                              
                              SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: GestureDetector(
                                  onTap: () {
                                              QuickAlert.show(
                                                context: context,
                                                title: "¿Estás seguro que deseas salir?",          
                                                type: QuickAlertType.success,
                                                confirmBtnText: 'Confirmar',
                                                cancelBtnText: 'Cancelar',
                                                showCancelBtn: true,  
                                                confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                                cancelBtnTextStyle:TextStyle(color: Colors.red, fontSize: 15, fontWeight:FontWeight.bold ), 
                                                onConfirmBtnTap:() {
                                                  LoadingIndicatorDialog().show(context);
                        
                                                  fetchDeleteSession();
                                                  prefs.remove();
                                                  
                                                  new Future.delayed(new Duration(seconds: 2), () {
                                                    LoadingIndicatorDialog().dismiss();
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    Navigator.of(contextP).pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext contextP) => WelcomeScreen()),
                                                        (Route<dynamic> route) => false);
                                                        QuickAlert.show(
                                                          context: context,
                                                          type: QuickAlertType.success,
                                                          title: "¡Hecho!",
                                                          text: "¡Gracias por usar Smart Driver!",
                                                          confirmBtnText: "Ok"
                                                        );
                                                  });
                                                },
                                                onCancelBtnTap: (() {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  /*QuickAlert.show(
                                                    context: context,
                                                    type: QuickAlertType.success,
                                                    text: "Cancelado",
                                                  );*/
                                                })
                                              );
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
                                                "assets/icons/cerrar-sesion.svg",
                                                color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                              ),
                                            ),
                                            Text(' Cerrar sesión', 
                                              style: Theme.of(contextP).textTheme.bodyMedium!.copyWith(fontSize: 16, color: prefs.tema ? Colors.white : Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/flechader.svg",
                                          color: prefs.tema ? Colors.white : const Color.fromRGBO(40, 93, 169, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20)
                            ],
                          ),
                        ),
                      ),
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
      ),
    );
      
  }

}
