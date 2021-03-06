//
//  ArticleWebViewController.m
//  notifyr
//
//  Created by Nelson Narciso on 2014-08-02.
//  Copyright (c) 2014 Nelson Narciso. All rights reserved.
//

#import "ArticleWebViewController.h"

@interface ArticleWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end


@implementation ArticleWebViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *websiteUrl = [NSURL URLWithString:self.article.url];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [self.webView loadRequest:urlRequest];
    self.webView.delegate = self;
    //self.navigationController.hidesBarsOnSwipe = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //the below is needed to remove black bar at the bottom
//    self.webView.opaque = NO;
//    self.webView.backgroundColor = [UIColor clearColor];
    
}

- (IBAction)sharePressed:(id)sender {
    NSString *notifyrString = @"Sent From NotifyR";
    
    NSString *shareString = [NSString stringWithFormat:@"%@\n\n%@\n\n%@",self.article.title,self.article.url,notifyrString];
    
    NSArray *activityItems = @[shareString];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController animated:YES completion:^{
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = theTitle;
}

@end
