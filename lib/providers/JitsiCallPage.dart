import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart'; // Importación correcta

class JitsiCallPage extends StatefulWidget {
  final String roomId;
  final String name;
  final String serverUrl; // Añadimos serverUrl como parámetro
  const JitsiCallPage({
    required this.roomId,
    required this.name,
    this.serverUrl = "https://jitsi.smtdriver.com", // Valor por defecto
    super.key,
  });

  @override
  _JitsiCallPageState createState() => _JitsiCallPageState();
}

class _JitsiCallPageState extends State<JitsiCallPage> {
  final JitsiMeet _jitsiMeetPlugin = JitsiMeet(); // Instancia de JitsiMeet

  @override
  void initState() {
    super.initState();
    // Llamar a _joinMeeting directamente al iniciar la página
    _joinMeeting();
  }

  Future<void> _joinMeeting() async {
    if (widget.roomId.isEmpty) {
      debugPrint('ERROR: Room ID is empty');
      // Maneja este caso, quizás mostrando un error al usuario y cerrando la página
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    var options = JitsiMeetConferenceOptions(
      serverURL: widget.serverUrl, // Usar el serverUrl del widget
      room: widget.roomId,
      configOverrides: {
        // Configuraciones para iniciar el audio y video mutados
        "startWithAudioMuted": false, // False para que el audio esté activado al inicio
        "startWithVideoMuted": false, // False para que el video esté activado al inicio
        "subject": "Llamada de ${widget.name}", // Asunto de la sala
        // Puedes añadir otras configuraciones aquí según necesites, por ejemplo:
        // "prejoinPageEnabled": false, // Para saltar la pantalla de pre-unión
        // "enableClosePage": false, // Para evitar que la vista se cierre automáticamente al salir
      },
      featureFlags: {
        // Puedes habilitar o deshabilitar funcionalidades aquí.
        // Copié algunas de tu ejemplo de main.dart que pueden ser útiles.
        // Asegúrate de que los FeatureFlags que uses sean válidos para tu versión de SDK.
        FeatureFlags.addPeopleEnabled: true,
        FeatureFlags.welcomePageEnabled: true,
        FeatureFlags.preJoinPageEnabled: true,
        FeatureFlags.unsafeRoomWarningEnabled: true,
        FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution720p,
        FeatureFlags.audioFocusDisabled: false, // False si quieres que la app tome el foco de audio
        FeatureFlags.audioMuteButtonEnabled: true,
        FeatureFlags.audioOnlyButtonEnabled: true,
        // FeatureFlags.calenderEnabled: true, // Revisa si necesitas esto
        FeatureFlags.callIntegrationEnabled: false, // Desactiva la integración con llamadas nativas
        FeatureFlags.carModeEnabled: true,
        // FeatureFlags.closeCaptionsEnabled: true, // Revisa si necesitas esto
        FeatureFlags.conferenceTimerEnabled: true,
        FeatureFlags.chatEnabled: true,
        FeatureFlags.filmstripEnabled: true,
        FeatureFlags.fullScreenEnabled: true,
        FeatureFlags.helpButtonEnabled: true,
        FeatureFlags.inviteEnabled: true,
        FeatureFlags.androidScreenSharingEnabled: true,
        FeatureFlags.speakerStatsEnabled: true,
        FeatureFlags.kickOutEnabled: true,
        FeatureFlags.liveStreamingEnabled: false, // Desactivado por defecto, actívalo si lo usas
        FeatureFlags.lobbyModeEnabled: true,
        FeatureFlags.meetingNameEnabled: true,
        FeatureFlags.meetingPasswordEnabled: true,
        FeatureFlags.notificationEnabled: true,
        FeatureFlags.overflowMenuEnabled: true,
        FeatureFlags.pipEnabled: true,
        FeatureFlags.pipWhileScreenSharingEnabled: true,
        FeatureFlags.preJoinPageHideDisplayName: false, // False para mostrar el nombre
        FeatureFlags.raiseHandEnabled: true,
        FeatureFlags.reactionsEnabled: true,
        FeatureFlags.recordingEnabled: false, // Desactivado por defecto
        FeatureFlags.replaceParticipant: true,
        FeatureFlags.securityOptionEnabled: true,
        FeatureFlags.serverUrlChangeEnabled: false, // Desactiva la opción de cambiar URL
        FeatureFlags.settingsEnabled: true,
        FeatureFlags.tileViewEnabled: true,
        FeatureFlags.videoMuteEnabled: true,
        FeatureFlags.videoShareEnabled: true,
        FeatureFlags.toolboxEnabled: true,
        FeatureFlags.iosRecordingEnabled: false, // Desactivado por defecto
        FeatureFlags.iosScreenSharingEnabled: true,
        FeatureFlags.toolboxAlwaysVisible: true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: widget.name,
        // Puedes añadir email y avatar si los tienes en tu modelo de usuario
        // email: "user@example.com",
        // avatar: "https://example.com/avatar.png",
      ),
    );

    try {
      // No pasamos un listener explícito aquí
      await _jitsiMeetPlugin.join(options);
    } catch (error) {
      debugPrint("❌ Error al intentar unirse a la reunión de Jitsi: $error");
      // Maneja el error, por ejemplo, mostrando un SnackBar y saliendo de la pantalla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar la llamada: $error')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    // Aunque no tengamos listeners explícitos, siempre es bueno asegurar la limpieza.
    // jitsi_meet_flutter_sdk maneja el cierre de la vista de Jitsi cuando se hace pop de la ruta.
    // Sin embargo, si quieres forzar un cierre, puedes usar:
    // _jitsiMeetPlugin.closeMeeting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Conectando a la llamada Jitsi...'),
            Text('Espera un momento, por favor.'),
          ],
        ),
      ),
    );
  }
}