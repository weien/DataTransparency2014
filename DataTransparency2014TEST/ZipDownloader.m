//
//  ZipDownloader.m
//  DataTransparencyConference
//
//  Created by Weien on 8/5/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "ZipDownloader.h"
#import "SSZipArchive.h"

@implementation ZipDownloader

+ (void) downloadZipAtURL:(NSURL*)url WithCompletion:(void (^)(void))completion {
    dispatch_async(dispatch_queue_create("_site downloader", NULL), ^{
        NSError* error = nil;
        id data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
        if (!data) {
            NSLog(@"Failure to download zip file: %@", error);
            completion(); //still gotta hide the syncbar
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //get Application Support directory
                NSString *appSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
                
                // ensure app support dir exists, from http://stackoverflow.com/a/12114488/2284713
                NSFileManager *manager = [NSFileManager defaultManager];
                if(![manager fileExistsAtPath:appSupportDir]) {
                    __autoreleasing NSError *error;
                    BOOL ret = [manager createDirectoryAtPath:appSupportDir withIntermediateDirectories:NO attributes:nil error:&error];
                    if(!ret) {
                        NSLog(@"Failed to create appSupportDir: %@", error);
                        exit(0);
                    }
                    
                    //we'll just addSkipBackupAttribute to the whole appSupportDir -- shouldn't have to do this more than at this point
                    if ([self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:appSupportDir isDirectory:NO]])
                        NSLog(@"Successfully added SkipBackupAttribute to %@", appSupportDir);
                }
                
                NSString* siteVersionZipName = [url lastPathComponent];
                NSString* newSiteVersionFileDirName = [siteVersionZipName stringByDeletingPathExtension];
                //NSLog(@"siteVersionName is %@, fileName is %@", siteVersionZipName, siteVersionFileDirName);
                
                //write our data to the file!
                NSString* completeFilePath = [appSupportDir stringByAppendingPathComponent:siteVersionZipName];
                NSError* writeError = nil;
                if (![data writeToFile:completeFilePath options:NSDataWritingAtomic error:&writeError]) {
                    NSLog(@"Failure to write to file: %@", writeError);
                }
                else {
                    // Unzipping
                    NSError* unzipError = nil;
                    [SSZipArchive unzipFileAtPath:completeFilePath
                                    toDestination:appSupportDir
                                        overwrite:YES
                                         password:nil
                                            error:&unzipError];
                    NSLog(@"*****Just Unzipped to %@", appSupportDir);
                    if (unzipError) {
                        NSLog(@"Unzipping failed, error: %@", unzipError);
                    }
                    else {
                        NSString* sitePath = [appSupportDir stringByAppendingPathComponent:@"_site"];
                        NSString* siteToDeletePath = [appSupportDir stringByAppendingPathComponent:@"_site-to-delete"];
                        NSString* newSiteVersionPath = [appSupportDir stringByAppendingPathComponent:newSiteVersionFileDirName];
                        if ([manager fileExistsAtPath:sitePath] && [manager fileExistsAtPath:newSiteVersionPath]) {
                            //replace old _site with newly unpacked _site-n directory
                            NSLog(@"Directory now contains %@", [manager contentsOfDirectoryAtPath:appSupportDir error:nil]);
                            [manager moveItemAtPath:sitePath toPath:siteToDeletePath error:nil];
                            NSLog(@"Directory now contains %@", [manager contentsOfDirectoryAtPath:appSupportDir error:nil]);
                            [manager moveItemAtPath:newSiteVersionPath toPath:sitePath error:nil];
                            NSLog(@"Directory now contains %@", [manager contentsOfDirectoryAtPath:appSupportDir error:nil]);
                            [manager removeItemAtPath:siteToDeletePath error:nil];
                            NSLog(@"Directory now contains %@", [manager contentsOfDirectoryAtPath:appSupportDir error:nil]);
                        }
                        else {
                            //unzipping for the first time OR user is grabbing _site.zip from R1
                            //just make sure the path is sitePath, and we're done
                            [manager moveItemAtPath:newSiteVersionPath toPath:sitePath error:nil];
                            NSLog(@"Directory now contains %@", [manager contentsOfDirectoryAtPath:appSupportDir error:nil]);
                        }
                        //remove the old .zip file
                        [manager removeItemAtPath:completeFilePath error:nil];
                        NSLog(@"Directory now contains %@", [manager contentsOfDirectoryAtPath:appSupportDir error:nil]);
                    }
                }
                completion();
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SiteContentDidUpdate" object:self];
            });
        }
    });
}

//from http://developer.apple.com/library/ios/#qa/qa1719/_index.html
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


@end
