import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/AgentTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/agentsInTravelModel.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../components/AppBarPosterior.dart';
import '../../../../components/AppBarSuperior.dart';
import '../../../../components/backgroundB.dart';
import '../../../../constants.dart';

void main() {
  runApp(MyFinishedTrips());
}

class MyFinishedTrips extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;

  const MyFinishedTrips({Key? key, this.plantillaDriver}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<MyFinishedTrips> {
  bool checkBoxValue = false;
  final format = DateFormat("HH:mm");
  Future<TripsList3>? item;
  Future<TripsList2>? itemx;
  bool confirmados = true;
  bool noconfirmados = false;
  var datos;

  @override
  void initState() {
    super.initState();
    item = fetchAgentsCompleted();
    itemx = fetchAgentsInTravel2();
    getData();
  }

  void getData() async{
    
    await fetchAgentsCompleted().then((value) => {
      datos = value.trips,      
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBody(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: AppBarSuperior(item: 44,)
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: body()),
                      ),
                      SafeArea(child: AppBarPosterior(item:-1)),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
        child: ListView(children: <Widget>[
        opcionesBotones(),
        SizedBox(height: 10.0),

        if(confirmados)
          _agentToConfirm(),

        if(noconfirmados)
          _agentToCancel(),

        SizedBox(height: 20.0),
      ]),
    );
  }

  Widget opcionesBotones() {
    return datos!=null? Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1
        ) 
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0, bottom: 2, right: 8, left: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
              
                    elevation: 0,
                    backgroundColor: confirmados!=true?Colors.transparent:Theme.of(context).unselectedWidgetColor,
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, color: confirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                      
                      SizedBox(width: 5),
                      
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: confirmados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '${datos[0].inTrip!.length}',
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: confirmados == true ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight, fontSize: 9)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: confirmados==true?null:() {
                    setState(() {
                      confirmados = true;
                      noconfirmados = false;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    elevation: 0,
                    backgroundColor: noconfirmados!=true?Colors.transparent:Theme.of(context).unselectedWidgetColor,
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Cancelados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, color: noconfirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                    
                      SizedBox(width: 5),
                  
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: noconfirmados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '${datos[1].cancelAgent!.length}',
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: noconfirmados == true ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight, fontSize: 9)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: noconfirmados==true?null:() {
                    setState(() {
                      confirmados = false;
                      noconfirmados = true;
                    });
                  },
                ),
              ),
          
            ],
          ),
      ),
    ):
    WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  launchSalidasMaps(lat,lng)async{
    String destination = '$lat,$lng';
    String url = 'google.navigation:q=$destination&mode=d';
    await launchUrl(Uri.parse(url));
  }

  Widget _agentToConfirm() {
    return FutureBuilder<TripsList3>(
      future: item,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![0].inTrip!.length == 0) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1
                ) // Radio de la esquina
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset( 
                      "assets/icons/advertencia.svg",
                      color: Theme.of(context).primaryIconTheme.color,
                      width: 18,
                      height: 18,
                    ),
                    Flexible(
                      child: Text(
                          '  No hay agentes confirmados para este viaje',
                          style: TextStyle(
                            color: Color.fromRGBO(213, 0, 0, 1),
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0
                          )
                        ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return FutureBuilder<TripsList3>(
              future: item,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: abc.data!.trips![0].inTrip!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Theme.of(context).dividerColor,),
                          ),
                          child: ExpansionTile(
                            iconColor: Theme.of(context).focusColor,
                            tilePadding: const EdgeInsets.only(right: 10, left: 10),
                              title: Column(
                              children: [

                                SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10, left: 10),
                                  child: Row(
                                    children: [
                                      
                                      abc.data!.trips![0].inTrip![index].traveled == 1 
                                      ? Container(
                                        width: 18,
                                        height: 18,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromRGBO(0, 191, 95, 1), // Borde blanco
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: SvgPicture.asset(
                                            "assets/icons/check.svg",
                                            color: Colors.white,
                                            width: 2,
                                            height: 2,
                                          ),
                                        ),
                                      ):
                                      Container(
                                        width: 18,
                                        height: 18,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromRGBO(178, 13, 13, 1), // Borde blanco
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Center(child: Text('X', style: TextStyle(color: Colors.white, fontSize: 12))),
                                        ),
                                      )
                                      ,
                                              SizedBox(width: 10),
                                              Flexible(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Nombre: ',
                                                        style: TextStyle(fontWeight: FontWeight.w500),
                                                      ),
                                                      TextSpan(
                                                        text: '${abc.data!.trips![0].inTrip![index].agentFullname}',
                                                        style: TextStyle(fontWeight: FontWeight.normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )                   
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20),
                                        Padding(
                                            padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                          width: 18,
                                                          height: 18,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/hora.svg",
                                                            color: Theme.of(context).primaryIconTheme.color,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Flexible(
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Hora de encuentro: ',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                                TextSpan(
                                                                  text: abc.data!.trips![0].inTrip![index].hourForTrip==null?' --':
                                                                  '${abc.data!.trips![0].inTrip![index].hourForTrip}',
                                                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
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
                                        color: Theme.of(context).dividerColor,
                                      ),

                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/Casa.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Dirección: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: '${abc.data!.trips![0].inTrip![index].agentReferencePoint} ${abc.data!.trips![0].inTrip![index].neighborhoodName} ${abc.data!.trips![0].inTrip![index].districtName}',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),

                                      if (abc.data!.trips![0].inTrip![index].neighborhoodReferencePoint != null)... {
                                        Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        SizedBox(height: 20),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                          child: Row(
                                            children: [
                                              Container(
                                                        width: 18,
                                                        height: 18,
                                                        child: SvgPicture.asset(
                                                          "assets/icons/warning.svg",
                                                          color: Theme.of(context).primaryIconTheme.color,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Flexible(
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                            children: [
                                                              TextSpan(
                                                                text: 'Acceso autorizado: ',
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              TextSpan(
                                                                text: '${abc.data!.trips![0].inTrip![index].neighborhoodReferencePoint}',
                                                                style: TextStyle(fontWeight: FontWeight.normal),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )                   
                                            ],
                                          ),
                                        ),
                                }
                              ],
                            ),
                              trailing: SizedBox(),
                              children: [
                                
                              Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                            padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                          width: 18,
                                                          height: 18,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/hora.svg",
                                                            color: Theme.of(context).primaryIconTheme.color,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Flexible(
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Entrada: ',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                                TextSpan(
                                                                  text: '${abc.data!.trips![0].inTrip![index].hourIn}',
                                                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )                   
                                              ],
                                            ),
                                          ),
                                          Padding(
                                        padding: const EdgeInsets.only(right: 10, left: 10),
                                        child: Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),

                              
                              SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/telefono_num.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          launchUrl(Uri.parse(
                                                            'tel://${abc.data!.trips![0].inTrip![index].agentPhone}',
                                                          ));
                                                        },
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                            children: [
                                                              TextSpan(
                                                                text: 'Teléfono: ',
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              TextSpan(
                                                                text: '${abc.data!.trips![0].inTrip![index].agentPhone}',
                                                                style: TextStyle(fontWeight: FontWeight.normal),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10, left: 10),
                                        child: Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),

                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/compania.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Empresa: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: '${abc.data!.trips![0].inTrip![index].companyName}',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ), 
                                      SizedBox(height: 20.0),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                                          fixedSize: Size(150, 25),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async{
                                          showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        backgroundColor:
                                                            backgroundColor,
                                                        content: Container(
                                                          width: 400,
                                                          height: 200,
                                                          child: Column(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                  height: 15),
                                                              if (abc
                                                                      .data
                                                                      !.trips![0]
                                                                      .inTrip![
                                                                          index]
                                                                      .commentDriver ==
                                                                  null) ...{
                                                                Center(
                                                                    child: Text(
                                                                  'Observación',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                                Text('')
                                                              } else ...{
                                                                Center(
                                                                  child: Text(
                                                                    'Observación',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            thirdColor),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 15),
                                                                Center(
                                                                  child: Text(
                                                                    '${abc.data!.trips![0].inTrip![index].commentDriver}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              },
                                                              SizedBox(
                                                                  height: 21),
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              backgroundColor, // foreground
                                                                        ),
                                                                        // foreground
                                                                        backgroundColor:
                                                                            firstColor),
                                                                onPressed: () =>
                                                                    {
                                                                  setState(() {
                                                                    Navigator.pop(
                                                                        context);
                                                                  }),
                                                                },
                                                                child: Text(
                                                                    'Entendido',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            backgroundColor)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ));                                
                                        },
                                        child: Text('Observaciones',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(height: 10.0),
                                      // Usamos una fila para ordenar los botones del card
                              ],
                            ),
                          ),
                        );
                    });
              },
            );
          }
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
    );
  }

  Widget _agentToCancel() {
    return FutureBuilder<TripsList2>(
      future: itemx,
      builder: (BuildContext context, abc) {
        if (abc.connectionState == ConnectionState.done) {
          if (abc.data!.trips![2].cancelados!.length == 0) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1
                ) // Radio de la esquina
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset( 
                      "assets/icons/advertencia.svg",
                      color: Theme.of(context).primaryIconTheme.color,
                      width: 18,
                      height: 18,
                    ),
                    Flexible(
                      child: Text(
                          '  No hay agentes cancelados para este viaje',
                          style: TextStyle(
                            color: Color.fromRGBO(213, 0, 0, 1),
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0
                          )
                        ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return FutureBuilder<TripsList3>(
              future: item,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: abc.data!.trips![2].cancelados!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Theme.of(context).dividerColor,),
                          ),
                          child: ExpansionTile(
                            iconColor: Theme.of(context).focusColor,
                            tilePadding: const EdgeInsets.only(right: 10, left: 10),
                              title: Column(
                              children: [

                                SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10, left: 10),
                                  child: Row(
                                    children: [
                                      
                                      abc.data!.trips![2].cancelados![index].traveled == 1 
                                      ? Container(
                                        width: 18,
                                        height: 18,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromRGBO(0, 191, 95, 1), // Borde blanco
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: SvgPicture.asset(
                                            "assets/icons/check.svg",
                                            color: Colors.white,
                                            width: 2,
                                            height: 2,
                                          ),
                                        ),
                                      ):
                                      Container(
                                        width: 18,
                                        height: 18,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromRGBO(178, 13, 13, 1), // Borde blanco
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Center(child: Text('X', style: TextStyle(color: Colors.white, fontSize: 12))),
                                        ),
                                      )
                                      ,
                                              SizedBox(width: 10),
                                              Flexible(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                    children: [
                                                      TextSpan(
                                                        text: 'Nombre: ',
                                                        style: TextStyle(fontWeight: FontWeight.w500),
                                                      ),
                                                      TextSpan(
                                                        text: '${abc.data!.trips![2].cancelados![index].agentFullname}',
                                                        style: TextStyle(fontWeight: FontWeight.normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )                   
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20),
                                        Padding(
                                            padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                          width: 18,
                                                          height: 18,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/hora.svg",
                                                            color: Theme.of(context).primaryIconTheme.color,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Flexible(
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Hora de encuentro: ',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                                TextSpan(
                                                                  text: abc.data!.trips![2].cancelados![index].hourForTrip==null?' --':
                                                                  '${abc.data!.trips![2].cancelados![index].hourForTrip}',
                                                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
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
                                        color: Theme.of(context).dividerColor,
                                      ),

                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/Casa.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Dirección: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: '${abc.data!.trips![2].cancelados![index].agentReferencePoint} ${abc.data!.trips![2].cancelados![index].neighborhoodName} ${abc.data!.trips![2].cancelados![index].districtName}',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),

                                      if (abc.data!.trips![2].cancelados![index].neighborhoodReferencePoint != null)... {
                                        Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        SizedBox(height: 20),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                          child: Row(
                                            children: [
                                              Container(
                                                        width: 18,
                                                        height: 18,
                                                        child: SvgPicture.asset(
                                                          "assets/icons/warning.svg",
                                                          color: Theme.of(context).primaryIconTheme.color,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Flexible(
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                            children: [
                                                              TextSpan(
                                                                text: 'Acceso autorizado: ',
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              TextSpan(
                                                                text: '${abc.data!.trips![2].cancelados![index].neighborhoodReferencePoint}',
                                                                style: TextStyle(fontWeight: FontWeight.normal),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )                   
                                            ],
                                          ),
                                        ),
                                }
                              ],
                            ),
                              trailing: SizedBox(),
                              children: [
                                
                              Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                            padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                          width: 18,
                                                          height: 18,
                                                          child: SvgPicture.asset(
                                                            "assets/icons/hora.svg",
                                                            color: Theme.of(context).primaryIconTheme.color,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Flexible(
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Entrada: ',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                                TextSpan(
                                                                  text: '${abc.data!.trips![2].cancelados![index].hourIn}',
                                                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )                   
                                              ],
                                            ),
                                          ),
                                          Padding(
                                        padding: const EdgeInsets.only(right: 10, left: 10),
                                        child: Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),

                              
                              SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/telefono_num.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          launchUrl(Uri.parse(
                                                            'tel://${abc.data!.trips![2].cancelados![index].agentPhone}',
                                                          ));
                                                        },
                                                        child: RichText(
                                                          text: TextSpan(
                                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                            children: [
                                                              TextSpan(
                                                                text: 'Teléfono: ',
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              TextSpan(
                                                                text: '${abc.data!.trips![2].cancelados![index].agentPhone}',
                                                                style: TextStyle(fontWeight: FontWeight.normal),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10, left: 10),
                                        child: Container(
                                          height: 1,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),

                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 20, bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                                      width: 18,
                                                      height: 18,
                                                      child: SvgPicture.asset(
                                                        "assets/icons/compania.svg",
                                                        color: Theme.of(context).primaryIconTheme.color,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Flexible(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Empresa: ',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ),
                                                            TextSpan(
                                                              text: '${abc.data!.trips![2].cancelados![index].companyName}',
                                                              style: TextStyle(fontWeight: FontWeight.normal),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )                   
                                          ],
                                        ),
                                      ),
                                      Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10),
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ), 
                                      SizedBox(height: 20.0),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                                          fixedSize: Size(150, 25),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async{
                                          showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        backgroundColor:
                                                            backgroundColor,
                                                        content: Container(
                                                          width: 400,
                                                          height: 200,
                                                          child: Column(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                  height: 15),
                                                              if (abc
                                                                      .data
                                                                      !.trips![2]
                                                                      .cancelados![
                                                                          index]
                                                                      .commentDriver ==
                                                                  null) ...{
                                                                Center(
                                                                    child: Text(
                                                                  'Observación',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                                Text('')
                                                              } else ...{
                                                                Center(
                                                                  child: Text(
                                                                    'Observación',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            thirdColor),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 15),
                                                                Center(
                                                                  child: Text(
                                                                    '${abc.data!.trips![2].cancelados![index].commentDriver}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              },
                                                              SizedBox(
                                                                  height: 21),
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              backgroundColor, // foreground
                                                                        ),
                                                                        // foreground
                                                                        backgroundColor:
                                                                            firstColor),
                                                                onPressed: () =>
                                                                    {
                                                                  setState(() {
                                                                    Navigator.pop(
                                                                        context);
                                                                  }),
                                                                },
                                                                child: Text(
                                                                    'Entendido',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            backgroundColor)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ));                                
                                        },
                                        child: Text('Observaciones',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(height: 10.0),
                                      // Usamos una fila para ordenar los botones del card
                              ],
                            ),
                          ),
                        );
                    });
              },
            );
          }
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
    );
  }


}