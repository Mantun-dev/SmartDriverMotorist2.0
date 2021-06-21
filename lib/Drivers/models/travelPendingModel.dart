import 'dart:convert';

Driver driverFromJson(String str) => Driver.fromJson(json.decode(str));

String driverToJson(Driver data) => json.encode(data.toJson());

class Driver {
  Driver({
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

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
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
