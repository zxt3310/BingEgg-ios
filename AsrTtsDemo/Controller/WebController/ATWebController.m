//
//  ATWebController.m
//  AsrTtsDemo
//
//  Created by 张信涛 on 2019/12/5.
//  Copyright © 2019年 zhangxintao. All rights reserved.
//


#import "ATWebController.h"
#import <WebKit/WebKit.h>

@implementation ATWebController
{
    WKWebView *webview;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view layoutIfNeeded];
    self.view.backgroundColor = [UIColor whiteColor];
    webview = [[WKWebView alloc] initWithFrame:self.view.frame];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://180.76.128.198:8000/h5/my-box/list"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20]];
    [self.view addSubview:webview];
}

- (UIEdgeInsets)getSafeArea:(BOOL)portrait{
    return UIEdgeInsetsMake(kNavBarAndStatusBarHeight, 0, kTabBarHeight, 0);
}

- (void)viewDidAppear:(BOOL)animated{
    [webview reload];
}

- (void)viewDidLayoutSubviews{
    webview.frame = self.view.bounds;
}
@end
