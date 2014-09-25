//
//  WebViewController.m
//  TwitterTimelineSpike
//
//  Created by Weien on 6/19/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "ExternalWebViewController.h"

@interface ExternalWebViewController () <UIWebViewDelegate, NSURLConnectionDataDelegate>
@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@property (strong, nonatomic) NSString* mime;
@end

@implementation ExternalWebViewController
@synthesize externalLinkViewer = _externalLinkViewer;
@synthesize urlToDisplay = _urlToDisplay;
@synthesize spinner = _spinner;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize mime = _mime;

#pragma mark - prevent long touch on PDF
//thanks http://stackoverflow.com/a/14742517/2284713
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.mime = [response MIMEType];
    NSLog(@"Mime is %@", self.mime);
    
    if ([self isDisplayingPDF]) {
        NSLog(@"Yes, displaying PDF");
        //dispatch_async(dispatch_get_main_queue(), ^{
            //[self.externalLinkViewer stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
            //[self.externalLinkViewer setDataDetectorTypes:UIDataDetectorTypeNone];
            for (UIView *pdfView in self.externalLinkViewer.scrollView.subviews)
            {
                //just preventing long touch not quite working; just disable userInteraction
                pdfView.userInteractionEnabled = NO;
            }
        //});
    }
}

- (BOOL)isDisplayingPDF {
    NSString *mimeExtension = [[self.mime substringFromIndex:([self.mime length] - 3)] lowercaseString];
    NSLog(@"MimeExtension is %@", mimeExtension);
    
    return ([[[self.externalLinkViewer.request.URL pathExtension] lowercaseString] isEqualToString:@"pdf"] || [mimeExtension isEqualToString:@"pdf"]);
}

#pragma mark - webview loading methods

- (void) setUrlToDisplay:(NSURL *)urlToDisplay {
    _urlToDisplay = urlToDisplay;
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.spinner startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [NSURLConnection connectionWithRequest:webView.request delegate:self]; //in order to collect MIME
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.spinner stopAnimating];
    
    [self.backButton setEnabled:[webView canGoBack]];
    [self.forwardButton setEnabled:[webView canGoForward]];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"This webpage is not available, error is %@.", error);
    [self.spinner stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) initSpinner {
    if (!self.spinner) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:self.spinner];
        self.spinner.center = CGPointMake(self.externalLinkViewer.frame.size.width / 2, self.externalLinkViewer.frame.size.height / 2);
        self.spinner.hidesWhenStopped = YES;
    }
}

#pragma mark - browser open, back, forward buttons

- (void)openPageInBrowser:(id)sender {
    [[UIApplication sharedApplication] openURL:self.externalLinkViewer.request.URL];
}

- (IBAction)goBack:(id)sender {
    [self.externalLinkViewer goBack];
}

- (IBAction)goForward:(id)sender {
    [self.externalLinkViewer goForward];
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //iOS 7 -- toolbar isn't working, but this isn't high priority right now
//    [self.navigationController setToolbarHidden:NO];
//    [self.navigationController.toolbar setItems:@[self.backButton, self.forwardButton]];
    
    self.externalLinkViewer.delegate = self;
    if (self.urlToDisplay) {
        [self initSpinner];        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.urlToDisplay];
        [self.externalLinkViewer loadRequest:request];
        
        [self.backButton setEnabled:[self.externalLinkViewer canGoBack]];
        [self.forwardButton setEnabled:[self.externalLinkViewer canGoForward]];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.externalLinkViewer = nil;
}

#pragma mark - autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
