// To parse this JSON data, do
//
//     final tripsPending = tripsPendingFromJson(jsonString);

import 'dart:convert';

List<TripsPending> tripsPendingFromJson(String str) => List<TripsPending>.from(json.decode(str).map((x) => TripsPending.fromJson(x)));

String tripsPendingToJson(List<TripsPending> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TripsPending {
    TripsPending({
        this.tripId,
        this.fecha,
        this.hora,
        this.empresa,
        this.agentes,
    });

    int tripId;
    String fecha;
    String hora;
    String empresa;
    int agentes;

    factory TripsPending.fromJson(Map<String, dynamic> json) => TripsPending(
        tripId: json["tripId"],
        fecha: json["Fecha"],
        hora: json["Hora"],
        empresa: json["Empresa"],
        agentes: json["Agentes"],
    );

    Map<String, dynamic> toJson() => {
        "tripId": tripId,
        "Fecha": fecha,
        "Hora": hora,
        "Empresa": empresa,
        "Agentes": agentes,
    };
}

class TripsList {
  final List<TripsPending> trips;

  TripsList({
    this.trips,
  });

  factory TripsList.fromJson(List<dynamic> parsedJson) {

    List<TripsPending> trips = [];

    trips = parsedJson.map((i)=>TripsPending.fromJson(i)).toList();
    return new TripsList(
       trips: trips,
    );
  }

}
