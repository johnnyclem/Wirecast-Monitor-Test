//
//  TraceLog.m
//  Wirecast Monitor
//
//  Created by hoeiriis on 10/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TraceLog.h"

@implementation TraceLog

+(NSString *)strVersion{
    NSString    *path   = @"/private/tmp/wirecast_trace_log.txt";
    NSString    *str    = @"";
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        str = [str substringWithRange:NSMakeRange(23, 13)];
    }
    return str;
}

+(BOOL)boolRunning{
    BOOL suc = NO;
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.varasoftware.wirecast"] count] > 0) {
        suc = YES;
    }
    return suc;
}

@end
