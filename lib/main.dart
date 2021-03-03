
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_recorder/audio_recorder.dart';
//import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';

typedef void OnError(Exception exception);

void main() {
  runApp(new MaterialApp(home: new ExampleApp()));
}

class ExampleApp extends StatefulWidget {

  @override
  _ExampleAppState createState() => new _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  //FlutterSound flutterSound = new FlutterSound();
  AudioPlayer advancedPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache();
  String currentTime = "00:00:00";
  String completeTime= "00:00:00";
  String curTime = "00:00:00";
  String cmpTime= "00:00:00";
  Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();
  bool isPlaying = false;


  @override
  void initState(){
    super.initState();
    initPlayer();

  }

  void initPlayer(){
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.onAudioPositionChanged.listen((d) {
      setState(() {
        _duration = d;
        currentTime = _duration.toString().split(".")[0];
    });
    });

    advancedPlayer.onDurationChanged.listen((p) {
      setState(() {
     _position = p;
      completeTime = _position.toString().split(".")[0];
      }) ;
    });
  }

  String localFilePath;

  Widget slider() {
    return Slider(
        value: _position.inSeconds.toDouble(),
        min: 0.0,
        max: _duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            if(isPlaying==true){
            seekSecond(value.toInt());
            value = value;
            }
          });
        });
  }

  void seekSecond(int second){
    Duration newDuration = Duration(seconds: second);
    advancedPlayer.seek(newDuration);
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
          await AudioRecorder.start();
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration());
          _isRecording = isRecording;
          curTime = _duration.toString().split(".")[0];
        });

      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
      cmpTime = _position.toString().split(".")[0];

    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Audioplayer'),
        ),
        body: Stack(
        children: <Widget>[
         // Container(child: Text('Recording'),),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  FlatButton(onPressed: _isRecording ? null : _start, child: Text("start")),
                  FlatButton(onPressed: _isRecording ? _stop : null, child: Text("stop")),
                  // new Text(
                  //     "Audio recording duration : ${_recording.duration.toString()}"),
                  Text(curTime, style: TextStyle(fontWeight: FontWeight.w700),),
                  Text(" | "),
                  Text(cmpTime, style: TextStyle(fontWeight: FontWeight.w300),),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: RaisedButton(
                onPressed: () async{
                  int result = await advancedPlayer.play('https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3');
                  if(result == 1){
                    setState(() {
                      isPlaying = true;
                    });
                    print("Success");
                  }
                },
                child: Text("Network",),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width*0.8,
            height: 70,
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.7, left: MediaQuery.of(context).size.width*0.1),
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(50)
            ),
            child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      //slider(),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: (){
                          if(isPlaying){
                           advancedPlayer.pause();
                            setState(() {
                              isPlaying = false;
                            });
                          }else{
                            //audioCache.play('download.mp3');
                            advancedPlayer.resume();
                            setState(() {
                              isPlaying = true;
                            });
                          }
                        },
                      ),

                      SizedBox(width: 10,),
                      IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: (){
                          advancedPlayer.stop();
                          setState(() {
                            isPlaying = false;
                          });
                        },
                      ),
                      Text(currentTime, style: TextStyle(fontWeight: FontWeight.w700),),
                      Text(" | "),
                      Text(completeTime, style: TextStyle(fontWeight: FontWeight.w300),),
                    ],
                  ),
               ),
          // Container(
          //   margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.4, left: MediaQuery.of(context).size.width*0.1),
          //   child: slider(),
          // ),
        ],
        ),
    );
  }
}
