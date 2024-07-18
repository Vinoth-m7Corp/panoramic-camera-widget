#import "PanoramicCameraPlugin.h"
#import "PanoramicCameraViewFactory.h"
#import "ShooterViewController.h"


@implementation PanoramicCameraPlugin {
    FlutterMethodChannel *_channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"panoramic_channel"
                                     binaryMessenger:[registrar messenger]];
    PanoramicCameraPlugin* instance = [[PanoramicCameraPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];

    // Register the view factory for the custom view
    PanoramicCameraViewFactory* factory = [[PanoramicCameraViewFactory alloc] initWithMessenger:[registrar messenger] channel:channel];
    [registrar registerViewFactory:factory withId:@"panoramic_view"];
}


- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"setOutputHeight" isEqualToString:call.method]) {
        // Handle setting output height
        result(nil);
    } else if ([@"setShowGuide" isEqualToString:call.method]) {
        // Handle setting show guide
        result(nil);
    } else if ([@"onResume" isEqualToString:call.method]) {
        // Handle resume
        result(nil);
    } else if ([@"onPause" isEqualToString:call.method]) {
        // Handle pause
        result(nil);
    } else if ([@"updateFrame" isEqualToString:call.method]) {
        result(nil);
    }  else {
        result(FlutterMethodNotImplemented);
    }
}

@end
