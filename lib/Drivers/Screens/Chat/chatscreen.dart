import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatViews.dart';

import 'package:flutter_auth/Drivers/Screens/Chat/chatapis.dart';

import 'package:flutter_auth/constants.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../components/warning_dialog.dart';
import '../../../helpers/base_client.dart';
import '../../../helpers/res_apis.dart';
import '../../../providers/chat.dart';
import '../../SharePreferences/preferencias_usuario.dart';
import '../../models/message_chat.dart';
//import '../Details/components/agents_Trip.dart';
import '../DriverProfile/driverProfile.dart';
//import 'package:intl/intl.dart';

import 'component/audio.dart';
import 'socketChat.dart';

class ChatScreen extends StatefulWidget {
  final String? nombre;
  final String? id;
  final String? rol;
  final String? nombreAgent;
  final String? idAgent;
  final String? tipoViaje;
  final String? idV;
  const ChatScreen(
      {Key? key, this.nombre, this.id, this.rol, this.nombreAgent, this.idAgent, this.tipoViaje, this.idV})
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
  bool activateMic = false;
  late AudioPlayer _audioPlayer;
  late Record _audioRecord;
  List<String> _audioList = [];
  String filePathP = '';

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

  void _sendAudio(String audioPath) async {
    if (await File(audioPath).exists()) {
      try {

        ChatApis().sendAudio(audioPath, sala.toString(),
        nameAgent!, widget.id!, nameDriver!, idDb!, widget.idAgent!);
      } catch (e) {
        // Handle any error during compression or sending
        print('Error al enviar el audio: $e');
      }
      // Resto del código
    } else {
      print('El archivo de audio no existe en la ruta especificada: $audioPath');
    }
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
    _audioPlayer = AudioPlayer();
    _audioRecord = Record();
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
    _audioPlayer.dispose();
    _audioRecord.dispose();
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
                  tipoViaje: this.widget.tipoViaje,
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


    String hoyayer(fechaBs){

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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
     backgroundColor: Theme.of(context).canvasColor,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: AppBar(
                  backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                    elevation: 0,
                    iconTheme: IconThemeData(size: 25),
                    automaticallyImplyLeading: false, 
                    actions: <Widget>[
                    //aquí está el icono de las notificaciones
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          streamSocket.socket!.emit('salir');
                          streamSocket.socket!.disconnect();
                          streamSocket.socket!.close();
                          streamSocket.socket!.dispose();
                          deleteAllTempAudioFiles();
                          recargar=-1;
                          Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                tripId: this.widget.idV,
                                tipoViaje: this.widget.tipoViaje,
                              )
                            )
                          );
                        },
                        child: Container(
                          width: 45,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryIconTheme.color!,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset(
                              "assets/icons/flecha_atras_oscuro.svg",
                              color: Theme.of(context).primaryIconTheme.color!,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Row(
                        children: [
                      
                          Container(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              "assets/images/perfil-usuario-general.png",
                            ),
                          ),
                           SizedBox(width: 5),
                          nameDriver != null ? 
                            Flexible(
                              child: Text(
                                nameAgent!,
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
                              ),
                            ) 
                          : Text(''),
                        ],
                      )
                    ),

                  ],
                ),
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
                            var message = provider.mensaje[index];

                            if(fecha('${message.mes}/${message.dia}/${message.ao}')==true ){
                              message.mostrarF=true;
                            }

                            return Wrap(
                              alignment:
                                  message.id == widget.id
                                      ? WrapAlignment.end
                                      : WrapAlignment.start,
                              children: [
                                if(message.mostrarF==true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 35, bottom: 35, left: 8, right: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Color.fromRGBO(158, 158, 158, 1),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(hoyayer('${message.mes}/${message.dia}/${message.ao}'), style: TextStyle(color: Color.fromRGBO(158, 158, 158, 1), fontSize: 17)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Color.fromRGBO(158, 158, 158, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
  
                                Container(
                                  width: size.width/2,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8.0),
                                        topRight: message.id == widget.id?Radius.zero:Radius.circular(8.0),
                                        bottomLeft:  message.id == widget.id? Radius.circular(8.0):Radius.zero,
                                        bottomRight: Radius.circular(8.0),
                                      ),
                                    ),
                                    color: message.id == widget.id
                                        ? Theme.of(context).focusColor
                                        : Theme.of(context).cardColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (message.mensaje != null) ...{
                                            message.tipo=='AUDIO'?
                                              AudioContainer(
                                                audioName: message.mensaje!,
                                                colorIcono: message.id == widget.id
                                                    ? Colors.white
                                                    : Theme.of(context).primaryColorDark,
                                                    idSala: int.parse(message.sala),
                                              )
                                            :
                                            Text(
                                              message.mensaje!,
                                              style: TextStyle(
                                                  color: message.id ==
                                                      widget.id
                                                  ? Colors.white
                                                  : Theme.of(context).primaryColorDark,
                                                  fontSize: 17),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(child: SizedBox()),
                                                if (message.id ==
                                                    widget.id)
                                                  Text(
                                                    message.hora,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  ),
                                                if (message.id !=
                                                    widget.id)
                                                  Text(
                                                    message.hora,
                                                    style: TextStyle(
                                                        color: Theme.of(context).primaryColorDark,
                                                        fontSize: 10),
                                                  ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                if (message.id ==
                                                    widget.id)
                                                  Icon(
                                                    message.leido == true
                                                        ? Icons.done_all
                                                        : Icons.done,
                                                    size: 16,
                                                    color: message.leido == true
                                                        ? Color.fromRGBO(0, 255, 255, 1)
                                                        : Colors.grey,
                                                  )
                                              ],
                                            ),
                                          },
                                        ],
                                      ),
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
                          SizedBox(width: 5),
                          NeumorphicButton(
                            margin: EdgeInsets.only(top: 0),
                            onPressed: () {
                                _messageInputController.text =
                                    "Estoy en camino";
                                if (_messageInputController.text
                                    .trim()
                                    .isNotEmpty) {
                                  _sendMessage();
                                }
                              },
                            style: NeumorphicStyle(
                              color: Color.fromRGBO(40, 93, 169, 1),
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                              depth: 0, // Quita la sombra estableciendo la profundidad en 0
                              border: NeumorphicBorder( // Agrega un borde
                                color: Theme.of(context).disabledColor, // Color del borde
                                width: 1.0, // Ancho del borde
                              ),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Estoy en camino",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          SizedBox(width: 5),
                          NeumorphicButton(
                              margin: EdgeInsets.only(top: 0),
                              onPressed: () {
                                _messageInputController.text =
                                    "Estoy aquí";
                                if (_messageInputController.text
                                    .trim()
                                    .isNotEmpty) {
                                  _sendMessage();
                                }
                              },
                              style: NeumorphicStyle(
                              color: Color.fromRGBO(40, 93, 169, 1),
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                              depth: 0, // Quita la sombra estableciendo la profundidad en 0
                              border: NeumorphicBorder( // Agrega un borde
                                color: Theme.of(context).disabledColor, // Color del borde
                                width: 1.0, // Ancho del borde
                              ),
                            ),
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "Estoy aquí",
                                style: TextStyle(color: Colors.white),
                              )),
                          SizedBox(width: 5),
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
                              color: Color.fromRGBO(40, 93, 169, 1),
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                              depth: 0, // Quita la sombra estableciendo la profundidad en 0
                              border: NeumorphicBorder( // Agrega un borde
                                color: Theme.of(context).disabledColor, // Color del borde
                                width: 1.0, // Ancho del borde
                              ),
                            ),
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "¡Entendido!",
                                style: TextStyle(color: Colors.white),
                              )),

                              SizedBox(width: 5),
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
                              color: Color.fromRGBO(40, 93, 169, 1),
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                              depth: 0, // Quita la sombra estableciendo la profundidad en 0
                              border: NeumorphicBorder( // Agrega un borde
                                color: Theme.of(context).disabledColor, // Color del borde
                                width: 1.0, // Ancho del borde
                              ),
                            ),
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "Lo estoy buscando",
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                  ),
                Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(top: 15, bottom: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).cardTheme.color,
                                border: Border.all(color: Theme.of(context).disabledColor),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      enabled: !activateMic ? true : false,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15),
                                      controller: _messageInputController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(left: 10),
                                        hintText: !activateMic ? 'Mensaje' : 'Grabando audio...',
                                        hintStyle: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).hintColor, fontSize: 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      {
                                        if (_messageInputController.text
                                            .trim()
                                            .isNotEmpty) {
                                          _sendMessage();
                                        }
                                      }
                                    },
                                    icon: Icon(Icons.send, color: Theme.of(context).primaryIconTheme.color),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(40, 93, 169, 1),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  
                                  bool permiso= await checkAudioPermission();
                          
                                  if(permiso){                                   
                                    if(!activateMic){
                                      await QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.confirm,
                                        text: "¿Está seguro que desea grabar un audio?",
                                        confirmBtnText: "Confirmar",
                                        cancelBtnText: "Cancelar",
                                        title: '¿Está seguro?',
                                        showCancelBtn: true,
                                        confirmBtnTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                                        cancelBtnTextStyle: TextStyle(
                                            color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                                        onConfirmBtnTap: () async {
                                          startRecording();
                                          Navigator.pop(context);
                                        },
                                        onCancelBtnTap: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                      
                                    }else{
                                      stopRecording();
                                    }
                                  }else{
                                    WarningSuccessDialog().show(
                                          context,
                                          title: "No dio permiso del uso del microfono",
                                          tipo: 1,
                                          onOkay: () {
                                            try{
                                              AppSettings.openAppSettings();
                                            }catch(error){
                                              print(error);
                                            }
                                          },
                                        ); 
                                  }
                                },
                                icon: !activateMic ? Icon(Icons.mic, color: Colors.white) : Icon(Icons.mic_off, color: Colors.red),
                              ),
                            ),
                          )
                        ],
                      ),
                    )

                  ),
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

Future<bool> checkAudioPermission() async {
    // Verificar si se tiene el permiso de grabación de audio
    var status = await Permission.microphone.status;
    
    if (status.isGranted) {
      // Permiso concedido
      return true;
    } else {
      // No se ha solicitado el permiso, solicitarlo al usuario
      return false;
    }
  }

  void startRecording() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      String filePath = '${cacheDir.path}/${sala}_recording${_audioList.length + 1}.m4a';
      await _audioRecord.start(path: filePath, encoder: AudioEncoder.aacLc);

      setState(() {
        filePathP = filePath;
        activateMic = true;
      });

      await Future.delayed(Duration(seconds: 60), () {
        if (activateMic) {
          stopRecording();
        }
      });

    } catch (e) {
      // Handle any error during recording
      print('Error al iniciar la grabación: $e');
    }
  }

  void stopRecording() async {
    try {
      await _audioRecord.stop();

      String recordedFilePath = filePathP;

      // Verificar si el archivo existe
      File audioFile = File(recordedFilePath);
      if (await audioFile.exists()) {
        _sendAudio(recordedFilePath);
        print(filePathP);
        setState(() {
          activateMic = false;
          _audioList.add('audio');
        });

      } else {
        print('El archivo de audio no existe');
      }
    } catch (e) {
      // Manejo más detallado de errores
      print('Error al detener la grabación o enviar el audio: $e');
    }
  }

}

class AudioData {
  final String filePath;
  bool isPlaying = false;

  AudioData(this.filePath);
}