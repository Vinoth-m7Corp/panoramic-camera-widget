//
//  DMDLensElement.m
//  TestLensSelector
//
//  Created by AMS on 10/19/16.
//  Copyright © 2016 AMS. All rights reserved.
//

#import "DMDLensElement.h"

@implementation DMDLensElement

-(instancetype)initWithName:(NSString*)name andDescription:(NSString*)description andImagePath:(NSString*)image andLensID:(NSString*)ID
{
    if (self = [super init]) {
        self.lensID = ID;
        self.lensName = name;
        self.lensDescription = description;
        self.lensImage = image;
    }
    return self;
}


- (void)dealloc
{
    if(self.lensID) self.lensID=nil;
    if(self.lensName) self.lensName=nil;
    if(self.lensDescription) self.lensDescription=nil;
    if(self.lensImage)self.lensImage=nil;
}

@end
