#import "PanoramicCameraView.h"
#import "ShooterViewController.h"

@implementation PanoramicCameraView {
    UIView *_view;
    ShooterViewController *_shooterViewController;
    FlutterMethodChannel *_channel;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    messenger:(NSObject<FlutterBinaryMessenger>*)messenger
                      channel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _view = [[UIView alloc] initWithFrame:frame];
        _channel = channel;

        // Initialize and add ShooterViewController with the method channel
        _shooterViewController = [[ShooterViewController alloc] initWithMethodChannel:_channel frame:frame];
        _shooterViewController.view.frame = _view.bounds;
        _shooterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_view addSubview:_shooterViewController.view];

    }
    return self;
}

- (UIView *)view {
    return _view;
}

@end
