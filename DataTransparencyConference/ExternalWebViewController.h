//
//  WebViewController.h
//  TwitterTimelineSpike
//
//  Created by Weien on 6/19/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExternalWebViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *externalLinkViewer;
@property (strong, nonatomic) NSURL* urlToDisplay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

- (IBAction)openPageInBrowser:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;


@end
