//
//  CustomTabBarController.m
//  TwitterTimelineSpike
//
//  Created by Weien on 6/22/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "CustomTabBarController.h"

#import "ZipDownloader.h"
#import "DTCUtil.h"
#import "DTCViewController.h"

@interface CustomTabBarController ()
@property (strong, nonatomic) UILabel* syncBar;
@end

@implementation CustomTabBarController
@synthesize syncBar = _syncBar;

- (void) fetchUpdate {
    NSURL* versionDataLink = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/8902155/data_transparency_version.json"];
    

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_queue_create("checkForUpdate", NULL), ^{
        NSError* error = nil;
        NSData* JSONData = [NSData dataWithContentsOfURL:versionDataLink options:NSDataReadingMappedIfSafe error:&error];
        if (!JSONData) {
            NSLog(@"Data download error: %@", error);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSError* error = nil;
            NSDictionary* latestVersion = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
            //NSLog(@"New Dict is %@, error is %@", latestVersion, error);
            
            NSInteger versionNumber = [latestVersion[@"data transparency"][@"current version"] integerValue];
            NSURL* previousVersionFile = [DTCUtil reformedURLWithCorrectDirectoryUsingPathComponent:@"_site/version.txt"];
            NSInteger previousVersionNumber = [[NSString stringWithContentsOfURL:previousVersionFile encoding:NSUTF8StringEncoding error:&error] integerValue];
            NSLog(@"new version is %ld, previous version is %ld", (long)versionNumber, (long)previousVersionNumber);
            
            if (versionNumber > previousVersionNumber) {
                NSLog(@"new (%ld) is greater than previous version (%ld), downloading update", (long)versionNumber, (long)previousVersionNumber);
                [self showCustomSyncBar];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                void (^completionBlock)(void) = ^() {
                    //increase minimum visibility of sync bar
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.3 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self hideCustomSyncBar];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    });
                };
                //NSURL* newVersionLocation = [NSURL URLWithString:latestVersion[@"data transparency"][@"current version download url"]];
                //"updated current version" instead of "current version" is key difference between R1 and future releases
                NSURL* newVersionLocation = [NSURL URLWithString:latestVersion[@"data transparency"][@"updated current version download url"]];
                [ZipDownloader downloadZipAtURL:newVersionLocation WithCompletion:completionBlock];
            }
        });
    });
}

#pragma mark - syncBar methods

- (void) showCustomSyncBar {
    CGSize viewSize = [self currentViewSize];
    CGFloat adjustmentHeight = [self adjustmentHeight];
    
    if (!self.syncBar) {
        self.syncBar = [[UILabel alloc] initWithFrame:CGRectMake(0, adjustmentHeight, viewSize.width, 0.0f)];
        [self.syncBar setBackgroundColor:[UIColor colorWithRed:68/255.0f green:110/255.0f blue:143/255.0f alpha:1.0f]];
        
        [self.syncBar setText:@"UPDATING..."];
        [self.syncBar setTextAlignment:NSTextAlignmentCenter];
        [self.syncBar setTextColor:[UIColor whiteColor]];
        [self.syncBar setFont:[UIFont systemFontOfSize:8]];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.syncBar];
    }
    
    [UIView beginAnimations:@"showSyncBar" context:nil];
    [UIView setAnimationDuration:0.3];
    [self.syncBar setFrame:CGRectMake(0, adjustmentHeight, viewSize.width, 10.0f)];
    //    [self.selectedViewController.view setFrame:CGRectMake(0, 10.0f, screenSize.width, screenSize.height-10)];
    [UIView commitAnimations];
}

- (void) hideCustomSyncBar {
    CGSize viewSize = [self currentViewSize];
    CGFloat adjustmentHeight = [self adjustmentHeight];

    //    if (CGRectIntersectsRect(self.syncBar.frame, self.view.frame)) {
    [UIView beginAnimations:@"hideSyncBar" context:nil];
    [UIView setAnimationDuration:0.3];

    //"CurlUp" isn't ideal, but what works easiest for now
//    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.syncBar cache:YES]; //looks horrible in iOS7
    [self.syncBar setFrame:CGRectMake(0, adjustmentHeight, viewSize.width, 0)];
    [UIView commitAnimations];
    //    [self.selectedViewController.view setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
}

- (CGSize) currentViewSize {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UITabBarController *rootViewController = (UITabBarController*) window.rootViewController;
    UINavigationController* navViewController = (UINavigationController*) rootViewController.selectedViewController;
    CGSize viewSize = navViewController.visibleViewController.view.frame.size;
    //    NSLog(@"viewSize is %f, %f", viewSize.width, viewSize.height);
    return viewSize;
}

- (CGFloat) adjustmentHeight {
    CGFloat navigationBarHeight = ((UINavigationController*)[self selectedViewController]).navigationBar.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    return (navigationBarHeight + statusBarHeight);
}

#pragma mark - autorotation

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //thanks http://stackoverflow.com/a/12505461/2284713
    // You do not need this method if you are not supporting earlier iOS Versions
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
