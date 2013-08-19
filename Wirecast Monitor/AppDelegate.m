//
//  AppDelegate.m
//  Wirecast Monitor
//
//  Created by hoeiriis on 10/15/12.
//  Copyright (c) 2012 LearningLab DTU. All rights reserved.
//

#import "AppDelegate.h"
#import "TraceLog.h"

@interface AppDelegate ()

@property (nonatomic, copy) NSString *PID;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_window setTitle:[NSString stringWithFormat:@"Wirecast Monitor %@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    wcStatus    = NO;
    wcNetwork   = NO;
    wcDisk      = NO;
    wcNetworkC  = 0;
    [_fieldVersion  setStringValue:[NSString stringWithFormat:@"Monitoring Wirecast %@",[TraceLog strVersion]]];
    [_labelStatics  setStringValue:@"Status :\nNetwork Activity :\n Disk Activity :\n\nRefresh Rate :"];
    [self updateStrings];
}

- (BOOL)updateDisk{
    BOOL suc = NO;
    if ([TraceLog boolRunning]) {
        NSTask          *task               = [NSTask new];
        [task           setLaunchPath:@"/usr/sbin/lsof"];
        [task           setArguments:[NSArray arrayWithObjects:@"-p",_PID, nil]];
        NSPipe          *outputPipe         = [NSPipe pipe];
        [task           setStandardInput:[NSPipe pipe]];
        [task           setStandardOutput:outputPipe];
        [task           launch];
        NSData          *outputData         = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        NSString        *outputString       = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        NSArray         *arrCon             = [outputString componentsSeparatedByString:@"\n"];
        NSEnumerator    *enumerator         = [arrCon objectEnumerator];
        id value;
        while ((value = [enumerator nextObject])) {
            NSRange         range               = [value rangeOfString:_PID options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound) {
                NSRange         rangeF4V               = [value rangeOfString:@".f4v" options:NSCaseInsensitiveSearch];
                NSRange         rangeMOV               = [value rangeOfString:@".mov" options:NSCaseInsensitiveSearch];
                NSRange         rangeM4V               = [value rangeOfString:@".m4v" options:NSCaseInsensitiveSearch];
                NSRange         rangeMP4               = [value rangeOfString:@".mp4" options:NSCaseInsensitiveSearch];
                NSRange         rangeWC                = [value rangeOfString:@"Wirecast.app" options:NSCaseInsensitiveSearch];
                if(rangeF4V.location != NSNotFound && rangeWC.location == NSNotFound) {
                    suc = YES;
                }else if(rangeMOV.location != NSNotFound && rangeWC.location == NSNotFound) {
                    suc = YES;
                }else if(rangeM4V.location != NSNotFound && rangeWC.location == NSNotFound) {
                    suc = YES;
                }else if(rangeMP4.location != NSNotFound && rangeWC.location == NSNotFound) {
                    suc = YES;
                }
            }
        }
    }
    return suc;
}

- (BOOL)updateNetwork{
    BOOL suc = NO;
    if ([TraceLog boolRunning]) {
        NSTask          *task               = [NSTask new];
        [task           setLaunchPath:@"/bin/ps"];
        [task           setArguments:[NSArray arrayWithObjects:@"axc", nil]];
        NSPipe          *outputPipe         = [NSPipe pipe];
        [task           setStandardInput:[NSPipe pipe]];
        [task           setStandardOutput:outputPipe];
        [task           launch];
        [task           waitUntilExit];
        NSTask          *task2               = [NSTask new];
        [task2           setLaunchPath:@"/usr/sbin/lsof"];
        [task2           setArguments:[NSArray arrayWithObjects:@"-i", @"-P", @"grep", @"Wirecast", nil]];
        NSPipe          *outputPipe2         = [NSPipe pipe];
        [task2           setStandardInput:[NSPipe pipe]];
        [task2           setStandardOutput:outputPipe2];
        [task2           launch];
        [task2           waitUntilExit];
        NSData          *outputData2         = [[outputPipe2 fileHandleForReading] readDataToEndOfFile];
        NSString        *outputString2       = [[NSString alloc] initWithData:outputData2 encoding:NSUTF8StringEncoding];
        NSArray *arrCon = [outputString2 componentsSeparatedByString:@"\n"];
        NSLog(@"%@", arrCon);
        NSEnumerator    *enumerator2 = [arrCon objectEnumerator];
        id value2;
        while ((value2 = [enumerator2 nextObject])) {
            NSRange         range2               = [value2 rangeOfString:_PID options:NSCaseInsensitiveSearch];
            if(range2.location != NSNotFound) {
                NSRange         range2               = [value2 rangeOfString:@"ESTABLISHED" options:NSCaseInsensitiveSearch];
                if(range2.location != NSNotFound) {
                    suc = YES;
                }else {
                    suc = NO;
                }
            }
        }
    }
    
    return suc;
}

- (NSString *)getPIDForWirecast
{
    if (_PID == nil) {
        NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
        
        for (NSRunningApplication *app in runningApps) {
            NSRange appRange = [app.description rangeOfString:@"com.varasoftware.wirecast"];
            if (appRange.location != NSNotFound) {
                _PID = [NSString stringWithFormat:@"%d", app.processIdentifier];
            }
        }
    }
    
    NSLog(@"%@", _PID);
    return _PID;
}

- (NSArray *)arrayBySeparatingStringIntoParagraphs:(NSString *)rawString
{
    NSUInteger length = [rawString length];
    NSUInteger paraStart = 0;
    NSUInteger paraEnd = 0;
    NSUInteger contentsEnd = 0;
    
    NSMutableArray *array = [NSMutableArray array];
    NSRange currentRange;
    while (paraEnd < length)
    {
        [rawString getParagraphStart:&paraStart
                                 end:&paraEnd
                         contentsEnd:&contentsEnd
                            forRange:NSMakeRange(paraEnd, 0)];
        
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        [array addObject:[rawString substringWithRange:currentRange]];
    }

    return array;
}

- (NSArray *)tokensForString:(NSString *)string SeparatedByCharactersInSet:(NSCharacterSet *)separator
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSMutableArray *array = [NSMutableArray array];
    while (![scanner isAtEnd])
    {
        [scanner scanCharactersFromSet:separator intoString:nil];
        
        NSString *component;
        if ([scanner scanUpToCharactersFromSet:separator intoString:&component])
        {
            [array addObject:component];
        }
    }
    return array;
}

- (IBAction)refresh:(id)sender
{
    _PID =           [self getPIDForWirecast];

    if ([TraceLog boolRunning]) {
        [_LED00 setImage:[[NSImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusLightGreenOn" ofType:@"tiff"]]];
        wcStatus = YES;
        if ([self updateNetwork]) {
            wcNetworkC = wcNetworkC+1;
            if (wcNetworkC>2) {
                [_LED01 setImage:[[NSImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusLightGreenOn" ofType:@"tiff"]]];
                wcNetwork = YES;
            }
        }else {
            [_LED01 setImage:[[NSImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusLightGrayOff" ofType:@"tiff"]]];
            wcNetwork   = NO;
            wcNetworkC  = 0;
        }
        if ([self updateDisk]) {
            [_LED02 setImage:[[NSImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusLightGreenOn" ofType:@"tiff"]]];
            wcDisk = YES;
        }else {
            [_LED02 setImage:[[NSImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusLightGrayOff" ofType:@"tiff"]]];
            wcDisk = NO;
        }
    }else {
        [_LED00 setImage:[[NSImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusLightGrayOff" ofType:@"tiff"]]];
        wcStatus = NO;
    }
    
    [self updateStrings];
    [self updateNetwork];
    [self updateDisk];
}

- (void)updateStrings{
    NSString *str00 = @"not running";
    NSString *str01 = @"not streaming";
    NSString *str02 = @"not recording";
    if (wcStatus) {
        str00 = @"running";
    }
    if (wcNetwork) {
        str01 = @"streaming";
    }
    if (wcDisk) {
        str02 = @"recording";
    }
    [_labelStatus   setStringValue:[NSString stringWithFormat:@"%@\n%@\n%@",str00,str01,str02]];
}

@end
