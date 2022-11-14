// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'dart:convert';

MessageDriver messageFromJson(String str) =>
    MessageDriver.fromJson(json.decode(str));

String messageToJson(MessageDriver data) => json.encode(data.toJson());

class MessageDriver {
  MessageDriver(
      {this.user,
      this.sala,
      this.id,
      this.mensaje,
      this.hora,
      this.dia,
      this.mes,
      this.ao,
      this.tipo,
      this.leido});

  String user;
  dynamic sala;
  dynamic id;
  String mensaje;
  dynamic hora;
  dynamic dia;
  dynamic mes;
  dynamic ao;
  String tipo;
  bool leido;

  factory MessageDriver.fromJson(Map<String, dynamic> json) => MessageDriver(
      mensaje: json["mensaje"],
      sala: json["sala"],
      user: json["user"],
      id: json["id"],
      hora: json["hora"],
      dia: json["dia"],
      mes: json["mes"],
      ao: json["año"],
      tipo: json["tipo"],
      leido: json["leido"]);

  Map<String, dynamic> toJson() => {
        "mensaje": mensaje,
        "sala": sala,
        "user": user,
        "id": id,
        "hora": hora,
        "dia": dia,
        "mes": mes,
        "año": ao,
        "tipo": tipo,
        "leido": leido
      };
}
