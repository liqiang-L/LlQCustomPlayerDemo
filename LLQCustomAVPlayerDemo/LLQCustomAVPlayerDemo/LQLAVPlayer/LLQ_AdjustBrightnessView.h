//
//  LLQ_AdjustBrightnessView.h
//  LLQCustomAVPlayerDemo
//
//  Created by Apple on 16/9/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLQ_AdjustBrightnessView : UIView

@property (nonatomic,assign) float lightValue;

-(void)changeLightViewWithValue:(float)lightValue;

@end
