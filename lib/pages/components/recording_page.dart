import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:truesight/widgets/page_navigator.dart';
import 'package:record/record.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key, required this.navigatorController});
  final PageNavigatorController navigatorController;

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  bool isRecording = false;
  var maxDuration = Duration(seconds: 15);
  late Timer recordingTimer;
  late final RecorderController controller;
  PlayerController playerController = PlayerController();
  Directory appDocDir = Directory(''); // Directory for the recording

  @override
  void initState() {
    super.initState();
    widget.navigatorController.canProceed = false;
    controller = RecorderController();
    recordingTimer = Timer(Duration(seconds: 0), () {});
  }

  @override
  void dispose() {
    recordingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getApplicationDocumentsDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          appDocDir = snapshot.data as Directory;
        } else {
          return CircularProgressIndicator();
        }

        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Record your surroundings", style: TextStyle(fontSize: 20)),
              if (Directory(appDocDir.path + '/recording.m4a').existsSync())
                AudioFileWaveforms(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    200.0,
                  ),
                  playerController: playerController,
                ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: AudioWaveforms(
                  size: Size(MediaQuery.of(context).size.width, 200.0),
                  recorderController: controller,
                  enableGesture: true,
                  waveStyle: WaveStyle(
                    backgroundColor: Colors.tealAccent,
                    spacing: 8.0,
                    showBottom: false,
                    extendWaveform: true,
                    showMiddleLine: false,
                    scaleFactor: 2.0,
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isRecording ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      iconSize: 80.0,
                      onPressed: () async {
                        if (isRecording) {
                          await controller.stop();
                          setState(() {
                            isRecording = false;
                            recordingTimer.cancel();
                          });
                        } else {
                          await controller.record(path: appDocDir.path + '/recording.m4a');
                          setState(() {
                            isRecording = true;
                            recordingTimer = Timer(maxDuration, () async {
                            await controller.stop();
                            
                          });
                          });

                          
                        }
                      },
                      icon: Icon(isRecording ? Icons.stop : Icons.mic),
                    ),
                  ),
                  if (isRecording)
                    Text(
                      recordingTimer.tick.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
