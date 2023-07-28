import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';

//aquí está la clase para después traer la api
class PlantillaDriver {
  final String? image, title, name, imageMain;
  final int? size, id;
  final Color? color;
  final description;
  PlantillaDriver({
    this.imageMain,
    this.id,
    this.image,
    this.title,
    this.name,
    this.description,
    this.size,
    this.color,
  });
}

//aquí la lista que llamamos para mostrar el texto de las imagenes y las imagenes
List<PlantillaDriver> plantillaDriver = [
  PlantillaDriver(
      id: 1,
      title: "Asignar horas de encuentro",
      name: 'Carlos',
      size: 20,
      description: dummyText,
      image: "assets/icons/asignar_viajes.svg",
      imageMain: "assets/images/clipboard.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 2,
      title: "Viajes en Proceso",
      name: '234',
      size: 20,
      description: dummyText2,
      image: "assets/icons/viaje_proceso.svg",
      imageMain: "assets/images/TripProcess.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 3,
      title: "Registrar Salidas",
      name: '234',
      size: 20,
      description: dummyText3,
      image: "assets/icons/Codigo_QR.svg",
      imageMain: "assets/images/RegisterOut.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 4,
      title: "Historial de viajes",
      name: '234',
      size: 20,
      description: dummyText4,
      image: "assets/icons/historial_de_viaje.svg",
      imageMain: "assets/images/history.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 5,
      title: "Viajes ejecutivos",
      name: '234',
      size: 20,
      description: dummyText5,
      image: "assets/icons/ejecutivo.svg",
      imageMain: "assets/images/clipboard.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 6,
      title: "Registrar viaje sólido",
      name: '234',
      size: 20,
      description: dummyText6,
      image: "assets/icons/viaje_proceso.svg",
      imageMain: "assets/images/adduser.svg",
      color: backgroundColor),
];

String dummyText = "Programa encuentros en tus viajes";

String dummyText2 = "Revisa tus viajes en curso";

String dummyText3 = "Registra tus viajes de salida";

String dummyText4 = "Revisa tus viajes realizados";

String dummyText5 = "Revisa tu programación";

String dummyText6 = "prueba 5 we";
