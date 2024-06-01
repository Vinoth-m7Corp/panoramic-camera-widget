//
//  DMDNavigationControllerPortrait.m
//  DMDTest
//
//  Created by AMS on 10/25/16.
//  Copyright © 2016 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import "DMDNavigationControllerPortrait.h"

@implementation DMDNavigationControllerPortrait

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
