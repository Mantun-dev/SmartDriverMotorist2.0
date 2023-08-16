import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class AudioContainer extends StatefulWidget {
  final String audioName;
  final int idSala;
  final Color colorIcono;

  const AudioContainer({required this.audioName, required this.colorIcono, required this.idSala});

  @override
  _AudioContainerState createState() =>
      _AudioContainerState(audioName: audioName, colorIcono: colorIcono, idSala: idSala);
}

class _AudioContainerState extends State<AudioContainer> {
  final String audioName;
  final Color colorIcono;
  final int idSala;
  late AudioPlayer _audioPlayer;
  bool audioPlaying = false;
  Map<String, File> tempFiles = {};
  Duration? audioDuration;
  String base64Audio = '';
  bool cargarAudio = false;
  String audioPath = '';
  Duration? audioPosition;

  _AudioContainerState({required this.audioName, required this.colorIcono, required this.idSala});

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    getAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cargarAudio == false ? CircularProgressIndicator()
            : IconButton(
              onPressed: () {
                setState(() {
                  if (!audioPlaying) {
                    playAudio();
                  } else {
                    stopAudio();
                  }
                });
              },
              icon: !audioPlaying
                ? Icon(Icons.play_arrow, color: colorIcono)
                : Icon(Icons.stop, color: Colors.red),
            ),
          if (audioDuration != null)
            Row(
              children: [
                Text(
                  '${audioPosition?.inMinutes ?? 0}:${(audioPosition?.inSeconds ?? 0).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: colorIcono),
                ),
                Text(
                  ' / ',
                  style: TextStyle(fontSize: 10, color: colorIcono),
                ),
                Text(
                  '${audioDuration!.inMinutes}:${(audioDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: colorIcono),
                ),
                Icon(
                  Icons.done,
                  size: 16,
                  color: Colors.transparent,
                )
              ],
            ),
        ],
      ),
    );
  }

  void getAudio() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/$audioName'); // Construct the file path

      if (await audioFile.exists()) {
        setState(() {
          cargarAudio = true;
          audioPath = audioFile.path;
        });
        print('Audio encontrado en el dispositivo: $audioPath');
      } else {
        // El archivo no existe en el dispositivo, intenta descargarlo del servidor
        final response = await http.get(Uri.parse('https://apichat.smtdriver.com/api/audios/$audioName'));
        print('https://apichat.smtdriver.com/api/audios/$audioName');
        if (response.statusCode == 200) {
          // Guardar el archivo descargado en el dispositivo
          await audioFile.writeAsBytes(response.bodyBytes);

          setState(() {
            cargarAudio = true;
            audioPath = audioFile.path;
          });

          print('Audio descargado desde el servidor y encontrado en el dispositivo: $audioPath');
        } else {
          print('El archivo de audio no existe en el servidor ni en el dispositivo');
        }
      }
    } catch (e) {
      print('Error al verificar la existencia del audio: $e');
    }
  }

  void playAudio() async {
    try {
      await _audioPlayer.play(UrlSource(audioPath), position: audioPosition);// Specify that the audio source is local
      final duration = await _audioPlayer.getDuration();

      setState(() {
        audioPlaying = true;
        audioDuration = duration;
      });

      _audioPlayer.onPositionChanged.listen((position) {
        setState(() {
          audioPosition = position;
        });
      });

      _audioPlayer.onPlayerComplete.listen((position) {
        if (audioPlaying) {
          stopAudio2();
        }
      });
    } catch (e) {
      print('Error al reproducir el audio: $e');
    }
  }

  void stopAudio() async {
    await _audioPlayer.stop();

    setState(() {
      audioPlaying = false;
    });
  }

  void stopAudio2() async {
    await _audioPlayer.stop();

    setState(() {
      audioPlaying = false;
      audioPosition = Duration(seconds: 0);
    });
  }

}

void deleteAllTempAudioFiles() async {
  try {
    final tempDir = await getTemporaryDirectory();
    final tempFiles = tempDir.listSync();

    for (final file in tempFiles) {
      if (file is File && file.path.endsWith('.m4a')) { // Cambiar la extensión a wav
        await file.delete();
      }
    }
    print('Archivos temporales de audio eliminados con éxito');
  } catch (e) {
    print('Error al eliminar archivos temporales de audio: $e');
  }
}