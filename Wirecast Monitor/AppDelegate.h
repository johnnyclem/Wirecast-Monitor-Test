//
//  AppDelegate.h
//  Wirecast Monitor
//
//  Created by hoeiriis on 10/15/12.
//  Copyright (c) 2012 LearningLab DTU. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    BOOL wcStatus, wcNetwork, wcDisk;
    int  wcNetworkC;
    NSTimer     *refreshTimer;
    NSString    *PID;
}

@property (weak)    IBOutlet NSTextField    *fieldVersion;
@property (assign)  IBOutlet NSWindow       *window;
@property (weak)    IBOutlet NSTextField    *labelStatics;
@property (weak)    IBOutlet NSTextField    *labelStatus;

@property (weak) IBOutlet NSImageView *LED00;
@property (weak) IBOutlet NSImageView *LED01;
@property (weak) IBOutlet NSImageView *LED02;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
