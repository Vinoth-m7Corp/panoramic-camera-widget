//
//  ShooterViewController.h
//  engine_demo
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>

#import "DMD.h"

@interface ShooterViewController : UIViewController <MonitorDelegate>

- (void)start:(id)sender;
- (void)restart:(id)sender;
- (void)stop:(id)sender;
- (void)leaveShooter;
- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel frame:(CGRect)frame;

@end
