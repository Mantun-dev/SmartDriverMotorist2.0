import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;


import '../../../components/AppBarPosterior.dart';
import '../../../components/AppBarSuperior.dart';
import '../../../components/backgroundB.dart';

import '../../../components/progress_indicator.dart';
import '../../../main.dart';
import '../../SharePreferences/preferencias_usuario.dart';
import '../../models/DriverData.dart';
import 'chatViews.dart';

class ChatsList extends StatefulWidget {

  const ChatsList(
    {
      Key? key,
    }
  ): super(key: key);

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  var listaChats;
  var listaChats2;
  var listaB;
  final prefs = new PreferenciasUsuario();


  bool cargarP = false;
  



  void getData() async{
    http.Response response = await http.get(Uri.parse('https://driver.smtdriver.com/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(response.body));

    http.Response responses = await http.get(Uri.parse('https://apichat.smtdriver.com/api/salas/userId/${data.driverId}?estadoSala=NOFINALIZADOS'));
    var resp = json.decode(responses.body);

    for(var i=0;i<resp['salas'].length;i++){
      if(listaChats==null)
        listaChats=[];

      http.Response response2 = await http.get(Uri.parse('https://driver.smtdriver.com/apis/getTripDetails/${resp['salas'][i]['id']}'));
      var resp2 = json.decode(response2.body);

      listaChats.add(
        {
          'Viaje': resp['salas'][i]['id'],
          'Fecha': resp['salas'][i]['Fecha'],
          'Company': getCompany(resp['salas'][i]['Company']),
          'Hora': resp2['trip']!= null ?resp2['trip']['tripHour']:"",
          'Agentes': getCantAgentes(resp['salas'][i]['Agentes']),
          'Tipo': resp2['trip']!= null ?(resp2['trip']['tripType'] == true ? 'Entrada' : 'Salida'):""
        }
      );
    }

    listaChats2 = listaChats;

    if(mounted){
      cargarP=true;
      setState(() { });
    }
  }

  void refresh() async{
    
    LoadingIndicatorDialog().show(context);
    http.Response response = await http.get(Uri.parse('https://driver.smtdriver.com/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(response.body));
    listaChats=[];
    http.Response responses = await http.get(Uri.parse('https://apichat.smtdriver.com/api/salas/userId/${data.driverId}?estadoSala=NOFINALIZADOS'));
    var resp = json.decode(responses.body);
     
    for(var i=0;i<resp['salas'].length;i++){

      http.Response response2 = await http.get(Uri.parse('https://driver.smtdriver.com/apis/getTripDetails/${resp['salas'][i]['id']}'));
      var resp2 = json.decode(response2.body);

      listaChats.add(
        {
          'Viaje': resp['salas'][i]['id'],
          'Fecha': resp['salas'][i]['Fecha'],
          'Company': getCompany(resp['salas'][i]['Company']),
          'Hora': resp2['trip']['tripHour'],
          'Agentes': getCantAgentes(resp['salas'][i]['Agentes']),
          'Tipo': resp2['trip']['tripType'] == true ? 'Entrada' : 'Salida'
        }
      );
    }

    listaChats2 = listaChats;

    if(mounted){
      LoadingIndicatorDialog().dismiss();
      cargarP=true;
      setState(() { });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return BackgroundBody(
      child: Scaffold(
        backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: AppBarSuperior(item: 6)
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 700.0, // Aquí defines el ancho máximo deseado
                          ),
                          child: SingleChildScrollView(child: body()),
                        ),
                      )
                    ),
                    SafeArea(child: AppBarPosterior(item:3)),
                  ],
                ),
              ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: cargarP!=false?
      listaChats != null ? listaChats2.length>0 ? contenido() :
      Padding(
                padding: const EdgeInsets.only(left: 15, right: 15,bottom: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
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
                              '  No hay salas de chat actualmente',
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15, color: Color.fromRGBO(213, 0, 0, 1), fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ) : 
      Padding(
                padding: const EdgeInsets.only(left: 15, right: 15,bottom: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
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
                              '  No hay salas de chat actualmente',
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15, color: Color.fromRGBO(213, 0, 0, 1), fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ):WillPopScope(
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
                                  'Cargando...', 
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                  ),
                              )
                            ],
                          ),
                        )
                      ] ,
                    ),
                  ),
    );
  }

  Widget contenido() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Theme.of(context).disabledColor)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged:(value) {
                        listaChats=listaChats2;
                        setState(() {
                              
                          if(value.isNotEmpty){
                            listaB = listaChats.where((salas) =>
                              salas['Viaje'].toString().toLowerCase().contains(value.toLowerCase()) 
                              || salas['Company'].toString().toLowerCase().contains(value.toLowerCase()) 
                              || salas['Fecha'].toString().toLowerCase().contains(value.toLowerCase()) 
                              || salas['Tipo'].toString().toLowerCase().contains(value.toLowerCase()) 
                              || salas['Hora'].toString().toLowerCase().contains(value.toLowerCase()) 
                            ).toList();
                            listaChats = listaB;
                          }
                            
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryIconTheme.color),
                        hintText: 'Buscar',
                        hintStyle: TextStyle(
                            color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto'
                          ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.refresh),
                    color: Theme.of(context).primaryIconTheme.color,
                    onPressed: () {
                      refresh();
                    },
                  )
                ],
              )
            ),
    
            listaChats != null ?
            SingleChildScrollView(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: listaChats.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            navigatorKey.currentContext!,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 200),
                              pageBuilder: (_, __, ___) => ChatPage(tripId: listaChats[index]['Viaje'].toString(), tipoViaje: listaChats[index]['Tipo']),
                              transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(1.0, 0.0),
                                    end: Offset.zero, // Mantener Offset de final en (0.0, 0.0)
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Theme.of(context).dividerColor,),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: Column(
                              children:[
                          
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                  child: Row(
                                    children: [ 
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/Numeral.svg",
                                          color: Theme.of(context).primaryIconTheme.color,
                                        ),
                                      ),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                            children: [
                                              TextSpan(
                                                text: '  Viaje: ',
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: '${listaChats[index]['Viaje']}',
                                                style: TextStyle(fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                      
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
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
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                            children: [
                                              TextSpan(
                                                text: '  Empresa: ',
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: listaChats[index]['Company'],
                                                style: TextStyle(fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/calendar2.svg",
                                          color: Theme.of(context).primaryIconTheme.color,
                                        ),
                                      ),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                            children: [
                                              TextSpan(
                                                text: '  Fecha: ',
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: '${listaChats[index]['Fecha']}',
                                                style: TextStyle(fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          
                                SizedBox(height: 10),
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
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                            children: [
                                              TextSpan(
                                                text: '  Hora: ',
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: '${listaChats[index]['Hora']}',
                                                style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/agentes.svg",
                                          color: Theme.of(context).primaryIconTheme.color,
                                        ),
                                      ),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                            children: [
                                              TextSpan(
                                                text: '  Agentes: ',
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: '${listaChats[index]['Agentes']}',
                                                style: TextStyle(fontWeight: FontWeight.w700,),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: SvgPicture.asset(
                                          "assets/icons/advertencia.svg",
                                          color: Theme.of(context).primaryIconTheme.color,
                                        ),
                                      ),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                            children: [
                                              TextSpan(
                                                text: '  Tipo: ',
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: '${listaChats[index]['Tipo']}',
                                                style: TextStyle(fontWeight: FontWeight.normal,),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          
                                SizedBox(height: 10),
                                    
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ):WillPopScope(
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
                                  'Cargando..', 
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                  ),
                              )
                            ],
                          ),
                        )
                      ] ,
                    ),
                  ),
    
          ],
        );
  }

  int getCantAgentes(listaAgente){
    return listaAgente.length;
  }

  String getCompany(int idCompany){
    final String comp = "Company";
    final String comp2 = "Company 2";
    final String ibexTgu = "IBEX TGU";
    final String resultTgu = "RESULT TGU";
    final String partner = "PARTNER HERO TGU";
    final String startekSPS = "Startek SPS";
    final String starteTGU = "Startek TGU";
    final String aloricaSPS = "Alorica SPS";
    final String zerovarianceSPS = "Zero Variance SPS";

    if (idCompany == 1) {
      return comp;
    } else if (idCompany == 2) {
      return startekSPS;
    } else if (idCompany == 3) {
      return starteTGU;
    } else if (idCompany == 6) {
      return aloricaSPS;
    } else if (idCompany == 7) {
      return zerovarianceSPS;
    } else if (idCompany == 5) {
      return comp2;
    } else if (idCompany == 9) {
      return ibexTgu;
    } else if (idCompany == 11) {
      return resultTgu;
    } else if (idCompany == 12) {
      return partner;
    }
    return ' Compaña desconocida';
  }
}