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

    bool? ok;
    String? type;
    String? title;
    String? message;
    TripId? tripId;

    factory Salida.fromJson(Map<String, dynamic> json) => Salida(
        ok: json["ok"],
        type: json["type"],
        title: json["title"],
        message: json["message"],
        tripId: TripId.fromJson(json["tripId"]),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "type": type,
        "title": title,
        "message": message,
        "tripId": tripId!.toJson(),
    };
}

class TripId {
    TripId({
        this.tripId,
        this.tripHour,
    });

    int? tripId;
    String? tripHour;

    factory TripId.fromJson(Map<String, dynamic> json) => TripId(
        tripId: json["tripId"],
        tripHour: json["tripHour"],
    );

    Map<String, dynamic> toJson() => {
        "tripId": tripId,
        "tripHour": tripHour,
    };
}
