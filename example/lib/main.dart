import 'package:flutter/material.dart';
import 'package:panoramic_camera/panoramic_camera.dart';
import 'package:panoramic_camera/panoramic_camera_controller.dart';

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
  late PanoramicCameraController controller;

  @override
  void initState() {
    super.initState();
    controller = PanoramicCameraController(
      onCameraStarted: () {
        print('Camera started');
      },
      onFinishRelease: () {
        print('Finished release');
      },
      onShootingCompleted: (value) {},
      onCameraStopped: () {},
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
      onCompassEvent: (value) {
        print('onCompassEvent: ${value.toString()}');
      },
      onUpdateIndicators: (value) {
        print('onUpdateIndicators: ${value.toString()}');
      },
      onFinishGeneratingEqui: (value) {
        debugPrint("---------------Foto creada---------------");
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
            helperText = 'Rotate left   right or tap to restart';
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
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.camera_alt),
              onPressed: () {
                controller.startShooting();
              }),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  helperText,
                  style: const TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 630,
                  width: 330,
                  child: PanoramicCameraWidget(
                    showGuide: true,
                    controller: controller,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
