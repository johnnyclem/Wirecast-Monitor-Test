//
//  AppDelegate.h
//  Wirecast Monitor
//
//  Created by hoeiriis on 10/15/12.
//  Copyright (c) 2012 LearningLab DTU. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    BOOL wcStatus;
    BOOL wcNetwork;
    BOOL wcDisk;
    
    int wcNetworkC;
    NSTimer *refreshTimer;
}

@property (nonatomic, assign) IBOutlet NSWindow *window;

@property (nonatomic, weak) IBOutlet NSTextField *fieldVersion;
@property (nonatomic, weak) IBOutlet NSTextField *labelStatics;
@property (nonatomic, weak) IBOutlet NSTextField *labelStatus;

@property (nonatomic, weak) IBOutlet NSImageView *LED00;
@property (nonatomic, weak) IBOutlet NSImageView *LED01;
@property (nonatomic, weak) IBOutlet NSImageView *LED02;

- (IBAction)refresh:(id)sender;


@end
