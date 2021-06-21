import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';

//aquí está la clase para después traer la api
class PlantillaDriver {
  final String image, title, name;
  final int size, id;
  final Color color;
  final description;
  PlantillaDriver({
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
      title: "Asignar horas de viaje",
      name: 'Carlos',
      size: 20,
      description: dummyText,
      image: "assets/images/checklistDriver.png",
      color: kCardColorDriver1),
  PlantillaDriver(
      id: 2,
      title: "Viajes en Proceso",
      name: '234',
      size: 20,
      description: dummyText2,
      image: "assets/images/destinationDriver.png",
      color: kCardColorDriver2),
  PlantillaDriver(
      id: 3,
      title: "Registrar Salidas",
      name: '234',
      size: 20,
      description: dummyText3,
      image: "assets/images/QRDriver.png",
      color: kCardColorDriver2),
  PlantillaDriver(
      id: 4,
      title: "Historial de viajes",
      name: '234',
      size: 20,
      description: dummyText4,
      image: "assets/images/History.png",
      color: kCardColorDriver1),
];

String dummyText = "Prueba uno we";

String dummyText2 = "Prueba 2 we";

String dummyText3 = "Prueba 3 we";

String dummyText4 = "prueba 4 we";
