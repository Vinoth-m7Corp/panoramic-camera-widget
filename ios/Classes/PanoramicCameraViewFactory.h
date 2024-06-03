#ifndef PanoramicCameraViewFactory_h
#define PanoramicCameraViewFactory_h

#import <Flutter/Flutter.h>

@interface PanoramicCameraViewFactory : NSObject <FlutterPlatformViewFactory>

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                          channel:(FlutterMethodChannel *)channel;

@end

#endif