import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/profile.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:flutter_svg/svg.dart';

import '../../../components/AppBarPosterior.dart';
import '../../../components/AppBarSuperior.dart';
import '../../../components/backgroundB.dart';
import '../../../constants.dart';

void main() {
  runApp(DriverProfilePage());
}

class DriverProfilePage extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;
  final Profile? item;

  const DriverProfilePage({Key? key, this.plantillaDriver, this.item})
      : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<DriverProfilePage> {
  Future<Profile>? item;
  final si = 0.0;
  @override
  void initState() {
    super.initState();
    item = fetchRefresProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBody(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: AppBarSuperior(item: 7)
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child:body()),
                      ),
                      SafeArea(child: AppBarPosterior(item:-1)),
                    ],
                  ),
                ),
      ),
    );
  }


  Widget body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<Profile>(
          future: item,
          builder: (BuildContext context, abc) {
            if (abc.connectionState == ConnectionState.done) {
              print('${abc.data!.rating}');
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                      child: Column(
                        children: [

                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: Image.asset(
                                "assets/images/perfilmotorista.png",
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              '${abc.data!.driver!.driverFullname}',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3, right: 5, left: 5),
                            child: Row(
                              children: [ 
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    "assets/icons/ID.svg",
                                    color: Theme.of(context).primaryIconTheme.color,
                                  ),
                                ),
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16),
                                      children: [
                                        TextSpan(
                                          text: '  Identidad: ',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(
                                          text: '${abc.data!.driver!.driverDni}',
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
                            color: Color.fromRGBO(158, 158, 158, 1),
                          ),

                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3, right: 5, left: 5),
                            child: Row(
                              children: [ 
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    "assets/icons/usuario.svg",
                                    color: Theme.of(context).primaryIconTheme.color,
                                  ),
                                ),
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16),
                                      children: [
                                        TextSpan(
                                          text: '  Nombre: ',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(
                                          text: '${abc.data!.driver!.driverFullname}',
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
                            color: Color.fromRGBO(158, 158, 158, 1),
                          ),

                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3, right: 5, left: 5),
                            child: Row(
                              children: [ 
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    "assets/icons/telefono_num.svg",
                                    color: Theme.of(context).primaryIconTheme.color,
                                  ),
                                ),
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16),
                                      children: [
                                        TextSpan(
                                          text: '  Celular: ',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(
                                          text: '${abc.data!.driver!.driverPhone}',
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
                            color: Color.fromRGBO(158, 158, 158, 1),
                          ),

                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Puntuación',
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),

                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              '${abc.data!.rating!["driverRating"]!}',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 45, fontWeight: FontWeight.w500),
                            ),
                          ),

                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              '(${abc.data!.rating!["totalReviews"]!} opiniones)',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                            ),
                          ),

                          SizedBox(height: 10),
                          RatingBarIndicator(
                            rating: abc.data!.rating!["driverRating"]!,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 10, left: 10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/estrella.svg",
                                    color: Colors.black,
                                    height: 60,
                                    width: 60,
                                  ),
                                  SvgPicture.asset(
                                    "assets/icons/estrella.svg",
                                    color: Color.fromRGBO(255, 225, 69, 1),
                                    height: 52,
                                    width: 52,
                                  ),
                                ],
                              ),
                            ),
                            itemCount: 5,
                            itemSize: 50,
                            direction: Axis.horizontal,
                          ),          
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (abc.data!.percentageBars1!.stars5 == null ||
                      abc.data!.percentageBars2!.stars5 == null ||
                      abc.data!.percentageBars3!.stars5 == null) ...{
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
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
                                  '  Aún no ha sido calificado',
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15, color: Color.fromRGBO(213, 0, 0, 1), fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  } else ...{
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1
                        )
                      ),

                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Conducción',
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),

                          SizedBox(height: 5),
                          RatingBarIndicator(
                            rating: abc.data!.rating!["driverRating"]!,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 10, left: 10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/estrella.svg",
                                    color: Colors.black,
                                    height: 60,
                                    width: 60,
                                  ),
                                  SvgPicture.asset(
                                    "assets/icons/estrella.svg",
                                    color: Color.fromRGBO(255, 225, 69, 1),
                                    height: 52,
                                    width: 52,
                                  ),
                                ],
                              ),
                            ),
                            itemCount: 5,
                            itemSize: 50,
                            direction: Axis.horizontal,
                          ), 

                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              '4 Estrellas (30 opiniones)',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                            ),
                          ),

                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Amabilidad',
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),

                          SizedBox(height: 5),
                          RatingBarIndicator(
                            rating: abc.data!.rating!["driverRating"]!,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 10, left: 10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/estrella.svg",
                                    color: Colors.black,
                                    height: 60,
                                    width: 60,
                                  ),
                                  SvgPicture.asset(
                                    "assets/icons/estrella.svg",
                                    color: Color.fromRGBO(255, 225, 69, 1),
                                    height: 52,
                                    width: 52,
                                  ),
                                ],
                              ),
                            ),
                            itemCount: 5,
                            itemSize: 50,
                            direction: Axis.horizontal,
                          ), 

                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              '4 Estrellas (30 opiniones)',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                            ),
                          ),

                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Condiciones del vehículo',
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),

                          SizedBox(height: 5),
                          RatingBarIndicator(
                            rating: abc.data!.rating!["driverRating"]!,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 10, left: 10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/estrella.svg",
                                    color: Colors.black,
                                    height: 60,
                                    width: 60,
                                  ),
                                  SvgPicture.asset(
                                    "assets/icons/estrella.svg",
                                    color: Color.fromRGBO(255, 225, 69, 1),
                                    height: 52,
                                    width: 52,
                                  ),
                                ],
                              ),
                            ),
                            itemCount: 5,
                            itemSize: 50,
                            direction: Axis.horizontal,
                          ), 

                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              '4 Estrellas (30 opiniones)',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                            ),
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  }
                ],
              );
            } else {
              return WillPopScope(
                onWillPop: () async => false,
                child: Center(
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
