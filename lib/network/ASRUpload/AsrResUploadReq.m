//
//  AsrResUploadReq.m
//  AsrTtsDemo
//
//  Created by zhangxintao on 2019/12/6.
//  Copyright © 2019 zhangxintao. All rights reserved.
//

#import "AsrResUploadReq.h"

@implementation AsrResUploadReq

- (NSString *)requestUrl{
    return @"api/voice-result/analyze";
}

- (YTKRequestMethod)requestMethod{
    return YTKRequestMethodGET;
}


- (void)reqDidResponse:(id)obj{
    self.succeed(obj);
}

- (void)reqFaild:(id)obj{
    self.faild(obj);
}

@end
