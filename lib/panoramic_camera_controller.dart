import 'package:flutter/material.dart';
import 'package:panoramic_camera/constants.dart';
import 'package:panoramic_camera/panoramic_camera_interface.dart';

class PanoramicCameraController {
  PanoramicCameraInterface? _cameraControl;

  PanoramicCameraController({
    this.onCameraStopped,
    this.onCameraStarted,
    this.onFinishClear,
    this.onFinishRelease,
    this.onPreparingToShoot,
    this.onCanceledPreparingToShoot,
    this.onTakingPhoto,
    this.onPhotoTaken,
    this.onExposureChanged,
    this.onFinishGeneratingEqui,
    this.onRotatorConnected,
    this.onRotatorDisconnected,
    this.onStartedRotating,
    this.onFinishedRotating,
    this.onDeviceVerticalityChanged,
    this.onDirectionUpdated,
    this.onCompassEvent,
    this.onShootingCompleted,
    this.onUpdateIndicators,
  });

  void attach(PanoramicCameraInterface cameraControl) {
    _cameraControl = cameraControl;
  }

  void detach() {
    _cameraControl = null;
  }

  Future<void> onResume() async {
    return _cameraControl?.invokeMethod(PanoramicMethodNames.onResume);
  }

  Future<void> onPause() async {
    return _cameraControl?.invokeMethod(PanoramicMethodNames.onPause);
  }

  Future<void> startShooting() async {
    await _cameraControl?.invokeMethod(PanoramicMethodNames.startShooting);
  }

  Future<void> finishShooting() async {
    await _cameraControl?.invokeMethod(PanoramicMethodNames.finishShooting);
  }

  VoidCallback? onCameraStopped;
  VoidCallback? onCameraStarted;
  VoidCallback? onFinishClear;
  VoidCallback? onFinishRelease;
  VoidCallback? onPreparingToShoot;
  VoidCallback? onCanceledPreparingToShoot;
  VoidCallback? onTakingPhoto;
  VoidCallback? onPhotoTaken;
  ValueChanged<String>? onExposureChanged;
  ValueChanged<String>? onFinishGeneratingEqui;
  VoidCallback? onRotatorConnected;
  VoidCallback? onRotatorDisconnected;
  VoidCallback? onStartedRotating;
  VoidCallback? onFinishedRotating;
  ValueChanged<int>? onDeviceVerticalityChanged;
  ValueChanged<double>? onDirectionUpdated;
  ValueChanged<Map<String, dynamic>>? onCompassEvent;
  ValueChanged<Map<String, dynamic>>? onUpdateIndicators;
  ValueChanged<bool>? onShootingCompleted;
}
