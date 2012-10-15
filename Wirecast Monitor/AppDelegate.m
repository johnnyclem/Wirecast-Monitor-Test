//
//  AppDelegate.m
//  Wirecast Monitor
//
//  Created by hoeiriis on 10/15/12.
//  Copyright (c) 2012 LearningLab DTU. All rights reserved.
//

#import "AppDelegate.h"
#import "TraceLog.h"

@implementation AppDelegate

@synthesize fieldVersion                = _fieldVersion;
@synthesize window                      = _window;
@synthesize labelStatics                = _labelStatics;
@synthesize labelStatus                 = _labelStatus;
@synthesize LED00                       = _LED00;
@synthesize LED01                       = _LED01;
@synthesize LED02                       = _LED02;
@synthesize persistentStoreCoordinator  = __persistentStoreCoordinator;
@synthesize managedObjectModel          = __managedObjectModel;
@synthesize managedObjectContext        = __managedObjectContext;

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
    [self initRefresh];
}

- (void)initRefresh{
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                    target:self
                                                  selector:@selector(refreshFired:)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)refreshFired:(NSTimer *)timer {
    [self updateLEDs];
    [self updateStrings];
    [self updateNetwork];
    [self updateDisk];
}

- (BOOL)updateDisk{
    BOOL suc = NO;
    if ([TraceLog boolRunning]) {
        NSTask          *task               = [NSTask new];
        [task           setLaunchPath:@"/usr/sbin/lsof"];
        [task           setArguments:[NSArray arrayWithObjects:@"-p",PID, nil]];
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
            NSRange         range               = [value rangeOfString:PID options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound) {
                NSRange         rangeF4V               = [value rangeOfString:@".f4v" options:NSCaseInsensitiveSearch];
                NSRange         rangeMOV               = [value rangeOfString:@".mov" options:NSCaseInsensitiveSearch];
                NSRange         rangeM4V               = [value rangeOfString:@".m4v" options:NSCaseInsensitiveSearch];
                NSRange         rangeWC                = [value rangeOfString:@"Wirecast.app" options:NSCaseInsensitiveSearch];
                if(rangeF4V.location != NSNotFound && rangeWC.location == NSNotFound) {
                    suc = YES;
                }else if(rangeMOV.location != NSNotFound && rangeWC.location == NSNotFound) {
                    suc = YES;
                }else if(rangeM4V.location != NSNotFound && rangeWC.location == NSNotFound) {
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
        NSData          *outputData         = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        NSString        *outputString       = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        NSArray *arrPid = [outputString componentsSeparatedByString:@"\n"];
        NSEnumerator    *enumerator = [arrPid objectEnumerator];
        id value;
        NSString *name, *pid = [[NSString alloc] init];
        while ((value = [enumerator nextObject])) {
            name = [value substringWithRange:NSMakeRange([value length]-8, 8)];
            if ([name isEqualToString:@"Wirecast"]) {
                pid = [value substringWithRange:NSMakeRange(0, 5)];
                PID = pid;
            }
        }
        NSTask          *task2               = [NSTask new];
        [task2           setLaunchPath:@"/usr/sbin/lsof"];
        [task2           setArguments:[NSArray arrayWithObjects:@"-i", nil]];
        NSPipe          *outputPipe2         = [NSPipe pipe];
        [task2           setStandardInput:[NSPipe pipe]];
        [task2           setStandardOutput:outputPipe2];
        [task2           launch];
        [task2           waitUntilExit];
        NSData          *outputData2         = [[outputPipe2 fileHandleForReading] readDataToEndOfFile];
        NSString        *outputString2       = [[NSString alloc] initWithData:outputData2 encoding:NSUTF8StringEncoding];
        NSArray *arrCon = [outputString2 componentsSeparatedByString:@"\n"];
        NSEnumerator    *enumerator2 = [arrCon objectEnumerator];
        id value2;
        while ((value2 = [enumerator2 nextObject])) {
            NSRange         range2               = [value2 rangeOfString:pid options:NSCaseInsensitiveSearch];
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



- (void)updateLEDs{
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


// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "LearningLab-DTU.Wirecast_Monitor" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"LearningLab-DTU.Wirecast_Monitor"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Wirecast_Monitor" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Wirecast_Monitor.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = coordinator;
    
    return __persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!__managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
