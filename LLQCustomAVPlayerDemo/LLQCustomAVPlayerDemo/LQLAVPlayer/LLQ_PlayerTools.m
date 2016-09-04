//
//  LLQ_PlayerTools.m
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/3.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "LLQ_PlayerTools.h"

@implementation LLQ_PlayerTools

#pragma mark - 根据秒数计算时间
NSString * calculateTimeWithTimeFormatter(long long timeSecond){
    NSString * theLastTime = nil;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2lld", timeSecond];
    }else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond/60, timeSecond%60];
    }else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
    }
    return theLastTime;
}


@end
