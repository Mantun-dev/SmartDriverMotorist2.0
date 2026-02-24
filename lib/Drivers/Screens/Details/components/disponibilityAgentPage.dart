import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/components/warning_dialog.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- PANTALLA 1: MI DISPONIBILIDAD ---
class AvailabilityScreen extends StatefulWidget {
  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {

  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";

  List<dynamic> activeAbsences = [];
  List<dynamic> historyAbsences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAbsences();
  }

  Future<void> fetchAbsences() async {
    try {
      http.Response response = await http
          .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
      final data = DriverData.fromJson(json.decode(response.body));

      final responses = await http.get(
        Uri.parse('$ip/apis/getDriverAbsences/${data.driverId.toString()}'),
      );

      if (responses.statusCode == 200) {
        final decodedData = json.decode(responses.body);
        final List<dynamic> allData = decodedData['data'];

        setState(() {
          // Filtramos según la lógica que definimos en el SP
          activeAbsences = allData.where((e) => e['displayStatus'] == 'Activa').toList();
          historyAbsences = allData.where((e) => e['displayStatus'] == 'Historial').toList();
          print("Ausencias activas: ${activeAbsences}, Historial: ${historyAbsences}");
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error cargando ausencias: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: fetchAbsences,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min es vital aquí
          
          mainAxisSize: MainAxisSize.min, 
          children: [
            // --- BLOQUE DE NOTA ---
            _buildNoteCard(),
            const SizedBox(height: 25),
      
            const Text("Próxima Ausencia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
      
            // Mostramos la activa o un mensaje si no hay
            activeAbsences.isNotEmpty 
            ? Column(
                children: activeAbsences.map((abs) => _buildAbsenceCard(abs)).toList(),
              )
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("No tienes ausencias próximas programadas."),
              ),
      
            const SizedBox(height: 25),
            const Text("Historial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
      
            // Renderizamos el historial real
            ...historyAbsences.map((abs) => _buildHistoryItem(abs)).toList(),
      
            const SizedBox(height: 25),
            _buildBottomButton(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- MANTENEMOS TUS MÉTODOS DE DISEÑO (Nota, Tarjeta, Item, Botón) ---
  // Asegúrate de que ninguno de estos métodos use 'Expanded', 'Spacer' o 'Flexible'
  // ya que dentro de un SingleChildScrollView causarían el mismo error.

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Nota ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Los permisos deben solicitarse con 24h de anticipación. Para emergencias hoy, contacte a su coordinador.",
            style: TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenceCard(Map<String, dynamic> abs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.calendar_today_outlined, 
            "${abs['Fecha inicio']} - ${abs['Fecha fin']}", Colors.blue),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.description_outlined, abs['Tipo de ausencia'] ?? "N/A", Colors.blue),
          const SizedBox(height: 12),
          
          // Estado con punto verde
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 14),
                const SizedBox(width: 12),
                const Text("Activa", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.green)),
              ],
            ),
          ),
          
          // Detalles adicionales opcionales
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFEEEEEE)),
          ),
          Text("Notas: ${abs['Notas'] ?? 'Sin notas'}", 
            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text("Por: ${abs['Registrado por'] ?? 'N/A'}", 
            style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> abs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: Theme(
        // Quitamos las líneas divisorias que trae ExpansionTile por defecto
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.calendar_today_outlined, color: Colors.blue, size: 20),
          title: Text(
            "${abs['Fecha inicio']} - ${abs['Fecha fin']}",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            "${abs['Tipo de ausencia']}",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 50, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MOSTRAR NOTAS
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xFFEEEEEE)),
                  ),
                  Text("Notas: ${abs['Notas'] ?? 'Sin notas'}", 
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text("Por: ${abs['Registrado por'] ?? 'N/A'}", 
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las filas de detalle dentro del despliegue
  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        children: [
          TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return ElevatedButton(
        onPressed: () async{
          final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewAbsenceScreen()),
        );

        // 2. Si el resultado es true, refrescamos los datos
        if (result == true) {
          setState(() {
            isLoading = true; // Mostramos el loader para dar feedback visual
          });
          fetchAbsences();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E67A2),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text("REGISTRAR NUEVA AUSENCIA", 
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

// --- PANTALLA 2: NUEVA AUSENCIA ---
class NewAbsenceScreen extends StatefulWidget {
  @override
  _NewAbsenceScreenState createState() => _NewAbsenceScreenState();
}

class _NewAbsenceScreenState extends State<NewAbsenceScreen> {
  String? selectedType;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController _notesController = TextEditingController();

  Future<void> fetchRegisterAbsence() async {
    if (selectedType == null || startDate == null || endDate == null) {
      _showWarning("Por favor complete todos los campos obligatorios.");
      return;
    }

    final prefs = new PreferenciasUsuario();
    String ip = "https://driver.smtdriver.com";

    http.Response resp = await http
          .get(Uri.parse('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
      final data = DriverData.fromJson(json.decode(resp.body));

    _showLoadingDialog();

    // Formateamos las fechas para el SP (YYYY-MM-DD)
    String formattedStart = DateFormat('yyyy-MM-dd').format(startDate!);
    String formattedEnd = DateFormat('yyyy-MM-dd').format(endDate!);

    Map dataBody = {
      'driverId': data.driverId.toString(), // ID del conductor logueado
      'startDate': formattedStart,
      'endDate': formattedEnd,
      'absenceType': selectedType,
      'notes': _notesController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('$ip/apis/registerAbsence'),
        body: dataBody,
      );

      final resp = json.decode(response.body);
      Navigator.pop(context); // Quitar loader

      if (response.statusCode == 200 && resp['ok'] == true) {
        WarningSuccessDialog().show(
          context,
          title: resp['title'] ?? "¡Éxito!",
          message: resp['message'],
          tipo: 0, // Éxito
          onOkay: () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          }, // Regresar y avisar que hubo cambios
        );
      } else {
        _showWarning(resp['message'] ?? "Error al registrar");
      }
    } catch (e) {
      Navigator.pop(context);
      _showWarning("Error de conexión con el servidor");
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


  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      //personalizar texto idioma español
      helpText: isStart ? "Selecciona fecha de inicio" : "Selecciona fecha final",
      cancelText: "Cancelar",
      confirmText: "Aceptar",      
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked; else endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Nueva ausencia", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E67A2),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Tipo de ausencia:"),
              _buildDropdown(),
              const SizedBox(height: 20),
              _buildLabel("Desde:"),
              _buildDateTile(startDate, () => _selectDate(context, true)),
              const SizedBox(height: 20),
              _buildLabel("Hasta:"),
              _buildDateTile(endDate, () => _selectDate(context, false)),
              const SizedBox(height: 20),
              _buildLabel("Notas adicionales (opcional):"),
              _buildNotesField(),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          isExpanded: true,
          hint: Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Color(0xFF1A4D8C)),
              const SizedBox(width: 10),
              const Text("Seleccione..."),
            ],
          ),
          items: ["Falla mecánica", "Incapacidad", "Emergencia familiar","Permiso"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (val) => setState(() => selectedType = val),
        ),
      ),
    );
  }

  Widget _buildDateTile(DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF1A4D8C)),
                const SizedBox(width: 12),
                Text(date == null ? "DD/MM/AAAA" : DateFormat('dd/MM/yyyy').format(date!),
                    style: TextStyle(color: date == null ? Colors.grey : Colors.black)),
              ],
            ),
            const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Escribe el motivo o detalles de tu ausencia...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text("Cancelar", style: TextStyle(color: Colors.black87)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              fetchRegisterAbsence();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E67A2),
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}