//
//  CustomNavigationViewController.m
//  TwitterTimelineSpike
//
//  Created by Weien on 6/22/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "CustomNavigationViewController.h"

@interface CustomNavigationViewController ()

@end

@implementation CustomNavigationViewController

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
