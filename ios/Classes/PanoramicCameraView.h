#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>

@interface PanoramicCameraView : NSObject <FlutterPlatformView>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                      channel:(FlutterMethodChannel *)channel;

@end
