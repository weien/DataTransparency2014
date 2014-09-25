//
//  ViewController.h
//  DataTransparencyConference
//
//  Created by Weien on 7/26/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTCViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView* DTCWebView;
@property (strong, nonatomic) NSURL* urlToPassForward;
@property (strong, nonatomic) NSURL* urlToDisplayHere;

- (void) webViewDidFinishLoad:(UIWebView *)webView;

@end
