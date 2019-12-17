//
//  UIDefine.h
//  TYSalePlatForm
//
//  Created by zhangxintao on 2019/4/25.
//  Copyright © 2019 zhangxintao. All rights reserved.
//

#ifndef UIDefine_h
#define UIDefine_h
#import <UIKit/UIKit.h>
//百度语音识别
#define APPID @"17933442"
#define API_KEY @"WrG2dAP89ivVyr0LMGOKkliS"
#define SECRET_KEY @"Zakea9N9mRYRTOxxit2DuqpuW1ta3lQl"

/*请求错误码*/
#define TokenInvalid 999   //token过期
#define VERSION @"1.0.0626"
#define MessageFreshBetween 30

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX kScreenWidth >=375.0f && kScreenHeight >=812.0f&& kIs_iphone

/*状态栏高度*/
#define kStatusBarHeight (CGFloat)(kIs_iPhoneX?(44.0):(20.0))
/*导航栏高度*/
#define kNavBarHeight (44)
/*状态栏和导航栏总高度*/
#define kNavBarAndStatusBarHeight (CGFloat)(kIs_iPhoneX?(88.0):(64.0))
/*TabBar高度*/
#define kTabBarHeight (CGFloat)(kIs_iPhoneX?(49.0 + 34.0):(49.0))
/*顶部安全区域远离高度*/
#define kTopBarSafeHeight (CGFloat)(kIs_iPhoneX?(44.0):(0))
/*底部安全区域远离高度*/
#define kBottomSafeHeight (CGFloat)(kIs_iPhoneX?(34.0):(0))
/*iPhoneX的状态栏高度差值*/
#define kTopBarDifHeight (CGFloat)(kIs_iPhoneX?(24.0):(0))
/*导航条和Tabbar总高度*/
#define kNavAndTabHeight (kNavBarAndStatusBarHeight + kTabBarHeight)

/* 空字符串替换 */
#define KIsBlankString(str)  [NSString isBlankString:str]
#define Kstr(a) KIsBlankString(a)?@"":a

//#ifdef DEBUG
//    #define PlatFormId @"1"
//    #define TYSale_Api_domain @"http://180.76.128.198:8011"
//#else
//    #define PlatFormId @"5"
//    #define TYSale_Api_domain @"http://api.rankshop.ranknowcn.com"
//#endif

/*接口域名*/
#define ASR_Api_domain @"http://180.76.128.198:8000"
#define ASR_Api_url(a) [NSString stringWithFormat:@"%@/api/%@",ASR_Api_domain,a]

/* 通知 */


/* NSUserDefault */
#define LocalUser @"userInfo"

///微信支付


#ifdef DEBUG
# define DLog(fmt, ...) NSLog((@"\n[File:%s]\n" "[Function:%s]\n" "[Line:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define DLog(...);
#endif

#endif /* UIDefine_h */



