import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatViews.dart';

import 'package:flutter_auth/Drivers/Screens/Chat/chatapis.dart';

import 'package:flutter_auth/constants.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../helpers/base_client.dart';
import '../../../helpers/res_apis.dart';
import '../../../providers/chat.dart';
import '../../SharePreferences/preferencias_usuario.dart';
import '../../models/message_chat.dart';
//import '../Details/components/agents_Trip.dart';
import '../DriverProfile/driverProfile.dart';
//import 'package:intl/intl.dart';

import 'socketChat.dart';

class ChatScreen extends StatefulWidget {
  final String? nombre;
  final String? id;
  final String? rol;
  final String? nombreAgent;
  final String? idAgent;
  const ChatScreen(
      {Key? key, this.nombre, this.id, this.rol, this.nombreAgent, this.idAgent})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

  int recargar = -1;

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  // final _socketResponse = StreamController<dynamic>();
  // Stream<dynamic> get getResponse => _socketResponse.stream;
  IO.Socket? socket;
  final prefs = new PreferenciasUsuario();
  final TextEditingController _messageInputController = TextEditingController();
  var usuario = {};
  var arrayStructure = [];
  var idE;
  var idR;
  String? sala;
  String? idDriver;
  String? idDb;
  String? nameDriver;
  String? nameAgent;
  bool isloading = false;
  ScrollController _scrollController = new ScrollController();
  final arrayTemp = [];
  final StreamSocket streamSocket = StreamSocket(host: 'wschat.smtdriver.com');

  _sendMessage() {    
    ChatApis().sendMessage(_messageInputController.text.trim(), sala.toString(),
        nameAgent!, widget.id!, nameDriver!, idDb!, widget.idAgent!);
    // DateTime now = DateTime.now();
    // String formattedHour = DateFormat('hh:mm a').format(now);
    // var formatter = new DateFormat('dd');
    // String dia = formatter.format(now);
    // var formatter2 = new DateFormat('MM');
    // String mes = formatter2.format(now);
    // var formatter3 = new DateFormat('yy');
    // String anio = formatter3.format(now);
    // Provider.of<ChatProvider>(context, listen: false).addNewMessage(
    //   MessageDriver.fromJson({
    //     'mensaje': _messageInputController.text.trim(),
    //     'sala': sala.toString(),
    //     'user': widget.nombre,
    //     'id': widget.id,
    //     "hora": formattedHour,
    //     "dia": dia,
    //     "mes": mes,
    //     "año": anio,
    //     "leido": false
    //   }),
    // );
    //ChatApis().rendV(modid, sala);
    _messageInputController.clear();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(AppLifecycleState.resumed==state){
      if(mounted){
            
        if(recargar==0){
          print(recargar);
        }
      }
    }
    
  }

  @override
  void initState() {
    super.initState();
    recargar=0;
    WidgetsBinding.instance.addObserver(this);
    ChatApis().dataLogin(widget.id!, widget.rol!, widget.nombre!, prefs.tripId,
        widget.nombreAgent!, widget.idAgent!);

       
    datas();
    streamSocket.socket!.on("act_target", (data) {
      //print("**********************************************actTarget");
      getUpdateT(data);
    });
    getMessages(widget.id!, widget.idAgent!, prefs.tripId);
    //inicializador del botón de android para manejarlo manual
    BackButtonInterceptor.add(myInterceptor);
    ChatApis().notificationCounter(prefs.tripId);
  }

  void getUpdateT(dynamic data) {
    //print("**********************************************actTarget");
    streamSocket.socket!.emit("updateT", data);
  }

  void getMessages(String idE, String idR, String sala) async {

    Provider.of<ChatProvider>(context, listen: false).mensaje2.clear();
    final response = await BaseClient().get(
        RestApis.messages + "/$sala" + "/$idE" + "/$idR",
        {"Content-Type": "application/json"});
  if (response == null) return null;
    final data = jsonDecode(response);    
    data["listM"].forEach((element) {      
      arrayStructure.add({
        "mensaje": element["Mensaje"],
        "sala": element["Sala"],
        "user": element["Nombre_emisor"],
        "id": element["id_emisor"],
        "hora": element["Hora"],
        "dia": element["Dia"],
        "mes": element["Mes"],
        "año": element["Año"],
        "tipo": element["Tipo"],
        "leido": element["Leido"]
      });
    });
    controllerLoading(true);

    ChatApis().readMessage(prefs.tripId, widget.idAgent!, widget.id!); 
    arrayStructure.forEach((result) {
      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false)
            .addNewMessage(MessageDriver.fromJson(result));
      }
    });
    //print(arrayStructure);
    
  }

  void datas() {
    
    streamSocket.socket!.on('detectarE', (data) => print(data));
    streamSocket.socket!.on('entrarChat_flutter', (data) {
      setState(() {
        sala = data["Usuarios"]["target"]['sala'].toString();
        idDriver = data["Usuarios"]["target"]['id'].toString();
        idDb = data["Usuarios"]["target"]['_id'].toString();
        nameDriver = widget.nombre;
        nameAgent = data["Usuarios"]["target"]['nombre'];
      });

      //Provider.of<ChatProvider>(context, listen: false).mensaje2.clear();
      // data['listM'].forEach((value) {
      //   if (mounted) {
      //     Provider.of<ChatProvider>(context, listen: false)
      //         .addNewMessage(MessageDriver.fromJson(value));
      //   }
      // });
      
      
    });

    //     print('***********************************************************');
    streamSocket.socket!.on(
      'cargarM',
      ((listM) {
        print('*************cargarM');
        print(listM);
        if (mounted) {
          Provider.of<ChatProvider>(context, listen: false).mensaje2.clear();
          listM.forEach((value) {
            print(value);
            Provider.of<ChatProvider>(context, listen: false)
                .addNewMessage(MessageDriver.fromJson(value));
          });
        }
      }),
    );

    streamSocket.socket!.on(
      'enviar-mensaje2',
      ((data) {              
        if (mounted) {
          Provider.of<ChatProvider>(context, listen: false)
              .addNewMessage(MessageDriver.fromJson(data));
          ChatApis().readMessage( prefs.tripId, widget.idAgent!, widget.id!);
          // ChatApis().sendReadOnline(
          //     data["sala"].toString(), data["_id"].toString(), widget.id!);
        }
      }),
    );
    controllerLoading(false);
  }

  void controllerLoading(bool controller) {
    setState(() {
      isloading = controller;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageInputController.dispose();

    //creación del dispose para removerlo después del evento
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    streamSocket.socket!.emit('salir');
    streamSocket.socket!.disconnect();
    streamSocket.socket!.close();
    streamSocket.socket!.dispose();



    //Navigator.of(context).pop();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  tripId: prefs.tripId,
                )));

    return true;
  }

  @override
  Widget build(BuildContext context) {

    String fechaA = '';
    
    bool fecha(fechaBs){
      if(fechaA!=fechaBs){
        fechaA=fechaBs;
        return true;
      }
      else
        return false;
    }

    // ignore: non_constant_identifier_names
    String hoy_ayer(fechaBs){

      DateTime now = new DateTime.now();
      DateTime date = new DateTime(now.year, now.month, now.day);

      String day = date.day.toString();
      String month = date.month.toString();
      String year = date.year.toString();

      if(day.toString().length!=2){
        day='0'+day;
      }
      if(month.toString().length!=2){
        month='0'+month;
      }
      if(year.toString().length==4){
        year=year[2]+year[3];
      }

      String fecha = '$month/$day/$year';

      if(fecha==fechaBs){
        fechaA=fechaBs;
        return 'Hoy';
      }
      else
        return fechaBs;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: nameAgent == null
            ? Text("")
            : Text(
                nameAgent!,
                style: TextStyle(color: thirdColor),
              ),
        backgroundColor: backgroundColor,
        shadowColor: Colors.black87,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_circle_left,
            color: secondColor,
          ),
          onPressed: () {
            streamSocket.socket!.emit('salir');
            streamSocket.socket!.disconnect();
            streamSocket.socket!.close();
            streamSocket.socket!.dispose();
            recargar=-1;
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                      tripId: prefs.tripId,
                    )));
          },
        ),
        elevation: 10,
        iconTheme: IconThemeData(color: secondColor, size: 35),
        actions: <Widget>[
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/user.svg",
              width: 100,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DriverProfilePage();
              }));
            },
          ),
          SizedBox(width: kDefaultPadding / 2)
        ],
      ),
      body: isloading == true
          ? Column(
              children: [
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, provider, child) =>
                        SingleChildScrollView(
                      reverse: true,
                      child: ListView.separated(
                        shrinkWrap: true,
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final message = provider.mensaje[index];
                          return Wrap(
                            alignment: message.user!.toUpperCase() ==
                                    widget.nombre!.toUpperCase()
                                ? WrapAlignment.end
                                : WrapAlignment.start,
                            children: [
                              Center(
                                child: fecha('${message.mes}/${message.dia}/${message.ao}')==true  
                                ?Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Card(
                                    color: Color.fromARGB(255, 101, 87, 170),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(hoy_ayer('${message.mes}/${message.dia}/${message.ao}'), style: TextStyle(color: Colors.white, fontSize: 17)),
                                    ),
                                  ),
                                ) : null,
                              ),
                              Card(
                                color: message.user!.toUpperCase() ==
                                        widget.nombre!.toUpperCase()
                                    ? thirdColor
                                    : chatBubbleColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        message.user!.toUpperCase() ==
                                                widget.nombre!.toUpperCase()
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      if (message.mensaje != null) ...{
                                        Text(
                                          message.mensaje!,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        )
                                      },
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (message.user!.toUpperCase() ==
                                              widget.nombre!.toUpperCase())
                                            Icon(
                                              message.leido == true
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              size: 15,
                                              color: message.leido == true
                                                  ? firstColor
                                                  : backgroundColor,
                                            ),
                                          if (message.user!.toUpperCase() ==
                                              widget.nombre!.toUpperCase())
                                            Text(
                                              message.hora,
                                              style: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 12),
                                            ),
                                          if (message.user!.toUpperCase() !=
                                              widget.nombre!.toUpperCase())
                                            Text(
                                              message.hora,
                                              style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 12),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                        separatorBuilder: (_, index) => const SizedBox(
                          height: 5,
                        ),
                        itemCount: provider.mensaje.length,
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    //color: Gradiant2,
                    height: 50,
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        NeumorphicButton(
                            curve: Neumorphic.DEFAULT_CURVE,
                            margin: EdgeInsets.only(top: 0),
                            onPressed: () {
                              _messageInputController.text = "Estoy en camino";
                              if (_messageInputController.text
                                  .trim()
                                  .isNotEmpty) {
                                _sendMessage();
                              }
                            },
                            style: NeumorphicStyle(
                              shadowLightColor: thirdColor,
                              color: thirdColor,
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(8)),
                              //border: NeumorphicBorder()
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Estoy en camino",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(width: 8),
                        NeumorphicButton(
                            margin: EdgeInsets.only(top: 0),
                            onPressed: () {
                              _messageInputController.text = "Estoy aquí";
                              if (_messageInputController.text
                                  .trim()
                                  .isNotEmpty) {
                                _sendMessage();
                              }
                            },
                            style: NeumorphicStyle(
                              color: thirdColor,
                              shadowLightColor: thirdColor,
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(8)),
                              //border: NeumorphicBorder()
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Estoy aquí",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                        SizedBox(width: 8),
                        NeumorphicButton(
                            margin: EdgeInsets.only(top: 0),
                            onPressed: () {
                              _messageInputController.text = "¡Entendido!";
                              if (_messageInputController.text
                                  .trim()
                                  .isNotEmpty) {
                                _sendMessage();
                              }
                            },
                            style: NeumorphicStyle(
                              color: thirdColor,
                              shadowLightColor: thirdColor,
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(8)),
                              //border: NeumorphicBorder()
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Entendido!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                        SizedBox(width: 8),
                        NeumorphicButton(
                            margin: EdgeInsets.only(top: 0),
                            onPressed: () {
                              _messageInputController.text =
                                  "Lo estoy buscando";
                              if (_messageInputController.text
                                  .trim()
                                  .isNotEmpty) {
                                _sendMessage();
                              }
                            },
                            style: NeumorphicStyle(
                                shape: NeumorphicShape.flat,
                                boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(8),
                                ),
                                color: thirdColor,
                                shadowLightColor: thirdColor
                                //border: NeumorphicBorder()
                                ),
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Lo estoy buscando",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageInputController,
                            decoration: const InputDecoration(
                              hintText: 'Escribe tu mensaje aqui...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_messageInputController.text
                                .trim()
                                .isNotEmpty) {
                              _sendMessage();
                            }
                          },
                          icon: const Icon(Icons.send),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void changeSeen() {
    setState(() {});
  }
}