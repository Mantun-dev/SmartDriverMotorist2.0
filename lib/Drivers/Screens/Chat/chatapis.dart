import 'dart:convert';
import 'dart:io';
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

  Future dataLogin(String id, String rol, String nombre, String sala,
      String nombreAgent, String idAgent) async {
    streamSocket.socket!.connect();
    var dataS = await BaseClient().get(
        RestApis.rooms + '/Tripid/$sala', {"Content-Type": "application/json"});
    var dataM = await BaseClient().get(
        RestApis.messages + "/$sala"+ "/$id"+"/$idAgent", {"Content-Type": "application/json"});
    if (dataS == null || dataM == null) return null;
    final sendDataS = jsonDecode(dataS);
    final sendDataM = jsonDecode(dataM);
    Map data = {
      'send1': {'nombre': nombre, 'rol': "MOTORISTA", 'id': id, 'sala': sala},
      'send2': sendDataS['salas'],
      'send3': sendDataM['listM'],
      'send4': {
        'nombre': nombreAgent,
        'rol': "AGENTE",
        '_id': idAgent,
        'sala': sala
      }
    };
    String str = json.encode(data);
    streamSocket.socket!.emit('driver2', str);
    print(streamSocket.socket!.connected);
  }

  void sendMessage(
    String message,
    String sala,
    String nombre,
    String idDriver,
    String nameDriver,
    String idDb,
    String idR,
  ) async {
    DateTime now = DateTime.now();
    String formattedHour = DateFormat('hh:mm a').format(now);
    var formatter = new DateFormat('dd');
    String dia = formatter.format(now);
    var formatter2 = new DateFormat('MM');
    String mes = formatter2.format(now);
    var formatter3 = new DateFormat('yy');
    String anio = formatter3.format(now);
    Map sendMessage = {
          "id_emisor": idDriver,
          "id_receptor": idR,
          "Nombre_emisor": nameDriver,
          "Mensaje": message,
          "Sala": sala,
          "Nombre_receptor": nombre,
          "Tipo": "MENSAJE",
          "Dia": dia,
          "Mes": mes,
          "Año": anio,
          "Hora": formattedHour
        };

    // Map str = json.decode(sendMessage);
    await BaseClient().post(
        RestApis.messages, sendMessage, {"Content-Type": "application/json"});
    streamSocket.socket!.emit('enviar-mensaje2', {
      'mensaje': message,
      'sala': sala,
      'user': nameDriver,
      'id': idDriver,
      'hora': formattedHour,
      'dia': dia,
      'mes': mes,
      'año': anio,
      "leido": false
    });
    Map sendNotification = {
      "receiverId": idR,
      "receiverRole": "agente",
      "textMessage": message,
      "hourMessage": formattedHour,
      "nameSender": nameDriver,
      "tripId": sala
    };

    await BaseClient().post(
        'https://admin.smtdriver.com/sendMessageNotification',
        sendNotification,
        {"Content-Type": "application/json"});


    
  }

  Future<void> sendAudio(String audioPath, String sala, String nombre, String idDriver, String nameDriver, String idDb, String idR) async {
    try {
      DateTime now = DateTime.now();
      String formattedHour = DateFormat('hh:mm a').format(now);
      var formatter = new DateFormat('dd');
      String dia = formatter.format(now);
      var formatter2 = new DateFormat('MM');
      String mes = formatter2.format(now);
      var formatter3 = new DateFormat('yy');
      String anio = formatter3.format(now);

      if (await File(audioPath).exists()) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(RestApis.audios), // Reemplaza con la URL correcta
        );

        var audioFile = File(audioPath);
        if (!audioFile.existsSync()) {
          print('Archivo de audio no encontrado en la ruta especificada.');
          return;
        }
        print( audioFile.path.split('/').last);
        // Agregar el archivo de audio al campo de archivo en la solicitud
        request.files.add(
          http.MultipartFile(
            'audio', // Nombre del campo que se espera en el servidor
            audioFile.readAsBytes().asStream(),
            audioFile.lengthSync(),
            filename: audioFile.path.split('/').last, // Obtener el nombre del archivo
          ),
        );

        var response = await request.send();
          String responseBody = await response.stream.bytesToString();
          print(responseBody);
          var resp = json.decode(responseBody);

        if (response.statusCode != 200) {
            print(responseBody);
            return;
          }
          var audioName = resp['audioName'];

          Map sendMessage = {
                "id_emisor": idDriver,
                "id_receptor": idR,
                "Nombre_emisor": nameDriver,
                "Mensaje": audioName,
                "Sala": sala,
                "Nombre_receptor": nombre,
                "Tipo": "AUDIO",
                "Dia": dia,
                "Mes": mes,
                "Año": anio,
                "Hora": formattedHour
              };

          // Map str = json.decode(sendMessage);
          String sendDataM = json.encode(sendMessage);
          await http.post(Uri.parse(RestApis.messages),body: sendDataM, headers: {"Content-Type": "application/json"});

          streamSocket.socket!.emit('enviar-mensaje2', {
            'mensaje': audioName,
            'sala': sala,
            'user': nameDriver,
            'id': idDriver,
            'hora': formattedHour,
            'tipo': 'AUDIO',
            'dia': dia,
            'mes': mes,
            'año': anio,
            "leido": false
          });
          Map sendNotification = {
            "receiverId": idR,
            "receiverRole": "agente",
            "textMessage": 'Mensaje de voz',
            "hourMessage": formattedHour,
            "nameSender": nameDriver,
            "tripId": sala
          };

          await BaseClient().post(
              'https://admin.smtdriver.com/sendMessageNotification',
              sendNotification,
              {"Content-Type": "application/json"});
      } else {
        print('Audio no encontrado');
        return;
      }
    } catch (error) {
      print("Error sending audio: $error");
    }
  }

  void getDataUsuarios(dynamic getData) {
    getDataUsuariosVar = getData;
  }

  void readMessage(
       String sala, String idAgent, String driverId) async {
    
        Map mensaje = {"Leido": true};
        String str = json.encode(mensaje);
        await http.put(
            Uri.parse(
              RestApis.messages + "/$sala" + "/$idAgent" + "/$driverId",
            ),
            headers: {"Content-Type": "application/json"},
            body: str); 
  }

  void sendReadOnline(String dataSala, String dataid, String driverId) async {
    Map info = {"Leido": true};

    String str = json.encode(info);
    await http.put(
        Uri.parse(
          RestApis.messages + "/$dataSala" + "/$dataid"+"/$driverId", 
        ),
        headers: {"Content-Type": "application/json"},
        body: str);
    var responseM = await BaseClient().get(
        RestApis.messages + "/$dataSala" + "/$dataid" + "/$driverId",
        {"Content-Type": "application/json"});
    
    Map dat = {'mens': responseM};
    String str2 = json.encode(dat);    
    streamSocket.socket!.emit('updateM', str2);
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
