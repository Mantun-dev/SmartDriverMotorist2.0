// To parse this JSON data, do
//
//     final tmpArray = tmpArrayFromJson(jsonString);

import 'dart:convert';

List<TmpArray> tmpArrayFromJson(String str) => List<TmpArray>.from(json.decode(str).map((x) => TmpArray.fromJson(x)));

String tmpArrayToJson(List<TmpArray> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TmpArray {
    TmpArray({
        this.noempleado,
        this.nombre,
        this.horaSalida,
        this.direccion,
    });

    String noempleado;
    String nombre;
    String horaSalida;
    String direccion;

    factory TmpArray.fromJson(Map<String, dynamic> json) => TmpArray(
        noempleado: json["Noempleado"],
        nombre: json["Nombre"],
        horaSalida: json["HoraSalida"],
        direccion: json["Direccion"],
    );

    Map<String, dynamic> toJson() => {
        "Noempleado": noempleado,
        "Nombre": nombre,
        "HoraSalida": horaSalida,
        "Direccion": direccion,
    };
}

class TmpArr{
    TmpArr(
      this.noempleado,
      this.nombre,
      this.horaSalida,
      this.direccion,
    );

    String noempleado;
    String nombre;
    String horaSalida;
    String direccion;
}
