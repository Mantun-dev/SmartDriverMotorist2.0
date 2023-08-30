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

                          SizedBox(height: 20),
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
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1
                        )
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.bus_alert, color: thirdColor),
                            title: Text('Calificación',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20.0)),
                            subtitle: Text('Aún no ha sido calificado',
                                style: TextStyle(
                                    color: fourthColor,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15.0)),
                          ),
                        ],
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
                          SizedBox(height: 10.0),
                          Text('Conducción',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: firstColor)),
                          SizedBox(height: 10.0),
                          Text('5 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["five1"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars1!.stars5
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars1!.stars5
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.blue),
                          Text('4 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["four1"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars1!.stars4
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars1!.stars4
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.green),
                          Text('3 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["three1"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars1!.stars3
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars1!.stars3
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.purple),
                          Text('2 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["two1"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars1!.stars2
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars1!.stars2
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.yellow),
                          Text('1 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["one1"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars1!.stars1
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars1!.stars1
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.red),
                          Divider(),
                          SizedBox(height: 30.0),
                          Text('Amabilidad',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: firstColor)),
                          SizedBox(height: 10.0),
                          Text('5 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["five2"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars2!.stars5
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars2!.stars5
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.blue),
                          Text('4 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["four2"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars2!.stars4
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars2!.stars4
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.green),
                          Text('3 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["three2"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars2!.stars3
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars2!.stars3
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.purple),
                          Text('2 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["two2"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars2!.stars2
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars2!.stars2
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.yellow),
                          Text('1 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["one2"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars2!.stars1
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars2!.stars1
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.red),
                          Divider(),
                          SizedBox(height: 30.0),
                          Text('Condiciones del vehículo',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: firstColor)),
                          SizedBox(height: 10.0),
                          Text('5 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["five3"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars3!.stars5
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars3!.stars5
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.blue),
                          Text('4 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["four3"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars3!.stars4
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars3!.stars4
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.green),
                          Text('3 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["three3"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars3!.stars3
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars3!.stars3
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.purple),
                          Text('2 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["two3"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars3!.stars2
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars3!.stars2
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.yellow),
                          Text('1 Estrellas',
                              style: TextStyle(color: Colors.white)),
                          RoundedProgressBar(
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                              childCenter: Text(
                                  "${abc.data!.rating!["one3"]!.toInt()} ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              percent: abc.data!.percentageBars3!.stars1
                                          .toDouble() ==
                                      null
                                  ? si
                                  : abc.data!.percentageBars3!.stars1
                                      .toDouble(),
                              height: 20,
                              theme: RoundedProgressBarTheme.red),
                        ],
                      ),
                    ),
                  }
                ],
              );
            } else {
              return ColorLoader3();
            }
          },
        ),
      ),
    );
  }
}
