//
//  ViewController.m
//  ZipDownloadSpike
//
//  Created by Weien on 8/2/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "ViewController.h"
#import "SSZipArchive.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) downloadZip {
    NSURL* fileURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/8902155/_site.zip"];

    dispatch_async(dispatch_queue_create("_site downloader", NULL), ^{
        NSError* error = nil;
        id data = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
                NSLog(@"Failure to download zip file: %@", error);
            
            //get Application Support directory
            NSString *appSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
            
            // ensure this dir exists, from http://stackoverflow.com/a/12114488/2284713
            NSFileManager *manager = [NSFileManager defaultManager];
            if(![manager fileExistsAtPath:appSupportDir]) {
                __autoreleasing NSError *error;
                BOOL ret = [manager createDirectoryAtPath:appSupportDir withIntermediateDirectories:NO attributes:nil error:&error];
                if(!ret) {
                    NSLog(@"Failed to create appSupportDir: %@", error);
                    exit(0);
                }
            }
            else {
                //write our data to the file!
                NSString* completeFilePath = [appSupportDir stringByAppendingPathComponent:@"_site.zip"];
                NSError* writeError = nil;
                if (![data writeToFile:completeFilePath options:NSDataWritingAtomic error:&writeError]) {
                    NSLog(@"Failure to write to file: %@", writeError);
                }
                else {
                    if ([self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:completeFilePath isDirectory:NO]])
                        NSLog(@"Successfully added SkipBackupAttribute to %@", completeFilePath);
                    
                    // Unzipping
                    [SSZipArchive unzipFileAtPath:completeFilePath toDestination:appSupportDir];
                    
                    NSString *unZippedFolderPath = [appSupportDir stringByAppendingPathComponent:@"_site"];
                    if ([self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:unZippedFolderPath isDirectory:YES]])
                        NSLog(@"Successfully added SkipBackupAttribute to %@", unZippedFolderPath);
                    
                    //could alternatively just addSkipBackupAttribute to the entire appSupportDir, I suppose
                }
            }
        });
    });
}

//from http://developer.apple.com/library/ios/#qa/qa1719/_index.html
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self downloadZip];
}

@end
