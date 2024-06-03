#ifndef PanoramicCameraPlugin_h
#define PanoramicCameraPlugin_h

#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>

@interface PanoramicCameraPlugin : NSObject <FlutterPlugin>
@property(nonatomic, strong) NSObject<FlutterPluginRegistrar> *flutterRegistrar;

@end

#endif