//
//  DMDLensSelector.h
//  LensSelector
//
//  Created by AMS on 10/19/16.
//  Copyright © 2016 AMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMD.h"

#define NOLENS              @"NoLens"


@protocol DMDLensSelectionDelegate

@optional
- (void)onLensSelectionFinished;
- (void)onLensSelectionClosed;

@end


@interface DMDLensSelector : UIViewController

- (instancetype)initWithDelegate:(NSObject<DMDLensSelectionDelegate>*)delegate;
+ (NSString*)currentLensName;
+ (enum DMDLensID)currentLensID;

@end
