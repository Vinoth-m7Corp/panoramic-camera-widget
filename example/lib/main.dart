import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panoramic_camera/panoramic_camera.dart';
import 'package:panoramic_camera/panoramic_camera_controller.dart';

void main() {
  runApp(const AppWidget());
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: MyApp(),
      ),
    );
  }
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
  bool isExpanded = false;
  int photos = 0;
  bool isHide = false;
  double pitch = 0.0;
  double roll = 0.0;
  double percentage = 0.0;
  late PanoramicCameraController controller;

  @override
  void initState() {
    super.initState();
    controller = PanoramicCameraController(
      onCameraStarted: () {
        debugPrint('Camera started');
      },
      onFinishRelease: () {
        debugPrint('Finished release');
      },
      onShootingCompleted: (bool value) {
        debugPrint('onShootingCompleted $value');
        isShootingStarted = false;
      },
      onShootingCanceled: (bool value) {
        debugPrint('onShootingCanceled $value');
      },
      onCameraStopped: () {
        debugPrint('onCameraStopped');
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
      },
      onDirectionUpdated: (value) {
        // print('Device onDirectionUpdated changed: $value');
      },
      onCompassEvent: (value) {},
      onUpdateIndicators: (value) {
        setState(() {
          percentage = value.percentage;
          pitch = value.pitch;
          roll = value.roll;
        });
      },
      onFinishGeneratingEqui: (path) async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Generated Image"),
              content: SizedBox(
                  width: 250, height: 250, child: Image.file(File(path))),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
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
            helperText = 'Rotate left right or tap to restart';
          });
        } else {
          setState(() {
            helperText = 'Tap to finish when ready or continue rotating';
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Plugin example app'),
      // ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.stop),
            onPressed: () {
              controller.stopShootingAndRestart();
            },
          ),
          FloatingActionButton(
            child: const Icon(Icons.camera_alt),
            onPressed: () {
              isShootingStarted = true;
              controller.startShooting();
            },
          ),
          FloatingActionButton(
            child: const Icon(Icons.change_circle),
            onPressed: () {
              setState(() {
                isHide = !isHide;
              });
            },
          ),
          FloatingActionButton(
            child: const Icon(Icons.hide_image),
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            // duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.yellow)),
            width: double.infinity,
            height: isExpanded ? 600 : 200,
            child: PanoramicCameraWidget(
              showGuide: false,
              controller: controller,
              loadingWidget: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Center(
            child: Container(
              color: Colors.white,
              child: Text(
                  "isVertical: $isVertical pitch: ${pitch.toStringAsFixed(2)}  roll: ${roll.toStringAsFixed(2)}  percentage: ${percentage.toStringAsFixed(2)}"),
            ),
          )
        ],
      ),
    );
  }
}
