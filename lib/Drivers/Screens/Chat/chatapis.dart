import 'dart:convert';
import 'package:flutter_auth/Drivers/Screens/Chat/socketChat.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import '../../../helpers/base_client.dart';
import '../../../helpers/res_apis.dart';

class ChatApis {
  final StreamSocket streamSocket = StreamSocket(host: 'wschat.smtdriver.com');
  List info = [];
  dynamic getDataUsuariosVar;
  final header = {"Content-Type": "application/json"};

  Future dataLogin(String id, String rol, String nombre) async {
    streamSocket.socket.connect();
    var dataS = await BaseClient().get(
        RestApis.rooms + '/Tripid/12', {"Content-Type": "application/json"});
    var dataM = await BaseClient()
        .get(RestApis.messages + "/12", {"Content-Type": "application/json"});
    if (dataS == null || dataM == null) return null;
    final sendDataS = jsonDecode(dataS);
    final sendDataM = jsonDecode(dataM);
    Map data = {
      'send1': {'nombre': "DEREK", 'rol': "MOTORISTA", 'id': "0", 'sala': "12"},
      'send2': sendDataS['salas'],
      'send3': sendDataM['mensajes'],
      'send4': {'nombre': "FRANKLIN", 'rol': "AGENTE", '_id': "8", 'sala': "12"}
    };
    String str = json.encode(data);
    streamSocket.socket.emit('driver', str);
    print(streamSocket.socket.connected);
  }

  void sendMessage(String message, String sala, String nombre, String id,
      String nameDriver, String idDb, String idE, String idR) async {
    DateTime now = DateTime.now();
    String formattedHour = DateFormat('hh:mm a').format(now);
    var formatter = new DateFormat('dd');
    String dia = formatter.format(now);
    var formatter2 = new DateFormat('MM');
    String mes = formatter2.format(now);
    var formatter3 = new DateFormat('yy');
    String anio = formatter3.format(now);

    streamSocket.socket.emit('enviar-mensaje', {
      'mensaje': message,
      'sala': sala,
      'user': nombre,
      'id': id,
      'hora': formattedHour,
      'dia': dia,
      'mes': mes,
      'año': anio,
      "leido": false
    });
    Map sendMessage = {
      "id_emisor": "0",
      "id_receptor": "8",
      "Nombre_emisor": nombre,
      "Mensaje": message,
      "Sala": sala,
      "Nombre_receptor": "FRANKLIN",
      "Tipo": "MENSAJE",
      "Dia": dia,
      "Mes": mes,
      "Año": anio,
      "Hora": formattedHour,
      "leido": false
    };
    print(sendMessage);
    // Map str = json.decode(sendMessage);
    await BaseClient().post(
        RestApis.messages, sendMessage, {"Content-Type": "application/json"});
  }

  void getDataUsuarios(dynamic getData) {
    getDataUsuariosVar = getData;
  }

  void readMessage(dynamic data) async {
    data["listM"].forEach((asm) async {
      if (asm["leido"] == false && asm["tipo"] == "MENSAJE" && asm["id"] == 8) {
        Map mensaje = {"Leido": true};
        String str = json.encode(mensaje);
        await http.put(
            Uri.parse(
              RestApis.messages + "/12" + "/8",
            ),
            headers: {"Content-Type": "application/json"},
            body: str);
      }
    });
    var response = await BaseClient().get(
        RestApis.messages + "/12" + "/8" + "/0",
        {"Content-Type": "application/json"});
    Map dat = {'mens': response};
    String str2 = json.encode(dat);
    streamSocket.socket.emit('updateM', str2);
  }

  void sendReadOnline(String dataSala, String dataid) async {
    Map info = {"Leido": true};
    String str = json.encode(info);
    await http.put(
        Uri.parse(
          RestApis.messages + "/$dataSala" + "/$dataid",
        ),
        headers: {"Content-Type": "application/json"},
        body: str);
    var responseM = await BaseClient().get(
        RestApis.messages + "/$dataSala" + "/$dataid" + "/0",
        {"Content-Type": "application/json"});

    Map dat = {'mens': responseM};
    String str2 = json.encode(dat);
    streamSocket.socket.emit('updateM', str2);
  }

  Future<List<dynamic>> notificationCounter(String tripId) async {
    try {
      var notification = await BaseClient().get(
          RestApis.messages + "/$tripId", {"Content-Type": "application/json"});

      var itemsData = jsonDecode(notification != null ? notification : "[]");
      if (notification != null) {
        List<dynamic> counter = [];
        itemsData['Agentes'].forEach((item) {
          counter.add(item);
        });
        return counter;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
