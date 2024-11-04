import 'dart:async';

import 'package:flutter/material.dart';
import 'package:truesight/widgets/page_navigator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key, required this.navigatorController});
  final PageNavigatorController navigatorController;

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  bool isRecording = false;
  var maxDuration = Duration(seconds: 5);
  late Timer recordingTimer;

  @override
  void initState() {
    super.initState();
    recordingTimer = Timer(Duration(seconds: 0), () {});
  }

  @override
  void dispose() {
    recordingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Record your surroundings", style: TextStyle(fontSize: 20)),
          Container(height: 200, width: 100),
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
            iconSize: 60.0,
            onPressed: () async {
              if (isRecording) {
                // if we're recording, stop recording and change icon back to mic
                setState(() {
                  isRecording = false;
                   recordingTimer.cancel();
                });
               

              } else {
                // if we're not recording, start recording and change icon to stop
                setState(() {
                  isRecording = true;
                });
                
                // when the timer runs out, stop recording
                recordingTimer = Timer(maxDuration, () {
                  setState(() {
                    isRecording = false;
                  });
                });
              }
            },
            icon: Icon(isRecording ? Icons.stop : Icons.mic),
          ),
          ),


        ],
      ),
    );
  }
}
