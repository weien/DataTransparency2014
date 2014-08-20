//
//  NewsViewController.m
//  DataTransparencyConference
//
//  Created by Weien on 7/29/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()
@property (strong, nonatomic) UIImageView* launchImageView;
@property BOOL splashScreenHasBeenShown;
@end

#define splashScreenDesired 0

@implementation NewsViewController
@synthesize launchImageView = _launchImageView;
@synthesize splashScreenHasBeenShown = _splashScreenHasBeenShown;

- (NSString*) uniqueTabPathComponent {
    NSString* pathComponent = @"news";
    return pathComponent;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    self.launchImageView.hidden = YES;
}

- (void) preventBlackFlash {
    //minimize black flash (maybe not needed now that we have splash screen)
    //calling loadHTMLString doesn't really make a difference, just show a view
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.launchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];

    //thanks http://stackoverflow.com/a/12532527/2284713 -- have to manually check for 4" display
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        self.launchImageView.image = [UIImage imageNamed:@"Default-568h.png"];
    } else {
        self.launchImageView.image = [UIImage imageNamed:@"Default.png"];
    }
    self.launchImageView.hidden = NO;
    [self.navigationController.view addSubview:self.launchImageView];
}

- (void) viewDidLoad {
    [self preventBlackFlash];
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    if (splashScreenDesired) {
        [self displaySplashScreen];
    }
}

- (void) displaySplashScreen {
    if (!self.splashScreenHasBeenShown) {
        UIImageView* splashScreen = nil;
        if ([UIScreen mainScreen].scale == 2.f && [UIScreen mainScreen].bounds.size.height == 568.0f) {
            splashScreen = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default-568h.png"]];
        }
        else {
            splashScreen = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default.png"]];
        }
        
        UIViewController* vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [[vc view] addSubview:splashScreen];
        [[vc view] bringSubviewToFront:splashScreen];
        
        [UIView animateWithDuration:0.5f delay:1.0f options:UIViewAnimationOptionTransitionNone animations:^(void){splashScreen.alpha=0.0f;} completion:^(BOOL finished){[splashScreen removeFromSuperview];}];
    }
    self.splashScreenHasBeenShown = YES; //only show upon launch of app
}

@end
