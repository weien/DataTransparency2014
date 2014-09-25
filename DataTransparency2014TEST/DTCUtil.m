//
//  DTCUtil.m
//  DataTransparencyConference
//
//  Created by Weien on 8/9/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "DTCUtil.h"

@implementation DTCUtil

+ (NSURL*) reformedURLWithCorrectDirectoryUsingPathComponent:(NSString*)pathComponent {
    //if the specific file not available in AppSuppDir, then use mainBundle
    //and get the right URL
    
    NSString* appSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSString* updateFilesDir = [appSupportDir stringByAppendingPathComponent:pathComponent];
    NSURL* baseDirectory = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:updateFilesDir]) {
    //if (1==0) { //force mainBundle (for test purposes)
        NSLog(@"Using Application Support directory");
        baseDirectory = [NSURL fileURLWithPath:appSupportDir];
    }
    else {
        NSLog(@"Using mainBundle bundle");
        baseDirectory = [[NSBundle mainBundle] bundleURL];
    }
    return [baseDirectory URLByAppendingPathComponent:pathComponent isDirectory:NO];
}

@end
