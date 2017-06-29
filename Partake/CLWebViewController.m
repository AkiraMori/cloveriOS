//
//  CLWebViewController.m
//  Partake
//
//  Created by Maikel on 10/07/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLWebViewController.h"
#import "UIViewController+SVProgressHUD.h"


@interface CLWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CLWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_URL) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_URL]]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showProgressHUDWithStatus:@"Loading"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self dismissProgressHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self dismissProgressHUD];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
