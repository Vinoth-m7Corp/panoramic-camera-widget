import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CameraCallback = void Function();
typedef CameraExposureChangedCallback = void Function(String mode);
typedef CameraGeneratingEquiCallback = void Function(String path);

class PanoramicCameraWidget extends StatefulWidget {
  final void Function()? onCameraStopped;
  final void Function()? onCameraStarted;
  final void Function()? onFinishClear;
  final void Function()? onFinishRelease;
  final void Function()? onPreparingToShoot;
  final void Function()? onCanceledPreparingToShoot;
  final void Function()? onTakingPhoto;
  final void Function()? onPhotoTaken;
  final void Function(String mode)? onExposureChanged;
  final void Function(String path)? onFinishGeneratingEqui;
  final void Function()? onRotatorConnected;
  final void Function()? onRotatorDisconnected;
  final void Function()? onStartedRotating;
  final void Function()? onFinishedRotating;
  final void Function(int isVertical)? onDeviceVerticalityChanged;
  final void Function(double direction)? onDirectionUpdated;
  final void Function(Map<String, dynamic> info)? onCompassEvent;
  final void Function(bool finished)? onShootingCompleted;
  final int outputHeight;
  final bool showGuide;

  const PanoramicCameraWidget({
    super.key,
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
    this.onCompassEvent,
    this.onShootingCompleted,
    this.onDirectionUpdated,
    this.outputHeight = 800,
    this.showGuide = true,
  });

  @override
  State<PanoramicCameraWidget> createState() => _PanoramicCameraWidgetState();
}

class _PanoramicCameraWidgetState extends State<PanoramicCameraWidget>
    with WidgetsBindingObserver {
  static const platform = MethodChannel('panoramic_channel');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    platform.setMethodCallHandler(_handleMethod);

    platform.invokeMethod('setOutputHeight', widget.outputHeight);
    platform.invokeMethod('setShowGuide', widget.showGuide);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onCameraStopped':
        widget.onCameraStopped?.call();
        break;
      case 'onCameraStarted':
        widget.onCameraStarted?.call();
        break;
      case 'onFinishClear':
        widget.onFinishClear?.call();
        break;
      case 'onFinishRelease':
        widget.onFinishRelease?.call();
        break;
      case 'preparingToShoot':
        widget.onPreparingToShoot?.call();
        break;
      case 'canceledPreparingToShoot':
        widget.onCanceledPreparingToShoot?.call();
        break;
      case 'takingPhoto':
        widget.onTakingPhoto?.call();
        break;
      case 'photoTaken':
        widget.onPhotoTaken?.call();
        break;
      case 'stitchingCompleted':
        widget.onFinishGeneratingEqui?.call(call.arguments);
        break;
      case 'shootingCompleted':
        widget.onShootingCompleted?.call(call.arguments);
        break;
      case 'onDirectionUpdated':
        widget.onDirectionUpdated?.call(call.arguments);
        break;
      case 'deviceVerticalityChanged':
        widget.onDeviceVerticalityChanged?.call(call.arguments);
        break;
      case 'compassEvent':
        widget.onCompassEvent?.call(Map<String, dynamic>.from(call.arguments));
        break;
      case 'onFinishGeneratingEqui':
        widget.onFinishGeneratingEqui?.call(call.arguments);
        break;
      case 'onExposureChanged':
        widget.onExposureChanged?.call(call.arguments);
        break;
      case 'onRotatorConnected':
        widget.onRotatorConnected?.call();
        break;
      case 'onRotatorDisconnected':
        widget.onRotatorDisconnected?.call();
        break;
      case 'onStartedRotating':
        widget.onStartedRotating?.call();
        break;
      case 'onFinishedRotating':
        widget.onFinishedRotating?.call();
        break;
      default:
        throw MissingPluginException('not implemented');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      platform.invokeMethod('onResume');
    } else if (state == AppLifecycleState.paused) {
      platform.invokeMethod('onPause');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AndroidView(viewType: 'panoramic_view');
  }
}
