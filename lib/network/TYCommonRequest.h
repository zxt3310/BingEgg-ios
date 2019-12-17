//
//  TYCommonRequest.h
//  TYSalePlatForm
//
//  Created by zhangxintao on 2019/6/26.
//  Copyright © 2019 zhangxintao. All rights reserved.
//

#import "YTKRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^resblock)(id obj);

@interface TYCommonRequest : YTKRequest <YTKRequestDelegate>

@property resblock succeed;
@property resblock faild;

- (instancetype) initWithParam:(id)param;

- (void)startRequest;

- (void)reqDidResponse:(id) obj;

- (void)reqFaild:(id) obj;

@end

NS_ASSUME_NONNULL_END
