//
//  TweetsViewController.m
//  DataTransparencyConference
//
//  Created by Weien on 7/29/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "TweetsViewController.h"
#import <Social/Social.h>

@interface TweetsViewController ()

@end

@implementation TweetsViewController

- (IBAction)presentTweetSheet:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"#datasummit14"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Check that your device has an internet connection and you have at least one Twitter account set up"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (NSString*) uniqueTabPathComponent {
    NSString* pathComponent = @"tweets";
    return pathComponent;
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    if (self.isViewLoaded && self.view.window) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    //self.DTCWebView.scrollView.scrollEnabled = NO;
    self.DTCWebView.scrollView.bounces = NO;
}

@end
