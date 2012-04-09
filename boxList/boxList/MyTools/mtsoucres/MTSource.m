//
//  MTSource.m
//  iDoubs
//
//  Created by zrz on 11-4-21.
//  Copyright 2011 doubango. All rights reserved.
//

#import "MTSource.h"

@implementation MTSource


+ (UIColor*)whiteColor
{
	return [UIColor whiteColor];
}

+ (UIColor*)clearColor
{
	return [UIColor clearColor];
}

+ (UIColor*)shadowColor
{
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
}

+ (UIColor*)blackColor
{
	return [UIColor blackColor];
}


+ (CGFloat)widthOfLabel:(UILabel*)label
{
	CGSize dateStringSize = [label.text sizeWithFont:label.font
							   constrainedToSize:CGSizeMake(9999, label.frame.size.height) 
								   lineBreakMode:label.lineBreakMode];
	return dateStringSize.width;
}

+ (CGFloat)heightOfLabel:(UILabel*)label
{
    CGSize dateStringSize = [label.text sizeWithFont:label.font
                                   constrainedToSize:CGSizeMake(label.frame.size.width, 9999) 
                                       lineBreakMode:label.lineBreakMode];
	return dateStringSize.height;
}

+ (void)setLeft:(CGFloat)left withView:(UIView*)view
{
	CGRect rect = view.frame;
	rect.origin.x = left;
	view.frame = rect;
}

+ (void)setHeight:(CGFloat)height withView:(UIView*)view
{
	CGRect rect = view.frame;
	rect.size.height = height;
	view.frame = rect;
}
+ (void)setWidth:(CGFloat)width withView:(UIView*)view
{
	CGRect rect = view.frame;
	rect.size.width = width;
	view.frame = rect;
}

+ (void)setTop:(CGFloat)top withView:(UIView*)view
{
	CGRect rect = view.frame;
	rect.origin.y = top;
	view.frame = rect;
}

+ (void)setLeft:(CGFloat)left top:(CGFloat)top withView:(UIView*)view
{
	CGRect rect = view.frame;
	rect.origin.x = left;
	rect.origin.y = top;
	view.frame = rect;
}

+ (NSString*)getExtend:(NSString*)file
{
	NSRange range = [file rangeOfString:@"." options:NSBackwardsSearch];
	if (!range.length || !range.location) {
		return @"";
	}
	return [file substringFromIndex:range.location];
}

+ (CGRect)autoImage:(UIImage*)image maxRect:(CGRect)rect
{
    CGRect addRect;
    CGSize tSize = image.size;
    if (tSize.height < rect.size.height && tSize.width < rect.size.width) {
        addRect.origin.y = rect.origin.y + (rect.size.height - tSize.height) / 2;
        addRect.origin.x = rect.origin.x + (rect.size.width - tSize.width) / 2;
        addRect.size.width = tSize.width;
        addRect.size.height = tSize.height;
    }else{
        if (tSize.height * rect.size.width / tSize.width > rect.size.height) {
            addRect.size.height = rect.size.height;
            addRect.size.width = tSize.width * rect.size.height / tSize.height;
            addRect.origin.x = rect.origin.x + (rect.size.width - addRect.size.width) / 2;
            addRect.origin.y = rect.origin.y;
        }else {
            addRect.origin.x = rect.origin.x;
            addRect.size.width = rect.size.width;
            addRect.size.height = tSize.height * rect.size.width / tSize.width;
            addRect.origin.y = rect.origin.y + (rect.size.height - addRect.size.height) / 2;
        }
    }
    return addRect;
}

+ (UIColor*)myGrayColor
{
    return [UIColor colorWithRed:0.4023 green:0.4023 blue:0.4023 alpha:1];
}

+ (UIColor*)colorWithKey:(NSUInteger)key
{
    NSUInteger red = (key >> 16) & 0xff, green = (key >> 8) & 0xff, blue = key & 0xff;
    return [UIColor colorWithRed:(float)red / 255
                           green:(float)green / 255
                            blue:(float)blue / 255
                           alpha:1];
}

@end
