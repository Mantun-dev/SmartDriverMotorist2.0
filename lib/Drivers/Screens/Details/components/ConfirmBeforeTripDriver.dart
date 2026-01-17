import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../components/warning_dialog.dart';
import 'package:http/http.dart' as http;

class ConfirmBeforeTripDriver extends StatefulWidget {
  @override
  _ConfirmBeforeTripDriverState createState() => _ConfirmBeforeTripDriverState();
}

class _ConfirmBeforeTripDriverState extends State<ConfirmBeforeTripDriver> {
  String barcodeScan = "";
  bool showForm = false;

  String agentName = "";
  String agentStatus = "";
  String companyName = "";
  int? selectedAgentId; // ID interno para la confirmación
  String selectedTripType = "Salida"; // Valor por defecto del dropdown
  String ip = "https://driver.smtdriver.com";
  final prefs = new PreferenciasUsuario();

  TimeOfDay selectedTime = TimeOfDay.now();
  
  // 1. Función para buscar el agente (GET)
  Future<void> fetchSearchAgent(String qrCode) async {
    // Mostramos el loader que ya usas en tus otras páginas
    _showLoadingDialog();

    try {
      final response = await http.get(
        Uri.parse('$ip/apis/searchAgentByQR/$qrCode'),
      );

      // Cerramos el loader
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        
        if (decodedData['ok'] == true) {
          setState(() {
            agentName = decodedData['agent']['agentFullname'];
            agentStatus = decodedData['agent']['agentStatus'];
            companyName = decodedData['agent']['companyName'];
            selectedAgentId = decodedData['agent']['agentId'];
            showForm = true; // Mostramos el formulario con los datos
          });
        } else {
          _showWarning(decodedData['message'] ?? "Error al validar agente");
        }
      } else {
        _showWarning("Error de servidor: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context);
      _showWarning("Error de conexión");
    }
  }

  // 2. Función para confirmar el viaje (POST)
  Future<void> fetchConfirmTrip() async {
    if (selectedAgentId == null) return;

    http.Response response = await http
        .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final data = DriverData.fromJson(json.decode(response.body));

    _showLoadingDialog();

    Map datas = {
      'agentId': selectedAgentId.toString(),
      'tripType': selectedTripType, // "Entrada" o "Salida" (El API hace el mapeo a bit)
      'hourToTravel': _formatTime(selectedTime), // Aquí puedes usar un TimePicker o la hora actual
      'driverId': data.driverId.toString(), // ID del conductor desde preferencias
    };

    try {
      http.Response response = await http.post(
        Uri.parse('$ip/apis/confirmAgentTrip'), 
        body: datas
      );

      final resp = json.decode(response.body);
      Navigator.pop(context); // Quitar loader

      if (response.statusCode == 200 && resp['ok'] == true) {
        // Éxito: Mostrar diálogo y limpiar/regresar
        WarningSuccessDialog().show(
          context,
          title: "${resp['title']}",
          message: "Agente confirmado con éxito",
          tipo: 0, // Tipo éxito
          onOkay: () {
            setState(() {
              showForm = false; // Regresar al escáner
            });
          },
        );
      } else {
        _showWarning(resp['message'] ?? "No se pudo confirmar");
      }
    } catch (e) {
      Navigator.pop(context);
      _showWarning("Error al conectar con el servidor");
    }
  }

  // Lógica de escaneo adaptada
  Future<void> startScan() async {
    // Aquí iría tu lógica de FlutterBarcodeScanner
    String codigoQR = await FlutterBarcodeScanner.scanBarcode("#9580FF", "Cancelar", true, ScanMode.QR);
    if (codigoQR != "-1") {
      fetchSearchAgent(codigoQR);
    } 
  }

  void _showWarning(String message) {
    WarningSuccessDialog().show(
      context,
      title: "¡Atención! $message",
      // message: message,
      tipo: 1, // Tipo error/advertencia
      onOkay: () {},
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(
          elevation: 20,
          backgroundColor: Theme.of(context).cardColor,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Procesando...', style: Theme.of(context).textTheme.bodyMedium),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Función auxiliar para mostrar la hora formateada en el widget
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }
  
  @override
Widget build(BuildContext context) {
  // Obtenemos la altura total disponible de la pantalla
  final double screenHeight = MediaQuery.of(context).size.height;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: !showForm 
      ? Container(
          // Forzamos al contenedor a medir casi toda la pantalla
          // Restamos un poco por el AppBar y el TabBar (aprox 200)
          height: screenHeight * 0.7, 
          width: double.infinity,
          alignment: Alignment.center, // Esto centra el hijo vertical y horizontalmente
          child: _buildScanButton(),
        )
      : ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [_buildTripForm()],
        ),
  );
}
  // 1. Vista de Escaneo
  Widget _buildScanButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
          children: [
            const Icon(Icons.qr_code_scanner, size: 60, color: Colors.blue),
            const SizedBox(height: 15),
            Text(
              "Escanee el QR del Agente",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                fixedSize: const Size(180, 40),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Escanear', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: startScan,
            ),
          ],
        ),
      ),
    );
  }

  // 2. Formulario Ajustado (Sin scroll y con colores de estado)
  Widget _buildTripForm() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ajusta al contenido
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- TARJETA 1: INFORMACIÓN DEL AGENTE ---
        _buildCustomCard(
          padding: 15, // Padding reducido para ahorrar espacio
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAgentInfoLabel("Agente:", agentName),
              const SizedBox(height: 10),
              _buildAgentInfoLabel("Compañía:", companyName),
              const SizedBox(height: 10),
              _buildAgentInfoLabel(
                "Estado:",
                agentStatus,
                // Lógica de color: Verde si es Activo, Rojo de lo contrario
                valueColor: agentStatus.toLowerCase().contains("activo")
                    ? Colors.green 
                    : Colors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), 

        // --- TARJETA 2: TIPO DE VIAJE ---
        _buildCustomCard(
          padding: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tipo de Viaje:",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                height: 45, // Altura fija compacta
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTripType,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: ["Entrada", "Salida"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Ligeramente más pequeño para evitar scroll
                          color: Colors.black,
                        ),),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedTripType = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // --- TARJETA 3: CONFIRMACIÓN Y BOTONES ---
        // Reemplaza la Tarjeta 3 en tu método _buildTripForm:

        _buildCustomCard(
          padding: 15,
          child: Column(
            children: [
              const Text(
                "¿Confirmar para la siguiente hora?",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              
              // Contenedor interactivo de la hora
              GestureDetector(
                onTap: () => _selectTime(context), // Al tocar, abre el reloj
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF4FC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)), // Sutil borde azul
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF546E7A), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        _formatTime(selectedTime), // Muestra la hora seleccionada
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF37474F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showForm = false;
                          // Limpiar datos...
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Cancelar", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => fetchConfirmTrip(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E67A2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Confirmar", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget auxiliar ajustado para controlar padding
  Widget _buildCustomCard({required Widget child, double padding = 20}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Widget auxiliar de etiquetas optimizado
  Widget _buildAgentInfoLabel(String label, String value, {Color valueColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // Ligeramente más pequeño para evitar scroll
            color: valueColor,
          ),
        ),
      ],
    );
  }
}