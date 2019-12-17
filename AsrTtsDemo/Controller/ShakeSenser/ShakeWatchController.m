//
//  ShakeWatchController.m
//  AsrTtsDemo
//
//  Created by zhangxintao on 2019/12/10.
//  Copyright © 2019 zhangxintao. All rights reserved.
//

#import "ShakeWatchController.h"
#import <CoreMotion/CoreMotion.h>

#define totalCount 20

@implementation ShakeWatchController
{
    FlexTextView *accTextView;
    FlexTextView *graTextView;
    FlexTextView *rotTextView;
    
    UILabel *trackLb;
    CMMotionManager *manager;
    BOOL isTracking;
    NSTimer *timer;
    NSInteger count;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    isTracking = NO;
    count = 0;
    
    manager = [[CMMotionManager alloc] init];
    manager.accelerometerUpdateInterval = 0.1;
    manager.deviceMotionUpdateInterval = 0.1;
    manager.gyroUpdateInterval = 0.1;
    
    timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *tim){
        self->count++;
        if (self->count < 6) {
            self->trackLb.text = [NSString stringWithFormat:@"%ld",6-(long)self->count];
        }else{
            if (self->count == 6) {
                [self start];
            }else if (self->count == 21){
                self->count = 0;
                [tim setFireDate:[NSDate distantFuture]];
                [self start];
            }
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer setFireDate:[NSDate distantFuture]];
}

- (void)startTrack{
    [timer setFireDate:[NSDate date]];
}

- (void)start{
    if (isTracking) {
        [manager stopAccelerometerUpdates];
        [manager stopDeviceMotionUpdates];
        [manager stopGyroUpdates];
        
        isTracking = NO;
        trackLb.text = @"开始跟踪";
    }else{
        [self clearLog];
        NSOperationQueue *queue = [NSOperationQueue new];
        [manager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *data,NSError *error){
            [self updatingWithAcc:data Error:error];
        }];
        
        [manager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            [self updatingWithGra:motion Error:error];
        }];
        
        [manager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            [self updatingWithRot:gyroData Error:error];
        }];
        
        isTracking = YES;
        trackLb.text = @"停止跟踪";
    }
    
}

- (void)clearLog{
    accTextView.text = @"";
    graTextView.text = @"";
    rotTextView.text = @"";
}

- (void)updatingWithAcc:(CMAccelerometerData *)data Error:(NSError *)error{
    double x = data.acceleration.x;
    double y = data.acceleration.y;
    double z = data.acceleration.z;

    double accelerameter = sqrt( pow(x , 2 ) + pow(y , 2 ) + pow(z , 2) );
        //当综合加速度大于2.3时，就激活效果（数据越小，用户摇动的动作就越小，越容易激活）
        if (accelerameter>1.0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->accTextView.text = [@"检测到震动 \n" stringByAppendingString:self->accTextView.text];
            });
        }


        //self->accTextView.text = [[NSString stringWithFormat:@"\n x:%f   y:%f   z:%f",x,y,z] stringByAppendingString:self->accTextView.text];
    
    
}

- (void)updatingWithGra:(CMDeviceMotion *)data Error:(NSError *)error{
    double x = data.gravity.x;
    double y = data.gravity.y;
    double z = data.gravity.z;

    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->graTextView.text = [[NSString stringWithFormat:@"\n x:%f   y:%f   z:%f",x,y,z] stringByAppendingString:self->graTextView.text];
    });
    
}

- (void)updatingWithRot:(CMGyroData *)data Error:(NSError *)error{
    double x = data.rotationRate.x;
    double y = data.rotationRate.y;
    double z = data.rotationRate.z;

    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->rotTextView.text = [[NSString stringWithFormat:@"\n x:%f   y:%f   z:%f",x,y,z] stringByAppendingString:self->rotTextView.text];
    });
    
}



- (void)dealloc{
    NSLog(@"dealloc succeeds");
}

@end
