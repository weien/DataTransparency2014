//
//  ViewController.m
//  DataTransparencyConference
//
//  Created by Weien on 7/26/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "DTCViewController.h"
#import "ExternalWebViewController.h"
#import "DTCUtil.h"

#define IS_IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0

@interface DTCViewController () <UIWebViewDelegate>
@end

@implementation DTCViewController
@synthesize DTCWebView = _DTCWebView;
@synthesize urlToPassForward = _urlToPassForward;
@synthesize urlToDisplayHere = _urlToDisplayHere;

#pragma mark - data handling

- (void) receiveUpdateNotification:(NSNotification *) notification
{
    //reload webview if ZipDownloader has unzipped an update for us
    if ([[notification name] isEqualToString:@"SiteContentDidUpdate"]) {
        NSLog (@"Successfully received the update notification!");
        [self loadAndDisplayWebViewContent];
    }
}

- (void) setUpPage {
    //to prevent the dreaded "white flash" http://stackoverflow.com/a/2722801/2284713
    self.DTCWebView.backgroundColor = [UIColor clearColor];
    self.DTCWebView.opaque = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUpdateNotification:)
                                                 name:@"SiteContentDidUpdate"
                                               object:nil];
    [self loadAndDisplayWebViewContent];
}

- (void) loadAndDisplayWebViewContent {
    if (self.urlToDisplayHere) { //was forwarded from another DTCViewController
        //        NSError* error = nil;
        //        NSString* indexHTML = [NSString stringWithContentsOfURL:self.urlToDisplayHere encoding:NSUTF8StringEncoding error:&error];
        //        NSLog(@"Actual HTML is %@, error is %@", indexHTML, error);
        
        [self.DTCWebView loadRequest:[NSURLRequest requestWithURL:self.urlToDisplayHere]];
    }
    else {
        NSString* pathComponent = [NSString stringWithFormat:@"_site/%@/index.html", [self uniqueTabPathComponent]];
        NSURL* processedURL = [DTCUtil reformedURLWithCorrectDirectoryUsingPathComponent:pathComponent];
        [self.DTCWebView loadRequest:[NSURLRequest requestWithURL:processedURL]];
    }
}

//differentiates each of the tabs
- (NSString*) uniqueTabPathComponent {
    NSString* pathComponent = @"news";
    NSLog(@"Something's wrong -- getting superclass uniqueTabPathComponent");
    return pathComponent;
}

#pragma mark - webView handling

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSLog(@"Request URL is %@, scheme is %@, last path component is %@, host is %@", request.URL, request.URL.scheme, request.URL.lastPathComponent, request.URL.host);
    if ([request.URL.scheme isEqualToString: @"file"]) {
        if ([request.URL.lastPathComponent isEqualToString:@"index.html"]) { //initial load of given tab
            return YES;
        }
        else {
            //NSLog(@"NavigationType is %d (O is 'clicked', 5 is 'other')", navigationType);
            if (navigationType != UIWebViewNavigationTypeLinkClicked) { //from another VC, don't segue again
                return YES;
            }
            self.urlToPassForward = request.URL; //the URL is fully-formed, just send it forward
            [self performSegueWithIdentifier:@"pushNextWebView" sender:self];
            return NO;
        }
    }
    else if ([request.URL.absoluteString isEqualToString:@"https://twitter.com/i/jot"] ||
             [request.URL.absoluteString isEqualToString:@"https://platform.twitter.com/jot.html"] ||
             [request.URL.absoluteString isEqualToString:@"https://syndication.twitter.com/i/jot/syndication"]) {
        //annoying twitter redirect on twitter tabs, just let 'em do their thing
        return YES;
    }
    else if ([request.URL.host isEqualToString:@"maps.apple.com"]) {
        if ([[UIApplication sharedApplication]canOpenURL:request.URL]) {
            [[UIApplication sharedApplication]openURL:request.URL];
            return NO;
        }
    }
    else if ([request.URL.scheme isEqualToString:@"http"] ||
             [request.URL.scheme isEqualToString:@"https"]) {
        self.urlToPassForward = request.URL;
        [self performSegueWithIdentifier:@"handleExternalLink" sender:self];
        return NO;
    }
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    //reset background color to something more compositing-friendly (was transparent to prevent white flash)
    self.DTCWebView.backgroundColor = [UIColor colorWithRed:237/255.0f green:237/255.0f blue:237/255.0f alpha:1.0f];
    self.DTCWebView.opaque = YES;
    
    //http://stackoverflow.com/a/2280767/2284713 and http://stackoverflow.com/q/2275876/2284713
    NSString* documentTitle = [self.DTCWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (documentTitle) {
        self.navigationController.navigationBar.topItem.title  = documentTitle;
    }
}

#pragma mark - segue and VC lifecycle

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushNextWebView"]) {
        DTCViewController* dtcvc = (DTCViewController*)segue.destinationViewController;
        [dtcvc setUrlToDisplayHere:self.urlToPassForward];
    }
    if ([segue.identifier isEqualToString:@"handleExternalLink"]) {
        ExternalWebViewController* wvc = (ExternalWebViewController*) segue.destinationViewController;
        [wvc setUrlToDisplay:self.urlToPassForward];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (IS_IOS7) {
        UIColor* orangeishColor = [UIColor colorWithRed:0.990 green:0.474 blue:0.033 alpha:1.000];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setTranslucent:YES];
        [self.navigationController.navigationBar setTintColor:orangeishColor];
        [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor colorWithRed:78/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f]}];

        [self.tabBarController.tabBar setTintColor:orangeishColor];
    }
    else {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    }
    
    self.DTCWebView.delegate = self;
    [self setUpPage];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.DTCWebView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
