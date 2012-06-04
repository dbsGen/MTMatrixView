//
//  UIImage+UIImage_Resize.m
//  Bottle
//
//  Created by apple on 12-1-9.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "UIImage+MTResize.h"

@implementation UIImage (MTResize)

- (UIImage *)transformToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
} 

@end
