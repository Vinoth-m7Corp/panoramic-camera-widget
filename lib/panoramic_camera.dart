import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panoramic_camera/constants.dart';
import 'package:panoramic_camera/dto/indicators.dart';
import 'package:panoramic_camera/panoramic_camera_controller.dart';
import 'package:panoramic_camera/panoramic_camera_interface.dart';

typedef CameraCallback = void Function();
typedef CameraExposureChangedCallback = void Function(String mode);
typedef CameraGeneratingEquiCallback = void Function(String path);

class PanoramicCameraWidget extends StatefulWidget {
  final PanoramicCameraController controller;
  final int outputHeight;
  final bool showGuide;
  final Widget? loadingWidget;

  const PanoramicCameraWidget({
    super.key,
    this.outputHeight = 800,
    this.showGuide = true,
    required this.controller,
    this.loadingWidget,
  });

  @override
  State<PanoramicCameraWidget> createState() => _PanoramicCameraWidgetState();
}

class _PanoramicCameraWidgetState extends State<PanoramicCameraWidget>
    with WidgetsBindingObserver
    implements PanoramicCameraInterface {
  static const platform = MethodChannel('panoramic_channel');
  bool isLoading = false;
  double? lastHeight;
  double? lastWidth;

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
    if (Platform.isAndroid) isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        invokeMethod(PanoramicMethodNames.onResume);
      }
    });
  }

  @override
  Future<void> invokeMethod(String method) async {
    await platform.invokeMethod(method);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case PanoramicMethodNames.onCameraStopped:
        widget.controller.onCameraStopped?.call();
        break;
      case PanoramicMethodNames.onCameraStarted:
        setState(() {
          isLoading = false;
        });
        widget.controller.onCameraStarted?.call();
        break;
      case PanoramicMethodNames.onFinishClear:
        widget.controller.onFinishClear?.call();
        break;
      case PanoramicMethodNames.onFinishRelease:
        widget.controller.onFinishRelease?.call();
        break;
      case PanoramicMethodNames.preparingToShoot:
        widget.controller.onPreparingToShoot?.call();
        break;
      case PanoramicMethodNames.canceledPreparingToShoot:
        widget.controller.onCanceledPreparingToShoot?.call();
        break;
      case PanoramicMethodNames.takingPhoto:
        widget.controller.onTakingPhoto?.call();
        break;
      case PanoramicMethodNames.photoTaken:
        widget.controller.onPhotoTaken?.call();
        break;
      case PanoramicMethodNames.shootingCompleted:
        widget.controller.onShootingCompleted?.call(call.arguments);
        break;
      case PanoramicMethodNames.onDirectionUpdated:
        widget.controller.onDirectionUpdated?.call(call.arguments);
        break;
      case PanoramicMethodNames.deviceVerticalityChanged:
        widget.controller.onDeviceVerticalityChanged?.call(call.arguments);
        break;
      case PanoramicMethodNames.compassEvent:
        final args = Map<String, dynamic>.from(call.arguments as Map);
        widget.controller.onCompassEvent?.call(args);
        break;
      case PanoramicMethodNames.onFinishGeneratingEqui:
        widget.controller.onFinishGeneratingEqui?.call(call.arguments);
        break;
      case PanoramicMethodNames.onExposureChanged:
        widget.controller.onExposureChanged?.call(call.arguments);
        break;
      case PanoramicMethodNames.onRotatorConnected:
        widget.controller.onRotatorConnected?.call();
        break;
      case PanoramicMethodNames.onRotatorDisconnected:
        widget.controller.onRotatorDisconnected?.call();
        break;
      case PanoramicMethodNames.onStartedRotating:
        widget.controller.onStartedRotating?.call();
        break;
      case PanoramicMethodNames.onFinishedRotating:
        widget.controller.onFinishedRotating?.call();
        break;
      case PanoramicMethodNames.onShootingCanceled:
        widget.controller.onShootingCanceled?.call(call.arguments);
        break;
      case PanoramicMethodNames.onUpdateIndicators:
        final args = Map<String, dynamic>.from(call.arguments as Map);
        widget.controller.onUpdateIndicators?.call(Indicators.fromJson(args));
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
      platform.invokeMethod(PanoramicMethodNames.onResume);
    } else if (state == AppLifecycleState.paused) {
      platform.invokeMethod(PanoramicMethodNames.onPause);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (defaultTargetPlatform == TargetPlatform.iOS)
          LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;

              // Check if the dimensions have changed
              if (height != lastHeight || width != lastWidth) {
                lastHeight = height;
                lastWidth = width;

                platform.invokeMethod(PanoramicMethodNames.updateFrame, {
                  'height': height - 5,
                  'width': width,
                });
              }

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
          )
        else
          const AndroidView(viewType: 'panoramic_view'),
        if (isLoading)
          widget.loadingWidget ??
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
      ],
    );
  }
}
