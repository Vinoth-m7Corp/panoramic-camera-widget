import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panoramic_camera/panoramic_camera_controller.dart';
import 'package:panoramic_camera/panoramic_camera_interface.dart';

typedef CameraCallback = void Function();
typedef CameraExposureChangedCallback = void Function(String mode);
typedef CameraGeneratingEquiCallback = void Function(String path);

class PanoramicCameraWidget extends StatefulWidget {
  final PanoramicCameraController controller;
  final int outputHeight;
  final bool showGuide;

  const PanoramicCameraWidget({
    super.key,
    this.outputHeight = 800,
    this.showGuide = true,
    required this.controller,
  });

  @override
  State<PanoramicCameraWidget> createState() => _PanoramicCameraWidgetState();
}

class _PanoramicCameraWidgetState extends State<PanoramicCameraWidget>
    with WidgetsBindingObserver
    implements PanoramicCameraInterface {
  static const platform = MethodChannel('panoramic_channel');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    platform.setMethodCallHandler(_handleMethod);
    widget.controller.attach(this);
    platform.invokeMethod('setOutputHeight', widget.outputHeight);
    platform.invokeMethod('setShowGuide', widget.showGuide);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && Platform.isAndroid) {
        await platform.invokeMethod('onResume');
      }
    });
  }

  @override
  Future<void> invokeMethod(String method) async {
    await platform.invokeMethod(method);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onCameraStopped':
        widget.controller.onCameraStopped?.call();
        break;
      case 'onCameraStarted':
        widget.controller.onCameraStarted?.call();
        break;
      case 'onFinishClear':
        widget.controller.onFinishClear?.call();
        break;
      case 'onFinishRelease':
        widget.controller.onFinishRelease?.call();
        break;
      case 'preparingToShoot':
        widget.controller.onPreparingToShoot?.call();
        break;
      case 'canceledPreparingToShoot':
        widget.controller.onCanceledPreparingToShoot?.call();
        break;
      case 'takingPhoto':
        widget.controller.onTakingPhoto?.call();
        break;
      case 'photoTaken':
        widget.controller.onPhotoTaken?.call();
        break;
      case 'shootingCompleted':
        widget.controller.onShootingCompleted?.call(call.arguments);
        break;
      case 'onDirectionUpdated':
        widget.controller.onDirectionUpdated?.call(call.arguments);
        break;
      case 'deviceVerticalityChanged':
        widget.controller.onDeviceVerticalityChanged?.call(call.arguments);
        break;
      case 'compassEvent':
        final args = Map<String, dynamic>.from(call.arguments as Map);
        widget.controller.onCompassEvent?.call(args);
        break;
      case 'onFinishGeneratingEqui':
        widget.controller.onFinishGeneratingEqui?.call(call.arguments);
        break;
      case 'onExposureChanged':
        widget.controller.onExposureChanged?.call(call.arguments);
        break;
      case 'onRotatorConnected':
        widget.controller.onRotatorConnected?.call();
        break;
      case 'onRotatorDisconnected':
        widget.controller.onRotatorDisconnected?.call();
        break;
      case 'onStartedRotating':
        widget.controller.onStartedRotating?.call();
        break;
      case 'onFinishedRotating':
        widget.controller.onFinishedRotating?.call();
        break;
      case 'onUpdateIndicators':
        final args = Map<String, dynamic>.from(call.arguments as Map);
        widget.controller.onUpdateIndicators?.call(args);
        break;
      default:
        throw MissingPluginException('not implemented');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.detach();
    platform.setMethodCallHandler(null);
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
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          return SizedBox(
            height: height,
            width: width,
            child: UiKitView(
              viewType: 'panoramic_view',
              creationParams: {'height': height, 'width': width},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          );
        },
      );
    }
    return const AndroidView(viewType: 'panoramic_view');
  }
}
