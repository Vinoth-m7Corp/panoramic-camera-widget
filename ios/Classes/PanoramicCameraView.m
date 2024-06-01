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
        _shooterViewController = [[ShooterViewController alloc] initWithMethodChannel:_channel];
        _shooterViewController.view.frame = _view.bounds;
        _shooterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_view addSubview:_shooterViewController.view];

        // Ensure the ShooterViewController is properly added to the view hierarchy
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [rootViewController addChildViewController:_shooterViewController];
        [_shooterViewController didMoveToParentViewController:rootViewController];
    }
    return self;
}

- (UIView *)view {
    return _view;
}

@end
