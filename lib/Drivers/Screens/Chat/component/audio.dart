import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class AudioContainer extends StatefulWidget {
  final String base64Audio;
  final Color colorIcono;

  const AudioContainer({required this.base64Audio, required this.colorIcono});

  @override
  _AudioContainerState createState() =>
      _AudioContainerState(base64Audio: base64Audio, colorIcono: colorIcono);
}

class _AudioContainerState extends State<AudioContainer> {
  final String base64Audio;
  final Color colorIcono;
  late AudioPlayer _audioPlayer;
  bool audioPlaying = false;
  Map<String, File> tempFiles = {};
  Duration? audioDuration;

  _AudioContainerState({required this.base64Audio, required this.colorIcono});

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
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
  );
}



  void playAudio() async {
  try {
    if (!tempFiles.containsKey(base64Audio)) {
      List<int> audioBytes = base64.decode(base64Audio);
      File newTempFile = await _writeTempFile(audioBytes);
      if (newTempFile.existsSync()) {
        tempFiles[base64Audio] = newTempFile;
      } else {
        print('Error al crear el archivo temporal');
        return;
      }
    }

    await _audioPlayer.play(UrlSource(tempFiles[base64Audio]!.path));// Specify that the audio source is local
    final duration = await _audioPlayer.getDuration(); // Get the audio duration
    setState(() {
      audioPlaying = true;
      audioDuration = duration;
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

  Future<File> _writeTempFile(List<int> audioBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/temp_audio.wav'; // Mantener la extensión como wav
    return File(tempPath).writeAsBytes(audioBytes);
  }
}

void deleteAllTempAudioFiles() async {
  try {
    final tempDir = await getTemporaryDirectory();
    final tempFiles = tempDir.listSync();

    for (final file in tempFiles) {
      if (file is File && file.path.endsWith('.wav')) { // Cambiar la extensión a wav
        await file.delete();
      }
    }
    print('Archivos temporales de audio eliminados con éxito');
  } catch (e) {
    print('Error al eliminar archivos temporales de audio: $e');
  }
}