//
//  DMDLensElement.h
//  TestLensSelector
//
//  Created by AMS on 10/19/16.
//  Copyright © 2016 AMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMDLensElement : NSObject

@property (nonatomic,assign) NSString *lensID;
@property (nonatomic,assign) NSString *lensName;
@property (nonatomic,assign) NSString *lensDescription;
@property (nonatomic,assign) NSString *lensImage;

-(instancetype)initWithName:(NSString*)name andDescription:(NSString*)description andImagePath:(NSString*)image andLensID:(NSString*)ID;

@end

