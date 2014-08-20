//
//  ViewController.m
//  JavascriptMapDisplaySpike
//
//  Created by Weien on 8/5/13.
//  Copyright (c) 2013 Weien. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate>

@end

@implementation ViewController
@synthesize javascriptView = _javascriptView;

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    
//    if ([self.javascriptView respondsToSelector:@selector(scrollView)])
//    {
//        UIScrollView *scroll=[self.javascriptView scrollView];
//        
//        float zoom = self.javascriptView.bounds.size.width/scroll.contentSize.width;
//        [scroll setZoomScale:zoom animated:YES];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.javascriptView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.federaltransparency.gov/Style%20Library/GISMapping/index.html"]]];
    
//    NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = 4;"];
//    [self.javascriptView stringByEvaluatingJavaScriptFromString:jsCommand];
    
//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
//    [self.javascriptView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

@end
