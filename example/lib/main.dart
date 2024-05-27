import 'package:flutter/material.dart';
import 'package:panoramic_camera/panoramic_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String helperText = "Loading";
  int isVertical = 0;
  bool isShootingStarted = false;
  int photos = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              Text(
                helperText,
                style: const TextStyle(color: Colors.black),
              ),
              Expanded(
                child: PanoramicCameraWidget(
                  showGuide: true,
                  onCameraStarted: () {
                    debugPrint("---------------onCameraStarted---------------");
                    setState(() {
                      helperText = 'Tap to start';
                      photos = 0;
                    });
                  },
                  onCameraStopped: () {
                    debugPrint("---------------onCameraStopped---------------");
                  },
                  onCanceledPreparingToShoot: () {
                    debugPrint("---------------onCameraStopped---------------");
                  },
                  onTakingPhoto: () {
                    setState(() {
                      helperText = 'Tacking photo';
                    });
                  },
                  onPhotoTaken: () {
                    debugPrint("---------------onPhotoTaken---------------");
                    photos++;
                    if (photos <= 0) {
                      setState(() {
                        helperText = 'Tap to start';
                      });
                    } else if (photos == 1) {
                      setState(() {
                        helperText = 'Rotate left or right or tap to restart';
                      });
                    } else {
                      setState(() {
                        helperText =
                            'Tap to finish when ready or continue rotating';
                      });
                    }
                  },
                  onDeviceVerticalityChanged: (int val) {
                    isVertical = val;
                    if (isVertical == 1) {
                      if (!isShootingStarted) {
                        setState(() {
                          helperText = 'Tap to start';
                        });
                      }
                    } else {
                      setState(() {
                        helperText = 'Hold the device vertically';
                      });
                    }
                    debugPrint(
                        "---------------onDeviceVerticalityChanged: $val---------------");
                  },
                ),
              ),
            ],
          )),
    );
  }
}
