//
//  AboutViewController.m
//  v2ex
//
//  Created by Haven on 11/5/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *aboutWebView;
@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = ThemeColor;
    
    NSURLRequest *r = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:AboutMeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [self.aboutWebView loadRequest:r];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [NetHelper setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [NetHelper setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [NetHelper setNetworkActivityIndicatorVisible:NO];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"aboutme" ofType:@"html"];
    [self.aboutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlFile]]];
    //load local default html
}

@end
