import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../../../components/AppBarPosterior.dart';
import '../../../components/AppBarSuperior.dart';
import '../../../components/backgroundB.dart';

import '../../../components/progress_indicator.dart';
import '../../SharePreferences/preferencias_usuario.dart';
import '../../models/DriverData.dart';

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

    listaChats = resp['salas'] as List<dynamic>;

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

    http.Response responses = await http.get(Uri.parse('https://apichat.smtdriver.com/api/salas/userId/${data.driverId}?estadoSala=NOFINALIZADOS'));
    var resp = json.decode(responses.body);

    listaChats = resp['salas'] as List<dynamic>;

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
    Size size = MediaQuery.of(context).size;
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
                          child: Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              border: Border.all( 
                                color: Theme.of(context).disabledColor,
                                width: 2
                              ),
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: SingleChildScrollView(child: body())
                          ),
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
                            listaB = listaChats.where((salas) => salas['NombreM'].toString().toLowerCase().contains(value.toLowerCase())).toList();
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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Theme.of(context).dividerColor,),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, left: 20),
                          child: Column(
                            children:[
    
                              SizedBox(height: 20),
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
                                              text: '${listaChats[index]['id']}',
                                              style: TextStyle(fontWeight: FontWeight.w700),
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
                                              text: getCompany(int.parse(listaChats[index]['Company'])),
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
                                              text: '${listaChats[index]['Company']}',
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
                                              text: '${getCantAgentes(listaChats[index]['Agentes'])}',
                                              style: TextStyle(fontWeight: FontWeight.w700,),
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
                                              text: 'salida',
                                              style: TextStyle(fontWeight: FontWeight.normal,),
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
    
                              SizedBox(height: 15),
                                  
                            ],
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

    return '';
  }
}