# panoramic_camera

The PanoramicCameraWidget is a customizable Flutter widget that integrates with native Android/iOS panoramic camera functionality using the DMD_Capture library. This widget provides a comprehensive interface for capturing panoramic photos with various event callbacks and configurable parameters.

## Versioning
For versioning, it's necessary to create a GitHub tag. After a branch is merged into the master, a tag should be created with the latest version from the pubspec.yaml. In the future, this process should be automated using GitHub Actions, but for now, we will handle it manually.

Commands to create a tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```


## Getting Started

### Use
To use this library, since it is not published on pub.dev, you should reference it directly from this Git repository using the specific version tag.

```yaml
panoramic_camera:
  git:
    url: https://github.com/Genopets/panoramic-camera-widget
    ref: v0.0.18
```

### Installation on iOS
It is necessary add the keys NSCameraUsageDescription in the Info.plist file cause are required by iOS to inform the user why your app needs access to the library.

	<key>NSCameraUsageDescription</key>
		<string>App needs permission to use the camera in order to take a panoramic</string>

### Constructor Parameters
- **onCameraStopped:** A callback function that is triggered when the camera stops.
- **onCameraStarted:** A callback function that is triggered when the camera starts.
- **onFinishClear:** A callback function that is triggered when the camera finishes clearing data.
- **onFinishRelease:** A callback function that is triggered when the camera finishes releasing resources.
- **onPreparingToShoot:** A callback function that is triggered when the camera is preparing to shoot.
- **onCanceledPreparingToShoot:** A callback function that is triggered when the preparation to shoot is canceled.
- **onTakingPhoto:** A callback function that is triggered when the camera is taking a photo.
- **onPhotoTaken:** A callback function that is triggered when a photo is taken.
- **onFinishGeneratingEqui:** A callback function that receives the file path of the generated stitching image when the  generation is finished.
- **onRotatorConnected:** A callback function that is triggered when the rotator is connected.
- **onRotatorDisconnected:** A callback function that is triggered when the rotator is disconnected.
- **onStartedRotating:** A callback function that is triggered when the camera starts rotating.
- **onFinishedRotating:** A callback function that is triggered when the camera finishes rotating.
- **onDeviceVerticalityChanged:** A callback function that receives the verticality status (int) when the device verticality changes. Returns 1 if the device is vertical and 0 if the device is not vertical
- **onDirectionUpdated:** A callback function that receives the updated direction (int) when the camera direction changes.
- **onCompassEvent:** A callback function that receives a map of compass event data.
- **onShootingCompleted:** A callback function that receives a boolean indicating if the shooting is finished.
- **outputHeight:** An integer specifying the height of the output stitching image. Default value is 800.
- **showGuide:** A boolean to indicate whether to show guides during shooting (yin yang). Default value is true.


### Example

```dart
PanoramicCameraWidget(
    onCameraStopped: () {
      /// Camera stopped
    },
    onCameraStarted: () {
      /// Camera started
    },
    onFinishClear: () {
      /// Finish clear
    },
    onFinishRelease: () {
      /// Finish release
    },
    onPreparingToShoot: () {
      /// Preparing to shoot
    },
    onCanceledPreparingToShoot: () {
      /// Canceled preparing to shoot
    },
    onTakingPhoto: () {
      /// The singular photo is beginning to be taken, it is called per each single photo
    },
    onPhotoTaken: () {
      /// The singular photo was taken, it is called per each single photo
    },
    onFinishGeneratingEqui: (String path) {
      /// Returns the stitching image
    },
    onRotatorConnected: () {
       /// Rotator connected
    },
    onRotatorDisconnected: () {
       /// Rotator disconnected
    },
    onStartedRotating: () {
       /// Started rotating
    },
    onFinishedRotating: () {
       /// Finished rotating
    },
    onDeviceVerticalityChanged: (int isVertical) {
       /// Device verticality changed
    },
    onCompassEvent: (info) {
      /// Compass event
    },
    onShootingCompleted: (bool finished) {
      /// Shooting completed
    },
    onDirectionUpdated: (double direction) {
      /// Direction updated
    },
    outputHeight: 1000,
    showGuide: true,
)
```