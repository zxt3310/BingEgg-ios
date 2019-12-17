//
//  ATMainTabViewController.m
//  AsrTtsDemo
//
//  Created by zhangxintao on 2019/12/5.
//  Copyright © 2019 zhangxintao. All rights reserved.
//

#import "ATMainTabViewController.h"
#import "ATWebController.h"
#import "ATVoiceController.h"
#import "ShakeWatchController.h"
#import <AxcAE_TabBar.h>

@interface ATMainTabViewController()<AxcAE_TabBarDelegate>

@property AxcAE_TabBar *axcTabBar;

@end

@implementation ATMainTabViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    //构造配置字典
    NSArray <NSDictionary *> *vcDicAry = @[@{@"vc":[[ATWebController alloc] init],@"normalImg":@"web_n",@"selectImg":@"web_p",@"itemTitle":@"数据"},@{@"vc":[[ATVoiceController alloc] init],@"normalImg":@"voice_n",@"selectImg":@"voice_p",@"itemTitle":@"语音"},@{@"vc":[[ShakeWatchController alloc] init],@"normalImg":@"shake_n",@"selectImg":@"shake_p",@"itemTitle":@"震动"}];
    //构造配置模型数组
    NSMutableArray *tabBarConfs = [NSMutableArray array];
    //构造页面数组
    NSMutableArray *tabBarVCs = [NSMutableArray array];
    
    [vcDicAry enumerateObjectsUsingBlock:^(NSDictionary *obj,NSUInteger idx,BOOL *stop){
        AxcAE_TabBarConfigModel *model =[[AxcAE_TabBarConfigModel alloc] init];
        model.itemTitle = [obj objectForKey:@"itemTitle"];
        model.selectImageName = [obj objectForKey:@"selectImg"];
        model.normalImageName = [obj objectForKey:@"normalImg"];
        
        UIViewController *vc = [obj objectForKey:@"vc"];
        [tabBarVCs addObject:vc];
        [tabBarConfs addObject:model];
    }];
    
    self.viewControllers = tabBarVCs;
    self.axcTabBar = [[AxcAE_TabBar alloc] initWithTabBarConfig:tabBarConfs];
    //self.axcTabBar.tabBarConfig = tabBarConfs;
    self.axcTabBar.delegate = self;
    
    
    
    [self.tabBar addSubview:self.axcTabBar];
}

- (void)axcAE_TabBar:(AxcAE_TabBar *)tabbar selectIndex:(NSInteger)index{
    [self setSelectedIndex:index];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.axcTabBar.frame = self.tabBar.bounds;
    [self.axcTabBar viewDidLayoutItems];
}

@end
