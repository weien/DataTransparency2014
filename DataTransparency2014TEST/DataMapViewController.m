//
//  DataMapViewController.m
//  DataTransparencyConference
//
//  Created by Weien on 8/22/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "DataMapViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DataMapViewController ()
@property (strong, nonatomic) UIButton* infoView;
@property (strong, nonatomic) UIButton* dismissButton;
@property (strong, nonatomic) UILabel* infoLabel;
@property (strong, nonatomic) UILabel* sorryView;
@property (strong, nonatomic) UIButton* infoButton;

@end

@implementation DataMapViewController
@synthesize infoView = _infoView;
@synthesize dismissButton = _dismissButton;
@synthesize infoLabel = _infoLabel;
@synthesize sorryView = _sorryView;
@synthesize infoButton = _infoButton;

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //https://gist.github.com/ardalahmet/1153867 to check for 403 errors
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger status = [httpResponse statusCode];
        
        if (status == 403) {
            NSLog(@"Error. http status code: %ld", (long)status);
            //deleting cookies and clearing cache doesn't do anything for us
            
            //Display fail message
            [self displaySorryView];
        }
        else {
            [self showInfoView];
        }
    }
}

- (void) displaySorryView {
    self.sorryView.frame = self.view.bounds;
    
    if (!self.sorryView) {
        self.sorryView = [[UILabel alloc] initWithFrame:self.view.bounds];
        self.sorryView.backgroundColor = [UIColor colorWithRed:180/255.0f green:180/255.0f blue:180/255.0f alpha:1.0f];
        self.sorryView.numberOfLines = 0;
        self.sorryView.font = [UIFont boldSystemFontOfSize:16];
        NSMutableAttributedString* formattedText = [[NSMutableAttributedString alloc] initWithString:@"The federaltransparency.gov \n website is not currently available, \n please check back later. \n \n"];
        self.sorryView.attributedText = formattedText;
        self.sorryView.textAlignment = NSTextAlignmentCenter;
        self.sorryView.alpha = .8;
        
        [self.externalLinkViewer addSubview:self.sorryView];
    }
    
    [self hideInfoView];
    self.infoButton.hidden = YES;    
}

//just testing
//- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSLog(@"Request URL is %@, scheme is %@, last path component is %@, host is %@", request.URL, request.URL.scheme, request.URL.lastPathComponent, request.URL.host);
//    return YES;
//}

- (void) showInfoView {
    CGRect infoViewFrame = self.view.bounds;
    CGRect infoLabelFrame = CGRectMake(self.view.bounds.size.width / 2 - 140, self.view.bounds.size.height * .1, 280, 140);
    CGRect dismissButtonFrame = CGRectMake(5, 95, 270, 40);
    
    if (!self.infoView) {
        self.infoView = [[UIButton alloc] initWithFrame:infoViewFrame];
        self.infoView.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f];
        self.infoView.alpha = .8;
        self.infoView.userInteractionEnabled = YES;
        
        [self.infoView addTarget:self
                               action:@selector(hideInfoView)
                     forControlEvents:UIControlEventTouchUpInside];
        [self.externalLinkViewer addSubview:self.infoView];
        
        
        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(-280, self.view.bounds.size.height * .1, 280, 140)]; //previous frame was infoLabelFrame
        self.infoLabel.backgroundColor = [UIColor colorWithRed:180/255.0f green:180/255.0f blue:180/255.0f alpha:1.0f];
        self.infoLabel.textColor = [UIColor blackColor];        
        self.infoLabel.numberOfLines = 0;
        self.infoLabel.alpha = .9;
        self.infoLabel.font = [UIFont systemFontOfSize:16];
        NSMutableAttributedString* formattedText = [[NSMutableAttributedString alloc] initWithString:@"This map of Hurricane Sandy relief awards demonstrates what open federal spending data will make possible for all federal funds. \n \n"];
        self.infoLabel.attributedText = formattedText;
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        self.infoLabel.layer.cornerRadius = 3;
        [self.infoLabel.layer setMasksToBounds:YES];
        self.infoLabel.userInteractionEnabled = YES;
        [self.infoView addSubview:self.infoLabel];
//        self.infoLabel.layer.borderWidth = 1;
        
        
        self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.dismissButton addTarget:self
                   action:@selector(hideInfoView)
         forControlEvents:UIControlEventTouchUpInside];
        [self.dismissButton setTitle:@"OK" forState:UIControlStateNormal];
        self.dismissButton.frame = dismissButtonFrame;
        self.dismissButton.backgroundColor = [UIColor orangeColor];
        self.dismissButton.titleLabel.textColor = [UIColor whiteColor];
        self.dismissButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.dismissButton.layer.cornerRadius = 3;
        self.dismissButton.showsTouchWhenHighlighted = YES;
        [self.infoLabel addSubview:self.dismissButton];
    }

    [UIView beginAnimations:@"showInfoLabel" context:nil];
    [UIView setAnimationDuration:0.3];
    //    self.infoView.hidden = NO;
    self.infoView.frame = infoViewFrame;
    self.dismissButton.frame = dismissButtonFrame;
    self.infoLabel.frame = infoLabelFrame;
    self.infoView.alpha = .8;
    [UIView commitAnimations];
    
}

- (void) hideInfoView {
    [UIView beginAnimations:@"hideInfoLabel" context:nil];
    [UIView setAnimationDuration:0.3];
    [self.infoLabel setFrame:CGRectMake(-280, self.view.bounds.size.height * .1, 280, 140)];
    self.infoView.alpha = 0;
    [UIView commitAnimations];
}

- (void) addInfoButton {
    self.infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[self.infoButton addTarget:self action:@selector(hideOrDisplayInfoView) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:self.infoButton];
	[self.navigationItem setLeftBarButtonItem:modalButton animated:YES];
}

- (void) hideOrDisplayInfoView {
    //hide it if on screen
    if (CGRectIntersectsRect(self.externalLinkViewer.frame, self.infoLabel.frame)) {
        [self hideInfoView];
    }
    else {
        [self showInfoView];
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self.externalLinkViewer loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.federaltransparency.gov/Style%20Library/GISMapping/index.html"]]];
    //    [self showInfoView]; //don't display until we verify !403 error
    [self addInfoButton];
}

- (void) viewWillLayoutSubviews {
    //rotation handling
    [super viewWillLayoutSubviews];

    if (CGRectIntersectsRect(self.externalLinkViewer.frame, self.infoLabel.frame)) {
        [self showInfoView];    
    }
    
    if (self.sorryView) {
        [self displaySorryView];
    }
}

@end
