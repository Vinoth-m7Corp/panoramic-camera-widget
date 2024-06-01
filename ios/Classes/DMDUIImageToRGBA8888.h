//
//  DMDUIImageToRGBA8888.h
//
//  Created by AMS on 10/23/17.
//  Copyright © 2017 AMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMDUIImageToRGBA8888 : NSObject

// The caller should free this returned buffer (allocated using malloc)
// after finish using it. Use free().
+ (unsigned char*)uiImageToRGBA8888:(UIImage*)image;

@end
