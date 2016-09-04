//
//  LLQ_PlayerTools.h
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/3.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLQ_PlayerTools : NSObject

#pragma mark - 根据秒数计算时间
NSString * calculateTimeWithTimeFormatter(long long timeSecond);

@end
