// To parse this JSON data, do
//
//     final tripsToSolid = tripsToSolidFromJson(jsonString);

import 'dart:convert';

TripsToSolid tripsToSolidFromJson(String str) => TripsToSolid.fromJson(json.decode(str));

String tripsToSolidToJson(TripsToSolid data) => json.encode(data.toJson());

class TripsToSolid {
    TripsToSolid({
        this.type,
        this.title,
        this.message,
        this.trip,
    });

    String type;
    String title;
    String message;
    Trip trip;

    factory TripsToSolid.fromJson(Map<String, dynamic> json) => TripsToSolid(
        type: json["type"],
        title: json["title"],
        message: json["message"],
        trip: Trip.fromJson(json["trip"]),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "title": title,
        "message": message,
        "trip": trip.toJson(),
    };
}

class Trip {
    Trip({
        this.tripId,
        this.tripHour,
    });

    int tripId;
    DateTime tripHour;

    factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        tripId: json["tripId"],
        tripHour: DateTime.parse(json["tripHour"]),
    );

    Map<String, dynamic> toJson() => {
        "tripId": tripId,
        "tripHour": tripHour.toIso8601String(),
    };
}
