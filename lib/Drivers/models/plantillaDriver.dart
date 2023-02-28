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
      image: "assets/images/Asignar.png",
      imageMain: "assets/images/clipboard.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 2,
      title: "Viajes en Proceso",
      name: '234',
      size: 20,
      description: dummyText2,
      image: "assets/images/mapa.png",
      imageMain: "assets/images/TripProcess.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 3,
      title: "Registrar Salidas",
      name: '234',
      size: 20,
      description: dummyText3,
      image: "assets/images/QrCode.png",
      imageMain: "assets/images/RegisterOut.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 4,
      title: "Historial de viajes",
      name: '234',
      size: 20,
      description: dummyText4,
      image: "assets/images/historial.png",
      imageMain: "assets/images/history.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 5,
      title: "Viajes ejecutivos",
      name: '234',
      size: 20,
      description: dummyText4,
      image: "assets/images/ejecutivo.png",
      imageMain: "assets/images/clipboard.svg",
      color: backgroundColor),
  PlantillaDriver(
      id: 6,
      title: "Registrar viaje sólido",
      name: '234',
      size: 20,
      description: dummyText3,
      image: "assets/images/adduser.png",
      imageMain: "assets/images/clipBoard.svg",
      color: backgroundColor),
];

String dummyText = "Asigna las horas de encuentro a tus viajes disponibles";

String dummyText2 = "Revisa los viajes que estas realizando";

String dummyText3 = "Registra un viaje de salida.";

String dummyText4 = "Revisa tus viaje realizados";

String dummyText5 = "prueba 5 we";
