//
//  DMDUIImageToRGBA8888.m
//
//  Created by AMS on 10/23/17.
//  Copyright © 2017 AMS. All rights reserved.
//

#import "DMDUIImageToRGBA8888.h"

@implementation DMDUIImageToRGBA8888

+ (unsigned char*)uiImageToRGBA8888:(UIImage *)image
{
    CGImageRef imgRef = image.CGImage;
    CGContextRef context=[self contextFromUIImage:imgRef];
    if(!context) return 0;
    unsigned long width = CGImageGetWidth(imgRef), height = CGImageGetHeight(imgRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, rect, imgRef);
    unsigned char *imageData=(unsigned char *)CGBitmapContextGetData(context);
    unsigned long Bpr = CGBitmapContextGetBytesPerRow(context);
    unsigned long size = Bpr*height;
    unsigned char *bytes=0;
    if(imageData) {
        bytes = (unsigned char *)malloc(sizeof(unsigned char) * size);
        if(bytes) memcpy(bytes, imageData, size);
        free(imageData);
    }
    
    CGContextRelease(context);
    
    return bytes;
}

+ (CGContextRef)contextFromUIImage:(CGImageRef) image
{
    CGContextRef context=nil;
    CGColorSpaceRef cs;
    unsigned int *imageData = 0;
    
    unsigned long bpc=8, Bpp=32/bpc;
    unsigned long width=CGImageGetWidth(image), height=CGImageGetHeight(image);
    unsigned long Bpr=width*Bpp, size=Bpr*height;
    
    cs=CGColorSpaceCreateDeviceRGB(); if(!cs) return NULL;
    
    imageData = (uint32_t*)malloc(size); if(!imageData) { CGColorSpaceRelease(cs); return nil; }
    context = CGBitmapContextCreate(imageData, width, height, bpc, Bpr, cs, kCGImageAlphaPremultipliedLast/*RGBA*/);
    
    if(!context) free(imageData);
    CGColorSpaceRelease(cs);
    
    return context;
}

@end
