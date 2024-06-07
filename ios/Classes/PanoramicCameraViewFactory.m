#import "PanoramicCameraViewFactory.h"
#import "PanoramicCameraView.h"

@implementation PanoramicCameraViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
    FlutterMethodChannel *_channel;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                          channel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _messenger = messenger;
        _channel = channel;
    }
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                            viewIdentifier:(int64_t)viewId
                                                 arguments:(id _Nullable)args {
        // This allows the camera view to be displayed in all the available space of the widget.
        NSNumber *height = args[@"height"];
        NSNumber *width = args[@"width"];
        frame = CGRectMake(0, 0, [width floatValue], [height floatValue]);
    PanoramicCameraView* cameraView = [[PanoramicCameraView alloc] initWithFrame:frame
                                                                 viewIdentifier:viewId
                                                                      arguments:args
                                                                      messenger:_messenger channel:_channel];
    return cameraView;
}

@end
