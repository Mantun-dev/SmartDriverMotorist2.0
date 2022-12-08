import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';

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
import '../Details/components/agents_Trip.dart';
import '../DriverProfile/driverProfile.dart';
import 'package:intl/intl.dart';

import 'socketChat.dart';

class ChatScreen extends StatefulWidget {
  final String nombre;
  final String id;
  final String rol;
  const ChatScreen({Key key, this.nombre, this.id, this.rol}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final _socketResponse = StreamController<dynamic>();
  // Stream<dynamic> get getResponse => _socketResponse.stream;
  IO.Socket socket;
  final prefs = new PreferenciasUsuario();
  final TextEditingController _messageInputController = TextEditingController();
  var usuario = {};
  var arrayStructure = [];
  var idE;
  var idR;
  String sala;
  String id;
  String idDb;
  String nameDriver;
  String nameAgent;
  bool isloading = false;
  ScrollController _scrollController = new ScrollController();
  final arrayTemp = [];
  final StreamSocket streamSocket = StreamSocket(host: 'wschat.smtdriver.com');

  _sendMessage() {
    ChatApis().sendMessage(_messageInputController.text.trim(), sala.toString(),
        widget.nombre, id.toString(), nameAgent, idDb, idE, idR);
    DateTime now = DateTime.now();
    String formattedHour = DateFormat('hh:mm a').format(now);
    var formatter = new DateFormat('dd');
    String dia = formatter.format(now);
    var formatter2 = new DateFormat('MM');
    String mes = formatter2.format(now);
    var formatter3 = new DateFormat('yy');
    String anio = formatter3.format(now);
    Provider.of<ChatProvider>(context, listen: false).addNewMessage(
      MessageDriver.fromJson({
        'mensaje': _messageInputController.text.trim(),
        'sala': sala.toString(),
        'user': widget.nombre,
        'id': id.toString(),
        "hora": formattedHour,
        "dia": dia,
        "mes": mes,
        "año": anio,
        "leido": false
      }),
    );
    //ChatApis().rendV(modid, sala);
    _messageInputController.clear();
  }

  @override
  void initState() {
    super.initState();

    datas();
    streamSocket.socket.on("act_target", (data) {
      print("**********************************************actTarget");
      getUpdateT(data);
    });
    //inicializador del botón de android para manejarlo manual
    BackButtonInterceptor.add(myInterceptor);
    ChatApis().notificationCounter(prefs.tripId);
  }

  void getUpdateT(dynamic data) {
    print("**********************************************actTarget");
    streamSocket.socket.emit("updateT", data);
  }

  void getMessages(String idE, String idR, String sala) async {
    final response = await BaseClient().get(
        RestApis.messages + "/$sala" + "/$idE" + "/$idR",
        {"Content-Type": "application/json"});

    if (response == null) return null;
    final data = jsonDecode(response);
    Provider.of<ChatProvider>(context, listen: false).mensaje2.clear();

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
    arrayStructure.forEach((result) {
      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false)
            .addNewMessage(MessageDriver.fromJson(result));
      }
    });
  }

  void datas() {
    ChatApis().dataLogin(widget.id, widget.rol, widget.nombre);
    streamSocket.socket.on('detectarE', (data) => print(data));
    streamSocket.socket.on('entrarChat_flutter', (data) {
      setState(() {
        sala = data["Usuarios"]["target"]['sala'].toString();
        id = data["Usuarios"]["target"]['id'].toString();
        idDb = data["Usuarios"]["target"]['_id'].toString();
        //nameDriver = data["Usuarios"]["target"]['nombre'];
        nameAgent = data["Usuarios"]["target"]['nombre'];
      });
      Provider.of<ChatProvider>(context, listen: false).mensaje2.clear();
      data['listM'].forEach((value) {
        if (mounted) {
          Provider.of<ChatProvider>(context, listen: false)
              .addNewMessage(MessageDriver.fromJson(value));
        }
      });
      controllerLoading(true);
      ChatApis().readMessage(data);
    });

    streamSocket.socket.on(
      'cargarM',
      ((data) {
        if (mounted) {
          print("********************************************cargarM");
          print(data);
          //Provider.of<ChatProvider>(context, listen: false).mensaje2.clear();
          data['mens'].forEach((value) {
            if (mounted) {
              Provider.of<ChatProvider>(context, listen: false)
                  .addNewMessage(MessageDriver.fromJson(value));
            }
          });
        }
      }),
    );

    streamSocket.socket.on(
      'enviar-mensaje',
      ((data) {
        print("********************************************enviar-mensaje");
        print(data);
        if (mounted) {
          Provider.of<ChatProvider>(context, listen: false)
              .addNewMessage(MessageDriver.fromJson(data[0]));
          ChatApis().sendReadOnline(
              data[0]["sala"].toString(), data[0]["_id"].toString());
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
    print("BACK BUTTON!"); // Do some stuff.
    streamSocket.socket.disconnect();
    streamSocket.socket.close();
    streamSocket.socket.dispose();

    print(streamSocket.socket.connected);

    //Navigator.of(context).pop();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyAgent()));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: nameAgent == null
            ? Text("")
            : Text(
                nameAgent,
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
            streamSocket.socket.disconnect();
            streamSocket.socket.close();
            streamSocket.socket.dispose();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyAgent()));
          },
        ),
        elevation: 10,
        iconTheme: IconThemeData(color: secondColor, size: 35),
        actions: <Widget>[
          //aquí está el icono de las notificaciones
          IconButton(
            icon: Icon(
              Icons.message,
              size: 35,
              color: firstColor,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DriverProfilePage();
              }));
            },
          ),
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
                          print(provider.mensaje2.length);
                          return Wrap(
                            alignment: message.user == widget.nombre
                                ? WrapAlignment.end
                                : WrapAlignment.start,
                            children: [
                              Card(
                                color: message.user == widget.nombre
                                    ? thirdColor
                                    : chatBubbleColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        message.user == widget.nombre
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      if (message.mensaje != null) ...{
                                        Text(
                                          message.mensaje,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        )
                                      },
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (message.user == widget.nombre)
                                            Icon(
                                              message.leido == true
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              size: 15,
                                              color: message.leido == true
                                                  ? firstColor
                                                  : backgroundColor,
                                            ),
                                          if (message.user == widget.nombre)
                                            Text(
                                              message.hora,
                                              style: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 12),
                                            ),
                                          if (message.user != widget.nombre)
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
