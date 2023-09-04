import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatapis.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
//import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../components/AppBarPosterior.dart';
import '../../../components/AppBarSuperior.dart';
import '../../../components/backgroundB.dart';
import 'chatscreen.dart';

class ChatPage extends StatefulWidget {
  final String? tripId;
  final String? tipoViaje;

  const ChatPage({Key? key, this.tripId, this.tipoViaje}) : super(key: key);
  
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var chatUsers;
  var chatUsers2;
  bool cargarM = false;
  bool confirmados = true;
  bool noconfirmados = false;
  bool cancelados = false;
  int totalConfirmados = 0;
  int totalNoConfirmados = 0;
  int totalCancelados = 0;
  int? idMotorista;
  String? nombreMotorista;

  @override
  void initState() {
    super.initState();
    getCounterNotification(widget.tripId!);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {    
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  void getCounterNotification(String tripId) async {
    totalConfirmados = 0;
    totalNoConfirmados = 0;
    totalCancelados = 0;
    
    http.Response responses = await http.get(Uri.parse('https://apichat.smtdriver.com/api/mensajes/$tripId'));
    var getData = json.decode(responses.body);

    if (getData.isNotEmpty) {

      chatUsers = getData['Agentes'];
      chatUsers2 = chatUsers;
      idMotorista = getData['Motorista']['Id'];
      nombreMotorista = getData['Motorista']['Nombre'];

      for(var i=0;i<chatUsers.length;i++){
        
        if(chatUsers[i]['Estado']=='CONFIRMADO')
          totalConfirmados++;
        else if(chatUsers[i]['Estado']=='RECHAZADO')
          totalCancelados++;
        else 
          totalNoConfirmados++;
      }

    }
    cargarM = true;
    setState(() {});

  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {


    Navigator.of(context).pop();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BackgroundBody(
      child: Scaffold(
        backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: AppBarSuperior(item: 66)
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

  Widget opcionesBotones() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),

                elevation: 0,
                backgroundColor: confirmados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 5),
                  Text('Confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: confirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                
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
                              '$totalConfirmados',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, color: confirmados == false ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark)
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
                  cancelados = false;
                });
              },
            ),
    
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: TextButton(
                style: TextButton.styleFrom(
                  side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                  elevation: 0,
                  backgroundColor: noconfirmados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 5),
                    Text('No confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: noconfirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                  
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
                                '$totalNoConfirmados',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, color: noconfirmados == false ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark)
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
                    cancelados = false;
                  });
                },
              ),
            ),
    
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                elevation: 0,
                backgroundColor: cancelados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 5),
                    Text('Cancelados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: cancelados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                  
                    SizedBox(width: 5),
                    
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cancelados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                '$totalCancelados',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, color: cancelados == false ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark)
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              onPressed: cancelados==true?null:() {
                setState(() {
                  confirmados = false;
                  noconfirmados = false;
                  cancelados = true;
                });
              },
            ),
          ],
        ),
    );
  }

  SingleChildScrollView body() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: cargarM == true? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          
          if(this.widget.tipoViaje=='Entrada')
            opcionesBotones(),
          SizedBox(height: 10.0),
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
                        chatUsers = chatUsers2.where((element) => element['Nombre'].toString().toLowerCase().contains(value.toLowerCase())).toList();
                        setState(() {});
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
                      getCounterNotification(widget.tripId!);
                    },
                  )
                ],
              )
            ),
          ListView.builder(
            itemCount: chatUsers.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 8),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (this.widget.tipoViaje == 'Entrada') {
                if (confirmados == true) {
                  
                  if (chatUsers[index]['Estado'] == 'CONFIRMADO') {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: contenido(
                        chatUsers[index]['Nombre'],
                        chatUsers[index]['Id'],
                        chatUsers[index]['TiempoUltimoM'],
                        chatUsers[index]['mensajes'].isEmpty
                            ? chatUsers[index]['mensajes']
                            : chatUsers[index]['mensajes'][0],
                        chatUsers[index]['sinleer_Motorista'],
                        chatUsers[index]['esMotorista'],
                        chatUsers[index]['ultimoM'],
                        chatUsers[index]['Tipo'],
                      ),
                    );
                  }else return SizedBox();
                } else if (cancelados == true) {

                  if (chatUsers[index]['Estado'] == 'RECHAZADO') {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: contenido(
                        chatUsers[index]['Nombre'],
                        chatUsers[index]['Id'],
                        chatUsers[index]['TiempoUltimoM'],
                        chatUsers[index]['mensajes'].isEmpty
                            ? chatUsers[index]['mensajes']
                            : chatUsers[index]['mensajes'][0],
                        chatUsers[index]['sinleer_Motorista'],
                        chatUsers[index]['esMotorista'],
                        chatUsers[index]['ultimoM'],
                        chatUsers[index]['Tipo'],
                      ),
                    );
                  }else return SizedBox();
                } else {
                  if (chatUsers[index]['Estado'] != 'RECHAZADO' &&
                      chatUsers[index]['Estado'] != 'CONFIRMADO') {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: contenido(
                        chatUsers[index]['Nombre'],
                        chatUsers[index]['Id'],
                        chatUsers[index]['TiempoUltimoM'],
                        chatUsers[index]['mensajes'].isEmpty
                            ? chatUsers[index]['mensajes']
                            : chatUsers[index]['mensajes'][0],
                        chatUsers[index]['sinleer_Motorista'],
                        chatUsers[index]['esMotorista'],
                        chatUsers[index]['ultimoM'],
                        chatUsers[index]['Tipo'],
                      ),
                    );
                  }else return SizedBox();
                }
              } else {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: contenido(
                    chatUsers[index]['Nombre'],
                    chatUsers[index]['Id'],
                    chatUsers[index]['TiempoUltimoM'],
                    chatUsers[index]['mensajes'].isEmpty
                        ? chatUsers[index]['mensajes']
                        : chatUsers[index]['mensajes'][0],
                    chatUsers[index]['sinleer_Motorista'],
                    chatUsers[index]['esMotorista'],
                    chatUsers[index]['ultimoM'],
                    chatUsers[index]['Tipo'],
                  ),
                );
              }
            },
          ),
        ],
      ): WillPopScope(
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

  Widget contenido(String nombre, int idAg, String hora, var mensaje, int cantSinLeer, bool esMotorista, String ultimoM, String tipo){
    return mensaje.isNotEmpty? GestureDetector(
                    onTap: () {
                       Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
                                      pageBuilder: (_, __, ___) => ChatScreen(
                                        idAgent: idAg.toString(),
                                        nombreAgent: nombre,
                                        nombre: "$nombreMotorista",
                                        id: '$idMotorista',
                                        rol: "MOTORISTA",
                                        tipoViaje: this.widget.tipoViaje,
                                      ),
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
                      padding: const EdgeInsets.only(top:20),
                      child: Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              "assets/images/perfil-usuario-general.png",
                            ),
                          ),
                    
                          Positioned(
                            left: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$nombre',
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13),
                                ),
                                Text(
                                  '# de agente: $idAg',
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
            
                          Positioned(
                            left: 60,
                            bottom: 5,
                            child: esMotorista == true ?
                                  Row(
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 15,
                                        child: SvgPicture.asset(
                                          "assets/icons/ignorado.svg",
                                          color: mensaje['Leido'] == true?Theme.of(context).focusColor
                                            :Theme.of(context).splashColor,
                                        ),
                                      ),
                                      Text(
                                        tipo=='AUDIO'? 'Tu: Mensaje de voz':' Tu: $ultimoM',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ):
                                  Text(
                                    tipo=='AUDIO'? 'Mensaje de voz': '$ultimoM',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
                                  ),
                          ),
                                if (cantSinLeer!= 0)
                                  Positioned(
                                    right: 0,
                                    bottom: 5,
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$cantSinLeer',
                                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 9),
                                      ),
                                    ),
                                  ),
            
                          Positioned(
                            right: 0,
                            child: Text(
                                    '$hora',
                                    style: cantSinLeer != 0? 
                                      Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 12):
                                      Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12)
                                    ,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ): GestureDetector(
                    onTap: () {
                       Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
                                      pageBuilder: (_, __, ___) => ChatScreen(
                                        idAgent: idAg.toString(),
                                        nombreAgent: nombre,
                                        nombre: "$nombreMotorista",
                                        id: '$idMotorista',
                                        rol: "MOTORISTA",
                                        tipoViaje: this.widget.tipoViaje,
                                      ),
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
                      padding: const EdgeInsets.only(top:20),
                      child: Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              "assets/images/perfil-usuario-general.png",
                            ),
                          ),
                    
                          Positioned(
                            left: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$nombre',
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13),
                                ),
                                Text(
                                  '# de agente: $idAg',
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
            
                          Positioned(
                            left: 60,
                            bottom: 5,
                            child: esMotorista == true ?
                                  Row(
                                    children: [
                                      Text(
                                        '',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ):
                                  Text(
                                    '',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
                                  ),
                          ),
                                if (cantSinLeer!= 0)
                                  Positioned(
                                    right: 0,
                                    bottom: 5,
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$cantSinLeer',
                                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 9),
                                      ),
                                    ),
                                  ),
            
                          Positioned(
                            right: 0,
                            child: Text(
                                    '$hora',
                                    style: cantSinLeer != 0? 
                                      Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 12):
                                      Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12)
                                    ,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
  }
}
