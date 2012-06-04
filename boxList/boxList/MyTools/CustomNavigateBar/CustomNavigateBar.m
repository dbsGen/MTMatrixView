//
//  CustomNavigateBar.m
//  ic_meetingViewer
//
//  Created by zrz on 11-8-27.
//  Copyright 2011年 zrz. All rights reserved.
//

#import "CustomNavigateBar.h"


@implementation UINavigationBar(Custom)

static UIImage *backgrondImg;

- (void)drawRect:(CGRect)rect
{
    if (!backgrondImg) {
        backgrondImg = [[UIImage imageNamed:@"navigate_bg.png"] retain];
    }
    CGRect tFrame = self.bounds;
    tFrame.size.height += 1;
    [backgrondImg drawInRect:tFrame];
}

@end
