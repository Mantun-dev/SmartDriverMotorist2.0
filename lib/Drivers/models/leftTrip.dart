// To parse this JSON data, do
//
//     final salida = salidaFromJson(jsonString);

import 'dart:convert';

Salida salidaFromJson(String str) => Salida.fromJson(json.decode(str));

String salidaToJson(Salida data) => json.encode(data.toJson());

class Salida {
    Salida({
        this.ok,
        this.type,
        this.title,
        this.message,
        this.tripId,
    });

    bool ok;
    String type;
    String title;
    String message;
    int tripId;

    factory Salida.fromJson(Map<String, dynamic> json) => Salida(
        ok: json["ok"],
        type: json["type"],
        title: json["title"],
        message: json["message"],
        tripId: json["tripId"],
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "type": type,
        "title": title,
        "message": message,
        "tripId": tripId,
    };
}
