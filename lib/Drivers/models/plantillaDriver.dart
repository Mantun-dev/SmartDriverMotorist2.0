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
      title: "    Asignar horas de viaje",
      name: 'Carlos',
      size: 20,
      description: dummyText,
      image: "assets/images/checklist.png",
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
      title: "  Historial de viajes",
      name: '234',
      size: 20,
      description: dummyText4,
      image: "assets/images/History.png",
      color: kCardColorDriver1),
  PlantillaDriver(
      id: 5,
      title: "Viajes ejecutivos",
      name: '234',
      size: 20,
      description: dummyText4,
      image: "assets/images/executive.png",
      color: kCardColorDriver1),
  PlantillaDriver(
      id: 6,
      title: "Registrar viaje sólido",
      name: '234',
      size: 20,
      description: dummyText3,
      image: "assets/images/adduser.png",
      color: kCardColorDriver2),
];

String dummyText = "Asigna la hora a tus\nViajes disponibles";

String dummyText2 = "Revisa los viajes que\nestas realizando";

String dummyText3 = "Registra la salida de\nun vehículo";

String dummyText4 = "Revisa tus viaje\nrealizados";

String dummyText5 = "prueba 5 we";
