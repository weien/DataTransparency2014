//
//  AppDelegate.m
//  DataTransparencyConference
//
//  Created by Weien on 7/26/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "CustomTabBarController.h"
#import <Parse/Parse.h>

@implementation AppDelegate

- (void) fetchUpdateOnCustomTabBarController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CustomTabBarController *rootViewController = (CustomTabBarController*) window.rootViewController;
    [rootViewController fetchUpdate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [self fetchUpdateOnCustomTabBarController];
    [Crashlytics startWithAPIKey:@"f8325a280442dcfe187c30777d83465e38bea645"];
    
    //Parse, for push notifications
    [Parse setApplicationId:@"s8dcGkWr1y49D1Lj9puLLEkx0RBQmJRSiFwqfyPs"
                  clientKey:@"5mHE36JvF2CXqK36V1KCaPFcDjQ1y4lQ0WDeQ0QG"];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
