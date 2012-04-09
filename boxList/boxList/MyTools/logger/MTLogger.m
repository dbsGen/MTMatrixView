//
//  MTLogger.m
//  DateManager
//
//  Created by apple on 12-1-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MTLogger.h"

static MTLogLevel   _level = MTLogInfo | MTLogWarnning | MTLogError;
static BOOL isInit = NO;

void logv(MTLogLevel level,NSString *output, va_list argv)
{
    if (!isInit) {
#ifndef DEBUG
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fileName =[NSString stringWithFormat:@"date.log"];
        NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
#endif
        isInit = YES;
    }
    if (_level & level) {
        NSLogv(output, argv);
    }
}

void MTLogWithLevel(MTLogLevel level,NSString *output, ...)
{
    va_list arglist;
    va_start(arglist, output);
    logv(level, output, arglist);
    va_end(arglist);
}

void MTLog(NSString *output, ...)
{
    va_list arglist;
    va_start(arglist, output);
    logv(MTLogInfo, output, arglist);
    va_end(arglist);
}

void setLogLevel(MTLogLevel level)
{
    _level = level;
}

MTLogLevel logLevel()
{
    return _level;
}