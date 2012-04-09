//
//  MTSource.h
//  iDoubs
//
//  Created by zrz on 11-4-21.
//  Copyright 2011 doubango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTSource : NSObject {

}

//一些颜色
+ (UIColor*)whiteColor;
+ (UIColor*)clearColor;
+ (UIColor*)shadowColor;
+ (UIColor*)blackColor;
+ (UIColor*)myGrayColor;

+ (UIColor*)colorWithKey:(NSUInteger)key;

+ (CGFloat)widthOfLabel:(UILabel*)label;
+ (CGFloat)heightOfLabel:(UILabel*)label;
+ (void)setLeft:(CGFloat)left withView:(UIView*)view;
+ (void)setHeight:(CGFloat)height withView:(UIView*)view;
+ (void)setWidth:(CGFloat)width withView:(UIView*)view;
+ (void)setTop:(CGFloat)top withView:(UIView*)view;
+ (void)setLeft:(CGFloat)left top:(CGFloat)top withView:(UIView*)view;
+ (NSString*)getExtend:(NSString*)file;

//自适应大小
+ (CGRect)autoImage:(UIImage*)image maxRect:(CGRect)rect;

@end
