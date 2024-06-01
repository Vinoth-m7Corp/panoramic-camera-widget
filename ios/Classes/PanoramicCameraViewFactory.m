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

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                            viewIdentifier:(int64_t)viewId
                                                 arguments:(id _Nullable)args {
    PanoramicCameraView* cameraView = [[PanoramicCameraView alloc] initWithFrame:frame
                                                                 viewIdentifier:viewId
                                                                      arguments:args
                                                                      messenger:_messenger channel:_channel];
    return cameraView;
}

@end
