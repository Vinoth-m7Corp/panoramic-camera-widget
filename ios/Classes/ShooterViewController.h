//
//  ShooterViewController.h
//  engine_demo
//
// #ifndef ShooterViewController
// #define ShooterViewController

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>

// #define HD
#define LITE
#import "DMD.h"

@interface ShooterViewController : UIViewController <MonitorDelegate>

- (void)start:(id)sender;
- (void)restart:(id)sender;
- (void)stop:(id)sender;
- (void)leaveShooter;
- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel;

@end

// #endif
