//
//  MTLogger.h
//  DateManager
//
//  Created by apple on 12-1-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum MTLogLevel {
    MTLogInfo       = 0x1,
    MTLogWarnning   = 0x2,
    MTLogError      = 0x4
};

typedef NSInteger MTLogLevel;

void MTLog(NSString *output, ...);
void MTLogWithLevel(MTLogLevel level,NSString *output, ...);

void setLogLevel(MTLogLevel level);

MTLogLevel logLevel();